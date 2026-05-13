import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'crop_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Please log in to upload images.')),
			);
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
					fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
				);
				imagePaths.add(path);
			}

			// Try to insert a posts row with caption metadata. If the table doesn't exist
			// this will fail and be caught — upload still succeeds.
			final caption = _captionController.text.trim();
						try {
							final inserted = await Supabase.instance.client.from('post').insert({
								'storage_key': postKey,
								'user_id': user.id,
								'outfit_id': null,
								'media_url': imagePaths.isNotEmpty ? imagePaths.first : null,
								'caption': caption,
								'created_at': DateTime.fromMillisecondsSinceEpoch(now).toIso8601String(),
							}).select().maybeSingle();
							// log for debugging if insertion returned nothing
							// ignore: avoid_print
							print('Inserted post row: $inserted');
							if (inserted == null) {
								if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post metadata not saved (no DB row)')));
							}
						} catch (e) {
							// surface DB errors instead of silently ignoring
							// ignore: avoid_print
							print('Failed to insert post row: $e');
							if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save post metadata: $e')));
						}

			if (!mounted) {
				return;
			}

			Navigator.pop(context, true);
		} catch (e) {
			if (mounted) {
				ScaffoldMessenger.of(
					context,
				).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
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
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Upload Post Images')),
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
								itemCount: (_selectedBytes.isEmpty) ? 1 : (_selectedBytes.length + 1),
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
														child: Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 28),
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
																								child: const Icon(Icons.close, size: 16, color: Colors.white),
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
																									final cropped = await Navigator.of(context).push<Uint8List?>(
																										MaterialPageRoute(builder: (_) => CropPage(imageBytes: _selectedBytes[imgIndex], startCropping: true)),
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
																								child: const Icon(Icons.edit, size: 16, color: Colors.white),
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
						TextField(
							controller: _captionController,
							style: const TextStyle(color: Colors.white),
							decoration: const InputDecoration(
								hintText: 'Write a caption...',
								hintStyle: TextStyle(color: Colors.white54),
								contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
								filled: true,
								fillColor: Color(0xFF1E1E1E),
							),
						),
						const SizedBox(height: 12),
						ElevatedButton.icon(
							onPressed: _isUploading ? null : _uploadImages,
							icon: _isUploading
								? const SizedBox(
										width: 18,
										height: 18,
										child: CircularProgressIndicator(strokeWidth: 2),
									)
								: const Icon(Icons.cloud_upload_outlined),
							label: Text(_isUploading ? 'Uploading...' : 'Upload to User Posts'),
						),
					],
				),
			),
		);
	}
}
