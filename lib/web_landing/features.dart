import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Features extends StatelessWidget {
  Features({super.key});

  final Widget _imagePlaceholder = Container(child: Placeholder());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      constraints: BoxConstraints(
        maxWidth: 1000,
      ),
      child: Column(
        children: [
          _FeatureSection(
            title: "Tilføj strande",
            description: "Du kan nemt tilføje badesteder",
            image: _imagePlaceholder,
          ),
          _FeatureSection(
            title: "Tætteste badesteder",
            description:
                "Du kan også se hvilke badesteder der er tættest på hvor du er",
            image: _imagePlaceholder,
          ),
          _FeatureSection(
            title: "Lokalt vejr",
            description:
                "Med en vejrmodel kan du nemt og let se hvordan vejret på forskellige badesteder er",
            image: _imagePlaceholder,
          ),
          _FeatureSection(
            title: "Favorit badesteder",
            description:
                "Du kan selvfølgelig også tilføje et badested som favorit og hurtigt se vejrudsigen for det pågældende badested",
            image: _imagePlaceholder,
          ),
        ],
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection(
      {super.key, required this.title, this.description, this.image});

  final String title;
  final String? description;
  final Widget? image;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    TextTheme textTheme = themeData.textTheme;
    ColorScheme colorScheme = themeData.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge,
        ),
        Divider(
          color: colorScheme.primary,
          thickness: 3,
        ),
        Gap(8),
        description == null ? SizedBox.shrink() : Text(description!),
        Gap(8),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            constraints: BoxConstraints(maxHeight: 500),
            child: image ?? SizedBox.shrink()),
      ],
    );
  }
}
