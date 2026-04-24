import 'dart:io';
import 'dart:typed_data';

/// Durable per-analysis image persistence.
///
/// Unlike picker/cropper temp files — which the OS can reclaim —
/// entries here live in the app's documents directory, keyed by the
/// owning analysis id. History entries can safely reference the
/// returned path for the lifetime of the installation.
abstract class AnalysisImageStorage {
  /// Persists [bytes] under [analysisId] and returns the absolute path
  /// where they can be read back.
  Future<String> save({
    required String analysisId,
    required Uint8List bytes,
  });

  /// Removes the stored image for [analysisId]. No-op when absent.
  Future<void> delete(String analysisId);
}

class AnalysisImageStorageImpl implements AnalysisImageStorage {
  AnalysisImageStorageImpl({required Directory baseDirectory})
    : _baseDirectory = baseDirectory;

  final Directory _baseDirectory;

  static const _subdirectory = 'analyses';
  static const _extension = '.jpg';

  Directory get _imagesDir =>
      Directory('${_baseDirectory.path}/$_subdirectory');

  File _fileFor(String analysisId) =>
      File('${_imagesDir.path}/$analysisId$_extension');

  @override
  Future<String> save({
    required String analysisId,
    required Uint8List bytes,
  }) async {
    final dir = _imagesDir;
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    final file = _fileFor(analysisId);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<void> delete(String analysisId) async {
    final file = _fileFor(analysisId);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
