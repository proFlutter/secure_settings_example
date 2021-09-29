import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Name: file_utils
/// Description: Utility class that helps managing files on disk
/// Created by: Pascal Robert on 29.09.2021
/// Last edited by: Pascal Robert on 29.09.2021

class FileUtils {
  static const String fileSuffixDefault = '.txt';
  static const String directorySettings = '/settings/';
  static const String fileNameSettings = 'settings';

  String applicationDirectoryPath = '';

  /// getExternalStorageDirectory <- use this for debugging on Android only
  /// getApplicationDocumentsDirectory  <- use this when publishing the app.
  Future<String> get applicationDataPath async {
    if (applicationDirectoryPath != '') {
      return applicationDirectoryPath;
    }
    final Directory? storageDirectory = await getExternalStorageDirectory();
    applicationDirectoryPath = storageDirectory == null ? '' : storageDirectory.path;
    return applicationDirectoryPath;
  }

  Future<bool> directoryExists(String directory) async {
    final String appDataPath = await applicationDataPath;
    return await Directory('$appDataPath$directory').exists();
  }

  Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }

  Future<Directory> createDirectory(String directory) async {
    final String appDataPath = await applicationDataPath;
    return await Directory('$appDataPath$directory').create(recursive: true);
  }

  Future<File> createFile(String completeFileName) async {
    return await File(completeFileName).create();
  }

  Future<Directory> getDirectory(String directory) async {
    final String appDataPath = await applicationDataPath;
    return Directory('$appDataPath$directory');
  }

  Future<Directory> getOrCreateDirectory(String dirParadigm) async {
    if (await directoryExists(dirParadigm)) {
      return await getDirectory(dirParadigm);
    }
    return await createDirectory(dirParadigm);
  }

  Future<File> getOrCreateFile(String filePath) async {
    if (await fileExists(filePath)) {
      return File(filePath);
    }
    return await createFile(filePath);
  }

  Future<File> getOrCreateFileInDirectory(String directory, String fileName) async {
    final String dirName = (await getOrCreateDirectory(directory)).path;
    return await getOrCreateFile('$dirName$fileName');
  }

  Future<void> saveSettings(List<int> settings) async {
    final File settingsFile =
        await getOrCreateFileInDirectory(directorySettings, '$fileNameSettings$fileSuffixDefault');

    settingsFile.writeAsBytes(settings);
  }

  Future<List<int>> loadSettings() async {
    final File settingsFile =
        await getOrCreateFileInDirectory(directorySettings, '$fileNameSettings$fileSuffixDefault');

    return await settingsFile.readAsBytes();
  }
}
