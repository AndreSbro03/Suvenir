import 'package:flutter/material.dart';
import 'package:gallery_tok/account/user_stats.dart';
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
  List<AssetEntity?> trashedAssets = [];
  
  bool readyToGo = false;
  int _correntPage = 0;
  final PageController _pc = PageController();

  void _loadAssets() async {
    readyToGo = false;
      likedAssets = await SbroImage.getAllAssesInDatabase(likeAssetsDb);
      trashedAssets = await SbroImage.getAllAssesInDatabase(trashAssetsDb);
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
        backgroundColor: Colors.transparent,
        title: const Text(
          "Account",
          style: kH2Style,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            /// UserStatsBox
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
              child: UserStatsBox(
                originalAssetsLen: originalAssets.length, 
                likedAssetsLen: likedAssets.length, 
                trashedAssetsLen: trashedAssets.length
              ),
            ),

            const Divider(
              color: kContrColor,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /// GOTO like grid view
                  PageSelector(pc: _pc, correntPage: _correntPage, desirePage: 0, 
                    iconOnPage: Icons.favorite, iconNotOnPage: Icons.favorite_outline,),
                  /// GOTO trash grid view
                  PageSelector(pc: _pc, correntPage: _correntPage, desirePage: 1,
                    iconOnPage: Icons.delete, iconNotOnPage: Icons.delete_outline,),
                ],
              ),
            ),

            readyToGo ?
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  child: PageView(
                    controller: _pc,
                    onPageChanged: (value) {
                      setState(() {
                        _correntPage = value;
                      });
                    },
                    children: [
                      
                      /// Liked medias
                      AssetsGrid(assetsList: likedAssets, reloadAccount: (){
                        _loadAssets(); setState(() {});
                      },),
                  
                      /// Trash medias
                      AssetsGrid(assetsList: trashedAssets, isTrashFeed: true, reloadAccount: (){
                        _loadAssets(); setState(() {});
                      }),
                      
                    ],
                  ),
                ),
              ) 
              : 
              const Center(child: CircularProgressIndicator()),            

          ]
        )
      )
    );
  }
}

class PageSelector extends StatelessWidget {
  const PageSelector({
    super.key,
    required this.pc, 
    required this.correntPage, 
    required this.desirePage, 
    required this.iconOnPage, 
    required this.iconNotOnPage, 
  });

  /// Controller of the page to scroll
  final PageController pc;
  /// Corrent page
  final int correntPage;
  /// Destination page on click
  final int desirePage;
  /// Icons
  final IconData iconOnPage;
  final IconData iconNotOnPage;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: (){
        pc.jumpToPage(desirePage);
      }, 
      icon: Icon(
        (correntPage == desirePage) ? iconOnPage : iconNotOnPage,
      ), 
      style: ButtonStyle(
        iconColor: const WidgetStatePropertyAll(kIconColor),
        iconSize: const WidgetStatePropertyAll(kIconSize),
        backgroundColor: const WidgetStatePropertyAll(kPrimaryColor),
        minimumSize: WidgetStatePropertyAll(Size(getWidth(context) * 0.4, 50))
      ),
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
    if(assetsList.isNotEmpty){
    return GridView.builder(
      itemCount: assetsList.length,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // number of items in each row
        childAspectRatio: (3 / 4),
        mainAxisSpacing: 5.0, // spacing between rows
        crossAxisSpacing: 5.0, // spacing between columns
      ),
      itemBuilder: (_, index) {
        return FutureBuilder(
        future: assetsList[index]!.thumbnailData,
        
        builder: (_, AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            Image img = Image.memory(snapshot.data);
            return GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: kThirdColor),
                  image: DecorationImage(image: img.image)
                ),
              ),
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
            child: const Center(child: CircularProgressIndicator())));
        });
      }
    );
  }
  else{
    return const Center(child: Text("No media avaiable!", style: kNormalStyle,));
  }
  }
}