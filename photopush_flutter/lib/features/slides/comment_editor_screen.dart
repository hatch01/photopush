import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_limits.dart';
import 'slide_repository.dart';

class CommentEditorScreen extends ConsumerStatefulWidget {
  final Album album;
  final Slide? slide;
  final String orderKey;

  const CommentEditorScreen({
    super.key,
    required this.album,
    this.slide,
    required this.orderKey,
  });

  @override
  ConsumerState<CommentEditorScreen> createState() => _CommentEditorScreenState();
}

class _CommentEditorScreenState extends ConsumerState<CommentEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.slide?.title ?? '');
    _commentController = TextEditingController(text: widget.slide?.commentText ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final comment = _commentController.text.trim();
    final repo = ref.read(slideRepositoryProvider);

    if (widget.slide == null) {
      await repo.createCommentSlide(widget.album.id, comment, title, widget.orderKey);
    } else {
      await repo.updateComment(widget.slide!.id, comment, title);
    }
    
    ref.invalidate(albumSlidesProvider(widget.album.id));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          maxLength: AppLimits.maxSlideTitleLength,
          decoration: InputDecoration(
            hintText: l10n.slideTitleHint,
            border: InputBorder.none,
            counterText: '',
          ),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _commentController,
          autofocus: true,
          maxLength: AppLimits.maxCommentLength,
          maxLines: null,
          expands: true,
          decoration: InputDecoration(
            hintText: l10n.commentHint,
            border: InputBorder.none,
          ),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}