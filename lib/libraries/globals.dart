import 'package:flutter/material.dart';
import 'package:suvenir/db/liked_db.dart';
import 'package:suvenir/db/trash_db.dart';
import 'package:suvenir/feed/video_view.dart';
import 'package:photo_manager/photo_manager.dart';

const String appName = "SbroApp";

const TextStyle kH1Style = TextStyle( 
  fontWeight: FontWeight.bold, 
  color: kContrColor, 
  fontFamily: "Ubuntu",
  fontSize: 30,);

const TextStyle kH2Style = TextStyle( 
  fontWeight: FontWeight.bold, 
  color: kContrColor, 
  fontFamily: "Ubuntu",
  fontSize: 25,);

const TextStyle kDescriptionStyle = TextStyle( 
  fontWeight: FontWeight.w400, 
  fontStyle: FontStyle.italic,
  color: kContrColor, 
  fontFamily: "Ubuntu",
  fontSize: 18,
  );

const TextStyle kNormalStyle = TextStyle( 
  fontWeight: FontWeight.normal, 
  color: kContrColor, 
  fontFamily: "Ubuntu",
  fontSize: 15,);

TextStyle kErrorStyle = const TextStyle( 
  fontWeight: FontWeight.normal, 
  color: Colors.redAccent, 
  fontFamily: "Ubuntu",
  fontSize: 15,);

const Color kBackgroundColor = Color(0xFF040F0F);
const Color kPrimaryColor = Colors.deepPurple;
const Color kSecondaryColor = Colors.amber;
const Color kThirdColor = Color(0xFF2D3A3A);
const Color kContrColor = Color(0xFFFCFFFC);

const double kDefPadding = 10.0;

// Icons
const double kIconSize = 25.0;
const Color kIconColor = kContrColor;

/// Settings
bool initializeApp = true;
List<AssetEntity?> originalAssets = [];
late final int mainFeedHash;
int? corrIndx;
GlobalKey<VideoViewState>? lastVideoView;

int trashDays = 15;

LikeDatabase likeAssetsDb = LikeDatabase(tableName: 'like');
TrashDatabase trashAssetsDb = TrashDatabase(tableName: 'trash');

double getWidth(context) {
  return MediaQuery.sizeOf(context).width;
}

double getHeight(context) {
  return MediaQuery.sizeOf(context).height;
}

Widget loadingWidget(context) {
  return Center(child: SizedBox(
    height: getHeight(context) * 0.5,
    width: getWidth(context) * 0.5,
    child: const Center(child: CircularProgressIndicator())));
}

String getCorrDate() {
  return removeClockFromDate(DateTime.now());
}

String removeClockFromDate(DateTime d){
  return d.toString().split(' ').first;
}

int dateDistance(String d1, String d2){
  DateTime dt1 = DateTime.parse(d1);
  DateTime dt2 = DateTime.parse(d2);
  return dt1.difference(dt2).abs().inDays;
}

const double oneThousand = 1e3;
const double oneMillion = 1e6;
const double oneBillion = 1e9;
String shortNumber(int n){
  if(n < 100*oneThousand){
    return "$n";
  }
  else if(n < oneMillion){
    int x = (n / oneThousand).truncate();
    return "$x K";
  }
  else if(n < oneBillion){
    int x = (n / oneMillion).truncate();
    return "$x M";
  }
  else{
    int x = (n / oneBillion).truncate();
    return "$x G";
  }
}