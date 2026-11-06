import 'dart:io';

import 'package:flutter/material.dart';

import '../../controllers/album_detail_controller.dart';
import '../../models/models.dart';

/// Screen presenting a reorderable grid of slides.
class ReorderSlidesScreen extends StatefulWidget {
  const ReorderSlidesScreen({super.key, required this.controller});

  final AlbumDetailController controller;

  @override
  State<ReorderSlidesScreen> createState() => _ReorderSlidesScreenState();
}

class _ReorderSlidesScreenState extends State<ReorderSlidesScreen> {
  late final AlbumDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    setState(() {}); // Rebuild grid when slides change
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    // The new onReorderItem parameter is already adjusted by the framework
    // We update our controller logic which expected the old unadjusted newIndex
    // Wait, the new onReorderItem provides the EXACT new index directly.
    _controller.reorderSlides(oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final slides = _controller.slides;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réorganiser les diapositives'),
        centerTitle: true,
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: slides.length,
        onReorderItem: _onReorderItem,
        itemBuilder: (context, index) {
          final slide = slides[index];
          return _SlideListTile(
            key: ValueKey(slide.id),
            slide: slide,
            index: index,
            controller: _controller,
          );
        },
      ),
    );
  }
}

class _SlideListTile extends StatelessWidget {
  const _SlideListTile({
    super.key,
    required this.slide,
    required this.index,
    required this.controller,
  });

  final Slide slide;
  final int index;
  final AlbumDetailController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 64,
            height: 64,
            child: slide.isPhoto
                ? FutureBuilder<File?>(
                    future: controller.resolveImageFile(slide.image),
                    builder: (context, snapshot) {
                      final file = snapshot.data;
                      if (file != null && file.existsSync()) {
                        return Image.file(file, fit: BoxFit.cover);
                      }
                      return Container(
                        color: colorScheme.errorContainer,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colorScheme.onErrorContainer,
                        ),
                      );
                    },
                  )
                : Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.notes_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        title: Text(
          slide.title.isNotEmpty ? slide.title : 'Diapositive ${index + 1}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            if (slide.hasComment) ...[
              const Icon(Icons.comment, size: 14),
              const SizedBox(width: 8),
            ],
            if (slide.hasPins) ...[
              const Icon(Icons.location_on, size: 14),
              const SizedBox(width: 4),
              Text('${slide.pins.length}'),
            ],
          ],
        ),
        trailing: const Icon(Icons.drag_handle_rounded),
      ),
    );
  }
}
