import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class ConfirmationDialogViewModel extends ViewModel {

  final Future Function() onConfirm;

  final String? itemName;

  final String actionName;

  String get _actionToTitleCase => actionName[0].toUpperCase() + actionName.toLowerCase().substring(1);

  String get confirmButtonText => _actionToTitleCase == "Cancel" ? "Yes, Cancel" : _actionToTitleCase;

  String get title => 'Confirm $_actionToTitleCase';

  ConfirmationDialogViewModel({required this.itemName, required this.onConfirm, required this.actionName});

  bool _deleted = false;

  bool get finished => _deleted;

  set finished(bool value) {
    _deleted = value;
    buildView();
  }

  bool _canceled = false;

  bool get canceled => _canceled;

  set canceled(bool value) {
    _canceled = value;
    buildView();
  }

  final RoundedLoadingButtonController confirmButtonController = RoundedLoadingButtonController();

  void cancel() {
    canceled = true;
  }

  Future<void> confirm() async {
    try {
      // Set deleting state to true before the operation
      confirmButtonController.start();

      // Await the onDelete callback
      await onConfirm();

      // Set deleted state to true after successful deletion
      confirmButtonController.success();
      finished = true;
    } catch (e) {
      // Handle any potential errors
      // Optionally log the error or show a notification
      confirmButtonController.error();
    }
  }
}
