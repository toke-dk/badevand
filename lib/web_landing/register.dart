import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = themeData.textTheme;
    ColorScheme colorScheme = themeData.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      constraints: BoxConstraints(
        maxWidth: 1000,
      ),
      child: Column(
        children: [
          Text(
            "Tilmeld dig her",
            style: textTheme.displaySmall!.copyWith(
                color: colorScheme.tertiary, fontWeight: FontWeight.bold),
          ),
          Gap(20),
          Text(
            "Hvis du har lyst til at være testbruger, skal du blot tilmelde dig via nedenstående formular",
            textAlign: TextAlign.center,
          ),
          Gap(15),
          SubscribeSection(),
        ],
      ),
    );
  }
}

class SubscribeSection extends StatelessWidget {
  const SubscribeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              labelText: "Skriv din email her*",
            ),
          ),
        ),
        Gap(20),
        Container(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {},
            child: Text("Tilmeld"),
            style: ButtonStyle(
                shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.zero))),
          ),
        ),
        Gap(15),
        Text(
          "Tak for at tilmelde!",
        ),
      ],
    );
  }
}
