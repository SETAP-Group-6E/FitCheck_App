// File: lib/Presentation/App/app_pages/posts/crop_page.dart
// Purpose: Image cropping UI used when preparing post images or avatars.
// Notes: Wraps a cropping library to output bytes for upload.

// Image cropper page used when the user edits an image before upload.
// - Presents a cropping UI (square/free) using `crop_your_image`.
// - Returns the cropped bytes via `Navigator.pop(cropped)`.
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:fitcheck/Presentation/App/app_state.dart' as app_state;

class CropPage extends StatefulWidget {
  const CropPage({
    super.key,
    required this.imageBytes,
    this.startCropping = false,
  });

  final Uint8List imageBytes;
  final bool startCropping;

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  CropController _controller = CropController();
  bool _isCropping = false;
  bool _showCrop = false;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _showCrop = widget.startCropping;
    // hide navbar while cropping
    app_state.navbarVisible.value = false;
  }

  @override
  void dispose() {
    // restore navbar when leaving crop page
    app_state.navbarVisible.value = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          if (!_showCrop)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () => setState(() => _showCrop = true),
            ),
          if (_showCrop) ...[
            IconButton(
              icon: const Icon(Icons.check),
              onPressed:
                  _isCropping
                      ? null
                      : () {
                        setState(() => _isCropping = true);
                        _controller.crop();
                      },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
              onPressed: () => setState(() => _showCrop = false),
            ),
          ],
        ],
      ),
      body:
          _showCrop
              ? Column(
                children: [
                  Expanded(
                    child: Crop(
                      controller: _controller,
                      image: widget.imageBytes,
                      aspectRatio: _aspectRatio,
                      onCropped: (cropped) {
                        Navigator.of(context).pop(cropped);
                      },
                      withCircleUi: false,
                      baseColor: Colors.black,
                      maskColor: Colors.black.withOpacity(0.5),
                      cornerDotBuilder:
                          (size, edgeAlignment) => const DotControl(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip: 'Square',
                          icon: const Icon(Icons.crop_square),
                          onPressed: () => setState(() => _aspectRatio = 1),
                        ),
                        IconButton(
                          tooltip: 'Free',
                          icon: const Icon(Icons.crop_free),
                          onPressed: () => setState(() => _aspectRatio = null),
                        ),
                        IconButton(
                          tooltip: 'Reset',
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            setState(() {
                              _aspectRatio = null;
                              _controller = CropController();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Center(
                child: Image.memory(widget.imageBytes, fit: BoxFit.contain),
              ),
    );
  }
}

class DotControl extends StatelessWidget {
  const DotControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
  }
}
