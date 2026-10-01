import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

enum SlideChoice { photo, comment }

class AddSlideSheet extends StatelessWidget {
  const AddSlideSheet({super.key});

  static Future<SlideChoice?> show(BuildContext context) {
    return showModalBottomSheet<SlideChoice>(
      context: context,
      builder: (context) => const AddSlideSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text(l10n.addPhotoSlide),
            onTap: () => Navigator.of(context).pop(SlideChoice.photo),
          ),
          ListTile(
            leading: const Icon(Icons.notes),
            title: Text(l10n.addCommentSlide),
            onTap: () => Navigator.of(context).pop(SlideChoice.comment),
          ),
        ],
      ),
    );
  }
}