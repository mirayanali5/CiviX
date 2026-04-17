import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final ImageProvider imageProvider;

  const FullScreenImageViewer({
    super.key,
    required this.imageProvider,
  });

  static void open(BuildContext context, ImageProvider imageProvider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(imageProvider: imageProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image(
            image: imageProvider,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.image_not_supported,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
