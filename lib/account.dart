import 'package:flutter/material.dart';
import 'package:gallery_tok/globals.dart';
import 'package:photo_manager/photo_manager.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              child: Text(
                "Account",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
            ),

            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: const Icon(Icons.favorite_outline), onPressed: () {},),
                  IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {},),
                ]
              ),
            ),
            const Divider(
              color: Colors.black,
            ),
            Expanded(
              child: PageView(
                children: [
                  // Liked
                  
                  GridView.builder(
                    itemCount: likedIds.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // number of items in each row
                      mainAxisSpacing: 8.0, // spacing between rows
                      crossAxisSpacing: 8.0, // spacing between columns
                    ),
                    itemBuilder: (_, index) {
                      return FutureBuilder(
                        future: AssetEntity.fromId(likedIds[index]).then(
                              (media) => media?.thumbnailData),
                        
                        builder: (_, AsyncSnapshot snapshot) {
                          if(snapshot.hasData) {
                            return Image.memory(snapshot.data);
                          }
                          return Center(child: SizedBox(
                            height: getHeight(context) * 0.5,
                            width: getWidth(context) * 0.5,
                            child: const CircularProgressIndicator()));
                        });
                    },
                  )
                  // Trashed
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}