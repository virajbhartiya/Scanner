import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_scanner_cropper/flutter_scanner_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:scan/Utilities/Classes.dart';
import 'package:scan/Utilities/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FileOperations {
  final String appName = 'scan';
  static bool pdfStatus;
  DatabaseHelper database = DatabaseHelper();

  Future<String> getAppPath() async {
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/$appName/');

    if (await _appDocDirFolder.exists()) {
      return _appDocDirFolder.path;
    } else {
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  // CREATE PDF
  Future<bool> createPdf({selectedDirectory, fileName, images}) async {
    try {
      final output = File("${selectedDirectory.path}/$fileName.pdf");

      int i = 0;

      final doc = pw.Document();

      for (i = 0; i < images.length; i++) {
        final image = PdfImage.file(
          doc.document,
          bytes: images[i].readAsBytesSync(),
        );

        doc.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                // child: pw.Image.provider(image),
                // ignore: deprecated_member_use
                child: pw.Image(image),
              );
            },
            margin: pw.EdgeInsets.all(5.0),
          ),
        );
      }

      output.writeAsBytesSync(doc.save());
      return true;
    } catch (e) {
      return false;
    }
  }

  // ADD IMAGES
  Future<File> openCamera() async {
    File image;
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    if (picture != null) {
      image = File(picture.path);
    }
    return image;
  }

  Future<dynamic> openGallery() async {
    List<Asset> pic;
    try {
      pic = await MultiImagePicker.pickImages(maxImages: 30);
    } catch (e) {
      debugPrint(e);
    }

    List<File> imageFiles = [];

    if (pic != null) {
      for (Asset imagePath in pic) {
        imageFiles.add(
          File(
            await FlutterAbsolutePath.getAbsolutePath(imagePath.identifier),
          ),
        );
      }
    }
    return imageFiles;
  }

  Future<void> saveImage({File image, int index, String dirPath}) async {
    if (!await Directory(dirPath).exists()) {
      new Directory(dirPath).create();
      await database.createDirectory(
        directory: DirectoryOS(
          dirName: dirPath.substring(dirPath.lastIndexOf('/') + 1),
          dirPath: dirPath,
          imageCount: 0,
          created: DateTime.parse(dirPath
              .substring(dirPath.lastIndexOf('/') + 1)
              .substring(
                  dirPath.substring(dirPath.lastIndexOf('/') + 1).indexOf(' ') +
                      1)),
          newName: dirPath.substring(dirPath.lastIndexOf('/') + 1),
          lastModified: DateTime.parse(dirPath
              .substring(dirPath.lastIndexOf('/') + 1)
              .substring(
                  dirPath.substring(dirPath.lastIndexOf('/') + 1).indexOf(' ') +
                      1)),
          firstImgPath: null,
        ),
      );
    }

    /// Removed Index in image path
    File tempPic = File("$dirPath/${DateTime.now()}.jpg");
    image.copy(tempPic.path);
    database.createImage(
      image: ImageOS(
        imagePath: tempPic.path,
        idx: index,
      ),
      tableName: dirPath.substring(dirPath.lastIndexOf('/') + 1),
    );
    if (index == 1) {
      database.updateFirstImagePath(imagePath: tempPic.path, dirPath: dirPath);
    }
  }

  // SAVE TO DEVICE
  Future<Directory> pickDirectory(
      BuildContext context, selectedDirectory) async {
    Directory directory = selectedDirectory;
    try {
      if (Platform.isAndroid) {
        directory = Directory("/storage/emulated/0/");
      } else {
        directory = await getExternalStorageDirectory();
      }
    } catch (e) {
      debugPrint(e);
      directory = await getExternalStorageDirectory();
    }

    // Directory newDirectory = await DirectoryPicker.pick(
    //     allowFolderCreation: true,
    //     context: context,
    //     rootDirectory: directory,
    //     shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.all(Radius.circular(10))));

    return directory;
  }

  Future<String> download(
      {BuildContext context,
      String fileName,
      dynamic images,
      int quality}) async {
    Directory selectedDirectory;
    Directory scanDir = Directory("/storage/emulated/0/scan");
    Directory scanPdfDir = Directory("/storage/emulated/0/scan/PDF");
    int desiredQuality = 100;

    try {
      if (!scanDir.existsSync()) {
        scanDir.createSync();
        scanPdfDir.createSync();
      }
      selectedDirectory = scanPdfDir;
    } catch (e) {
      debugPrint(e);
      selectedDirectory = await pickDirectory(context, selectedDirectory);
    }

    var tempImages = [];
    String path;

    if (quality == 1) {
      desiredQuality = 60;
    } else if (quality == 2) {
      desiredQuality = 80;
    } else {
      desiredQuality = 100;
    }

    Directory cacheDir = await getTemporaryDirectory();
    for (ImageOS image in images) {
      path = await FlutterScannerCropper.compressImage(
        src: image.imagePath,
        dest: cacheDir.path,
        desiredQuality: desiredQuality,
      );
      tempImages.add(File(path));
    }
    images = tempImages;

    fileName = fileName.replaceAll('-', '');
    fileName = fileName.replaceAll('.', '');
    fileName = fileName.replaceAll(':', '');

    pdfStatus = await createPdf(
      selectedDirectory: selectedDirectory,
      fileName: fileName,
      images: images,
    );
    return (pdfStatus) ? selectedDirectory.path : null;
  }

  Future<bool> saveToAppDirectory(
      {BuildContext context, String fileName, dynamic images}) async {
    Directory selectedDirectory = await getApplicationDocumentsDirectory();
    List<ImageOS> foo = [];
    if (images.runtimeType == foo.runtimeType) {
      var tempImages = [];
      for (ImageOS image in images) {
        tempImages.add(File(image.imagePath));
      }
      images = tempImages;
    }
    pdfStatus = await createPdf(
      selectedDirectory: selectedDirectory,
      fileName: fileName,
      images: images,
    );
    return pdfStatus;
  }

  Future<void> deleteTemporaryFiles() async {
    // Delete the temporary files created by the image_picker package
    Directory appDocDir = await getExternalStorageDirectory();
    Directory cacheDir = await getTemporaryDirectory();
    String appDocPath = "${appDocDir.path}/Pictures/";
    Directory del = Directory(appDocPath);
    if (del.existsSync()) {
      del.deleteSync(recursive: true);
    }
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
    new Directory(appDocPath).create();
  }
}
