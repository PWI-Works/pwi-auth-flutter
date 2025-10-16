// lib\ui\settings\settings_drawer.dart

import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/widgets/loading_button.dart';
import 'settings_page_view_model.dart';

class SettingsPage extends ViewWidget<SettingsPageViewModel> {

  final List<Widget> additionalWidgets;

  SettingsPage({super.key, this.additionalWidgets = const []}) : super(builder: () => SettingsPageViewModel());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text("Settings", style: Theme.of(context).textTheme.headlineSmall),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text("light"),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text("dark"),
                      icon: Icon(Icons.dark_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text("system"),
                      icon: Icon(Icons.settings),
                    ),
                  ],
                  selected: {viewModel.currentTheme},
                  onSelectionChanged: (Set<ThemeMode> selection) =>
                      viewModel.currentTheme = selection.first,
                ),
              ],
            ),
          ),
          LoadingButton(
            controller: viewModel.signOutButtonController,
            onPressed: viewModel.signOut,
            color: Theme.of(context).colorScheme.error,
            successIcon: Icons.waving_hand_outlined,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout,
                    color: Theme.of(context).colorScheme.onError),
                const SizedBox(width: 8),
                Text('Sign Out',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onError)),
                const SizedBox(width: 8),
              ],
            ),
          ),
          ...additionalWidgets,
        ],
      ),
    );
  }
}
