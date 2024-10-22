
import 'package:flutter/material.dart';
import 'package:suvenir/account/account.dart';
import 'package:suvenir/homepage.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/libraries/styles.dart';

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
      padding: const EdgeInsets.all(kDefPadding),
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
                onTap: () async {
                  corrIndx = index;
                  PageController pc = PageController(initialPage: index);
                  
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => HomePage(
                      assets: assetsList, 
                      feedController: pc, 
                    ))
                  );

                  reloadAccount();
                  
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