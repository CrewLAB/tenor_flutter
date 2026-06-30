// ignore_for_file: implementation_imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cl_tenor_flutter/src/components/attribution.dart';
import 'package:cl_tenor_flutter/src/components/search_field.dart';
import 'package:cl_tenor_flutter/src/components/tab_bar.dart';
import 'package:cl_tenor_flutter/src/models/attribution.dart';
import 'package:cl_tenor_flutter/src/models/tab.dart';
import 'package:cl_tenor_flutter/src/providers/app_bar_provider.dart';
import 'package:cl_tenor_flutter/src/providers/sheet_provider.dart';
import 'package:cl_tenor_flutter/src/providers/tab_provider.dart';
import 'package:cl_tenor_flutter/tenor_flutter.dart';

/// A flat GIF picker layout designed for use inside any parent widget, including
/// [showCLBottomSheet]. Unlike [TenorSheet], this does not use a
/// [DraggableScrollableSheet] and can be placed in a [Column] or [Expanded].
class TenorPickerBody extends StatefulWidget {
  const TenorPickerBody({
    required this.client,
    required this.style,
    required this.tabs,
    this.attributionType = TenorAttributionType.poweredBy,
    this.debounce = const Duration(milliseconds: 300),
    this.initialTabIndex = 1,
    this.searchFieldHintText = 'Search Tenor',
    super.key,
  });

  final Tenor client;
  final TenorStyle style;
  final List<TenorTab> tabs;
  final TenorAttributionType attributionType;
  final Duration debounce;
  final int initialTabIndex;
  final String searchFieldHintText;

  @override
  State<TenorPickerBody> createState() => _TenorPickerBodyState();
}

class _TenorPickerBodyState extends State<TenorPickerBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget.initialTabIndex,
      length: widget.tabs.length,
      vsync: this,
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TenorSheetProvider is required by TenorSearchField. The
    // DraggableScrollableController will not be attached (no DraggableScrollableSheet),
    // and TenorSearchField guards the animateTo call with isAttached.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TenorAppBarProvider>(
          create: (_) => TenorAppBarProvider(
            '',
            widget.debounce,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          ),
        ),
        ChangeNotifierProvider<TenorSheetProvider>(
          create: (_) => TenorSheetProvider(
            initialExtent: 1,
            maxExtent: 1,
            minExtent: 0.7,
            scrollController: DraggableScrollableController(),
          ),
        ),
        ChangeNotifierProvider<TenorTabProvider>(
          create: (_) => TenorTabProvider(
            attributionType: widget.attributionType,
            client: widget.client,
          ),
        ),
      ],
      child: DefaultTextStyle.merge(
        style: TextStyle(fontFamily: widget.style.fontFamily),
        child: Column(
          children: [
            TenorTabBar(
              style: widget.style.tabBarStyle,
              tabController: _tabController,
              tabs: widget.tabs.map((tab) => tab.name).toList(),
            ),
            TenorSearchField(
              animationStyle: widget.style.animationStyle,
              hintText: widget.searchFieldHintText,
              scrollController: _scrollController,
              searchFieldWidget: null,
              selectedCategoryStyle: widget.style.selectedCategoryStyle,
              style: widget.style.searchFieldStyle,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: widget.tabs.map((tab) => tab.view).toList(),
              ),
            ),
            if (widget.attributionType == TenorAttributionType.poweredBy)
              TenorAttribution(style: widget.style.attributionStyle),
          ],
        ),
      ),
    );
  }
}
