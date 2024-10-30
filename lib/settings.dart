import 'package:flutter/material.dart';
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
      body: const Center(
        child: Text("Welcome to settings!", style: kNormalStyle,),
      ),
    );
  }
}