import 'package:flutter/material.dart';

class CustomSweetAlertDialog<T> extends StatelessWidget {
  final Widget title;
  final Widget content;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final Color cancelColor;
  final T confirmValue; // Value to return on confirmation
  final T cancelValue; // Value to return on cancellation

  const CustomSweetAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = "Yes",
    this.cancelText = "No",
    this.confirmColor = Colors.green,
    this.cancelColor = Colors.red,
    required this.confirmValue,
    required this.cancelValue,
  });

  static Future<T> show<T>(
    BuildContext context, {
    required Widget title,
    required Widget content,
    String confirmText = "Yes",
    String cancelText = "No",
    Color confirmColor = Colors.green,
    Color cancelColor = Colors.red,
    required T confirmValue,
    required T cancelValue,
  }) async {
    return (await showDialog<T>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomSweetAlertDialog<T>(
              title: title,
              content: content,
              confirmText: confirmText,
              cancelText: cancelText,
              confirmColor: confirmColor,
              cancelColor: cancelColor,
              confirmValue: confirmValue,
              cancelValue: cancelValue,
            );
          },
        )) ??
        cancelValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: title,
      content: content,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cancelColor,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.of(context).pop(cancelValue);
          },
          child: Text(cancelText),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.of(context).pop(confirmValue);
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
