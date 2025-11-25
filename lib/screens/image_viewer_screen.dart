import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String? title;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: title != null
            ? Text(
                title!,
                style: const TextStyle(color: Colors.white),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Đóng',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.imageOff,
                      color: Colors.white70,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Không thể tải ảnh',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

