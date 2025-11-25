import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/post.dart';
import '../widgets/common_widgets.dart';
import 'comments_screen.dart';
import 'image_viewer_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Post _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  Future<void> _openComments() async {
    final updatedCount = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => CommentsScreen(post: _post),
      ),
    );
    if (updatedCount != null && updatedCount != _post.comments) {
      setState(() {
        _post = _post.copyWith(comments: updatedCount);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài viết'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostContent(context),
            const SizedBox(height: 16),
            _buildEngagementCard(context),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Xem bình luận',
              icon: LucideIcons.messageCircle,
              onPressed: _openComments,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomAvatar(
                initials: _post.avatar,
                radius: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _post.author,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${_post.major} • ${_post.time}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_post.imageUrl != null && _post.imageUrl!.isNotEmpty) ...[
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ImageViewerScreen(
                      imageUrl: _post.imageUrl!,
                      title: 'Ảnh bài viết',
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    children: [
                      Image.network(
                        _post.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          alignment: Alignment.center,
                          child: const Icon(LucideIcons.imageOff, color: Colors.grey),
                        ),
                      ),
                      // Overlay để hiển thị icon zoom khi hover/tap
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.maximize2,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            _post.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementCard(BuildContext context) {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: LucideIcons.heart,
            label: 'Lượt thích',
            value: '${_post.likes}',
            iconColor: _post.liked ? Colors.red : Colors.grey,
          ),
          _buildStatItem(
            context,
            icon: LucideIcons.messageSquare,
            label: 'Bình luận',
            value: '${_post.comments}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6),
              ),
        ),
      ],
    );
  }
}

