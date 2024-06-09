import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class WebLandingPage extends StatelessWidget {
  const WebLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = themeData.textTheme;
    ColorScheme colorScheme = themeData.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dansk Badevand",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: Padding(
          padding: const EdgeInsets.all(15),
          child: Image.asset("assets/transparent_logo_white.png"),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue[300]!, Colors.blue[900]!])),
            child: Align(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
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
                    Gap(15),
                    Text(
                      "Tilmeld dig testgruppen på nedenstående felt",
                      style: textTheme.bodyLarge!.copyWith(color: Colors.white),
                    ),
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
                              padding: EdgeInsets.all(8),
                              color: Colors.grey[100],
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Skriv din email her*",
                                ),
                              ),
                            ),
                            Gap(20),
                            FilledButton(
                              onPressed: () {},
                              child: Text("Tilmeld"),
                              style: ButtonStyle(
                                  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero))),
                            ),
                            Gap(15),
                            Text(
                              "Tak for at tilmelde",
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
