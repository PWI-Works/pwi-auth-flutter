import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

/// A custom loading button widget that displays a loading indicator when pressed.
class LoadingButton extends StatefulWidget {
  /// Controller to manage the state of the loading button.
  final RoundedLoadingButtonController controller;

  /// Callback function to be executed when the button is pressed.
  final VoidCallback? onPressed;

  /// The child widget to be displayed inside the button.
  final Widget child;

  /// The background color of the button.
  final Color? color;

  /// The color of the loading indicator.
  final Color? valueColor;

  /// The border radius of the button.
  final double? borderRadius;

  /// The duration of the loading animation.
  final Duration? duration;

  /// The color of the button when an error occurs.
  final Color? errorColor;

  /// The color of the button when the operation is successful.
  final Color? successColor;

  /// The icon to be displayed when the operation is successful.
  final IconData? successIcon;

  /// The icon to be displayed when the operation fails.
  final IconData? failedIcon;

  /// The horizontal padding inside the button.
  final double horizontalPadding;

  /// Creates a new instance of the LoadingButton widget.
  const LoadingButton({
    super.key,
    required this.controller,
    required this.onPressed,
    required this.child,
    this.color,
    this.valueColor,
    this.borderRadius,
    this.duration,
    this.errorColor,
    this.successColor,
    this.successIcon,
    this.failedIcon,
    this.horizontalPadding = 12,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  /// Key to identify the child widget for measuring its size.
  final GlobalKey _childKey = GlobalKey();

  /// The width of the child widget.
  double? _childWidth;

  @override
  void initState() {
    super.initState();
    // Measure the child widget after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureChild());
  }

  /// Measures the width of the child widget.
  void _measureChild() {
    final RenderBox? renderBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _childWidth = renderBox.size.width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // First build: Measure the child
    if (_childWidth == null) {
      return Opacity(
        opacity: 0,
        child: Container(
          key: _childKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            child: widget.child,
          ),
        ),
      );
    }

    // Subsequent builds: Use the measured width
    return RoundedLoadingButton(
      controller: widget.controller,
      onPressed: widget.onPressed,
      color: widget.color ?? colorScheme.primary,
      height: 40,
      loaderSize: 20,
      width: _childWidth! + (widget.horizontalPadding * 2),
      valueColor: widget.valueColor ?? colorScheme.onPrimary,
      borderRadius: widget.borderRadius ?? 25.0,
      duration: widget.duration ?? const Duration(milliseconds: 400),
      errorColor: widget.errorColor ?? colorScheme.error,
      successColor: widget.successColor ?? colorScheme.primary,
      successIcon: widget.successIcon ?? Icons.check_circle,
      failedIcon: widget.failedIcon ?? Icons.error,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
        child: widget.child,
      ),
    );
  }
}