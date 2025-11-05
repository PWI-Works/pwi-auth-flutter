import 'package:flutter/material.dart';
import 'package:pwi_auth/widgets/settings/settings_drawer.dart';

class PageScaffold extends StatelessWidget {
  /// The title of the app bar.
  final String? title;

  /// A flag indicating whether to show the settings icon.
  final bool showSettings;

  /// The widget to display as the end drawer.
  /// If null, the settings drawer will be used if [showSettings] is true.
  final Widget? endDrawer;

  /// The main content of the scaffold.
  final Widget body;

  /// The widget to display as the drawer.
  final Widget? drawer;

  /// A list of widgets to display in the app bar's actions area.
  final List<Widget>? appBarActions;

  /// A flag indicating whether to hide the app bar.
  final bool hideAppBar;

  /// A button displayed floating above [body], in the bottom right corner.
  ///
  /// Typically a [FloatingActionButton].
  final Widget? floatingActionButton;

  /// Responsible for determining where the [floatingActionButton] should go.
  ///
  /// If null, the [ScaffoldState] will use the default location, [FloatingActionButtonLocation.endFloat].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Animator to move the [floatingActionButton] to a new [floatingActionButtonLocation].
  ///
  /// If null, the [ScaffoldState] will use the default animator, [FloatingActionButtonAnimator.scaling].
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;

  const PageScaffold({
    super.key,
    this.title,
    this.showSettings = true,
    this.endDrawer,
    required this.body,
    this.drawer,
    this.appBarActions,
    this.hideAppBar = false,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: hideAppBar
            ? null
            : AppBar(
                title: Text(title ?? "untitled"),
                centerTitle: true,
                actions: [
                  if (showSettings && endDrawer == null)
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ),
                  if (appBarActions != null) ...appBarActions!,
                ],
              ),
        drawer: hideAppBar ? null : drawer,
        endDrawer: hideAppBar
            ? null
            : endDrawer ?? (showSettings ? const SettingsDrawer() : null),
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonAnimator: floatingActionButtonAnimator,
        floatingActionButtonLocation:
            floatingActionButtonLocation, // This trailing comma makes auto-formatting nicer for build methods.
      );
    });
  }
}
