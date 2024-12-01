
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/homepage.dart';
import 'package:suvenir/istances/feed_manager.dart';
import 'package:suvenir/istances/video_player_manager.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/styles.dart';

class AssetsGrid extends StatelessWidget {
  const AssetsGrid({super.key, 
    required this.feedId, 
    required this.assets, 
    required this.reloadAccount,
    this.childBuilder, 
  });

  final FeedId feedId;
  final List<AssetEntity?> assets;
  final Function reloadAccount;
  final Widget? Function(int)? childBuilder;

  final SliverGridDelegateWithFixedCrossAxisCount gridAspect = const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3, // number of items in each row
    childAspectRatio: (3 / 4),
    mainAxisSpacing: 5.0, // spacing between rows
    crossAxisSpacing: 5.0, // spacing between columns
  );

  @override
  Widget build(BuildContext context) {
    if(assets.isNotEmpty){
      return Padding(
        padding: const EdgeInsets.all(kDefPadding),
        child: GridView.builder(
          itemCount: assets.length,
          shrinkWrap: true,
          gridDelegate: gridAspect,
          itemBuilder: (_, index) {
            if(assets[index] != null){

              return FutureBuilder(
              future: assets[index]!.thumbnailData,
              
              builder: (_, AsyncSnapshot snapshot) {
                if(snapshot.hasData && snapshot.data != null) {
                  Image img = Image.memory(snapshot.data);
                  return GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: kThirdColor),
                        image: DecorationImage(image: img.image),
                      ),
                      child: (childBuilder != null) ? childBuilder!(index) : null,
                    ),
                    onTap: () async {
                      corrIndx = index;
                      PageController pc = PageController(initialPage: index);
                      
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => HomePage(
                          id: feedId,
                          assets: assets, 
                          feedController: pc, 
                        ))
                      );

                      VideoPlayerManager.instance.pauseAll();
                      reloadAccount();
                      
                    },
                    );
                }
                return loadingWidget(context);
              });
            }
            else {
              return const Text("Error!", style: kNormalStyle,);
            }
          }
        ),
      );
    } else {
      return const Center(child: Text("No media avaiable!", style: kNormalStyle,));
    }
  }
}