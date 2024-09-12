import 'package:flutter/material.dart';
import 'package:gallery_tok/feed/feed.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/libraries/image.dart';

/// Welcome to the app settings page. Here for now you can only chose what folders do you 
/// want to see in the app.
class Settings extends StatefulWidget {
  const Settings({super.key});

  static Map<String, bool> validPathsMap = {};

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {

    double rapidButtonsZoneHeight = getHeight(context) * 0.1;

    return Scaffold(
      appBar: AppBar(
        title:  const Text("Select Folders", style: kSubTitleStyle,),
        backgroundColor: kBackgroundColor,
        foregroundColor: kContrColor,
      ),
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// Fast selection buttons

            SizedBox(
              height: rapidButtonsZoneHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    
                    /// Select All button
                    GestureDetectorTextButton(
                      w: getWidth(context) * 0.3, 
                      h: getHeight(context), 
                      text: const Text("Select All", style: kNormalStyle,), 
                      color: kPrimaryColor,
                      onTap: () {
                        print("Fattooooooooooooooooooooooooooooooooo");
                        setState(() {
                          Settings.validPathsMap.forEach((K, _) {
                            Settings.validPathsMap[K] = true;
                          });
                        });
                      },
                    ), 

                    /// Deselect All button
                    GestureDetectorTextButton(
                      w: getWidth(context) * 0.3, 
                      h: getHeight(context), 
                      text: const Text("Deselect All", style: kNormalStyle,), 
                      color: kPrimaryColor,
                      onTap: () {
                        setState(() {
                          Settings.validPathsMap.forEach((K, _) {
                            Settings.validPathsMap[K] = false;
                          });
                        });
                      },
                    ), 
                
                  ],
                ),
              ),
            ),

            /// Folders list
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: ListView.builder(
                  itemCount: Settings.validPathsMap.length,
                  /*prototypeItem: ListTile(
                    title: Text(widget.paths.first.name),
                  ),*/
                  itemBuilder: (_, index) {
                    String corrPath = Settings.validPathsMap.keys.elementAt(index);
                    bool isCheck = Settings.validPathsMap[corrPath]!;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: getWidth(context) * 0.70,
                          child: Text(corrPath , style: kNormalStyle,)
                        ),                        
                        Checkbox(
                          value: isCheck, 
                          checkColor: kContrColor,
                          activeColor: kSecondaryColor,
                          onChanged: (_) {
                            setState(() {
                                Settings.validPathsMap[corrPath] = !isCheck;
                            });
                          }
                        ),                                          
                      ],
                    );
                  }
                  ),
              ),
            ),

            /// Apply button

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: GestureDetectorTextButton(
                w: getWidth(context) * 0.8,
                h: getHeight(context) * 0.07,
                text: const Text( "Apply", style: kSubTitleStyle,),
                color: kPrimaryColor,
                onTap: (){
                  /// I use Feed.modIdxUpdate * 2 so I'm sure that all the medias until the next update in the feed
                  /// are going to be valid medias. (Feed.modIdxUpdate + 1 whould be sufficent)
                  assets.clear();
                  assets.addAll(originalAssets);
                  assets.shuffle();
                  print("${assets.length} --->${originalAssets.length}");
                  SbroImage.updateAssets(0, Feed.modIdxUpdate * 2);
                  feedController.jumpToPage(0);
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GestureDetectorTextButton extends StatelessWidget {
  const GestureDetectorTextButton({
    super.key, 
    required this.w, 
    required this.h, 
    required this.text, 
    required this.color, 
    required this.onTap,
  });

  final double w;
  final double h;
  final Text text;
  final Color color; 
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
          //border: Border.all( color: Colors.amber, width: 2.0,)
        ),
        child: Center(
          child: text,
        ),
      ),
    );
  }
}