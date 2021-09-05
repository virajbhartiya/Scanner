import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;

  PDFViewerScreen(this.pdfPath);

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      appBar: AppBar(
        title:
            Text(widget.pdfPath.substring(widget.pdfPath.lastIndexOf('/') + 1)),
      ),
      path: widget.pdfPath,
    );
  }
}
