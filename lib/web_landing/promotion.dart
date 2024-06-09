import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Promotion extends StatelessWidget {
  const Promotion({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = themeData.textTheme;
    ColorScheme colorScheme = themeData.colorScheme;

    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Align(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20),
          constraints: BoxConstraints(
            maxWidth: 1000,
          ),
          child: Column(
            children: [
              Text(
                "Appen har",
                style: textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              Gap(35),
              _PromotionAttribute(title: "1.900+", description: 'badesteder',),
              Gap(25),
              _PromotionAttribute(title: "15+", description: "kommuner"),
              Gap(25),
              _PromotionAttribute(title: "9", description: "dages vejrudsigt")
            ],
          ),
        ),
      ),
    );
  }
}

class _PromotionAttribute extends StatelessWidget {
  const _PromotionAttribute({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = themeData.textTheme;
    ColorScheme colorScheme = themeData.colorScheme;

    return Column(
      children: [
        Text(
          title,
          style: textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
        ),
        Gap(10),
        Text(
          description,
          style: textTheme.titleLarge,
        )
      ],
    );
  }
}
