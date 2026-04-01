import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

	Future<void> _pickImages() async {
		final files = await _picker.pickMultiImage();
		if (files.isEmpty) {
			return;
		}

		final bytes = await Future.wait(files.map((file) => file.readAsBytes()));

		if (!mounted) {
			return;
		}

		setState(() {
			_selectedImages
				..clear()
				..addAll(files);
			_selectedBytes
				..clear()
				..addAll(bytes);
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

			for (var i = 0; i < _selectedImages.length; i++) {
				final path = '${user.id}/${now}_$i.jpg';
				await bucket.uploadBinary(
					path,
					_selectedBytes[i],
					fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
				);
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
						OutlinedButton.icon(
							onPressed: _isUploading ? null : _pickImages,
							icon: const Icon(Icons.photo_library_outlined),
							label: const Text('Select Images'),
						),
						const SizedBox(height: 12),
						if (_selectedBytes.isEmpty)
							const Expanded(
								child: Center(
									child: Text(
										'No images selected',
										style: TextStyle(color: Colors.white70),
									),
								),
							)
						else
							Expanded(
								child: GridView.builder(
									gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
										crossAxisCount: 3,
										crossAxisSpacing: 8,
										mainAxisSpacing: 8,
									),
									itemCount: _selectedBytes.length,
									itemBuilder: (context, index) {
										return ClipRRect(
											borderRadius: BorderRadius.circular(8),
											child: Image.memory(
												_selectedBytes[index],
												fit: BoxFit.cover,
											),
										);
									},
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
