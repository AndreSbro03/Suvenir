import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';

class UserStatsBox extends StatelessWidget {
  const UserStatsBox({
    super.key,
  required this.originalAssetsLen, 
  required this.likedAssetsLen, 
  required this.trashedAssetsLen,
  });

  final int originalAssetsLen;
  final int likedAssetsLen;
  final int trashedAssetsLen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(context),
      //color: kPrimaryColor,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kPrimaryColor, kSecondaryColor]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total medias found on device: ", style: kDescriptionStyle,),
                Text("$originalAssetsLen", style: kH1Style,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total medias liked: ", style: kDescriptionStyle,),
                Text("$likedAssetsLen", style: kH1Style,),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total medias in the trash: ", style: kDescriptionStyle,),
                Text("$trashedAssetsLen", style: kH1Style,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}