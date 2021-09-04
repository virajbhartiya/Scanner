import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

class MergeScreen extends StatefulWidget {
  const MergeScreen({Key key}) : super(key: key);

  @override
  _MergeScreenState createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {

  pickFile() async {
    List<File> files = await FilePicker.getMultiFile(
        type: FileType.custom, allowedExtensions: ['pdf']);
    debugPrint("File Path Select---" + files.toString());
    List<String> filePaths = files.map((file) => file.path).toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Merge',
          style: GoogleFonts.quicksand(
              fontSize: 35,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).accentColor),
        ),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  pickFile();
                },
                child: Text('Pick File'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
