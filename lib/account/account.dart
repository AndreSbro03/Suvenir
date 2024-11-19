import 'package:flutter/material.dart';
import 'package:suvenir/account/liked_grid.dart';
import 'package:suvenir/account/trashed_grid.dart';
import 'package:suvenir/account/user_stats.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/image.dart';
import 'package:suvenir/libraries/saved_data.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:suvenir/libraries/styles.dart';
import 'package:suvenir/settings.dart';

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
  int totalAssetOnDevice = 0;  
  
  bool readyToGo = false;
  int _correntPage = 0;
  late PageController _pc;

  void _loadAssets() async {
    
    /// First we restore the last page in the page controller
    _pc = PageController(initialPage: _correntPage);
    
    setState(() {
      readyToGo = false;
    });

      List<Future<void>> tasks = [];

      /// Clear old data
      trashedAssets.clear();
      daysLeft.clear();

      /// Get all data
      tasks.add(PhotoManager.getAssetCount().then( (count) => totalAssetOnDevice = count));
      tasks.add(SbroImage.getAllAssesInDatabase(likeAssetsDb).then( (out) { likedAssets = out; }));
      tasks.add(SbroImage.getAssetsTrashedDate().then( (trashDatesMap) { 

        /// sort by days left
        trashDatesMap.sort( (a, b) => a.values.first.compareTo(b.values.first));

        /// Here we separete the map in the two arrays. Use first because there is only one K and one V
        for (var map in trashDatesMap) {
          trashedAssets.add(map.keys.first);
          daysLeft.add(map.values.first);
        }
       }));
      
      /// Load space saved
      tasks.add(SavedData.instance.getSavedSpace().then( (out) { spaceSaved = out; }));

      await Future.wait(tasks);

    setState(() {
      readyToGo = true;
    });
  }

  @override 
  void initState(){
    _loadAssets();
    //_pc = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        foregroundColor: kContrColor,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Account",
              style: kH2Style,
            ),
            IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Settings()));
            },),
          ],
        ),
      ),
      body: Column(
        children: [          
            
          Padding(
            padding: const EdgeInsets.all(kDefPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /// GOTO statistics
                PageSelector(pc: _pc, correntPage: _correntPage, pageIndex: 0, 
                  iconOnPage: Icons.analytics, iconNotOnPage: Icons.analytics_outlined,),
                /// GOTO like grid view
                PageSelector(pc: _pc, correntPage: _correntPage, pageIndex: 1, 
                  iconOnPage: Icons.favorite, iconNotOnPage: Icons.favorite_outline,),
                /// GOTO trash grid view
                PageSelector(pc: _pc, correntPage: _correntPage, pageIndex: 2,
                  iconOnPage: Icons.delete, iconNotOnPage: Icons.delete_outline,),
              ],
            ),
          ),
      
          const Padding(
            padding: EdgeInsets.all(kDefPadding),
            child: Divider(
              color: kContrColor,
            ),
          ),
            
          readyToGo ?
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(kDefPadding),
                child: PageView(
                  controller: _pc,
                  onPageChanged: (value) {
                    setState(() {
                      _correntPage = value;
                    });
                  },
                  children: [
                      /// UserStatsBox
                      Padding(
                        padding: const EdgeInsets.only(left: kDefPadding, right: kDefPadding, bottom: kDefPadding),
                        child: UserStatsBox(
                          originalAssetsLen: totalAssetOnDevice, 
                          likedAssetsLen: likedAssets.length, 
                          trashedAssetsLen: trashedAssets.length,
                          spaceSaved: spaceSaved,
                        ),
                      ),
                    
                    /// Liked medias
                    LikedGrid(assetsList: likedAssets, reloadAccount: (){
                      _loadAssets();
                    },),
                
                    /// Trash medias
                    TrashedGrid(assetsList: trashedAssets, daysLeft: daysLeft, reloadAccount: (){
                      _loadAssets();
                    }),
                    
                  ],
                ),
              ),
            ) 
            : 
            const Center(child: SizedBox(child: Center(child: CircularProgressIndicator()))),
        ]
      )
    );
  }
}

class PageSelector extends StatelessWidget {
  const PageSelector({
    super.key,
    required this.pc, 
    required this.correntPage, 
    required this.pageIndex, 
    required this.iconOnPage, 
    required this.iconNotOnPage, 
  });

  /// Controller of the page to scroll
  final PageController pc;
  /// Corrent page
  final int correntPage;
  /// Destination page on click
  final int pageIndex;
  /// Icons
  final IconData iconOnPage;
  final IconData iconNotOnPage;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: (){
        pc.jumpToPage(pageIndex);
      }, 
      icon: Icon(
        (correntPage == pageIndex) ? iconOnPage : iconNotOnPage,
      ), 
      style: ButtonStyle(
        iconColor: const WidgetStatePropertyAll(kIconColor),
        iconSize: const WidgetStatePropertyAll(kIconSize),
        backgroundColor: const WidgetStatePropertyAll(kPrimaryColor),
        minimumSize: WidgetStatePropertyAll(Size(getWidth(context) * 0.25, 40))
      ),
    );
  }
}


