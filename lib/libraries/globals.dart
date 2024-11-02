import 'package:flutter/material.dart';
import 'package:suvenir/db/liked_db.dart';
import 'package:suvenir/db/trash_db.dart';
import 'package:suvenir/feed/video_view.dart';
import 'package:photo_manager/photo_manager.dart';

/// TODO: tranform this file in a class for clarity
const String appName = "SbroApp";

/// K: 'nome cartella'
/// V:  Ptr ad array contenente gli ae.
Map<String, List<AssetEntity?>> folders = {};
ValueNotifier<bool> isFoldersReady = ValueNotifier<bool>(false);


/// Settings
bool initializeApp = true;
List<AssetEntity?> originalAssets = [];
late final int mainFeedHash;
int? corrIndx;
GlobalKey<VideoViewState>? lastVideoView;

int trashDays = 15;

LikeDatabase likeAssetsDb = LikeDatabase(tableName: 'like');
LikeDatabase savedAssetsDb = LikeDatabase(tableName: 'saved');
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