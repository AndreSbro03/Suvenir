import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:gallery_tok/settings.dart';

class SbroAppBar extends StatelessWidget {
  const SbroAppBar({
    super.key, 
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Title
            const Text(
              appName,
              style: kTitleStyle,
            ),

            /// Settings Button
            IconButton(
              onPressed: () {
                /// If a video is going we stop it before going to the settings
                if(vpController != null) vpController!.pause();

                // TODO: notify the feed page that the video is being paused so it can show the play icon

                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Settings(
                    
                  ))
                );
              }, 
              icon: const Icon(Icons.settings_outlined, size: kIconSize, color: kIconColor),
              )
          ],
        ),
      ),
    );
  }
}