// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionsTypes {
  granted,
  permanentlyDenied,
  other,
}

class SbroPermission {

  static Future<PermissionsTypes> getGalleryAccess() async {
    /// Here we request the permission to use the medias. Note that on newer devices this function always return false.
   
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        
        PermissionStatus storage = await Permission.storage.request();
        
        if ( storage.isGranted || storage.isLimited ) return PermissionsTypes.granted;
        else if ( storage.isPermanentlyDenied ) return PermissionsTypes.permanentlyDenied;
        else return PermissionsTypes.other;

      }
      else {

        PermissionStatus photos = await Permission.photos.request();
        PermissionStatus videos = await Permission.videos.request();
      
        if (( photos.isGranted || photos.isLimited ) && ( videos.isGranted || videos.isLimited ))
          return PermissionsTypes.granted;
        else if ( photos.isPermanentlyDenied  || videos.isPermanentlyDenied ) 
          return PermissionsTypes.permanentlyDenied;
        else 
          return PermissionsTypes.other;
      }
    }
    else {
      // TODO: manage ios permission
      return PermissionsTypes.other;
    }
  }

  static Future<PermissionsTypes> getStoragePermission() async {
    if (Platform.isAndroid) {

      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt <= 32) {
        return getGalleryAccess();
      }
      else {
      
        PermissionStatus manageExternalStorage = await Permission.manageExternalStorage.request();
        
        if ( manageExternalStorage.isGranted || manageExternalStorage.isLimited )
          return PermissionsTypes.granted;
        else if ( manageExternalStorage.isPermanentlyDenied ) 
          return PermissionsTypes.permanentlyDenied;
        else 
          return PermissionsTypes.other;

      }
    }
    else {
      // TODO: manage ios permission
      return PermissionsTypes.other;
    }

  }
}