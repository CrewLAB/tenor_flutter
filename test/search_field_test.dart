import 'package:cl_tenor_flutter/src/components/search_field.dart';
import 'package:cl_tenor_flutter/src/providers/app_bar_provider.dart';
import 'package:cl_tenor_flutter/src/providers/sheet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const Duration _debounce = Duration(milliseconds: 300);

Future<TenorAppBarProvider> _pumpSearchField(
  WidgetTester tester,
  TextEditingController controller,
) async {
  final appBarProvider = TenorAppBarProvider(
    '',
    _debounce,
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<TenorAppBarProvider>.value(
              value: appBarProvider,
            ),
            ChangeNotifierProvider<TenorSheetProvider>(
              create: (_) => TenorSheetProvider(
                minExtent: 0.7,
                maxExtent: 1,
                scrollController: DraggableScrollableController(),
              ),
            ),
          ],
          child: TenorSearchField(
            hintText: 'Search',
            scrollController: ScrollController(),
            searchFieldController: controller,
          ),
        ),
      ),
    ),
  );
  // The text listener is attached in a post-frame callback.
  await tester.pump();
  return appBarProvider;
}

void main() {
  testWidgets('committing the typed query leaves the field value untouched', (
    tester,
  ) async {
    final controller = TextEditingController();
    final appBarProvider = await _pumpSearchField(tester, controller);

    const typed = TextEditingValue(
      text: 'cat',
      selection: TextSelection.collapsed(offset: 3),
      composing: TextRange(start: 0, end: 3),
    );
    controller.value = typed;
    await tester.pump(_debounce);

    expect(appBarProvider.queryText, 'cat');
    expect(controller.value, typed);
  });

  testWidgets('a query set from outside the field replaces its text', (
    tester,
  ) async {
    final controller = TextEditingController();
    final appBarProvider = await _pumpSearchField(tester, controller);

    appBarProvider.queryText = 'dogs';
    await tester.pump(_debounce);

    expect(controller.text, 'dogs');
  });
}
