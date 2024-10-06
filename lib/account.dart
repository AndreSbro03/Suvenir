import 'package:flutter/material.dart';
import 'package:gallery_tok/homepage.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/libraries/image.dart';
import 'package:photo_manager/photo_manager.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {

  List<AssetEntity?> likedAssets = [];
  List<AssetEntity?> trahedAssets = [];
  
  bool readyToGo = false;

  void _loadAssets() async {
    readyToGo = false;
      likedAssets = await SbroImage.getAllAssesInDatabase(likeAssetsDb);
      trahedAssets = await SbroImage.getAllAssesInDatabase(trashAssetsDb);
    readyToGo = true;
    setState(() {});
  }

  @override 
  void initState(){
    _loadAssets();
    super.initState();
  }

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
                  Text("Total medias liked: ${likedAssets.length}", style: kNormalStyle,),
                  Text("Total medias in the trash: ${trahedAssets.length}", style: kNormalStyle,),
                ],
              ),
            ),
            
            readyToGo ?
              Expanded(
                child: PageView(
                  children: [
                    
                    /// Liked medias
                    AssetsGrid(assetsList: likedAssets, reloadAccount: (){
                      _loadAssets(); setState(() {});
                    },),

                    /// Trash medias
                    AssetsGrid(assetsList: trahedAssets, isTrashFeed: true, reloadAccount: (){
                      _loadAssets(); setState(() {});
                    }),
                    
                  ],
                ),
              ) 
              : 
              const CircularProgressIndicator(),            

          ]
        )
      )
    );
  }
}

class AssetsGrid extends StatelessWidget {
  const AssetsGrid({
    super.key,
    required this.assetsList,
    this.isTrashFeed = false, 
    required this.reloadAccount,
  });

  final List<AssetEntity?> assetsList;
  final bool isTrashFeed;
  final Function reloadAccount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: assetsList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // number of items in each row
        mainAxisSpacing: 8.0, // spacing between rows
        crossAxisSpacing: 8.0, // spacing between columns
      ),
      itemBuilder: (_, index) {
        return FutureBuilder(
        future: assetsList[index]!.thumbnailData,
        
        builder: (_, AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            return GestureDetector(
              child: Image.memory(snapshot.data),
              onTap: () {
                corrIndx = 0;
                PageController pc = PageController(initialPage: index);
                
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => HomePage(
                    assets: assetsList, 
                    feedController: pc, 
                    isTrashFeed: isTrashFeed,
                  ))
                ).then( (_) => reloadAccount);
                
              },
              );
          }
          return Center(child: SizedBox(
            height: getHeight(context) * 0.5,
            width: getWidth(context) * 0.5,
            child: const CircularProgressIndicator()));
        });
      }
    );
  }
}