import 'package:flutter/material.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/styles.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        foregroundColor: kContrColor,
        title: const Text("Settings", style: kH2Style,),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(kDefPadding),
              child: Container(
                height: 100,
                width: getWidth(context),
                decoration: BoxDecoration(
                  color: kSecondaryColor,
                  border: Border.all(color: kPrimaryColor, width: 5)
                ),
                child: Center(child: Text("Welcome to settings!", style: kNormalStyle,))),
            ),
          ),
        ],
      ),
    );
  }
}