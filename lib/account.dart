import 'package:flutter/material.dart';
import 'package:gallery_tok/feed/feed.dart';
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
  bool readyToGo = false;

  void _loadAssets()async {
    readyToGo = false;
    likedAssets = await SbroImage.getAllAssesInDatabase(likedMedias);
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
                  const Text("Total medias in the trash: ${69420}", style: kNormalStyle,),
                ],
              ),
            ),
            
            readyToGo ?
              Expanded(
                child: PageView(
                  children: [
                    
                    /// Liked medias
                    GridView.builder(
                      itemCount: likedAssets.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // number of items in each row
                        mainAxisSpacing: 8.0, // spacing between rows
                        crossAxisSpacing: 8.0, // spacing between columns
                      ),
                      itemBuilder: (_, index) {
                        return FutureBuilder(
                        future: likedAssets[index]!.thumbnailData,
                        
                        builder: (_, AsyncSnapshot snapshot) {
                          if(snapshot.hasData) {
                            return GestureDetector(
                              child: Image.memory(snapshot.data),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => HomePage(assetsList: likedAssets))
                                );
                              },
                              );
                          }
                          return Center(child: SizedBox(
                            height: getHeight(context) * 0.5,
                            width: getWidth(context) * 0.5,
                            child: const CircularProgressIndicator()));
                        });
                      }
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
              ) 
              : 
              const CircularProgressIndicator(),            

          ]
        )
      )
    );
  }
}