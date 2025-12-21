import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> saveImageToAppDir(File imageFile) async {
  final dir = await getApplicationDocumentsDirectory();

  final toursDir = Directory(p.join(dir.path, 'tour_images'));
  if (!await toursDir.exists()) {
    await toursDir.create(recursive: true);
  }

  final fileName =
      'tour_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';

  final newPath = p.join(toursDir.path, fileName);

  final newImage = await imageFile.copy(newPath);
  return newImage.path;
}
