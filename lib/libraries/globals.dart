import 'package:flutter/material.dart';
import 'package:gallery_tok/db/liked_db.dart';
import 'package:gallery_tok/db/trash_db.dart';
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

const Color kBackgroundColor = Color(0xFF040F0F);
const Color kPrimaryColor = Colors.deepPurple;
const Color kSecondaryColor = Colors.amber;
const Color kThirdColor = Color(0xFF2D3A3A);
const Color kContrColor = Color(0xFFFCFFFC);

// Icons
const double kIconSize = 25.0;
const Color kIconColor = kContrColor;

List<AssetEntity?> originalAssets = [];
late final int mainFeedHash;
int? corrIndx;

int trashDays = 15;

bool initializeApp = true;
bool deleteImageForReal = false;

LikeDatabase likeAssetsDb = LikeDatabase(tableName: 'like');
TrashDatabase trashAssetsDb = TrashDatabase(tableName: 'trash');

double getWidth(context) {
  return MediaQuery.sizeOf(context).width;
}

double getHeight(context) {
  return MediaQuery.sizeOf(context).height;
}

String getCorrDate() {
  DateTime now = DateTime.now();
  return now.toString().split(' ').first;
}

int dateDistance(String d1, String d2){
  DateTime dt1 = DateTime.parse(d1);
  DateTime dt2 = DateTime.parse(d2);
  return dt1.difference(dt2).abs().inDays;
}

const double oneThousand = 1000;
const double oneMillion = 1000000;
String shortNumber(int n){
  if(n < 100*oneThousand){
    return "$n";
  }
  else if(n < oneMillion){
    int x = (n / oneThousand).truncate();
    return "$x K";
  }
  else{
    int x = (n / oneMillion).truncate();
    return "$x M";
  }
}