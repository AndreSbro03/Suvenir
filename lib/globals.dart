import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

const Color primaryColor = Color(0xFF181818);

bool immersive = true;
List<AssetEntity> assets = [];
int? corrIndx;
List<String> likedIds = [];

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