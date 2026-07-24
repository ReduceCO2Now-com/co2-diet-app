// Widget tests for NoResultsWidget's "Add as custom food" link (LOG-10).
//
// Confirms the button appears only on NoResultsVariant.genuine and that the
// query is URL-encoded before being placed into the route path
// (T-04-10-01 mitigation).

import 'package:co2diet/features/food_search/widgets/no_results_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget _wrap(Widget child) {
  final router = GoRouter(
    initialLocation: '/no-results',
    routes: [
      GoRoute(path: '/no-results', builder: (context, state) => child),
      GoRoute(
        path: '/custom-food-stub',
        builder: (context, state) =>
            Text('stub:name=${state.uri.queryParameters['name']}'),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  group('NoResultsWidget', () {
    testWidgets(
      'genuine variant shows "Add as custom food" navigating with the '
      'URL-encoded query',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const NoResultsWidget(
              variant: NoResultsVariant.genuine,
              query: 'a&b',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Add as custom food'), findsOneWidget);

        await tester.tap(find.text('Add as custom food'));
        await tester.pumpAndSettle();

        expect(find.text('stub:name=a&b'), findsOneWidget);
      },
    );

    testWidgets(
      'offline variant does not show "Add as custom food"',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const NoResultsWidget(
              variant: NoResultsVariant.offline,
              query: 'oat milk',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Add as custom food'), findsNothing);
      },
    );

    testWidgets(
      'networkError variant does not show "Add as custom food" (only '
      '"Try again")',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            NoResultsWidget(
              variant: NoResultsVariant.networkError,
              query: 'oat milk',
              onRetry: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Add as custom food'), findsNothing);
        expect(find.text('Try again'), findsOneWidget);
      },
    );
  });
}
