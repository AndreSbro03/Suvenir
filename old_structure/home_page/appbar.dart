import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/home_page/footbar.dart';
import 'package:gallery_tok/settings.dart';
import 'package:photo_manager/photo_manager.dart';

class SbroAppBar extends StatelessWidget {
  const SbroAppBar({
    super.key, 
    required this.paths, 
    required this.isPathValid, 
    required this.applySettings
  });

  final List<AssetPathEntity> paths;
  final Wrapper<List<bool>> isPathValid;
  final Function applySettings;
  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "SbroApp",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: contrColor,
                fontSize: 30,
                ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => Settings(
                    paths: paths, 
                    isChecked: isPathValid,
                    apply: applySettings,
                  ))
                );
              }, 
              icon: const Icon(Icons.settings_outlined, size: Footbar.iconSize, color: Footbar.iconColor),
              )
          ],
        ),
      ),
    );
  }
}