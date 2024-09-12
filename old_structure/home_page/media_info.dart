import 'package:flutter/material.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaInfo extends StatelessWidget {
  const MediaInfo({
    super.key, required this.media,
  });

  final AssetEntity media;
  static const double height = 0.09;
  static const double width = 0.90;

  @override
  Widget build(BuildContext context) {

    final double _height = height * getHeight(context);
    final double _width = width * getWidth(context);
    final DateTime mDt = media.modifiedDateTime;

    if(immersive) return const SizedBox();

    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        color: const Color(0x5F000000),
        height: _height,
        width: _width,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Don't know why but modifiedDateTime report the correct media time.
              //infoText(text: DateTime.fromMillisecondsSinceEpoch(media.createDateSecond! * 1000).toString()),
              infoText(text: "${mDt.day}/${mDt.month}/${mDt.year}"),
              //infoText(text: media.title.toString()),
              //TODO: aggiungere la posizione se disponibile.
              infoText(text: media.relativePath.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Text infoText({required String text}) {
    return Text(
      text, 
      maxLines: 1,
      style: 
        const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 15,
          ),);
  }
}