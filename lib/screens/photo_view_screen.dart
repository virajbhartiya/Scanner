import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scan/Utilities/Classes.dart';

class PhotoViewScreen extends StatefulWidget {
  final List<ImageOS> galleryItems;
  final int index;
  const PhotoViewScreen(this.galleryItems, this.index);

  @override
  _PhotoViewScreenState createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            // Swiping in right direction.
            if (details.delta.dx < 0) if (currentIndex !=
                widget.galleryItems.length - 1)
              setState(() {
                currentIndex = currentIndex + 1;
              });

            // Swiping in left direction.
            if (details.delta.dx > 0) {
              if (currentIndex != 0)
                setState(() {
                  currentIndex = currentIndex - 1;
                });
            }
          },
          child: Container(
            child: Image.file(
              File(widget.galleryItems[currentIndex].imgPath),
            ),
          ),
        ),
      ),
    );
  }
}
