import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_merger/pdf_merger.dart';
import 'pdf_viewer_screen.dart';

class MergeScreen extends StatefulWidget {
  const MergeScreen({Key key}) : super(key: key);

  @override
  _MergeScreenState createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {
  List<File> _files = [];
  List<String> filePaths = [];

  mergeFiles() async {
    MergeMultiplePDFResponse response = await PdfMerger.mergeMultiplePDF(
        paths: filePaths,
        outputDirPath: '/storage/emulated/0/scan/PDF/' + time() + '.pdf');

    if (response.status == "success") {
      debugPrint('response--- ' + response.response);
      Navigator.of(context).push(MaterialPageRoute(
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
    debugPrint('file path---' + filePaths.toString());
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
  void initState() {
    super.initState();
    setState(() {
      _files = [];
      filePaths = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(onPressed: () => mergeFiles(), child: Text('Merge'))
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
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
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
