// File: lib/Presentation/App/app_pages/posts/social.dart
// Purpose: Post creation and upload UI (social flow).
// Notes: Handles selecting images, composing captions, and publishing posts.

// Post drafting page: pick/crop images, enter caption, and upload post media.
// - Uploads images to Supabase Storage and inserts a `post` row with metadata.
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'crop_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app_style/widgets/app_toast.dart';
import '../../app_state.dart' as app_state;

class PostDraftingPage extends StatefulWidget {
  const PostDraftingPage({super.key});

  @override
  State<PostDraftingPage> createState() => _PostDraftingPageState();
}

class _PostDraftingPageState extends State<PostDraftingPage> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _selectedBytes = [];
  bool _isUploading = false;
  final TextEditingController _captionController = TextEditingController();

  Future<void> _pickImages() async {
    // Pick a single image and add it to the selection.
    // The user can press the Edit button on the image to open the crop UI.
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      _selectedImages.add(file);
      _selectedBytes.add(bytes);
    });
  }

  void _removeImageAt(int index) {
    if (index < 0 || index >= _selectedImages.length) return;
    setState(() {
      _selectedImages.removeAt(index);
      _selectedBytes.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty || _isUploading) {
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      showAppMessage(context, 'Please log in to upload images.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final bucket = Supabase.instance.client.storage.from('User Posts');
      final now = DateTime.now().millisecondsSinceEpoch;
      final postKey = '${user.id}/$now';

      // upload each image and collect paths in order
      final imagePaths = <String>[];
      for (var i = 0; i < _selectedImages.length; i++) {
        final path = '${user.id}/${now}_$i.jpg';
        await bucket.uploadBinary(
          path,
          _selectedBytes[i],
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );
        imagePaths.add(path);
      }

      // Try to insert a posts row with caption metadata. If the table doesn't exist
      // this will fail and be caught — upload still succeeds.
      final originalCaption = _captionController.text; // preserve newlines for storage
      final caption = originalCaption.trim();
      try {
        final inserted =
            await Supabase.instance.client
                .from('post')
                .insert({
                  'storage_key': postKey,
                  'user_id': user.id,
                  'outfit_id': null,
                  'media_url': imagePaths.isNotEmpty ? imagePaths.first : null,
                  'caption': caption,
                  'created_at':
                      DateTime.fromMillisecondsSinceEpoch(
                        now,
                      ).toIso8601String(),
                })
                .select()
                .maybeSingle();
        // log for debugging if insertion returned nothing
        // ignore: avoid_print
        print('Inserted post row: $inserted');
        if (inserted == null) {
          if (mounted)
            showAppMessage(context, 'Post metadata not saved (no DB row)');
        }
      } catch (e) {
        // surface DB errors instead of silently ignoring
        // ignore: avoid_print
        print('Failed to insert post row: $e');
        if (mounted)
          showAppMessage(
            context,
            'Failed to save post metadata: $e',
            error: true,
          );
      }

      // Also upload a small public caption file as a fallback for unauthenticated viewers
      try {
        if (originalCaption.isNotEmpty) {
          final captionPath = '$postKey/${"caption.txt"}';
          await bucket.uploadBinary(
            captionPath,
            utf8.encode(originalCaption),
            fileOptions: const FileOptions(
              contentType: 'text/plain; charset=utf-8',
              upsert: true,
            ),
          );
        }
      } catch (e) {
        // non-fatal; keep going
        // ignore: avoid_print
        print('Caption file upload failed: $e');
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        showAppMessage(context, 'Upload failed: $e', error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // hide global navbar while drafting a post
    app_state.navbarVisible.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Create New Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grid area: first tile is the select-images button, followed by selected images
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount:
                    (_selectedBytes.isEmpty) ? 1 : (_selectedBytes.length + 1),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // select images tile
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Material(
                        color: const Color(0xFF1E1E1E),
                        child: InkWell(
                          onTap: _isUploading ? null : _pickImages,
                          child: const Center(
                            child: Icon(
                              Icons.add_a_photo_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  final imgIndex = index - 1;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(
                          _selectedBytes[imgIndex],
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => _removeImageAt(imgIndex),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 6,
                          top: 6,
                          child: GestureDetector(
                            onTap: () async {
                              // open crop editor for this image and replace bytes
                              try {
                                final cropped = await Navigator.of(
                                  context,
                                ).push<Uint8List?>(
                                  MaterialPageRoute(
                                    settings: const RouteSettings(
                                      name: '/crop',
                                    ),
                                    builder:
                                        (_) => CropPage(
                                          imageBytes: _selectedBytes[imgIndex],
                                          startCropping: true,
                                        ),
                                  ),
                                );
                                if (cropped != null) {
                                  setState(() {
                                    _selectedBytes[imgIndex] = cropped;
                                  });
                                }
                              } catch (_) {}
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Write a caption... (press Enter for new line)',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A017),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isUploading ? null : _uploadImages,
                    child:
                        _isUploading
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(
                              Icons.cloud_upload_outlined,
                              color: Colors.white,
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // restore navbar when leaving post drafting
    app_state.navbarVisible.value = true;
    _captionController.dispose();
    super.dispose();
  }
}
