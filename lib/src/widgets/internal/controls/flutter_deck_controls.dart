import 'package:flutter/widgets.dart';
import 'package:flutter_deck/src/flutter_deck.dart';
import 'package:flutter_deck/src/widgets/internal/controls/actions/actions.dart';
import 'package:flutter_deck/src/widgets/internal/controls/flutter_deck_controls_notifier.dart';

/// A widget that provides controls for the slide deck.
///
/// Key bindings are defined in global deck configuration. The following
/// shortcuts are supported:
///
/// * `nextKey` - Go to the next slide.
/// * `previousKey` - Go to the previous slide.
/// * `openDrawerKey` - Open the navigation drawer.
///
/// Cursor visibility is also handled by this widget. The cursor will be hidden
/// after 3 seconds of inactivity.
///
/// This widget is automatically added to the widget tree and should not be used
/// directly by the user.
class FlutterDeckControls extends StatelessWidget {
  /// Creates a widget that provides controls for the slide deck.
  ///
  /// [child] is the widget that will be wrapped by this widget. It should be
  /// the root of the slide deck.
  const FlutterDeckControls({
    required this.child,
    required this.notifier,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  ///
  final FlutterDeckControlsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final controls = context.flutterDeck.globalConfiguration.controls;

    Widget widget = Focus(
      autofocus: true,
      child: ListenableBuilder(
        listenable: notifier,
        builder: (context, child) => MouseRegion(
          cursor: notifier.cursorVisible
              ? MouseCursor.defer
              : SystemMouseCursors.none,
          onHover: (_) => notifier.showCursor(),
          child: child,
        ),
        child: child,
      ),
    );

    if (controls.enabled) {
      widget = Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(controls.nextKey): const GoNextIntent(),
          LogicalKeySet(controls.previousKey): const GoPreviousIntent(),
          LogicalKeySet(controls.openDrawerKey): const ToggleDrawerIntent(),
          LogicalKeySet(controls.toggleMarkerKey): const ToggleMarkerIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            GoNextIntent: GoNextAction(notifier),
            GoPreviousIntent: GoPreviousAction(notifier),
            ToggleDrawerIntent: ToggleDrawerAction(notifier),
            ToggleMarkerIntent: ToggleMarkerAction(notifier),
          },
          child: widget,
        ),
      );
    }

    return widget;
  }
}
