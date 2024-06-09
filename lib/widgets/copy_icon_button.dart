import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyIconButton extends StatelessWidget {
  const CopyIconButton({super.key, required this.textToCopy, required this.onFinishText});

  final String textToCopy;
  final String onFinishText;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(
          Icons.copy,
        ),
        onPressed: () {
          Clipboard.setData(ClipboardData(
              text:
              textToCopy))
              .then((value) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(onFinishText)));
          }); // -> show a notification
        });
  }
}
