import 'package:flutter/material.dart';

Future showMaxFavBeachDialog(context) async {
  await showDialog(
      context: context, builder: (context) => _MaxFavBeachReachedWidget());
}

class _MaxFavBeachReachedWidget extends StatelessWidget {
  const _MaxFavBeachReachedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Grænse nået!"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Du kan ikke tilføje flere steder som favoritter\n"),
          Text(
              "Du kan maksimalt have 5 steder til listen over dine favoritter"),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Ok"))
      ],
    );
  }
}
