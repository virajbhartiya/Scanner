class DirectoryOS {
  String dirName;
  String dirPath;
  DateTime created;
  int imageCount;
  String firstImgPath;
  DateTime lastModified;
  String newName;

  DirectoryOS({
    this.dirName,
    this.created,
    this.dirPath,
    this.firstImgPath,
    this.imageCount,
    this.lastModified,
    this.newName,
  });
}

class ImageOS {
  int idx;
  String imagePath;
  int shouldCompress;

  ImageOS({
    this.idx,
    this.imagePath,
    this.shouldCompress,
  });
}
