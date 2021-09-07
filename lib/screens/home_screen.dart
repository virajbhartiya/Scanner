import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scan/Utilities/Classes.dart';
import 'package:scan/Utilities/database_helper.dart';
import 'package:scan/Widgets/FAB.dart';
import 'package:scan/screens/view_document.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'merge_screen.dart';

class HomeScreen extends StatefulWidget {
  static String route = "HomeScreen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DatabaseHelper database = DatabaseHelper();
  List<Map<String, dynamic>> masterData;
  List<DirectoryOS> masterDirectories = [];
  QuickActions quickActions = QuickActions();

  Future homeRefresh() async {
    await getMasterData();
  }

  void getData() {
    homeRefresh();
  }

  Future<bool> _requestPermission() async {
    if (await Permission.storage.request().isGranted &&
        await Permission.camera.request().isGranted) {
      return true;
    }
    await Permission.storage.request();
    await Permission.camera.request();
    return false;
  }

  void askPermission() async {
    await _requestPermission();
  }

  Future<List<DirectoryOS>> getMasterData() async {
    masterDirectories = [];
    masterData = await database.getMasterData();
    for (var directory in masterData) {
      var flag = false;
      for (var dir in masterDirectories) {
        if (dir.dirPath == directory['dir_path']) {
          flag = true;
        }
      }
      if (!flag) {
        masterDirectories.add(
          DirectoryOS(
            dirName: directory['dir_name'],
            dirPath: directory['dir_path'],
            created: DateTime.parse(directory['created']),
            imageCount: directory['image_count'],
            firstImgPath: directory['first_img_path'],
            lastModified: DateTime.parse(directory['last_modified']),
            newName: directory['new_name'],
          ),
        );
      }
    }
    masterDirectories = masterDirectories.reversed.toList();
    return masterDirectories;
  }

  @override
  void initState() {
    super.initState();
    askPermission();
    getMasterData();

    // Quick Action related
    quickActions.initialize((String shortcutType) {
      switch (shortcutType) {
        case 'Single Page':
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ViewDocument(
                quickScan: false,
                directoryOS: DirectoryOS(),
              ),
            ),
          ).whenComplete(() {
            homeRefresh();
          });
          break;
        case 'Multi Page':
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ViewDocument(
                quickScan: true,
                directoryOS: DirectoryOS(),
              ),
            ),
          ).whenComplete(() {
            homeRefresh();
          });
          break;
        case 'Import from Gallery':
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ViewDocument(
                quickScan: false,
                directoryOS: DirectoryOS(),
                fromGallery: true,
              ),
            ),
          ).whenComplete(() {
            homeRefresh();
          });
          break;
      }
    });
    quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(
        type: 'Single Page',
        localizedTitle: 'Single Page',
        icon: 'scan',
      ),
      ShortcutItem(
        type: 'Multi Page',
        localizedTitle: 'Multi Page',
        icon: 'scan',
      ),
      ShortcutItem(
        type: 'Import from Gallery',
        localizedTitle: 'Import from Gallery',
        icon: 'scan',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Scan',
            style: GoogleFonts.quicksand(
                fontSize: 35, color: Theme.of(context).accentColor),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).accentColor,
              ),
              child: IconButton(
                color: Colors.white,
                icon: Icon(Icons.merge_type_outlined),
                onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) => MergeScreen())),
              ),
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
        body: RefreshIndicator(
          backgroundColor: Theme.of(context).primaryColorLight,
          color: Theme.of(context).accentColor,
          onRefresh: homeRefresh,
          child: Column(
            children: <Widget>[
              Expanded(
                child: FutureBuilder(
                  future: getMasterData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return ListView.builder(
                      itemCount: masterDirectories.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ViewDocument(
                                    directoryOS: masterDirectories[index],
                                  ),
                                ),
                              ).whenComplete(() {
                                homeRefresh();
                              });
                            },
                            borderRadius: BorderRadius.circular(10.0),
                            child: ListTile(
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Directory'),
                                      content: Text(
                                          'Are you sure you want to delete this directory?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                          onPressed: () {
                                            DatabaseHelper.instance
                                                .deleteDirectory(
                                                    dirPath:
                                                        masterDirectories[index]
                                                            .dirPath);
                                            homeRefresh();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.file(
                                  File(masterDirectories[index].firstImgPath),
                                  fit: BoxFit.fill,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                              title: Text(
                                masterDirectories[index].newName ??
                                    masterDirectories[index].dirName,
                                style: GoogleFonts.quicksand(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Last Modified: ${masterDirectories[index].lastModified.day}-${masterDirectories[index].lastModified.month}-${masterDirectories[index].lastModified.year}',
                                    style: GoogleFonts.quicksand(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${masterDirectories[index].imageCount} ${(masterDirectories[index].imageCount == 1) ? 'image' : 'images'}',
                                    style: GoogleFonts.quicksand(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ViewDocument(
                                      directoryOS: masterDirectories[index],
                                    ),
                                  ),
                                ).whenComplete(() {
                                  homeRefresh();
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FAB(
          singlePageScanOnPresed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ViewDocument(
                  quickScan: false,
                  directoryOS: DirectoryOS(),
                ),
              ),
            ).whenComplete(() {
              homeRefresh();
            });
          },
          multiPageScanOnPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ViewDocument(
                  quickScan: true,
                  directoryOS: DirectoryOS(),
                ),
              ),
            ).whenComplete(() {
              homeRefresh();
            });
          },
          galleryOnPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ViewDocument(
                  quickScan: false,
                  directoryOS: DirectoryOS(),
                  fromGallery: true,
                ),
              ),
            ).whenComplete(() {
              homeRefresh();
            });
          },
        ),
      ),
    );
  }
}
