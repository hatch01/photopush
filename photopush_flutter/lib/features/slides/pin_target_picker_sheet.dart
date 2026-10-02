import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopush_client/photopush_client.dart';
import 'slide_repository.dart';
import 'asset_thumbnail.dart';
import '../../l10n/app_localizations.dart';

class PinTargetPickerSheet extends ConsumerStatefulWidget {
  final UuidValue albumId;
  final UuidValue currentSlideId;
  final UuidValue? initialTargetSlideId;

  const PinTargetPickerSheet({
    super.key,
    required this.albumId,
    required this.currentSlideId,
    this.initialTargetSlideId,
  });

  static Future<UuidValue?> show(
    BuildContext context, {
    required UuidValue albumId,
    required UuidValue currentSlideId,
    UuidValue? initialTargetSlideId,
  }) {
    return Navigator.of(context).push<UuidValue?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => PinTargetPickerSheet(
          albumId: albumId,
          currentSlideId: currentSlideId,
          initialTargetSlideId: initialTargetSlideId,
        ),
      ),
    );
  }

  @override
  ConsumerState<PinTargetPickerSheet> createState() =>
      _PinTargetPickerSheetState();
}

class _PinTargetPickerSheetState extends ConsumerState<PinTargetPickerSheet> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isGridView = false;
  bool _initializedPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slidesAsync = ref.watch(albumSlidesProvider(widget.albumId));

    return slidesAsync.when(
      data: (slides) {
        // Exclude current slide (RF-48) and ensure only photo slides with assets are shown
        final availableSlides = slides
            .where((s) => s.id != widget.currentSlideId && s.assetId != null)
            .toList();

        if (availableSlides.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.pinLinkTitle),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  l10n.noOtherSlides,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          );
        }

        // Initialize position on the currently linked image if present
        if (!_initializedPage && widget.initialTargetSlideId != null) {
          final targetIndex = availableSlides.indexWhere(
            (s) => s.id == widget.initialTargetSlideId,
          );
          if (targetIndex != -1) {
            _currentIndex = targetIndex;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients) {
                _pageController.jumpToPage(targetIndex);
              }
            });
          }
          _initializedPage = true;
        }

        // Clamp index in case availableSlides length changed
        final safeIndex = _currentIndex.clamp(0, availableSlides.length - 1);

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.pinLinkTitle),
                Text(
                  'Photo ${safeIndex + 1} / ${availableSlides.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(_isGridView ? Icons.view_carousel : Icons.grid_view),
                tooltip: _isGridView ? 'Plein écran' : 'Grille',
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
            ],
          ),
          body: _isGridView
              ? GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6.0,
                    mainAxisSpacing: 6.0,
                  ),
                  itemCount: availableSlides.length,
                  itemBuilder: (context, index) {
                    final slide = availableSlides[index];
                    final isSelected = index == safeIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                          _isGridView = false;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_pageController.hasClients) {
                            _pageController.jumpToPage(index);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3.0,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: AssetThumbnail(
                            assetId: slide.assetId!,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: availableSlides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = availableSlides[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: AssetThumbnail(
                            assetId: slide.assetId!,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    );
                  },
                ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: Text(l10n.ok),
                onPressed: () {
                  Navigator.of(context).pop(availableSlides[safeIndex].id);
                },
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.pinLinkTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: Text(l10n.pinLinkTitle)),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}
