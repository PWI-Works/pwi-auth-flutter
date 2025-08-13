import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/widgets/loading_button.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'confirmation_dialog_view_model.dart';

/// A dialog widget to confirm an action, such as deleting an item.
class ConfirmationDialog extends ViewWidget<ConfirmationDialogViewModel> {
  /// The context of the parent widget that can be popped.
  final BuildContext? poppableParentContext;

  /// Creates a new instance of the ConfirmationDialog widget.
  ///
  /// * [itemName] - The name of the item to be confirmed for the action.
  /// * [onConfirm] - The function to be executed when the action is confirmed.
  /// * [confirmButtonText] - The text to be displayed on the confirm button.
  /// * [poppableParentContext] - The context of the parent widget that can be popped.
  ConfirmationDialog({
    super.key,
    String? itemName,
    required Future Function() onConfirm,
    required String confirmButtonText,
    this.poppableParentContext,
  }) : super(
          builder: () => ConfirmationDialogViewModel(
            itemName: itemName,
            onConfirm: onConfirm,
            actionName: confirmButtonText,
          ),
        );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (viewModel.finished) {
      if (poppableParentContext != null) {
        Navigator.of(poppableParentContext!).pop();
      }
      // If the operation was canceled, close the dialog
      Navigator.of(context).pop();
    }

    if (viewModel.canceled) {
      // If the item was successfully deleted, close the dialog
      Navigator.of(context).pop();
    }

    return AlertDialog(
      title: Text(viewModel.title),
      content: Text(
        'Are you sure you want to ${viewModel.actionName.toLowerCase()}${viewModel.itemName != null ? ' ${viewModel.itemName}' : ''}?\nThis action cannot be undone.',
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: viewModel.confirmButtonController.currentState !=
                      ButtonState.loading
                  ? viewModel.cancel
                  : null,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 16),
            // Delete button with loading state
            LoadingButton(
              controller: viewModel.confirmButtonController,
              onPressed: viewModel.confirmButtonController.currentState !=
                      ButtonState.loading
                  ? viewModel.confirm
                  : null,
              color: colorScheme.error,
              child: Text(
                viewModel.confirmButtonText.toUpperCase(),
                style: TextStyle(color: colorScheme.onError),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
