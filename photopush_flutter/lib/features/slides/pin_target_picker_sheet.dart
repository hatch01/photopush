import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'slide_repository.dart';
import '../../l10n/app_localizations.dart';

class PinTargetPickerSheet extends ConsumerWidget {
  final UuidValue albumId;
  final UuidValue currentSlideId;

  const PinTargetPickerSheet({
    super.key,
    required this.albumId,
    required this.currentSlideId,
  });

  static Future<UuidValue?> show(
    BuildContext context, {
    required UuidValue albumId,
    required UuidValue currentSlideId,
  }) {
    return showModalBottomSheet<UuidValue?>(
      context: context,
      builder: (context) => PinTargetPickerSheet(
        albumId: albumId,
        currentSlideId: currentSlideId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final slidesAsync = ref.watch(albumSlidesProvider(albumId));

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.pinLinkTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: slidesAsync.when(
              data: (slides) {
                // RF-48: exclude current slide
                final availableSlides = slides
                    .where((s) => s.id != currentSlideId)
                    .toList();

                if (availableSlides.isEmpty) {
                  return Center(child: Text(l10n.noOtherSlides));
                }

                return ListView.builder(
                  itemCount: availableSlides.length,
                  itemBuilder: (context, index) {
                    final slide = availableSlides[index];
                    return ListTile(
                      leading: Text(
                        '${index + 1}',
                      ), // Should be global index, but list index is ok for now
                      title: Text(
                        slide.title.isEmpty ? l10n.untitledSlide : slide.title,
                      ),
                      onTap: () => Navigator.of(context).pop(slide.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
