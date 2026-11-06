import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late PageController _pageController;

  bool _isImmersive = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? AlbumDetailController(initialAlbum: widget.album);

    final initialPage = _controller.hasSlides
        ? 1000 * _controller.slides.length + _controller.currentIndex
        : 0;
    _pageController = PageController(initialPage: initialPage);

    _controller.addListener(_onControllerStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _pageController.dispose();
    if (_isImmersive) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
    super.dispose();
  }

  void _onControllerStateChanged() {
    if (!mounted) return;
    final currentRealIndex = _pageController.hasClients
        ? _pageController.page?.round()
        : 0;
    if (currentRealIndex != null && _controller.hasSlides) {
      final normalizedIndex = currentRealIndex % _controller.slides.length;
      if (normalizedIndex != _controller.currentIndex) {
        final offset = _controller.currentIndex - normalizedIndex;
        _pageController.jumpToPage(currentRealIndex + offset);
      }
    }
  }

  void _onPageChanged(int index) {
    if (!_controller.hasSlides) return;
    final normalizedIndex = index % _controller.slides.length;
    if (_controller.currentIndex != normalizedIndex) {
      _controller.goToSlide(normalizedIndex);
    }
  }

  void _toggleImmersiveMode() {
    setState(() {
      _isImmersive = !_isImmersive;
      if (_isImmersive) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
      }
    });
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
          backgroundColor: Colors.black,
          appBar: _isImmersive
              ? null
              : AppBar(
                  title: InkWell(
                    onTap: hasSlides ? _handleEditTitle : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide != null
                                ? slide.title
                                : _controller.album.name,
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
                    if (hasSlides)
                      IconButton(
                        icon: const Icon(Icons.fullscreen),
                        tooltip: 'Plein écran',
                        onPressed: _toggleImmersiveMode,
                      ),
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
          body: hasSlides
              ? Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        final normalizedIndex =
                            index % _controller.slides.length;
                        final currentSlide =
                            _controller.slides[normalizedIndex];
                        return _buildSlideBody(currentSlide);
                      },
                    ),

                    // Floating Back Button for Pin Link History
                    if (_controller.canGoBack && !_isImmersive)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          heroTag: 'history_back',
                          backgroundColor: colorScheme.primaryContainer,
                          onPressed: () {
                            _controller.goBackInHistory();
                          },
                          tooltip: 'Retour',
                          child: Icon(
                            Icons.keyboard_return_rounded,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                  ],
                )
              : _buildEmptyAlbumBody(),
          bottomNavigationBar: (hasSlides && !_isImmersive)
              ? _buildBottomBar()
              : null,
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
      isImmersive: _isImmersive,
      onToggleComment: _controller.toggleCommentView,
      onTapBackground: _toggleImmersiveMode,
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
                  ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
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
                  ? () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
