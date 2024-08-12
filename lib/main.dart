import 'package:flutter/material.dart';
import 'package:gallery_tok/gallery.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gallerizz'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  initState(){
    getImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: Center(
        child: ElevatedButton(onPressed: () => getImages(), child: const Text("Open Gallery")),
      ),
    );
  }

  void getImages() {
    PhotoManager.requestPermissionExtend().then(
      (PermissionState state) {
        if (state.isAuth) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Gallery()));
        }
      }
    );
  }
}