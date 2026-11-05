import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/services.dart';

/// Controller managing the state and actions of the albums list screen.
class AlbumsController extends ChangeNotifier {
  AlbumsController({AlbumStorageService? storageService})
    : _storageService = storageService ?? AlbumStorageService();

  final AlbumStorageService _storageService;

  List<AlbumLoadResult> _allAlbums = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  /// All loaded album results (successful and corrupted).
  List<AlbumLoadResult> get allAlbums => List.unmodifiable(_allAlbums);

  /// Filtered list of albums based on search query.
  List<AlbumLoadResult> get filteredAlbums {
    if (_searchQuery.trim().isEmpty) {
      return allAlbums;
    }
    final query = _searchQuery.trim().toLowerCase();
    return _allAlbums.where((result) {
      return result.albumName.toLowerCase().contains(query);
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isEmpty => !isLoading && _allAlbums.isEmpty;

  AlbumStorageService get storageService => _storageService;

  /// Loads all albums from disk.
  Future<void> loadAlbums() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allAlbums = await _storageService.loadAllAlbums();
    } catch (e) {
      _errorMessage = 'Impossible de charger les albums : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets the search query to filter the albums list.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clears the current search query.
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Creates a new album and persists it to disk.
  Future<Album> createAlbum(String name) async {
    final sanitizedName = name.trim();
    if (!Album.isValidName(sanitizedName)) {
      throw ArgumentError.value(
        name,
        'name',
        'Le nom de l\'album est invalide.',
      );
    }

    final exists = await _storageService.albumExists(sanitizedName);
    if (exists) {
      throw StateError('Un album avec ce nom existe déjà.');
    }

    final album = Album(name: sanitizedName);
    await _storageService.saveAlbum(album);
    await loadAlbums();
    return album;
  }

  /// Renames an existing album.
  Future<Album> renameAlbum(String oldName, String newName) async {
    final updatedAlbum = await _storageService.renameAlbum(oldName, newName);
    await loadAlbums();
    return updatedAlbum;
  }

  /// Duplicates an album.
  Future<Album> duplicateAlbum(String albumName) async {
    final duplicated = await _storageService.duplicateAlbum(albumName);
    await loadAlbums();
    return duplicated;
  }

  /// Deletes an album permanently from disk.
  Future<void> deleteAlbum(String albumName) async {
    await _storageService.deleteAlbum(albumName);
    await loadAlbums();
  }

  /// Resolves the absolute path to an album's cover image if it exists.
  Future<File?> getCoverFile(Album album) async {
    if (album.coverPath != null && album.coverPath!.isNotEmpty) {
      final dir = await _storageService.getAlbumDirectory(album.name);
      final file = File('${dir.path}/${album.coverPath}');
      if (file.existsSync()) return file;
    }

    // Fallback: check cover.jpg in album directory
    final dir = await _storageService.getAlbumDirectory(album.name);
    final defaultCover = File('${dir.path}/cover.jpg');
    if (defaultCover.existsSync()) return defaultCover;

    return null;
  }
}
