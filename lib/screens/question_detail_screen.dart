import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';
import '../providers/app_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/question_form_sheet.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailScreen({super.key, required this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  late Question _question;
  bool _loadingReplies = true;
  bool _postingReply = false;
  List<Map<String, dynamic>> _replies = [];
  bool _isSolved = false;
  bool _isOwner = false;
  RealtimeChannel? _repliesChannel;
  String? _replyingToReplyId;
  final Map<String, TextEditingController> _replyControllers = {};
  final Set<String> _expandedReplies = {};

  @override
  void initState() {
    super.initState();
    _question = widget.question;
    _isSolved = _question.solved;
    final currentUserId =
        Provider.of<AppProvider>(context, listen: false).currentUser?.id;
    _isOwner = currentUserId != null && currentUserId == _question.userId;
    _loadReplies();
    _subscribeToReplies();
  }

  @override
  void dispose() {
    _replyController.dispose();
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    _replyControllers.clear();
    _repliesChannel?.unsubscribe();
    _repliesChannel = null;
    super.dispose();
  }

  void _subscribeToReplies() {
    _repliesChannel = Supabase.instance.client
        .channel('question_replies_${_question.id}')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'question_replies',
        callback: (payload) async {
          final newRecord = payload.newRecord;
          if (newRecord != null &&
              newRecord['question_id'] == _question.id) {
            await _loadReplies();
          }
        },
      )
      ..subscribe();
  }

  Future<void> _loadReplies() async {
    final data = await SupabaseService.getQuestionReplies(_question.id);
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
        .createQuestionReply(_question.id, text, parentId: _replyingToReplyId);

    if (!mounted) return;

    setState(() => _postingReply = false);

    if (success) {
      _replyController.clear();
      setState(() {
        _replyingToReplyId = null;
      });
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

  Future<void> _sendReply(String replyId) async {
    final controller = _replyControllers[replyId];
    if (controller == null) return;
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _postingReply = true);
    final success = await context
        .read<AppProvider>()
        .createQuestionReply(_question.id, text, parentId: replyId);

    if (!mounted) return;

    setState(() => _postingReply = false);

    if (success) {
      controller.clear();
      _replyControllers.remove(replyId);
      setState(() {
        _replyingToReplyId = null;
      });
      await _loadReplies();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi trả lời')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi trả lời thất bại'),
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
        .markQuestionSolution(_question.id, replyId.toString());

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

  Future<void> _handleEditQuestion() async {
    await showQuestionFormSheet(context, editingQuestion: _question);
    if (!mounted) return;
    _refreshQuestionFromProvider();
  }

  Future<void> _confirmDeleteQuestion() async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xóa câu hỏi'),
            content:
                const Text('Bạn chắc chắn muốn xóa câu hỏi này khỏi diễn đàn?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    final success =
        await context.read<AppProvider>().deleteQuestion(_question.id);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa câu hỏi')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa câu hỏi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _refreshQuestionFromProvider() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    try {
      final updated =
          provider.questions.firstWhere((q) => q.id == _question.id);
      final currentUserId = provider.currentUser?.id;
      setState(() {
        _question = updated;
        _isSolved = updated.solved;
        _isOwner =
            currentUserId != null && currentUserId == updated.userId;
      });
    } catch (_) {
      // Question might have been deleted or not in the cache.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết câu hỏi'),
        actions: _isOwner
            ? [
                IconButton(
                  icon: const Icon(LucideIcons.edit),
                  onPressed: _handleEditQuestion,
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2),
                  onPressed: _confirmDeleteQuestion,
                ),
              ]
            : null,
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
                text: _question.course,
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
            _question.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_question.author} • ${_question.time}',
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
            _question.content.isNotEmpty
                ? _question.content
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
              return _buildReplyItem(_replies[index]);
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

  Widget _buildReplyItem(Map<String, dynamic> reply) {
    final user = reply['users'];
    final replyId = reply['id'].toString();
    final replies = (reply['replies'] as List?) ?? [];
    final hasReplies = replies.isNotEmpty;
    final isExpanded = _expandedReplies.contains(replyId);
    final bool isSolution = reply['is_solution'] == true;
    final replyOwnerId = reply['user_id']?.toString();
    final canMarkSolution = _isOwner &&
        !_isSolved &&
        !isSolution &&
        replyOwnerId !=
            Provider.of<AppProvider>(context, listen: false)
                .currentUser
                ?.id;

    if (!_replyControllers.containsKey(replyId)) {
      _replyControllers[replyId] = TextEditingController();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                  Row(
                    children: [
                      Text(
                        _formatTime(reply['created_at']),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _replyingToReplyId = _replyingToReplyId == replyId ? null : replyId;
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _replyingToReplyId == replyId ? 'Hủy' : 'Trả lời',
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
                                _expandedReplies.remove(replyId);
                              } else {
                                _expandedReplies.add(replyId);
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
        ),
        // Reply input
        if (_replyingToReplyId == replyId) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 30), // Align with avatar
              Expanded(
                child: TextField(
                  controller: _replyControllers[replyId],
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
                onPressed: () => _sendReply(replyId),
                icon: const Icon(LucideIcons.send, size: 20),
              ),
            ],
          ),
        ],
        // Nested replies
        if (hasReplies && isExpanded) ...[
          const SizedBox(height: 12),
          ...replies.map((nestedReply) => Padding(
                padding: const EdgeInsets.only(left: 30, top: 8),
                child: _buildReplyItem(nestedReply),
              )),
        ],
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

