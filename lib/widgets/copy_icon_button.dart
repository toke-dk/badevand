import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyIconButton extends StatelessWidget {
  const CopyIconButton({super.key, required this.textToCopy, required this.textOnFinish, this.onFinish});

  final String textToCopy;
  final String textOnFinish;
  final Function()? onFinish;

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
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(textOnFinish)));
            onFinish != null ? onFinish!() : null;
          }); // -> show a notification
        });
  }
}
