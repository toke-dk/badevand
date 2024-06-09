import 'package:flutter/material.dart';
import 'package:footer/footer.dart';
import 'package:gap/gap.dart';

Footer MyFooter(TextStyle style) {
  return Footer(
      backgroundColor: Color.fromARGB(255, 0, 0, 120),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset("assets/transparent_logo_white.png",width: 12,),
                Gap(10),
                Text("Dansk Badevand", style:style,),
              ],
            ),
            Gap(15),
            Text("Kontakt", style: style.copyWith(fontSize: 18),),
            Gap(8),
            Text("Copenhagen, Denmark", style: style,),
            Gap(8),
            Text("Email - tokefriis@gmail.com", style: style,),
            Gap(15),
            Row(
              children: [
                Icon(
                  Icons.copyright,
                  color: Colors.white,
                ),
                Text(" 2024 Dansk Badevand", style: style,)
              ],
            )
          ],
        ),
      ));
}
