import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:scan/Utilities/Classes.dart';
import 'package:scan/Utilities/database_helper.dart';
import 'package:scan/screens/photo_view_screen.dart';

import '../Utilities/constants.dart';
import '../screens/view_document.dart';

class ImageCard extends StatefulWidget {
  final Function fileEditCallback;
  final DirectoryOS directoryOS;
  final ImageOS imageOS;
  final Function selectCallback;
  final Function imageViewerCallback;
  final List<ImageOS> directoryImages;
  final String dirName;

  const ImageCard(
      {this.fileEditCallback,
      this.directoryOS,
      this.imageOS,
      this.selectCallback,
      this.imageViewerCallback,
      this.directoryImages,
      this.dirName});

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  DatabaseHelper database = DatabaseHelper();

  selectionOnPressed() {
    setState(() {
      selectedImageIndex[widget.imageOS.idx - 1] = true;
    });
    widget.selectCallback();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        MaterialButton(
          elevation: 0,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            (enableSelect)
                ? selectionOnPressed()
                : Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => PhotoViewScreen(
                        directoryImages: widget.directoryImages,
                        index: widget.directoryImages.indexOf(widget.imageOS),
                        dirName: widget.dirName,
                        fileEditCallback: widget.fileEditCallback,
                        directoryOS: widget.directoryOS,
                        selectCallback: widget.selectCallback,
                      ),
                    ),
                  );
          },
          child: FocusedMenuHolder(
            menuWidth: size.width * 0.25,
            onPressed: () {
              (enableSelect)
                  ? selectionOnPressed()
                  : Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => PhotoViewScreen(
                          directoryImages: widget.directoryImages,
                          index: widget.directoryImages.indexOf(widget.imageOS),
                          dirName: widget.dirName,
                          fileEditCallback: widget.fileEditCallback,
                          directoryOS: widget.directoryOS,
                          selectCallback: widget.selectCallback,
                        ),
                      ),
                    );
            },
            menuItems: [
              FocusedMenuItem(
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                trailingIcon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
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
                              File(widget.imageOS.imagePath).deleteSync();
                              database.deleteImage(
                                imgPath: widget.imageOS.imagePath,
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
                backgroundColor: Colors.white,
              ),
            ],
            child: Hero(
              tag: widget.imageOS.imagePath,
              child: Image.file(File(widget.imageOS.imagePath),
                  height: size.height * 0.25,
                  width: size.width * 0.395,
                  fit: BoxFit.cover),
            ),
          ),
        ),
        (selectedImageIndex[widget.imageOS.idx - 1] && enableSelect)
            ? Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImageIndex[widget.imageOS.idx - 1] = false;
                    });
                    widget.selectCallback();
                  },
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                        color: secondaryColor,
                      ),
                    ),
                    color: secondaryColor.withOpacity(0.3),
                  ),
                ),
              )
            : Container(
                width: 0.001,
                height: 0.001,
              ),
        (enableReorder)
            ? Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                ),
              )
            : Container(
                width: 0.001,
                height: 0.001,
              ),
      ],
    );
  }
}
