// PROF-05: a manually overridden target must survive being written to the
// database and read back, and must not be silently recalculated away.
//
// The columns and the domain logic both existed already — the schema has
// kcal_target/kcal_is_overridden etc., and TargetCalculator.derive's step 8
// honours the flags. What was missing was the persistence layer in between:
// DriftProfileRepository.saveProfile built its companion without any target
// columns, and _rowToProfile never read them back, so `existingTargets` was
// always null and every override was discarded on the next rebuild.
//
// Found 2026-09-08, after fixing the crash that had been masking it — the app
// died on Save before anyone could observe the value failing to stick.

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/user_profile_dao.dart';
import 'package:co2diet/data/repositories/drift_profile_repository.dart';
import 'package:co2diet/domain/entities/calc_targets.dart';
import 'package:co2diet/domain/entities/user_profile.dart';
import 'package:co2diet/domain/services/target_calculator.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftProfileRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftProfileRepository(UserProfileDao(db));
  });

  tearDown(() async {
    await db.close();
  });

  const baseProfile = UserProfile(
    id: 'p1',
    age: 25,
    gender: 'female',
    heightCm: 156,
    weightKg: 62,
    activityLevel: 'low',
    goal: 'gain_muscle',
  );

  group('target persistence', () {
    test('an overridden kcal target survives a save/read round trip',
        () async {
      await repo.saveProfile(
        baseProfile.copyWith(
          targets: const CalcTargets(
            kcalTarget: 2200,
            kcalIsOverridden: true,
          ),
        ),
      );

      final read = await repo.getProfile();

      expect(read?.targets?.kcalTarget, 2200);
      expect(read?.targets?.kcalIsOverridden, isTrue);
    });

    test('every macro override round-trips independently', () async {
      await repo.saveProfile(
        baseProfile.copyWith(
          targets: const CalcTargets(
            kcalTarget: 2200,
            proteinGTarget: 180,
            carbsGTarget: 200,
            fatGTarget: 70,
            kcalIsOverridden: true,
            proteinIsOverridden: true,
            // Explicit despite matching the default: this test exists to
            // prove a false flag round-trips as false. Leaving it implicit
            // would stop asserting the thing it is here to assert.
            // ignore: avoid_redundant_argument_values
            carbsIsOverridden: false,
            fatIsOverridden: true,
          ),
        ),
      );

      final t = (await repo.getProfile())?.targets;

      expect(t?.kcalTarget, 2200);
      expect(t?.proteinGTarget, 180);
      expect(t?.carbsGTarget, 200);
      expect(t?.fatGTarget, 70);
      expect(t?.kcalIsOverridden, isTrue);
      expect(t?.proteinIsOverridden, isTrue);
      // A stored value with its flag false must come back with the flag false —
      // otherwise recalculation would be permanently suppressed.
      expect(t?.carbsIsOverridden, isFalse);
      expect(t?.fatIsOverridden, isTrue);
    });

    test('a profile saved with no targets reads back with none', () async {
      await repo.saveProfile(baseProfile);

      final t = (await repo.getProfile())?.targets;

      // Nothing overridden and no values stored: derive() computes fresh.
      expect(t?.kcalIsOverridden ?? false, isFalse);
      expect(t?.kcalTarget, isNull);
    });

    test('clearing an override persists the cleared state', () async {
      await repo.saveProfile(
        baseProfile.copyWith(
          targets: const CalcTargets(
            kcalTarget: 2200,
            kcalIsOverridden: true,
          ),
        ),
      );
      await repo.saveProfile(
        baseProfile.copyWith(targets: const CalcTargets()),
      );

      final t = (await repo.getProfile())?.targets;

      expect(t?.kcalIsOverridden ?? false, isFalse);
      expect(t?.kcalTarget, isNull);
    });
  });

  group('overrides survive recalculation (D-06)', () {
    test('an override is kept when other profile fields change', () async {
      // CalcTargets' own contract: "When an override is active the value must
      // be preserved even if other profile fields change."
      await repo.saveProfile(
        baseProfile.copyWith(
          targets: const CalcTargets(
            kcalTarget: 2200,
            kcalIsOverridden: true,
          ),
        ),
      );

      // Simulate ProfileNotifier.build(): read, then derive with what was read.
      final stored = await repo.getProfile();
      final recomputed = TargetCalculator.derive(
        weightKg: 70, // weight changed
        heightCm: stored!.heightCm,
        age: stored.age,
        gender: stored.gender,
        activityLevel: stored.activityLevel,
        goal: stored.goal,
        existingTargets: stored.targets,
      );

      expect(recomputed.kcalTarget, 2200, reason: 'override must win');
      // Non-overridden macros should still track the new weight.
      expect(recomputed.proteinGTarget, isNot(isNull));
    });

    test('without persistence the override would be lost — guards the '
        'regression', () async {
      await repo.saveProfile(
        baseProfile.copyWith(
          targets: const CalcTargets(
            kcalTarget: 2200,
            kcalIsOverridden: true,
          ),
        ),
      );

      final stored = await repo.getProfile();

      // This is the exact link that was broken: if targets come back null,
      // derive() has no existingTargets to honour and recalculates over the
      // user's value.
      expect(
        stored?.targets,
        isNotNull,
        reason: 'repository must read target columns back',
      );
    });
  });

  group('overrides survive transient incomplete input', () {
    test('derive keeps an override when TDEE cannot be computed', () {
      // Every keystroke in the weight field auto-saves. Mid-edit the field is
      // momentarily empty, weightKg is null, and TDEE is uncomputable — and
      // derive()'s early return used to hand back a blank CalcTargets,
      // discarding the user's override. The next keystroke then persisted that
      // blank. Found on device 2026-09-08: editing weight silently wiped a
      // 2200 kcal override.
      final result = TargetCalculator.derive(
        weightKg: null, // field cleared mid-typing
        heightCm: 156,
        age: 25,
        gender: 'female',
        activityLevel: 'low',
        goal: 'gain_muscle',
        existingTargets: const CalcTargets(
          kcalTarget: 2200,
          kcalIsOverridden: true,
        ),
      );

      expect(result.kcalIsOverridden, isTrue);
      expect(result.kcalTarget, 2200);
    });

    test('derive drops non-overridden values when inputs are incomplete', () {
      // Calculated values SHOULD disappear — showing a stale computed number
      // for a body that no longer matches would be false precision (D-07).
      final result = TargetCalculator.derive(
        weightKg: null,
        heightCm: 156,
        age: 25,
        gender: 'female',
        activityLevel: 'low',
        goal: 'gain_muscle',
        existingTargets: const CalcTargets(
          kcalTarget: 2200,
          proteinGTarget: 135,
          kcalIsOverridden: true,
        ),
      );

      expect(result.kcalTarget, 2200, reason: 'overridden: kept');
      expect(result.proteinGTarget, isNull, reason: 'calculated: dropped');
      expect(result.proteinIsOverridden, isFalse);
    });

    test('an override survives the full edit round trip through storage',
        () async {
      await repo.saveProfile(
        baseProfile.copyWith(
          targets: const CalcTargets(
            kcalTarget: 2200,
            kcalIsOverridden: true,
          ),
        ),
      );

      // Simulate the auto-save sequence while retyping the weight field:
      // cleared -> partial -> complete. Each step is a real save in production.
      for (final w in <double?>[null, 1, 15, 150 * 0.453592]) {
        final stored = await repo.getProfile();
        final recomputed = TargetCalculator.derive(
          weightKg: w,
          heightCm: stored!.heightCm,
          age: stored.age,
          gender: stored.gender,
          activityLevel: stored.activityLevel,
          goal: stored.goal,
          existingTargets: stored.targets,
        );
        await repo.saveProfile(
          stored.copyWith(weightKg: w, targets: recomputed),
        );
      }

      final finalTargets = (await repo.getProfile())?.targets;
      expect(finalTargets?.kcalTarget, 2200);
      expect(finalTargets?.kcalIsOverridden, isTrue);
    });
  });
}
