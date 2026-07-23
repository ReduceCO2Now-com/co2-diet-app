// TDD tests for UserFoodDao (UserFoodTable).
// Covers LOG-10/LOG-11: required-field guard, override independent-row
// storage, revert leaves the original untouched, alphabetical + filter.

import 'package:co2diet/data/local/app_database.dart';
import 'package:co2diet/data/local/daos/user_food_dao.dart';
// isNotNull/isNull are defined in both drift and flutter_test — hide the
// drift ones so the matcher package's versions are used.
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late UserFoodDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = UserFoodDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  var idCounter = 0;

  UserFoodTableCompanion buildDraft({
    String? name = 'Oatmeal',
    double? calories = 350,
    String? overrideOfRef,
    String? overrideOfSource,
  }) {
    idCounter += 1;
    return UserFoodTableCompanion(
      id: Value('food-$idCounter'),
      hlcMillis: Value(BigInt.from(1000)),
      hlcCounter: const Value(0),
      hlcNodeId: const Value('test-node'),
      name: name == null ? const Value.absent() : Value(name),
      calories: calories == null ? const Value.absent() : Value(calories),
      quickServingSizes: const Value([]),
      overrideOfRef: overrideOfRef == null
          ? const Value.absent()
          : Value(overrideOfRef),
      overrideOfSource: overrideOfSource == null
          ? const Value.absent()
          : Value(overrideOfSource),
    );
  }

  group('UserFoodDao.insert', () {
    test(
      'insert requires name and calories; throws or rejects when either '
      'is missing',
      () async {
        expect(
          () => dao.insert(buildDraft(name: null)),
          throwsArgumentError,
        );
        expect(
          () => dao.insert(buildDraft(calories: null)),
          throwsArgumentError,
        );
        expect(
          () => dao.insert(buildDraft(name: '   ')),
          throwsArgumentError,
        );
      },
    );

    test(
      'insert with overrideOfRef+overrideOfSource stores an independent '
      'override row',
      () async {
        final row = await dao.insert(
          buildDraft(overrideOfRef: '123456', overrideOfSource: 'off_ref'),
        );

        expect(row.overrideOfRef, equals('123456'));
        expect(row.overrideOfSource, equals('off_ref'));

        final found = await dao.findOverrideByFoodRef('123456', 'off_ref');
        expect(found, isNotNull);
        expect(found!.id, equals(row.id));
      },
    );
  });

  group('UserFoodDao.findOverrideByFoodRef', () {
    test(
      'returns the override row when one exists for a catalog food',
      () async {
        await dao.insert(
          buildDraft(overrideOfRef: '999', overrideOfSource: 'off_ref'),
        );

        final found = await dao.findOverrideByFoodRef('999', 'off_ref');
        expect(found, isNotNull);

        final notFound = await dao.findOverrideByFoodRef('000', 'off_ref');
        expect(notFound, isNull);
      },
    );
  });

  group('UserFoodDao.revert', () {
    test(
      'deleting an override row (revert) leaves the original catalog '
      'data untouched',
      () async {
        final original = await dao.insert(buildDraft(name: 'Original'));
        final override = await dao.insert(
          buildDraft(
            name: 'Override',
            overrideOfRef: '111',
            overrideOfSource: 'off_ref',
          ),
        );

        await dao.revert(override.id);

        final overrideAfter = await dao.getById(override.id);
        expect(overrideAfter, isNull);

        final originalAfter = await dao.getById(original.id);
        expect(originalAfter, isNotNull);
        expect(originalAfter!.name, equals('Original'));
      },
    );
  });

  group('UserFoodDao.getAllAlphabetical', () {
    test(
      'returns rows sorted by name with optional filter substring',
      () async {
        await dao.insert(buildDraft(name: 'Banana'));
        await dao.insert(buildDraft());
        await dao.insert(buildDraft(name: 'Apple'));

        final all = await dao.getAllAlphabetical();
        expect(
          all.map((r) => r.name).toList(),
          equals(['Apple', 'Banana', 'Oatmeal']),
        );

        final filtered = await dao.getAllAlphabetical(filter: 'oat');
        expect(filtered, hasLength(1));
        expect(filtered.first.name, equals('Oatmeal'));
      },
    );
  });
}
