import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';

getCroppedImages() async {
  List<File> imageFiles = await FilePicker.getMultiFile(
    type: FileType.image,
  );

  print(imageFiles.toString());

  return imageFiles;
}