import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import '../services/club_leader_service.dart';
import '../services/supabase_service.dart';

class ClubDetailScreen extends StatefulWidget {
  final Map<String, dynamic> club;

  const ClubDetailScreen({
    super.key,
    required this.club,
  });

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> with SingleTickerProviderStateMixin {
  late Map<String, dynamic> _currentClub;
  late TabController _tabController;
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _activities = [];
  bool _isLoadingPosts = false;
  bool _isLoadingActivities = false;

  @override
  void initState() {
    super.initState();
    _currentClub = Map<String, dynamic>.from(widget.club);
    _tabController = TabController(length: 2, vsync: this);
    _loadPosts();
    _loadActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    if (_currentClub['id'] == null) return;
    setState(() => _isLoadingPosts = true);
    final posts = await ClubLeaderService.fetchClubPostsForUser(_currentClub['id']);
    setState(() {
      _posts = posts;
      _isLoadingPosts = false;
    });
  }

  Future<void> _loadActivities() async {
    if (_currentClub['id'] == null) return;
    setState(() => _isLoadingActivities = true);
    print('Loading activities for club: ${_currentClub['id']}');
    final activities = await ClubLeaderService.fetchClubActivitiesForUser(_currentClub['id']);
    print('Loaded ${activities.length} activities');
    setState(() {
      _activities = activities;
      _isLoadingActivities = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            final currentClub = appProvider.clubs.firstWhere(
              (c) => c['id'] == _currentClub['id'],
              orElse: () => _currentClub,
            );
            
            if (currentClub['members_count'] != _currentClub['members_count'] ||
                currentClub['isJoined'] != _currentClub['isJoined']) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _currentClub = currentClub;
                });
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _currentClub['name'] ?? 'Tên CLB',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (_currentClub['active'] ?? true) ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (_currentClub['active'] ?? true) ? 'Hoạt động' : 'Tạm dừng',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentClub['category'] ?? 'Danh mục',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.users,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentClub['members'] ?? _currentClub['members_count'] ?? 0} thành viên',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          Consumer<AppProvider>(
            builder: (context, appProvider, child) {
              if (_currentClub['isJoined'] == true) {
                return IconButton(
                  icon: const Icon(LucideIcons.userMinus),
                  tooltip: 'Rời CLB',
                  onPressed: () async {
                    if (_currentClub['id'] != null) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận'),
                          content: const Text('Bạn có chắc chắn muốn rời CLB này?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Rời CLB', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        final success = await appProvider.leaveClub(_currentClub['id']);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Đã rời CLB thành công'
                                    : 'Có lỗi xảy ra khi rời CLB',
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                          if (success) {
                            await appProvider.loadClubs();
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        }
                      }
                    }
                  },
                );
              } else if (_currentClub['isPending'] == true) {
                return PopupMenuButton<String>(
                  icon: Icon(
                    LucideIcons.clock,
                    color: Colors.orange[700],
                  ),
                  tooltip: 'Đang chờ duyệt',
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(LucideIcons.x, size: 18),
                          const SizedBox(width: 8),
                          const Text('Hủy yêu cầu'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'cancel' && _currentClub['id'] != null) {
                      final success = await appProvider.cancelJoinRequest(_currentClub['id']);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Đã hủy yêu cầu tham gia CLB'
                                  : 'Có lỗi xảy ra khi hủy yêu cầu',
                            ),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                          ),
                        );
                        if (success) {
                          await appProvider.loadClubs();
                          if (mounted) {
                            setState(() {
                              _currentClub = {
                                ..._currentClub,
                                'isPending': false,
                              };
                            });
                          }
                        }
                      }
                    }
                  },
                );
              } else {
                return IconButton(
                  icon: const Icon(LucideIcons.userPlus),
                  tooltip: 'Tham gia CLB',
                  onPressed: () async {
                    if (_currentClub['id'] != null) {
                      final success = await appProvider.joinClub(_currentClub['id']);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Đã gửi yêu cầu tham gia CLB. Đang chờ admin duyệt.'
                                  : 'Tham gia thất bại. Bạn có thể đã là thành viên hoặc đã gửi yêu cầu.',
                            ),
                            backgroundColor:
                                success ? Colors.orange : Colors.red,
                          ),
                        );
                        if (success) {
                          await appProvider.loadClubs();
                          if (mounted) {
                            setState(() {
                              _currentClub = {
                                ..._currentClub,
                                'isPending': true,
                              };
                            });
                          }
                        }
                      }
                    }
                  },
                );
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _currentClub['description'] ?? 'Chưa có mô tả',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Bài viết'),
                  Tab(text: 'Hoạt động'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          _buildActivitiesTab(),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    if (_isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.fileText,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài viết nào',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(_posts[index]);
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final author = post['users'] as Map<String, dynamic>?;
    final authorName = author?['name'] ?? 'Người dùng';
    final authorAvatar = author?['avatar_url'];
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: authorAvatar != null ? NetworkImage(authorAvatar) : null,
                child: authorAvatar == null
                    ? Text(
                        authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (post['created_at'] != null)
                      Text(
                        _formatTimeAgo(post['created_at']),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (post['title'] != null && post['title'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              post['title'],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (post['content'] != null && post['content'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              post['content'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          _buildPostComments(post),
        ],
      ),
    );
  }

  Widget _buildPostComments(Map<String, dynamic> post) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ClubLeaderService.getClubPostComments(post['id']),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        final comments = snapshot.data!;
        final totalComments = comments.fold<int>(
          0,
          (sum, comment) => sum + 1 + ((comment['replies'] as List?)?.length ?? 0),
        );

        return Column(
          children: [
            if (totalComments > 0)
              InkWell(
                onTap: () => _showCommentsDialog(post, comments),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Xem $totalComments bình luận',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            _buildCommentInput(post),
          ],
        );
      },
    );
  }

  Widget _buildCommentInput(Map<String, dynamic> post) {
    final controller = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Viết bình luận...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () async {
            if (controller.text.trim().isEmpty) return;
            final success = await ClubLeaderService.createClubPostComment(
              post['id'],
              controller.text.trim(),
            );
            if (success && mounted) {
              controller.clear();
              _loadPosts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã thêm bình luận'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Có lỗi xảy ra khi thêm bình luận'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          icon: const Icon(LucideIcons.send),
        ),
      ],
    );
  }

  void _showCommentsDialog(Map<String, dynamic> post, List<Map<String, dynamic>> comments) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _ClubPostCommentsSheet(
          post: post,
          comments: comments,
          scrollController: scrollController,
          onRefresh: _loadPosts,
        ),
      ),
    );
  }

  Widget _buildActivitiesTab() {
    if (_isLoadingActivities) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.calendar,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có hoạt động nào',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActivities,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          return _buildActivityCard(_activities[index]);
        },
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final isParticipating = activity['isParticipating'] == true;
    final date = DateTime.tryParse(activity['activity_date'] ?? '');
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.calendar,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] ?? 'Hoạt động',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (activity['location'] != null && activity['location'].toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              activity['location'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (activity['description'] != null && activity['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              activity['description'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: isParticipating ? 'Không tham gia' : 'Tham gia',
              icon: isParticipating ? LucideIcons.userMinus : LucideIcons.userPlus,
              type: isParticipating ? ButtonType.outline : ButtonType.primary,
              onPressed: () async {
                final success = await ClubLeaderService.toggleActivityParticipation(
                  activity['id'],
                  !isParticipating,
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isParticipating
                            ? 'Đã hủy tham gia hoạt động'
                            : 'Đã tham gia hoạt động',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadActivities();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final diff = now.difference(dateTime);
      if (diff.inDays > 0) return '${diff.inDays} ngày trước';
      if (diff.inHours > 0) return '${diff.inHours} giờ trước';
      if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
      return 'Vừa xong';
    } catch (_) {
      return '';
    }
  }
}

// Separate widget for comments sheet
class _ClubPostCommentsSheet extends StatefulWidget {
  final Map<String, dynamic> post;
  final List<Map<String, dynamic>> comments;
  final ScrollController scrollController;
  final VoidCallback onRefresh;

  const _ClubPostCommentsSheet({
    required this.post,
    required this.comments,
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  State<_ClubPostCommentsSheet> createState() => _ClubPostCommentsSheetState();
}

class _ClubPostCommentsSheetState extends State<_ClubPostCommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, TextEditingController> _editControllers = {};
  final Map<String, TextEditingController> _replyControllers = {};
  final Set<String> _expandedReplies = {};
  String? _replyingToCommentId;
  String? _editingCommentId;
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.comments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    for (var controller in _editControllers.values) {
      controller.dispose();
    }
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadComments() async {
    final comments = await ClubLeaderService.getClubPostComments(widget.post['id']);
    if (mounted) {
      setState(() {
        _comments = comments;
      });
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final success = await ClubLeaderService.createClubPostComment(
      widget.post['id'],
      _commentController.text.trim(),
    );
    if (success && mounted) {
      _commentController.clear();
      await _loadComments();
      widget.onRefresh();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi thêm bình luận'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendReply(String commentId) async {
    final controller = _replyControllers[commentId];
    if (controller == null || controller.text.trim().isEmpty) return;
    final success = await ClubLeaderService.createClubPostComment(
      widget.post['id'],
      controller.text.trim(),
      parentId: commentId,
    );
    if (success && mounted) {
      controller.clear();
      _replyControllers.remove(commentId);
      setState(() {
        _replyingToCommentId = null;
      });
      await _loadComments();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi thêm phản hồi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateComment(String commentId, String content) async {
    final success = await ClubLeaderService.updateClubPostComment(commentId, content);
    if (success && mounted) {
      setState(() {
        _editingCommentId = null;
      });
      _editControllers.remove(commentId)?.dispose();
      await _loadComments();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Có lỗi xảy ra khi cập nhật bình luận'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa bình luận này?'),
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
    if (confirm == true) {
      final success = await ClubLeaderService.deleteClubPostComment(commentId);
      if (success && mounted) {
        await _loadComments();
        widget.onRefresh();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi xóa bình luận'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final user = comment['users'] as Map<String, dynamic>?;
    final commentId = comment['id'].toString();
    final isOwner = comment['isOwner'] == true;
    final replies = (comment['replies'] as List?) ?? [];
    final isExpanded = _expandedReplies.contains(commentId);
    final isEditing = _editingCommentId == commentId;

    if (!_replyControllers.containsKey(commentId)) {
      _replyControllers[commentId] = TextEditingController();
    }
    if (!_editControllers.containsKey(commentId)) {
      _editControllers[commentId] = TextEditingController(text: comment['content'] ?? '');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: user?['avatar_url'] != null
                    ? NetworkImage(user!['avatar_url'])
                    : null,
                child: user?['avatar_url'] == null
                    ? Text(
                        (user?['name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user?['name'] ?? 'Người dùng',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimeAgo(comment['created_at']),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (isEditing)
                      TextField(
                        controller: _editControllers[commentId],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                        maxLines: 3,
                      )
                    else
                      Text(comment['content'] ?? ''),
                    if (isEditing) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _editingCommentId = null;
                              });
                            },
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => _updateComment(
                              commentId,
                              _editControllers[commentId]!.text,
                            ),
                            child: const Text('Lưu'),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _replyingToCommentId =
                                    _replyingToCommentId == commentId ? null : commentId;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _replyingToCommentId == commentId ? 'Hủy' : 'Trả lời',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          if (isOwner) ...[
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _editingCommentId = commentId;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sửa',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () => _deleteComment(commentId),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Xóa',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                          if (replies.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expandedReplies.remove(commentId);
                                  } else {
                                    _expandedReplies.add(commentId);
                                  }
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                isExpanded ? 'Ẩn phản hồi' : 'Xem ${replies.length} phản hồi',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_replyingToCommentId == commentId) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 28),
                Expanded(
                  child: TextField(
                    controller: _replyControllers[commentId],
                    decoration: InputDecoration(
                      hintText: 'Viết phản hồi...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendReply(commentId),
                  icon: const Icon(LucideIcons.send, size: 20),
                ),
              ],
            ),
          ],
          if (replies.isNotEmpty && isExpanded) ...[
            const SizedBox(height: 12),
            ...replies.map((reply) => Padding(
              padding: const EdgeInsets.only(left: 28, top: 8),
              child: _buildReplyItem(reply),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildReplyItem(Map<String, dynamic> reply) {
    final user = reply['users'] as Map<String, dynamic>?;
    final replyId = reply['id'].toString();
    final isOwner = reply['isOwner'] == true;
    final isEditing = _editingCommentId == replyId;

    if (!_editControllers.containsKey(replyId)) {
      _editControllers[replyId] = TextEditingController(text: reply['content'] ?? '');
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: user?['avatar_url'] != null
                ? NetworkImage(user!['avatar_url'])
                : null,
            child: user?['avatar_url'] == null
                ? Text(
                    (user?['name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user?['name'] ?? 'Người dùng',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(reply['created_at']),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (isEditing)
                  TextField(
                    controller: _editControllers[replyId],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    maxLines: 2,
                  )
                else
                  Text(
                    reply['content'] ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (isEditing) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _editingCommentId = null;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Hủy', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _updateComment(
                          replyId,
                          _editControllers[replyId]!.text,
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Lưu', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ] else if (isOwner) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _editingCommentId = replyId;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sửa',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => _deleteComment(replyId),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Xóa',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final diff = now.difference(dateTime);
      if (diff.inDays > 0) return '${diff.inDays} ngày trước';
      if (diff.inHours > 0) return '${diff.inHours} giờ trước';
      if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
      return 'Vừa xong';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Bình luận',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ..._comments.map((comment) => _buildCommentItem(comment)),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Viết bình luận...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendComment,
                icon: const Icon(LucideIcons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

