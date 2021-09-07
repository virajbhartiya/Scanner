import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_scanner_cropper/flutter_scanner_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scan/Utilities/Classes.dart';
import 'package:scan/Utilities/database_helper.dart';

class GalleryScreen extends StatefulWidget {
  final List<ImageOS> directoryImages;
  final int index;
  final String dirName;
  final Function fileEditCallback;
  final DirectoryOS directoryOS;
  final Function selectCallback;

  const GalleryScreen({
    this.directoryImages,
    this.index,
    this.dirName,
    this.fileEditCallback,
    this.directoryOS,
    this.selectCallback,
  });

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int currentIndex = 0;
  DatabaseHelper database = DatabaseHelper();
  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    PageController controller = PageController(initialPage: currentIndex);
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
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    title: Text('Delete'),
                    content: Text('Do you really want to delete image?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          File(widget.directoryImages[currentIndex].imagePath)
                              .deleteSync();
                          database.deleteImage(
                            imgPath:
                                widget.directoryImages[currentIndex].imagePath,
                            tableName: widget.directoryOS.dirName,
                          );
                          database.updateImageCount(
                            tableName: widget.directoryOS.dirName,
                          );
                          try {
                            Directory(widget.directoryOS.dirPath)
                                .deleteSync(recursive: false);
                            database.deleteDirectory(
                                dirPath: widget.directoryOS.dirPath);
                            Navigator.pop(context);
                          } catch (e) {
                            widget.fileEditCallback();
                          }
                          widget.selectCallback();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 5.1,
            imageProvider:
                FileImage(File(widget.directoryImages[index].imagePath)),
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(
                tag: widget.directoryImages[index].imagePath),
          );
        },
        itemCount: widget.directoryImages.length,
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes,
            ),
          ),
        ),
        backgroundDecoration: BoxDecoration(color: Colors.white),
        pageController: controller,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
