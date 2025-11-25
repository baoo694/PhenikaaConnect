import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../models/event.dart';
import '../services/club_leader_service.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'image_viewer_screen.dart';

class ClubLeaderPostFormSheet extends StatefulWidget {
  final ClubPost? post;
  final String clubId;

  const ClubLeaderPostFormSheet({
    super.key,
    this.post,
    required this.clubId,
  });

  @override
  State<ClubLeaderPostFormSheet> createState() => _ClubLeaderPostFormSheetState();
}

class _ClubLeaderPostFormSheetState extends State<ClubLeaderPostFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  String? _selectedImageBase64;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _titleController.text = widget.post!.title ?? '';
      _contentController.text = widget.post!.content;
      // Get existing image URL if any
      if (widget.post!.attachments.isNotEmpty) {
        final attachment = widget.post!.attachments.first;
        if (attachment != null) {
          _currentImageUrl = attachment.toString();
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung bài viết'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = context.read<AppProvider>().currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    bool success;
    if (widget.post != null) {
      // Update
      // Check if post originally had an image
      final originallyHadImage = widget.post!.attachments.isNotEmpty;
      // Check current state
      final hasImageNow = _selectedImageBase64 != null || 
                         (_currentImageUrl != null && _currentImageUrl!.isNotEmpty);
      // Image is removed if: originally had image, but now doesn't
      final imageRemoved = originallyHadImage && !hasImageNow;
      
      // Determine if we need to send imageBase64
      String? imageBase64;
      if (_selectedImageBase64 != null) {
        // Check if it's a new base64 image (not a URL)
        final selectedImage = _selectedImageBase64;
        if (selectedImage != null && 
            !selectedImage.startsWith('http') && 
            !selectedImage.startsWith('https')) {
          imageBase64 = selectedImage;
        }
      }
      
      success = await ClubLeaderService.updateClubPost(
        postId: widget.post!.id,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        content: _contentController.text,
        imageBase64: imageBase64,
        removeImage: imageRemoved,
      );
    } else {
      // Create
      success = await ClubLeaderService.createClubPost(
        clubId: widget.clubId,
        authorId: user.id,
        content: _contentController.text,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        imageBase64: _selectedImageBase64,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.post != null ? 'Đã cập nhật bài viết' : 'Đã tạo bài viết thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.post != null ? 'Có lỗi xảy ra khi cập nhật' : 'Có lỗi xảy ra khi tạo bài viết'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post != null ? 'Sửa bài viết' : 'Tạo bài viết'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(LucideIcons.check),
              onPressed: _submit,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInput(
                controller: _titleController,
                hintText: 'Tiêu đề (tùy chọn)',
                labelText: 'Tiêu đề',
                prefixIcon: LucideIcons.type,
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _contentController,
                hintText: 'Viết nội dung bài viết...',
                labelText: 'Nội dung *',
                prefixIcon: LucideIcons.edit,
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Image selection button
              Row(
                children: [
                  CustomButton(
                    text: 'Chọn ảnh',
                    type: ButtonType.ghost,
                    size: ButtonSize.small,
                    icon: LucideIcons.image,
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        withData: true,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        final bytes = result.files.first.bytes;
                        if (bytes != null) {
                          setState(() {
                            _selectedImageBase64 = base64Encode(bytes);
                            _currentImageUrl = null; // Clear existing URL when new image selected
                          });
                        }
                      }
                    },
                  ),
                  if ((_selectedImageBase64 != null || _currentImageUrl != null)) ...[
                    const SizedBox(width: 8),
                    CustomButton(
                      text: 'Xóa ảnh',
                      type: ButtonType.ghost,
                      size: ButtonSize.small,
                      icon: LucideIcons.trash2,
                      onPressed: () {
                        setState(() {
                          _selectedImageBase64 = null;
                          _currentImageUrl = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
              // Image preview
              if (_selectedImageBase64 != null || _currentImageUrl != null) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // Only allow viewing full screen if it's a URL (not base64)
                    final imageUrl = _currentImageUrl;
                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ImageViewerScreen(
                            imageUrl: imageUrl,
                            title: 'Xem ảnh',
                          ),
                        ),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _selectedImageBase64 != null && 
                           !_selectedImageBase64!.startsWith('http') &&
                           !_selectedImageBase64!.startsWith('https')
                        ? Image.memory(
                            base64Decode(_selectedImageBase64!),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : _currentImageUrl != null
                            ? Image.network(
                                _currentImageUrl!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Theme.of(context).colorScheme.surfaceVariant,
                                  alignment: Alignment.center,
                                  child: const Icon(LucideIcons.imageOff, color: Colors.grey),
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              CustomButton(
                text: widget.post != null ? 'Cập nhật' : 'Đăng bài',
                icon: LucideIcons.send,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

