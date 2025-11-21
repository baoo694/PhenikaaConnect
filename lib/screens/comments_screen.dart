import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/common_widgets.dart';

class CommentsScreen extends StatefulWidget {
  final dynamic post; // expecting Post model
  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;
  List<Map<String, dynamic>> _comments = [];
  String? _replyingToCommentId;
  final Map<String, TextEditingController> _replyControllers = {};
  final Set<String> _expandedReplies = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    _replyControllers.clear();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await SupabaseService.getComments(widget.post.id);
    if (mounted) {
      setState(() {
        _comments = data;
        _loading = false;
      });
    }
  }

  int get _totalComments {
    int total = 0;
    for (final comment in _comments) {
      total += 1;
      final replies = (comment['replies'] as List?) ?? [];
      total += replies.length;
    }
    return total;
  }

  void _closeWithResult() {
    Navigator.of(context).pop(_totalComments);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final ok = await context.read<AppProvider>().createComment(
      widget.post.id,
      text,
      parentId: _replyingToCommentId,
    );
    if (ok) {
      _controller.clear();
      setState(() {
        _replyingToCommentId = null;
      });
      await _load();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi bình luận thất bại'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _sendReply(String commentId) async {
    final controller = _replyControllers[commentId];
    if (controller == null) return;
    final text = controller.text.trim();
    if (text.isEmpty) return;
    final ok = await context.read<AppProvider>().createComment(
      widget.post.id,
      text,
      parentId: commentId,
    );
    if (ok) {
      controller.clear();
      _replyControllers.remove(commentId);
      setState(() {
        _replyingToCommentId = null;
      });
      await _load();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi trả lời thất bại'), backgroundColor: Colors.red),
      );
    }
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

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final user = comment['users'];
    final commentId = comment['id'].toString();
    final replies = (comment['replies'] as List?) ?? [];
    final hasReplies = replies.isNotEmpty;
    final isExpanded = _expandedReplies.contains(commentId);
    
    if (!_replyControllers.containsKey(commentId)) {
      _replyControllers[commentId] = TextEditingController();
    }
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAvatar(
                initials: (user?['name'] ?? 'U')[0],
                radius: 16,
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
                    Text(comment['content'] ?? ''),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _replyingToCommentId = _replyingToCommentId == commentId ? null : commentId;
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
                        if (hasReplies) ...[
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
                ),
              ),
            ],
          ),
          // Reply input
          if (_replyingToCommentId == commentId) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 28), // Align with avatar
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
          // Replies
          if (hasReplies && isExpanded) ...[
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
    final user = reply['users'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomAvatar(
          initials: (user?['name'] ?? 'U')[0],
          radius: 14,
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
                    _formatTimeAgo(reply['created_at']),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(reply['content'] ?? ''),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closeWithResult();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bình luận'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _closeWithResult,
          ),
        ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final c = _comments[i];
                      return _buildCommentItem(c);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: _replyingToCommentId == null
                            ? 'Viết bình luận...'
                            : 'Viết bình luận...',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(LucideIcons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}


