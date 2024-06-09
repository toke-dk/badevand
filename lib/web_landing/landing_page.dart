import 'package:badevand/web_landing/features.dart';
import 'package:badevand/web_landing/footer.dart';
import 'package:badevand/web_landing/promotion.dart';
import 'package:badevand/web_landing/register.dart';
import 'package:flutter/material.dart';
import 'package:footer/footer.dart';
import 'package:footer/footer_view.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import 'header.dart';

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
      body: FooterView(
        footer: MyFooter(textTheme.bodySmall!.copyWith(color: Colors.white)),
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Header(
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
                Gap(20),
                Features(),
                Gap(30),
                Promotion(),
                Gap(60),
                Register(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
