import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/enums/accessibility_animations.dart';
import 'package:aves/model/settings/enums/viewer_transition.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/magnifier/pan/gesture_detector_scope.dart';
import 'package:aves/widgets/common/magnifier/pan/scroll_physics.dart';
import 'package:aves/widgets/viewer/controller.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:aves/widgets/viewer/visual/entry_page_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiEntryScroller extends StatefulWidget {
  final CollectionLens collection;
  final ViewerController viewerController;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final void Function(AvesEntry mainEntry, AvesEntry? pageEntry) onViewDisposed;

  const MultiEntryScroller({
    super.key,
    required this.collection,
    required this.viewerController,
    required this.pageController,
    required this.onPageChanged,
    required this.onViewDisposed,
  });

  @override
  State<StatefulWidget> createState() => _MultiEntryScrollerState();
}

class _MultiEntryScrollerState extends State<MultiEntryScroller> with AutomaticKeepAliveClientMixin {
  List<AvesEntry> get entries => widget.collection.sortedEntries;

  ViewerController get viewerController => widget.viewerController;

  PageController get pageController => widget.pageController;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MagnifierGestureDetectorScope(
      axis: const [Axis.horizontal, Axis.vertical],
      child: PageView.builder(
        // key is expected by test driver
        key: const Key('horizontal-pageview'),
        scrollDirection: Axis.horizontal,
        controller: pageController,
        physics: MagnifierScrollerPhysics(
          gestureSettings: context.select<MediaQueryData, DeviceGestureSettings>((mq) => mq.gestureSettings),
          parent: const BouncingScrollPhysics(),
        ),
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, index) {
          final mainEntry = entries[index % entries.length];

          final child = mainEntry.isMultiPage
              ? PageEntryBuilder(
                  multiPageController: context.read<MultiPageConductor>().getController(mainEntry),
                  builder: (pageEntry) => _buildViewer(mainEntry, pageEntry: pageEntry),
                )
              : _buildViewer(mainEntry);

          return Selector<Settings, bool>(
            selector: (context, s) => s.accessibilityAnimations.animate,
            builder: (context, animate, child) {
              if (!animate) return child!;
              return AnimatedBuilder(
                animation: pageController,
                builder: viewerController.transition.builder(pageController, index),
                child: child,
              );
            },
            child: child,
          );
        },
        itemCount: viewerController.repeat ? null : entries.length,
      ),
    );
  }

  Widget _buildViewer(AvesEntry mainEntry, {AvesEntry? pageEntry}) {
    return EntryPageView(
      // key is expected by test driver
      key: const Key('image_view'),
      mainEntry: mainEntry,
      pageEntry: pageEntry ?? mainEntry,
      onDisposed: () => widget.onViewDisposed(mainEntry, pageEntry),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SingleEntryScroller extends StatefulWidget {
  final AvesEntry entry;

  const SingleEntryScroller({
    super.key,
    required this.entry,
  });

  @override
  State<StatefulWidget> createState() => _SingleEntryScrollerState();
}

class _SingleEntryScrollerState extends State<SingleEntryScroller> with AutomaticKeepAliveClientMixin {
  AvesEntry get mainEntry => widget.entry;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var child = mainEntry.isMultiPage
        ? PageEntryBuilder(
            multiPageController: context.read<MultiPageConductor>().getController(mainEntry),
            builder: (pageEntry) => _buildViewer(pageEntry: pageEntry),
          )
        : _buildViewer();

    return MagnifierGestureDetectorScope(
      axis: const [Axis.vertical],
      child: child,
    );
  }

  Widget _buildViewer({AvesEntry? pageEntry}) {
    return EntryPageView(
      mainEntry: mainEntry,
      pageEntry: pageEntry ?? mainEntry,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
