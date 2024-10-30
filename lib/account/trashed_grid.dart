
import 'package:flutter/material.dart';
import 'package:suvenir/account/account.dart';
import 'package:suvenir/homepage.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/image.dart';
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
                    SbroImage.deleteAssetFromId(id);
                    reloadAccount();
                  }                
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: kDefPadding),
                child: GridView.builder(
                  itemCount: assetsList.length,
                  shrinkWrap: true,
                  gridDelegate: Account.gridAspect, 
                  itemBuilder: (_, index) {
                    return FutureBuilder(
                    /// First because there is only a key
                    future: (assetsList[index] != null) ? 
                      assetsList[index]!.thumbnailData : 
                      null,
                    
                    builder: (_, AsyncSnapshot snapshot) {
                      /// TODO: since this function is the same on both trash and liked grid it should be unified and moved in account.
                      if(snapshot.hasData && snapshot.data != null) {
                        Image img = Image.memory(snapshot.data);
                        return GestureDetector(       
                          onTap: () async {
                            corrIndx = index;
                            PageController pc = PageController(initialPage: index);
                            
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => HomePage(
                                assets: assetsList, 
                                feedController: pc, 
                                isTrashFeed: true,
                              ))
                            );
                            
                            reloadAccount();
                            
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: kThirdColor),
                              image: DecorationImage(image: img.image)
                            ),
                            child: Text("${daysLeft[index]} days left", style: 
                              (daysLeft[index] <= 3) ? kErrorStyle : kNormalStyle,
                            ),
                          ),
                          );
                      }
                      return loadingWidget(context);
                    }
                  );
                }
                    ),
              ),
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