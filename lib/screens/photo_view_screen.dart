import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_scanner_cropper/flutter_scanner_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scan/Utilities/Classes.dart';
import 'package:scan/Utilities/database_helper.dart';

class PhotoViewScreen extends StatefulWidget {
  final List<ImageOS> directoryImages;
  final int index;
  final String dirName;
  final Function fileEditCallback;
  final DirectoryOS directoryOS;
  final Function selectCallback;

  const PhotoViewScreen({
    this.directoryImages,
    this.index,
    this.dirName,
    this.fileEditCallback,
    this.directoryOS,
    this.selectCallback,
  });

  @override
  _PhotoViewScreenState createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  int currentIndex = 0;
  DatabaseHelper database = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dirName),
        actions: [
          IconButton(
            icon: Icon(Icons.crop),
            onPressed: () async {
              Directory cacheDir = await getTemporaryDirectory();
              String imageFilePath = await FlutterScannerCropper.openCrop(
                src: widget.directoryImages[currentIndex].imagePath,
                dest: cacheDir.path,
              );
              File image = File(imageFilePath);
              File temp = File(widget.directoryImages[currentIndex].imagePath
                      .substring(
                          0,
                          widget.directoryImages[currentIndex].imagePath
                              .lastIndexOf(".")) +
                  "c.jpg");
              File(widget.directoryImages[currentIndex].imagePath).deleteSync();
              if (image != null) {
                image.copySync(temp.path);
              }
              widget.directoryImages[currentIndex].imagePath = temp.path;
              database.updateImagePath(
                tableName: widget.dirName,
                image: widget.directoryImages[currentIndex],
              );
              if (widget.directoryImages[currentIndex].idx == 1) {
                database.updateFirstImagePath(
                  imagePath: widget.directoryImages[currentIndex].imagePath,
                  dirPath: widget.directoryOS.dirPath,
                );
              }
              widget.fileEditCallback();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            int sensitivity = 25;
            // Swiping in right direction.
            if (details.delta.dx < sensitivity &&
                currentIndex != widget.directoryImages.length - 1)
              setState(() {
                currentIndex = currentIndex + 1;
              });

            // Swiping in left direction.
            if (details.delta.dx > -sensitivity && currentIndex != 0)
              setState(() {
                currentIndex = currentIndex - 1;
              });
          },
          child: Container(
            child: Hero(
              tag: widget.directoryImages[currentIndex].imagePath,
              child: InteractiveViewer(
                minScale: 0.1,
                maxScale: 5,
                child: Image.file(
                  File(widget.directoryImages[currentIndex].imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
