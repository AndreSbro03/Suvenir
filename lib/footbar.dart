import 'package:flutter/material.dart';


class Footbar extends StatefulWidget {
  const Footbar({super.key, required this.deleteMedia});
  static const iconSize = 25.0;
  static const fbHight = 60.0;
  static const iconColor = Colors.white;

  final Function deleteMedia;

  @override
  State<Footbar> createState() => _FootbarState();
}

class _FootbarState extends State<Footbar> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
            alignment: FractionalOffset.bottomCenter,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: Footbar.fbHight,
              color: const Color.fromARGB(255, 56, 56, 56),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_outline, size: Footbar.iconSize, color: Footbar.iconColor,), 
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_outline, size: Footbar.iconSize, color: Footbar.iconColor,), 
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: Footbar.iconSize, color: Footbar.iconColor,), 
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: Footbar.iconSize, color: Footbar.iconColor,), 
                    onPressed: () {
                     widget.deleteMedia();
                    },
                    ),
                ],
              ),
            ),
        ),
      ],
    );
  }
}

