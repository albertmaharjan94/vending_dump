import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveUtils {
  static late final Box box;
  static late final directory;

  static Future<Box> init() async {
    directory = await getApplicationDocumentsDirectory();
    box =  await Hive.openBox("gyapu_box");
    return box;
  }
}