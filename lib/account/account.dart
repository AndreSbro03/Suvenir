import 'package:flutter/material.dart';
import 'package:gallery_tok/account/liked_grid.dart';
import 'package:gallery_tok/account/trashed_grid.dart';
import 'package:gallery_tok/account/user_stats.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/libraries/image.dart';
import 'package:gallery_tok/libraries/statistics.dart';
import 'package:photo_manager/photo_manager.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  static SliverGridDelegateWithFixedCrossAxisCount gridAspect = const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3, // number of items in each row
    childAspectRatio: (3 / 4),
    mainAxisSpacing: 5.0, // spacing between rows
    crossAxisSpacing: 5.0, // spacing between columns
  );

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {

  List<AssetEntity?> likedAssets = [];
  List<AssetEntity?> trashedAssets = [];
  List<int> daysLeft = [];
  int spaceSaved = 0;
      
  
  bool readyToGo = false;
  int _correntPage = 0;
  late final PageController _pc;

  void _loadAssets() async {
    readyToGo = false;
      likedAssets = await SbroImage.getAllAssesInDatabase(likeAssetsDb);
      var trashDatesMap = await SbroImage.getAssetsTrashedDate();
      /// Here we separete the map in the two arrays. Use first because there is only one K and one V
      for (var map in trashDatesMap) {
        trashedAssets.add(map.keys.first);
        daysLeft.add(map.values.first);
      }
      //print(daysLeft.toString());

      /// Load space saved
      spaceSaved = await Statistics.instance.getSavedSpace();

    readyToGo = true;
    setState(() {});
  }

  @override 
  void initState(){
    _loadAssets();
    _pc = PageController();
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
                trashedAssetsLen: trashedAssets.length,
                spaceSaved: spaceSaved,
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
                      LikedGrid(assetsList: likedAssets, reloadAccount: (){
                        _loadAssets(); setState(() {});
                      },),
                  
                      /// Trash medias
                      TrashedGrid(assetsList: trashedAssets, daysLeft: daysLeft, reloadAccount: (){
                        _loadAssets(); setState(() {});
                      }),
                      
                    ],
                  ),
                ),
              ) 
              : 
              Center(child: SizedBox(child: const Center(child: CircularProgressIndicator()))),
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


