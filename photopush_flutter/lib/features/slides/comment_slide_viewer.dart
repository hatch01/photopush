import 'package:flutter/material.dart';
import 'package:photopush_client/photopush_client.dart';

class CommentSlideViewer extends StatelessWidget {
  final Slide slide;
  final VoidCallback onTap;
  final bool isImmersive;

  const CommentSlideViewer({
    super.key,
    required this.slide,
    required this.onTap,
    this.isImmersive = false,
  });

  @override
  Widget build(BuildContext context) {
    // When the top AppBar is visible, calculate padding so the title starts cleanly below it
    final topPadding = isImmersive
        ? MediaQuery.paddingOf(context).top + 32.0
        : MediaQuery.paddingOf(context).top + kToolbarHeight + 32.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Theme.of(
          context,
        ).scaffoldBackgroundColor, // Ensure background catches taps
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.fromLTRB(32.0, topPadding, 32.0, 32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (slide.title.isNotEmpty) ...[
                Text(
                  slide.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                slide.commentText ?? '',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
