import 'package:flutter/material.dart';
import 'package:suvenir/libraries/globals.dart';
import 'package:suvenir/libraries/saved_data.dart';
import 'package:suvenir/libraries/styles.dart';
import 'package:suvenir/libraries/trash.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool? moveToTrashFolder;

  void initVariables() async {
    moveToTrashFolder = await SavedData.instance.getMoveToTrashFolder();
    setState(() {});
  }

  void changeMoveToTrashFolder() {
    if(moveToTrashFolder != null){
      moveToTrashFolder = !moveToTrashFolder!;
      SavedData.instance.setMoveToTrashFolder(moveToTrashFolder!);
      setState(() {});
    }
  }

  @override
  void initState() {
    initVariables();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        foregroundColor: kContrColor,
        title: const Text("Settings", style: kH2Style,),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefPadding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Trash", style: kH2Style,),      
            const Text("Changes wont effect medias already in the trash!", style: kSmallDescriptionStyle,),
            SettingsCard(
              title: "Leave the media in the original folder", 
              description: "The media will maintain its position in the gallery. No loss of information.",
              /// if moveToTrashFolder is ready !moveToTrashFolder if not ready false
              selected: !(moveToTrashFolder??true),
              update: changeMoveToTrashFolder,
            ),
            SettingsCard(
              title: "Move the media into a different folder", 
              description: 
"""If selected, when a media is delted, the app will move the media to the ${Trash.trashPath} folder. 
The media will be recoverd to its original position when restored from the trash.
All of this operations will change the creation date of the media and it will be moved by the gallery to the top of your Recent folder.""",
              selected: moveToTrashFolder??false,
              update: changeMoveToTrashFolder,
            ),
            const Divider(color: kContrColor,),
          ],
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key, required this.title, required this.description, required this.selected, required this.update,
  });

  final String title;
  final String description;
  final bool selected;
  final Function update;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(!selected){
          update();
        }
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: kDefPadding),
          child: Container(
            width: getWidth(context),
            decoration: BoxDecoration(
              color: kPrimaryColor.withAlpha(selected ? 125 : 50),
              borderRadius: BorderRadius.circular(20),
              border: selected ? Border.all(color: kSecondaryColor, width: 3) : Border(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(kDefPadding * 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: kH3Style,),
                  Text(description, style: kSmallDescriptionStyle,)
                ],
              ),
            )),
        ),
      ),
    );
  }
}