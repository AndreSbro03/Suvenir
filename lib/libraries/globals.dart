import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
//import 'package:photo_manager/photo_manager.dart';

const String appName = "SbroApp";
const TextStyle kTitleStyle = TextStyle( 
  fontWeight: FontWeight.bold, color: kContrColor, fontSize: 30,);

const TextStyle kSubTitleStyle = TextStyle( 
  fontWeight: FontWeight.bold, color: kContrColor, fontSize: 25,);

const TextStyle kNormalStyle = TextStyle( 
  fontWeight: FontWeight.normal, color: kContrColor, fontSize: 15,);

const Color kBackgroundColor = Color(0xFF040F0F);
const Color kPrimaryColor = Colors.deepPurple;
const Color kSecondaryColor = Colors.amber;
const Color kThirdColor = Color(0xFF2D3A3A);
const Color kContrColor = Color(0xFFFCFFFC);

// Icons
const double kIconSize = 25.0;
const Color kIconColor = kContrColor;

List<AssetEntity?> originalAssets = [];
List<AssetEntity?> assets = [];
int? corrIndx;

bool initializeApp = true;

PageController feedController = PageController();
VideoPlayerController? vpController;

bool deleteImageForReal = false;

/*
bool immersive = true;
List<String> likedIds = [];
List<String> trashIds = [];
*/

double getWidth(context) {
  return MediaQuery.sizeOf(context).width;
}

double getHeight(context) {
  return MediaQuery.sizeOf(context).height;
}

class Wrapper<T> {
  T value;
  Wrapper(this.value);
}