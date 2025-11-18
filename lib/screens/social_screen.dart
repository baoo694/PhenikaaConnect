import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'comments_screen.dart';
import 'post_detail_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final TextEditingController _postController = TextEditingController();
  String? _selectedImageBase64;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: _buildFeedTab(),
    );
  }

  Widget _buildFeedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCreatePostCard(),
          const SizedBox(height: 16),
          _buildPostsList(),
        ],
      ),
    );
  }

  Widget _buildCreatePostCard() {
    return CustomCard(
      child: Column(
        children: [
          Row(
            children: [
              CustomAvatar(
                initials: 'Bạn',
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomInput(
                  controller: _postController,
                  hintText: 'Bạn đang nghĩ gì?',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CustomButton(
                text: 'Ảnh',
                type: ButtonType.ghost,
                size: ButtonSize.small,
                icon: LucideIcons.image,
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                  if (result != null && result.files.isNotEmpty) {
                    final bytes = result.files.first.bytes;
                    if (bytes != null) {
                      setState(() {
                        _selectedImageBase64 = base64Encode(bytes);
                      });
                    }
                  }
                },
              ),
              const SizedBox(width: 8),
              CustomButton(
                text: 'Cảm xúc',
                type: ButtonType.ghost,
                size: ButtonSize.small,
                icon: LucideIcons.smile,
                onPressed: () {},
              ),
              const Spacer(),
              CustomButton(
                text: 'Đăng bài',
                size: ButtonSize.small,
                onPressed: () async {
                  final text = _postController.text.trim();
                  if (text.isEmpty) return;
                  final appProvider = Provider.of<AppProvider>(context, listen: false);
                  final ok = await appProvider.createPost(text, imageBase64: _selectedImageBase64);
                  if (ok) {
                    _postController.clear();
                    setState(() { _selectedImageBase64 = null; });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đăng bài thành công')),);
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đăng bài thất bại'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          if (_selectedImageBase64 != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(base64Decode(_selectedImageBase64!), height: 160, fit: BoxFit.cover),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (appProvider.posts.isEmpty) {
          return const Center(
            child: Text('Chưa có bài đăng nào'),
          );
        }
        
        return Column(
          children: appProvider.posts.map((post) => _buildPostCard(post)).toList(),
        );
      },
    );
  }

  Widget _buildPostCard(dynamic post) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _openPostDetail(post),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomAvatar(
                initials: post.avatar,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${post.major} • ${post.time}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    alignment: Alignment.center,
                    child: const Icon(LucideIcons.imageOff, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Consumer<AppProvider>(
                builder: (context, appProvider, child) {
                  return GestureDetector(
                    onTap: () => appProvider.togglePostLike(post.id),
                    child: Row(
                      children: [
                        Icon(
                          post.liked ? LucideIcons.heart : LucideIcons.heart,
                          size: 20,
                          color: post.liked ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${post.likes}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (!mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CommentsScreen(post: post),
                        ),
                      );
                    },
                    child: const Icon(
                      LucideIcons.messageSquare,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${post.comments}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openPostDetail(dynamic post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
  }

}
