import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/club_leader_service.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _titleController.text = widget.post!.title ?? '';
      _contentController.text = widget.post!.content;
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
      success = await ClubLeaderService.updateClubPost(
        postId: widget.post!.id,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        content: _contentController.text,
      );
    } else {
      // Create
      success = await ClubLeaderService.createClubPost(
        clubId: widget.clubId,
        authorId: user.id,
        content: _contentController.text,
        title: _titleController.text.isEmpty ? null : _titleController.text,
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

