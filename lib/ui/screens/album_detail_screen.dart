import 'package:flutter/material.dart';

import '../../controllers/album_detail_controller.dart';
import '../../models/models.dart';
import '../widgets/add_slide_bottom_sheet.dart';
import '../widgets/comment_slide_view.dart';
import '../widgets/photo_slide_view.dart';

/// Screen for viewing and managing slides within an album.
class AlbumDetailScreen extends StatefulWidget {
  const AlbumDetailScreen({super.key, required this.album, this.controller});

  final Album album;
  final AlbumDetailController? controller;

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  late final AlbumDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? AlbumDetailController(initialAlbum: widget.album);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleAddSlide() async {
    final result = await showModalBottomSheet<AddSlideResult>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const AddSlideBottomSheet(),
    );

    if (result == null || !mounted) return;

    switch (result.action) {
      case AddSlideAction.camera:
        await _controller.addPhotoSlideFromPicker(
          fromCamera: true,
          storeInApp: result.storeInApp,
        );
        break;
      case AddSlideAction.gallery:
        await _controller.addPhotoSlideFromPicker(
          fromCamera: false,
          storeInApp: result.storeInApp,
        );
        break;
      case AddSlideAction.comment:
        await _promptAddCommentSlide();
        break;
    }
  }

  Future<void> _promptAddCommentSlide() async {
    final textController = TextEditingController();
    final titleController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle diapositive texte'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'Titre (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Commentaire ou récit',
                  hintText: 'Saisissez votre texte ici...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _controller.addCommentSlide(
        commentText: textController.text,
        customTitle: titleController.text.trim().isNotEmpty
            ? titleController.text.trim()
            : null,
      );
    }
  }

  Future<void> _handleEditTitle() async {
    final current = _controller.currentSlide;
    if (current == null) return;

    final controller = TextEditingController(text: current.title);

    final String? newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le titre'),
        content: TextField(
          controller: controller,
          maxLength: 40,
          decoration: const InputDecoration(
            labelText: 'Titre de la diapositive',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (newTitle != null && mounted) {
      await _controller.updateCurrentSlideTitle(newTitle);
    }
  }

  Future<void> _handleEditComment() async {
    final current = _controller.currentSlide;
    if (current == null) return;

    final controller = TextEditingController(text: current.comment ?? '');

    final String? newComment = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le commentaire'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Commentaire',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (newComment != null && mounted) {
      await _controller.updateCurrentSlideComment(newComment);
    }
  }

  Future<void> _handleDeleteSlide() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la diapositive'),
        content: const Text(
          'Voulez-vous vraiment supprimer cette diapositive ? Les punaises associées seront également effacées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _controller.deleteCurrentSlide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final slide = _controller.currentSlide;
        final hasSlides = _controller.hasSlides;

        return Scaffold(
          appBar: AppBar(
            title: InkWell(
              onTap: hasSlides ? _handleEditTitle : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide != null ? slide.title : _controller.album.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasSlides)
                      Text(
                        'Diapositive ${_controller.currentIndex + 1} / ${_controller.slides.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              if (slide != null && slide.isPhoto && slide.hasComment)
                IconButton(
                  icon: Icon(
                    _controller.showCommentView
                        ? Icons.photo_outlined
                        : Icons.notes_outlined,
                  ),
                  tooltip: _controller.showCommentView
                      ? 'Voir la photo'
                      : 'Voir le commentaire',
                  onPressed: _controller.toggleCommentView,
                ),
              if (slide != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Supprimer la diapositive',
                  onPressed: _handleDeleteSlide,
                ),
            ],
          ),
          body: hasSlides ? _buildSlideBody(slide!) : _buildEmptyAlbumBody(),
          bottomNavigationBar: hasSlides ? _buildBottomBar() : null,
        );
      },
    );
  }

  Widget _buildEmptyAlbumBody() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_outlined,
              size: 80,
              color: colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Album vide',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ajoutez une première photo ou une diapositive de commentaire pour donner vie à cet album.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _handleAddSlide,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Ajouter une diapositive'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideBody(Slide slide) {
    if (slide.isComment || _controller.showCommentView) {
      return CommentSlideView(slide: slide, onEditComment: _handleEditComment);
    }

    return PhotoSlideView(
      slide: slide,
      controller: _controller,
      onToggleComment: _controller.toggleCommentView,
    );
  }

  Widget _buildBottomBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              tooltip: 'Diapositive précédente',
              onPressed: _controller.slides.length > 1
                  ? _controller.previousSlide
                  : null,
            ),
            FilledButton.tonalIcon(
              onPressed: _handleAddSlide,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              tooltip: 'Diapositive suivante',
              onPressed: _controller.slides.length > 1
                  ? _controller.nextSlide
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
