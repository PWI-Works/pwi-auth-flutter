
import 'package:flutter/material.dart';

class DoubleScrollView extends StatelessWidget {
  final Widget child;
  const DoubleScrollView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      ),
    );
  }
}
