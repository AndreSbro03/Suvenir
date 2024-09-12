import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:gallery_tok/gallery.dart';
import 'package:gallery_tok/libraries/globals.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  initState(){
    getPermissions();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              getPermissions();
            }, 
            child: const Text("Request authorization")),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: getWidth(context) * 0.1 ),
            child: const Text(
              "Go to settings and provide multimedia and storage authorization to proceed", 
              style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
          )
        ],
      ),
    );
  }

  void getPermissions() async {
    /// Here we request the permission to use the medias. Note that on newer devices this function always return false.
    /// TODO: use the permission packet instead of PhotoManager
   
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        if (await Permission.storage.request().isGranted){
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Gallery()));
        }
      }
      else if
      (
        await Permission.photos.request().isGranted &&
        await Permission.videos.request().isGranted &&
        await Permission.manageExternalStorage.request().isGranted // Needed to delete medias
      ) 
      {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Gallery()));
      }
    }
  }
}
