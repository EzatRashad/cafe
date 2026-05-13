import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _storagePathKey = 'custom_storage_path';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// Get the currently used base path (CafeAppData parent)
  String? getStoredPath() {
    return _prefs.getString(_storagePathKey);
  }

  /// Save a new storage path
  Future<void> setStoredPath(String path) async {
    await _prefs.setString(_storagePathKey, path);
  }

  /// Get the default storage path for the platform
  Future<String> getDefaultPath() async {
    if (Platform.isWindows) {
      // For Windows, default to Documents
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    } else if (Platform.isAndroid || Platform.isIOS) {
      // For Mobile, always use Application Support for security/backups
      final dir = await getApplicationSupportDirectory();
      return dir.path;
    }
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Pick a directory using FilePicker (Windows only)
  Future<String?> pickDirectory() async {
    if (!Platform.isWindows) return await getDefaultPath();
    
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Folder for Café Egypt Data',
    );
    return selectedDirectory;
  }

  /// Create CafeAppData and backup folders in the target directory
  /// Returns the full path to the CafeAppData folder
  Future<Directory> setupDirectories(String basePath) async {
    final appDataPath = p.join(basePath, 'CafeAppData');
    final backupPath = p.join(appDataPath, 'backup');

    final appDataDir = Directory(appDataPath);
    if (!await appDataDir.exists()) {
      await appDataDir.create(recursive: true);
    }

    final backupDir = Directory(backupPath);
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return appDataDir;
  }

  /// Get the full path to the SQLite database file
  String getDatabasePath(String basePath) {
    return p.join(basePath, 'CafeAppData', 'database.sqlite');
  }

  /// Get the full path to the backup folder
  String getBackupPath(String basePath) {
    return p.join(basePath, 'CafeAppData', 'backup');
  }

  /// Validate if a path exists and contains the required folder
  bool isPathValid(String? basePath) {
    if (basePath == null || basePath.isEmpty) return false;
    final dir = Directory(p.join(basePath, 'CafeAppData'));
    return dir.existsSync();
  }
}
