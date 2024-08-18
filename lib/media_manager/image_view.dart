import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_tok/home_page/media_info.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.image});

  final AssetEntity image;

  @override
  Widget build(BuildContext context) {
    final Future<File?> imageFile = image.file;
    return Stack(
        children: [
        FutureBuilder<File>(
          future: imageFile.then((value) => value!), 
          builder: (_, snapshot) {
            final file = snapshot.data;
            if (file == null) return Container();
            return PhotoView(
              imageProvider: FileImage(file),
            );
          } 
        ),
        MediaInfo(media: image)
        ]
      );
    }
}
