import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        foregroundColor: kContrColor,
        backgroundColor: kThirdColor,
        title: const Text(
          "Account",
          style: kSubTitleStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            /// User Stats
            Container(
              width: getWidth(context),
              height: getHeight(context) * 0.20,
              color: Colors.white12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Total medias found on device: ${originalAssets.length}", style: kNormalStyle,),
                  const Text("Total medias liked: ${69420}", style: kNormalStyle,),
                  const Text("Total medias in the trash: ${69420}", style: kNormalStyle,),
                ],
              ),
            ),
            
            Expanded(
              child: PageView(
                children: [
                  
                  /// Liked medias
                  GridView.builder(
                    itemCount: 100,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // number of items in each row
                      mainAxisSpacing: 8.0, // spacing between rows
                      crossAxisSpacing: 8.0, // spacing between columns
                    ),
                    itemBuilder: (_, index) {
                      return Container(color: Colors.red,);
                    },
                  ),

                  /// Trash medias
                  GridView.builder(
                    itemCount: 15,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // number of items in each row
                      mainAxisSpacing: 8.0, // spacing between rows
                      crossAxisSpacing: 8.0, // spacing between columns
                    ),
                    itemBuilder: (_, index) {
                      return Container(color: Colors.green,);
                    },
                  )
                ],
              ),
            ),
          ]
        )
      )
    );
  }
}