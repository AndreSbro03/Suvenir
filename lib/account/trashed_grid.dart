
import 'package:flutter/material.dart';
import 'package:suvenir/account/assets_grid.dart';
import 'package:suvenir/istances/feed_manager.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/media_manager.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/libraries/styles.dart';

class TrashedGrid extends StatelessWidget {
  const TrashedGrid({
    super.key,
    required this.assetsList,
    required this.reloadAccount, 
    required this.daysLeft,
  });

  final List<AssetEntity?> assetsList;
  final List<int> daysLeft;
  final Function reloadAccount;

  @override
  Widget build(BuildContext context) {

    if(assetsList.isNotEmpty || assetsList.length == daysLeft.length){
      return Padding(
        padding: const EdgeInsets.all(kDefPadding),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: kDefPadding),
              child: GestureDetector(
                onTap: () async {
                  List<String> ids = await trashAssetsDb.readAllMediaIds();
                  for (String id in ids) {
                    trashAssetsDb.removeMedia(id);
                    SbroMediaManager.deleteAssetFromId(id);
                  }                
                  reloadAccount();
                },
                child: Container(
                  height: 50,
                  width: getWidth(context),
                  decoration: BoxDecoration(
                    color: kThirdColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Clear trash", style: kNormalStyle,),
                      Icon(Icons.chevron_right_sharp, size: kIconSize, color: kIconColor,),
                    ],
                  ),
                ),
              ),
            ),
            /// Trashed Grid
            Expanded(
              child: AssetsGrid(feedId: FeedId.trash, assets: assetsList, reloadAccount: reloadAccount, 
                childBuilder: (int index) { 
                  return Text("${daysLeft[index]} days left", style: (daysLeft[index] <= 3) ? kErrorStyle : kNormalStyle,);
                })
            ),
          ],
        ),
      );
  }
  else{
    if(assetsList.length != daysLeft.length) {
      print("[ERR] Passing a assetsList and a number of Days of different size!");
    }
    return const Center(child: Text("No media avaiable!", style: kNormalStyle,));
  }
  }
}