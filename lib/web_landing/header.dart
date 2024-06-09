import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.textTheme, required this.colorScheme});

  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[300]!, Colors.blue[900]!])),
      child: Align(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          constraints: BoxConstraints(
            maxWidth: 1000,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(30),
              Text(
                "Vil du være tester af Dansk Badevand?",
                style: textTheme.displaySmall!.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(10),
              Text(
                "Tilmeld dig testgruppen på nedenstående felt",
                style: textTheme.bodyLarge!.copyWith(color: Colors.white),
              ),
              Gap(20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bliv gratis en del af testgruppen".toUpperCase(),
                        style: textTheme.titleLarge!
                            .copyWith(color: colorScheme.primary),
                      ),
                      Gap(10),
                      Container(
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                            labelText: "Skriv din email her*",
                          ),
                        ),
                      ),
                      Gap(20),
                      FilledButton(
                        onPressed: () {},
                        child: Text("Tilmeld"),
                        style: ButtonStyle(
                            shape:
                            WidgetStatePropertyAll<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero))),
                      ),
                    ],
                  ),
                ),
              ),
              Gap(100)
            ],
          ),
        ),
      ),
    );
  }
}