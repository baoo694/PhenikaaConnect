import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import '../providers/app_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/common_widgets.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailScreen({super.key, required this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  bool _loadingReplies = true;
  bool _postingReply = false;
  List<Map<String, dynamic>> _replies = [];
  bool _isSolved = false;
  bool _isOwner = false;
  RealtimeChannel? _repliesChannel;

  @override
  void initState() {
    super.initState();
    _isSolved = widget.question.solved;
    final currentUserId =
        Provider.of<AppProvider>(context, listen: false).currentUser?.id;
    _isOwner = currentUserId != null && currentUserId == widget.question.userId;
    _loadReplies();
    _subscribeToReplies();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _repliesChannel?.unsubscribe();
    _repliesChannel = null;
    super.dispose();
  }

  void _subscribeToReplies() {
    _repliesChannel = Supabase.instance.client
        .channel('question_replies_${widget.question.id}')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'question_replies',
        callback: (payload) async {
          final newRecord = payload.newRecord;
          if (newRecord != null &&
              newRecord['question_id'] == widget.question.id) {
            await _loadReplies();
          }
        },
      )
      ..subscribe();
  }

  Future<void> _loadReplies() async {
    final data = await SupabaseService.getQuestionReplies(widget.question.id);
    if (!mounted) return;
    setState(() {
      _replies = data;
      _loadingReplies = false;
    });
  }

  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() => _postingReply = true);
    final success = await context
        .read<AppProvider>()
        .createQuestionReply(widget.question.id, text);

    if (!mounted) return;

    setState(() => _postingReply = false);

    if (success) {
      _replyController.clear();
      await _loadReplies();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi bình luận')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể gửi bình luận'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAsSolution(Map<String, dynamic> reply) async {
    final replyId = reply['id'];
    if (replyId == null) return;

    setState(() => _postingReply = true);
    final success = await context
        .read<AppProvider>()
        .markQuestionSolution(widget.question.id, replyId.toString());

    if (!mounted) return;

    setState(() => _postingReply = false);

    if (success) {
      setState(() {
        _isSolved = true;
      });
      await _loadReplies();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đánh dấu câu trả lời')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể cập nhật trạng thái'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết câu hỏi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildContent(context),
            const SizedBox(height: 16),
            _buildMetaCard(context),
            const SizedBox(height: 16),
            _buildRepliesSection(context),
            const SizedBox(height: 16),
            _buildReplyComposer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomBadge(
                text: widget.question.course,
                type: BadgeType.outline,
                size: BadgeSize.small,
              ),
              const SizedBox(width: 8),
              CustomBadge(
                text: _isSolved ? 'Đã giải quyết' : 'Đang mở',
                type: _isSolved
                    ? BadgeType.success
                    : BadgeType.outline,
                size: BadgeSize.small,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.question.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.question.author} • ${widget.question.time}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.fileText,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Mô tả vấn đề',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.question.content.isNotEmpty
                ? widget.question.content
                : 'Không có mô tả chi tiết.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(BuildContext context) {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            context,
            label: 'Bình luận',
            value: '${_replies.length}',
            icon: LucideIcons.messageSquare,
          ),
          _buildStat(
            context,
            label: 'Trạng thái',
            value: _isSolved ? 'Đã giải quyết' : 'Đang mở',
            icon: _isSolved ? LucideIcons.badgeCheck : LucideIcons.helpCircle,
            iconColor: _isSolved ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildRepliesSection(BuildContext context) {
    if (_loadingReplies) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_replies.isEmpty) {
      return CustomCard(
        child: Center(
          child: Text(
            'Chưa có bình luận nào. Hãy là người đầu tiên!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bình luận (${_replies.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _replies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final reply = _replies[index];
              final user = reply['users'];
              final bool isSolution = reply['is_solution'] == true;
              final replyOwnerId = reply['user_id']?.toString();
              final canMarkSolution = _isOwner &&
                  !_isSolved &&
                  !isSolution &&
                  replyOwnerId !=
                      Provider.of<AppProvider>(context, listen: false)
                          .currentUser
                          ?.id;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAvatar(
                    initials: (user?['name'] ?? 'U')[0],
                    radius: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['name'] ?? 'Người dùng',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (isSolution) ...[
                          const SizedBox(height: 4),
                          const CustomBadge(
                            text: 'Câu trả lời hay nhất',
                            type: BadgeType.success,
                            size: BadgeSize.small,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          reply['content'] ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(reply['created_at']),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                        ),
                        if (canMarkSolution) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CustomButton(
                              text: 'Đánh dấu là câu trả lời',
                              size: ButtonSize.small,
                              type: ButtonType.outline,
                              icon: LucideIcons.badgeCheck,
                              onPressed: _postingReply
                                  ? null
                                  : () => _markAsSolution(reply),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReplyComposer(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thêm bình luận',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          CustomInput(
            controller: _replyController,
            hintText: 'Chia sẻ câu trả lời hoặc gợi ý của bạn...',
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'Gửi bình luận',
              icon: LucideIcons.send,
              onPressed: _postingReply ? null : _submitReply,
              isLoading: _postingReply,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
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

  String _formatTime(dynamic dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString.toString());
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

