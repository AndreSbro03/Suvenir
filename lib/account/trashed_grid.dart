
import 'package:flutter/material.dart';
import 'package:gallery_tok/account/account.dart';
import 'package:gallery_tok/homepage.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';

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
      return GridView.builder(
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
            if(snapshot.hasData && snapshot.data != null) {
              Image img = Image.memory(snapshot.data);
              return GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: kThirdColor),
                    image: DecorationImage(image: img.image)
                  ),
                  child: Text("${daysLeft[index]} days left", style: 
                    (daysLeft[index] <= 3) ? kErrorStyle : kNormalStyle,
                  ),
                ),
                onTap: () {
                  corrIndx = index;
                  PageController pc = PageController(initialPage: index);
                  
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => HomePage(
                      assets: assetsList, 
                      feedController: pc, 
                      isTrashFeed: true,
                    ))
                  ).then( (_) => reloadAccount);
                  
                },
                );
            }
            return loadingWidget(context);
          }
        );
      }
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