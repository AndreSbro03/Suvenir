import 'package:flutter/material.dart';
import 'package:gallery_tok/globals.dart';

class PremissionBox extends StatelessWidget {
  const PremissionBox({
    super.key,
    required this.context, required this.f1, required this.f2,
  });

  final Function f1, f2;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    double w = getWidth(context) * 0.95;
    double h = w * 0.5625;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
            child: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all( color: Colors.amber, width: 2.0,)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                      "Do you really want to delete this photo?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: contrColor,
                        fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      YesNoButton(text: "Yes", color: Colors.green, shadowColor: const Color(0x5800FF00), fz: f1),
                      YesNoButton(text: "No", color: Colors.red, shadowColor: const Color(0x82FF0000), fz: f2),
                    ],
                  )
                ],
              ),
            ),
          ),
    );
  }
}

class YesNoButton extends StatelessWidget {
  const YesNoButton({
    super.key,
    required this.fz, required this.text, required this.color, required this.shadowColor,
  });

  final Function fz;
  final String text;
  final Color color;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              spreadRadius: 4,
              blurRadius: 5,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 20),)),
        ),
      ),
      onTap: () => fz(),
    );
  }
}
