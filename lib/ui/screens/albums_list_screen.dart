import 'package:flutter/material.dart';

import '../../controllers/albums_controller.dart';
import '../../services/services.dart';
import '../widgets/album_card.dart';
import '../widgets/create_album_dialog.dart';
import '../widgets/delete_album_dialog.dart';
import '../widgets/empty_albums_view.dart';
import '../widgets/rename_album_dialog.dart';

/// The main screen displaying the list of all photo albums.
class AlbumsListScreen extends StatefulWidget {
  const AlbumsListScreen({super.key, this.controller});

  final AlbumsController? controller;

  @override
  State<AlbumsListScreen> createState() => _AlbumsListScreenState();
}

class _AlbumsListScreenState extends State<AlbumsListScreen> {
  late final AlbumsController _controller;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AlbumsController();
    if (widget.controller == null) {
      _controller.loadAlbums();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleCreateAlbum() async {
    final existingNames = _controller.allAlbums.map((a) => a.albumName).toSet();

    final String? newName = await showDialog<String>(
      context: context,
      builder: (ctx) => CreateAlbumDialog(existingAlbumNames: existingNames),
    );

    if (newName != null && mounted) {
      try {
        final album = await _controller.createAlbum(newName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Album "${album.name}" créé avec succès !'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la création : $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleRenameAlbum(String currentName) async {
    final existingNames = _controller.allAlbums.map((a) => a.albumName).toSet();

    final String? newName = await showDialog<String>(
      context: context,
      builder: (ctx) => RenameAlbumDialog(
        currentName: currentName,
        existingAlbumNames: existingNames,
      ),
    );

    if (newName != null && newName != currentName && mounted) {
      try {
        await _controller.renameAlbum(currentName, newName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Album renommé en "$newName".'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du renommage : $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDuplicateAlbum(String albumName) async {
    try {
      final copy = await _controller.duplicateAlbum(albumName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Album dupliqué : "${copy.name}".'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la duplication : $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteAlbum(String albumName) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => DeleteAlbumDialog(albumName: albumName),
    );

    if (confirmed == true && mounted) {
      try {
        await _controller.deleteAlbum(albumName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Album "$albumName" supprimé.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression : $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final albums = _controller.filteredAlbums;

        return Scaffold(
          appBar: AppBar(
            title: _isSearchOpen
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un album...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    onChanged: (val) => _controller.setSearchQuery(val),
                  )
                : const Row(
                    children: [
                      Text(
                        'PhotoPush',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
            actions: [
              if (_isSearchOpen)
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Fermer la recherche',
                  onPressed: () {
                    setState(() {
                      _isSearchOpen = false;
                      _searchController.clear();
                      _controller.clearSearch();
                    });
                  },
                )
              else ...[
                if (_controller.allAlbums.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Rechercher',
                    onPressed: () {
                      setState(() => _isSearchOpen = true);
                    },
                  ),
              ],
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _controller.loadAlbums(),
            child: _buildBody(albums),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _handleCreateAlbum,
            icon: const Icon(Icons.add),
            label: const Text('Nouvel album'),
          ),
        );
      },
    );
  }

  Widget _buildBody(List<AlbumLoadResult> albums) {
    if (_controller.isLoading && _controller.allAlbums.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null && _controller.allAlbums.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(_controller.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _controller.loadAlbums(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.allAlbums.isEmpty) {
      return EmptyAlbumsView(onCreateAlbum: _handleCreateAlbum);
    }

    if (albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Aucun album trouvé pour "${_searchController.text}"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600
            ? 1
            : constraints.maxWidth < 950
            ? 2
            : 3;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 1 ? 1.7 : 1.25,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final result = albums[index];
            return AlbumCard(
              key: ValueKey(result.albumName),
              result: result,
              controller: _controller,
              onTap: () {
                if (result is AlbumLoadSuccess) {
                  // Navigation vers la visionneuse/éditeur (US-2/US-3/US-4)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ouverture de l\'album "${result.album.name}"',
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              onRename: () => _handleRenameAlbum(result.albumName),
              onDuplicate: () => _handleDuplicateAlbum(result.albumName),
              onDelete: () => _handleDeleteAlbum(result.albumName),
            );
          },
        );
      },
    );
  }
}
