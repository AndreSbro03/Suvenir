import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

const Color backgroundColor = Color(0xFF040F0F);
//const Color secondaryColor = Color(0xFF383838);
const Color primaryColor = Color(0xFF248232);
const Color secondaryColor = Color(0xFF2BA84A);
const Color thirdColor = Color(0xFF2D3A3A);
const Color contrColor = Color(0xFFFCFFFC);

bool immersive = true;
List<AssetEntity> assets = [];
int? corrIndx;
List<String> likedIds = [];
List<String> trashIds = [];

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