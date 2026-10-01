import 'package:flutter/material.dart';
import 'package:photopush_client/photopush_client.dart';

class CommentSlideViewer extends StatelessWidget {
  final Slide slide;
  final VoidCallback onTap;

  const CommentSlideViewer({
    super.key,
    required this.slide,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor, // Ensure background catches taps
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(32.0),
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