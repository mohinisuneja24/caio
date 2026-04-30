import 'package:flutter/material.dart';

/// Centers content and caps width on large screens / tablets.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxContentWidth = 560,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  final Widget child;
  final double maxContentWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final inner = w > maxContentWidth + padding.horizontal
            ? ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: child,
              )
            : child;
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: padding,
            child: inner,
          ),
        );
      },
    );
  }
}
