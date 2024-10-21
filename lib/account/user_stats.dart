import 'package:flutter/material.dart';
import 'package:suvenir/libraries/globals.dart';

class UserStatsBox extends StatelessWidget {
  const UserStatsBox({
    super.key,
  required this.originalAssetsLen, 
  required this.likedAssetsLen, 
  required this.trashedAssetsLen, 
  required this.spaceSaved,
  });

  final int originalAssetsLen;
  final int likedAssetsLen;
  final int trashedAssetsLen;
  final int spaceSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Uncomment to center the UserBox
        /// const Expanded(child: SizedBox()),
        Container(
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
                const Text("Statistics", style: kH2Style,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Medias found on device: ", style: kDescriptionStyle,),
                    Text(shortNumber(originalAssetsLen), style: kH1Style,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Medias liked: ", style: kDescriptionStyle,),
                    Text(shortNumber(likedAssetsLen), style: kH1Style,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Medias in the trash: ", style: kDescriptionStyle,),
                    Text(shortNumber(trashedAssetsLen), style: kH1Style,),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Space saved: ", style: kDescriptionStyle,),
                    Text(shortNumber(spaceSaved), style: kH1Style,),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}