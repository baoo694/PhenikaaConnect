import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/club_leader_service.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import 'club_leader_post_form_sheet.dart';
import 'image_viewer_screen.dart';

class ClubLeaderPostsScreen extends StatefulWidget {
  final String clubId;

  const ClubLeaderPostsScreen({super.key, required this.clubId});

  @override
  State<ClubLeaderPostsScreen> createState() => _ClubLeaderPostsScreenState();
}

class _ClubLeaderPostsScreenState extends State<ClubLeaderPostsScreen> {
  bool _isLoading = true;
  List<ClubPost> _posts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final posts = await ClubLeaderService.fetchPosts(widget.clubId);
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  Future<void> _createPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubLeaderPostFormSheet(clubId: widget.clubId),
      ),
    );
    if (result == true) {
      await _loadPosts();
    }
  }

  Future<void> _editPost(ClubPost post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubLeaderPostFormSheet(post: post, clubId: widget.clubId),
      ),
    );
    if (result == true) {
      await _loadPosts();
    }
  }

  Future<void> _deletePost(ClubPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bài viết này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ClubLeaderService.deleteClubPost(post.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa bài viết thành công'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadPosts();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi xóa bài viết'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showPostDetail(ClubPost post) async {
    final comments = await ClubLeaderService.getClubPostComments(post.id);
    final totalComments = comments.fold<int>(
      0,
      (sum, comment) => sum + 1 + ((comment['replies'] as List?)?.length ?? 0),
    );
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Chi tiết bài viết',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post content card
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post.title != null && post.title!.isNotEmpty) ...[
                            Text(
                              post.title!,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            post.content,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Comments section header
                    Row(
                      children: [
                        Icon(
                          LucideIcons.messageCircle,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bình luận ($totalComments)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Comments list
                    if (comments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.messageCircle,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có bình luận nào',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...comments.map((comment) {
                        final replies = (comment['replies'] as List?) ?? [];
                        return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  child: Text(
                                    (comment['author_name'] ?? 'N')[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment['author_name'] ?? 'Người dùng',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      if (comment['student_id'] != null &&
                                          comment['student_id'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'MSSV: ${comment['student_id']}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        comment['content'] ?? '',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              height: 1.4,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (replies.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Column(
                                children: replies
                                    .map(
                                      (reply) => _buildReplyTile(context, reply),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyTile(BuildContext context, Map<String, dynamic> reply) {
    return Container(
      margin: const EdgeInsets.only(left: 40, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Text(
              (reply['author_name'] ?? 'N')[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reply['author_name'] ?? 'Người dùng',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (reply['student_id'] != null && reply['student_id'].toString().isNotEmpty)
                  Text(
                    'MSSV: ${reply['student_id']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                const SizedBox(height: 6),
                Text(
                  reply['content'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<ClubPost> get _filteredPosts {
    if (_searchQuery.isEmpty) return _posts;
    return _posts.where((p) {
      return (p.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          p.content.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar and plus button in one row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm bài viết...',
                      prefixIcon: const Icon(LucideIcons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(LucideIcons.plus, color: Colors.white),
                    tooltip: 'Tạo bài viết mới',
                    onPressed: _createPost,
                  ),
                ),
              ],
            ),
          ),
          // Posts list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadPosts,
                    child: _filteredPosts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.fileText, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Chưa có bài viết nào'
                                      : 'Không tìm thấy bài viết',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredPosts.length,
                            itemBuilder: (context, index) {
                              final post = _filteredPosts[index];
                              return _buildPostCard(post);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(ClubPost post) {
    final hasImage = post.attachments.isNotEmpty;
    final imageUrl = hasImage ? post.attachments.first.toString() : null;

    return InkWell(
      onTap: () => _showPostDetail(post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: post.pinned 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: post.pinned ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (post.pinned) ...[
                  const Icon(LucideIcons.pin, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.title != null && post.title!.isNotEmpty)
                        Text(
                          post.title!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    post.pinned ? LucideIcons.pin : LucideIcons.pinOff,
                    size: 18,
                  ),
                  color: post.pinned ? Colors.orange : Colors.grey,
                  tooltip: post.pinned ? 'Bỏ ghim' : 'Ghim bài viết',
                  onPressed: () async {
                    final success = await ClubLeaderService.togglePinPost(
                      post.id,
                      !post.pinned,
                    );
                    if (success) {
                      await _loadPosts();
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Có lỗi xảy ra khi thay đổi trạng thái ghim'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(LucideIcons.edit, size: 18),
                  color: Colors.blue,
                  onPressed: () => _editPost(post),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  color: Colors.red,
                  onPressed: () => _deletePost(post),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            // Image preview
            if (hasImage && imageUrl != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ImageViewerScreen(
                        imageUrl: imageUrl,
                        title: 'Ảnh bài viết',
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      alignment: Alignment.center,
                      child: const Icon(LucideIcons.imageOff, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: ClubLeaderService.getClubPostCommentsCount(post.id),
              builder: (context, snapshot) {
                final commentCount = snapshot.data ?? 0;
                return Row(
                  children: [
                    Icon(LucideIcons.messageCircle, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$commentCount bình luận',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

