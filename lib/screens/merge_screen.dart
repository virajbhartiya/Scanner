import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_merger/pdf_merger.dart';

import 'pdf_viewer_screen.dart';

class MergeScreen extends StatefulWidget {
  static String route = "MergeScreen";
  final List<File> shareFiles;
  MergeScreen({
    Key key,
    this.shareFiles,
  }) : super(key: key);

  @override
  _MergeScreenState createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {
  List<File> _files = [];
  List<String> filePaths = [];
  bool canMerge = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _files = [];
      filePaths = [];
    });

    try {
      if (widget.shareFiles.length > 0) {
        setState(() {
          _files = widget.shareFiles;
          filePaths = _files.map((file) => file.path).toList();
          _files.length > 1 ? canMerge = true : canMerge = false;
        });
      }
    } catch (e) {}
  }

  mergeFiles() async {
    MergeMultiplePDFResponse response = await PdfMerger.mergeMultiplePDF(
        paths: filePaths,
        outputDirPath: '/storage/emulated/0/scan/PDF/' + time() + '.pdf');

    if (response.status == "success") {
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => PDFViewerScreen(response.response)));
      setState(() {
        _files = [];
        filePaths = [];
      });
    }
  }

  time() {
    DateTime now = DateTime.now();

    return (now.hour.toString() +
        "-" +
        now.minute.toString() +
        "-" +
        now.second.toString());
  }

  pickFiles() async {
    await FilePicker.getMultiFile(
        type: FileType.custom, allowedExtensions: ['pdf']).then((value) {
      setState(() {
        _files.addAll(value);
      });
    });
    filePaths = _files.map((file) => file.path).toList();
    setState(() {
      _files.length > 1 ? canMerge = true : canMerge = false;
    });
  }

  static String formatBytes(int bytes, {int decimals = 0}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            decoration: BoxDecoration(
              color: canMerge ? Theme.of(context).accentColor : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => canMerge ? mergeFiles() : null,
              icon: Icon(
                Icons.merge_type,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.01,
          ),
        ],
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
          child: ListView.builder(
            itemCount: _files.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () => Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => PDFViewerScreen(_files[index].path))),
                leading: Icon(Icons.picture_as_pdf),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _files.removeAt(index);
                    });
                  },
                ),
                subtitle: Text(formatBytes(_files[index].lengthSync())),
                title: Text(
                  _files[index].path.split('/').last,
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          pickFiles();
        },
      ),
    );
  }
}
