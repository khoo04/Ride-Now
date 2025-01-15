import 'package:flutter/material.dart';

class OverflowAwareText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  const OverflowAwareText({
    super.key,
    required this.text,
    required this.style,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Measure the text to check for overflow
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final bool isOverflowing = textPainter.didExceedMaxLines;

        // Render Tooltip only if text overflows
        if (isOverflowing) {
          return Tooltip(
            message: text,
            triggerMode: TooltipTriggerMode.longPress,
            margin: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: style,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else {
          return Text(
            text,
            style: style,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          );
        }
      },
    );
  }
}
