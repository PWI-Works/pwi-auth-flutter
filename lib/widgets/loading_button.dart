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
  ///
  /// This takes precedence over the enabled background color in [style].
  final Color? color;

  /// Overrides colors inherited from the ambient [ElevatedButtonTheme].
  ///
  /// [ButtonStyle.foregroundColor] and [ButtonStyle.backgroundColor] are
  /// supported. Other style properties continue to be controlled by
  /// [RoundedLoadingButton].
  final ButtonStyle? style;

  /// The background color of the button when [onPressed] is null.
  ///
  /// This takes precedence over the disabled background color in [style].
  final Color? disabledColor;

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
    this.style,
    this.disabledColor,
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
    final RenderBox? renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _childWidth = renderBox.size.width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final states = <WidgetState>{
      if (widget.onPressed == null) WidgetState.disabled,
    };
    final themedStyle = theme.elevatedButtonTheme.style;
    final effectiveStyle = themedStyle?.merge(widget.style) ?? widget.style;
    final defaultForegroundColor = widget.onPressed == null
        ? colorScheme.onSurface.withValues(alpha: 0.38)
        : colorScheme.onPrimary;
    final foregroundColor =
        effectiveStyle?.foregroundColor?.resolve(states) ??
            defaultForegroundColor;
    final backgroundColor = widget.onPressed == null
        ? widget.disabledColor ??
            effectiveStyle?.backgroundColor?.resolve(states) ??
            colorScheme.onSurface.withValues(alpha: 0.12)
        : widget.color ??
            effectiveStyle?.backgroundColor?.resolve(states) ??
            colorScheme.primary;
    final styledChild = DefaultTextStyle.merge(
      style: TextStyle(color: foregroundColor),
      child: IconTheme.merge(
        data: IconThemeData(color: foregroundColor),
        child: widget.child,
      ),
    );

    // First build: Measure the child
    if (_childWidth == null) {
      return Opacity(
        opacity: 0,
        child: Container(
          key: _childKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            child: styledChild,
          ),
        ),
      );
    }

    // Subsequent builds: Use the measured width
    return RoundedLoadingButton(
      controller: widget.controller,
      onPressed: widget.onPressed,
      color: backgroundColor,
      disabledColor: backgroundColor,
      height: 40,
      loaderSize: 20,
      width: _childWidth! + (widget.horizontalPadding * 2),
      valueColor: widget.valueColor ?? foregroundColor,
      borderRadius: widget.borderRadius ?? 25.0,
      duration: widget.duration ?? const Duration(milliseconds: 400),
      errorColor: widget.errorColor ?? colorScheme.error,
      successColor: widget.successColor ?? colorScheme.primary,
      successIcon: widget.successIcon ?? Icons.check_circle,
      failedIcon: widget.failedIcon ?? Icons.error,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
        child: styledChild,
      ),
    );
  }
}
