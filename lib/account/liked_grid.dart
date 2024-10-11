
import 'package:flutter/material.dart';
import 'package:gallery_tok/account/account.dart';
import 'package:gallery_tok/homepage.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';

class LikedGrid extends StatelessWidget {
  const LikedGrid({
    super.key,
    required this.assetsList,
    required this.reloadAccount,
  });

  final List<AssetEntity?> assetsList;
  final Function reloadAccount;

  @override
  Widget build(BuildContext context) {
    if(assetsList.isNotEmpty){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefPadding),
      child: GridView.builder(
        itemCount: assetsList.length,
        shrinkWrap: true,
        gridDelegate: Account.gridAspect,
        itemBuilder: (_, index) {
          return FutureBuilder(
          future: assetsList[index]!.thumbnailData,
          
          builder: (_, AsyncSnapshot snapshot) {
             if(snapshot.hasData && snapshot.data != null) {
              Image img = Image.memory(snapshot.data);
              return GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: kThirdColor),
                    image: DecorationImage(image: img.image),
                  ),
                  //child: Icon(Icons.favorite, size: kIconSize, color: kIconColor,),
                ),
                onTap: () {
                  corrIndx = index;
                  PageController pc = PageController(initialPage: index);
                  
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => HomePage(
                      assets: assetsList, 
                      feedController: pc, 
                    ))
                  ).then( (_) => reloadAccount);
                  
                },
                );
            }
            return loadingWidget(context);
          });
        }
      ),
    );
  }
  else{
    return const Center(child: Text("No media avaiable!", style: kNormalStyle,));
  }
  }
}