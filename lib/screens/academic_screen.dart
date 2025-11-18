import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import '../models/post.dart';
import 'question_detail_screen.dart';

class AcademicScreen extends StatefulWidget {
  const AcademicScreen({super.key});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

enum QuestionFilter { all, mine }

class _AcademicScreenState extends State<AcademicScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDay = 'Monday';
  String _searchQuery = '';
  QuestionFilter _questionFilter = QuestionFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(LucideIcons.calendar), text: 'Lịch học'),
            Tab(icon: Icon(LucideIcons.bookOpen), text: 'Môn học'),
            Tab(icon: Icon(LucideIcons.messageSquare), text: 'Q&A'),
            Tab(icon: Icon(LucideIcons.users), text: 'Nhóm'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScheduleTab(),
          _buildCoursesTab(),
          _buildQnATab(),
          _buildGroupsTab(),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thời khóa biểu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lịch học trong tuần của bạn',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDaySelector(),
                const SizedBox(height: 16),
                _buildScheduleList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final daysVN = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isSelected = _selectedDay == day;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CustomButton(
              text: daysVN[index],
              type: isSelected ? ButtonType.primary : ButtonType.outline,
              size: ButtonSize.small,
              onPressed: () {
                setState(() {
                  _selectedDay = day;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScheduleList() {
    return Center(
      child: Column(
        children: [
          Icon(
            LucideIcons.calendar,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Tính năng lịch học đang phát triển',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(dynamic cls) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cls.subject,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cls.instructor,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cls.room,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                LucideIcons.clock,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                cls.time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Môn học của tôi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quản lý và truy cập tài liệu môn học',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                _buildCoursesGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesGrid() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Tính năng môn học đang phát triển'),
      ),
    );
  }

  Widget _buildCourseCard(dynamic course) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: course.name == 'Data Structures' 
                  ? [Color(0xFF3B82F6), Color(0xFF1D4ED8)]
                  : [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.code} • ${course.instructor}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressBar(course.progress),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Tài liệu',
                        type: ButtonType.outline,
                        size: ButtonSize.small,
                        icon: LucideIcons.fileText,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        text: 'Q&A (${course.questions})',
                        type: ButtonType.outline,
                        size: ButtonSize.small,
                        icon: LucideIcons.messageSquare,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiến độ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              '$progress%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQnATab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Diễn đàn hỏi đáp',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  CustomButton(
                    text: 'Đặt câu hỏi',
                    size: ButtonSize.small,
                    icon: LucideIcons.plus,
                    onPressed: () => _showAskQuestionSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Đặt câu hỏi và hỗ trợ bạn bè trong lớp học.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 12),
              CustomInput(
                hintText: 'Tìm kiếm câu hỏi...',
                prefixIcon: LucideIcons.search,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildQuestionFilters(context),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildQuestionsList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsList() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (appProvider.questions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Chưa có câu hỏi nào'),
            ),
          );
        }

        var filteredQuestions = appProvider.questions.where((q) =>
            q.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            q.course.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();

        if (_questionFilter == QuestionFilter.mine) {
          final currentUserId = appProvider.currentUser?.id;
          filteredQuestions = filteredQuestions
              .where((q) => q.userId != null && q.userId == currentUserId)
              .toList();
        }

        if (filteredQuestions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                _questionFilter == QuestionFilter.mine
                    ? 'Bạn chưa đăng câu hỏi nào'
                    : 'Không tìm thấy câu hỏi phù hợp',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
            ),
          );
        }

        return Column(
          children: filteredQuestions.map((question) => _buildQuestionCard(question)).toList(),
        );
      },
    );
  }

  Widget _buildQuestionCard(Question question) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _openQuestionDetail(question),
      child: Row(
        children: [
          CustomAvatar(
            initials: question.author[0],
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomBadge(
                      text: question.course,
                      type: BadgeType.outline,
                      size: BadgeSize.small,
                    ),
                    if (question.solved) ...[
                      const SizedBox(width: 8),
                      const CustomBadge(
                        text: 'Đã giải quyết',
                        type: BadgeType.success,
                        size: BadgeSize.small,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  question.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (question.content.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    question.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${question.author} • ${question.time}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.messageSquare,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${question.replies}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionFilters(BuildContext context) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Tất cả'),
          selected: _questionFilter == QuestionFilter.all,
          onSelected: (value) {
            if (!value) return;
            setState(() {
              _questionFilter = QuestionFilter.all;
            });
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Câu hỏi của tôi'),
          selected: _questionFilter == QuestionFilter.mine,
          onSelected: (value) {
            if (!value) return;
            setState(() {
              _questionFilter = QuestionFilter.mine;
            });
          },
        ),
      ],
    );
  }

  void _showAskQuestionSheet(BuildContext context) {
    final titleController = TextEditingController();
    final courseController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, modalSetState) {
              Future<void> submit() async {
                if (!formKey.currentState!.validate()) return;
                modalSetState(() => isSubmitting = true);

                final success = await Provider.of<AppProvider>(context, listen: false)
                    .createQuestion({
                  'title': titleController.text.trim(),
                  'course': courseController.text.trim(),
                  'content': descriptionController.text.trim(),
                  'solved': false,
                });

                modalSetState(() => isSubmitting = false);

                if (success && context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đăng câu hỏi thành công')),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không thể đăng câu hỏi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Đặt câu hỏi mới',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        labelText: 'Tiêu đề câu hỏi',
                        controller: titleController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomInput(
                        labelText: 'Chủ đề / Môn học',
                        controller: courseController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập chủ đề';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomInput(
                        labelText: 'Mô tả chi tiết',
                        controller: descriptionController,
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng mô tả vấn đề';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Đăng câu hỏi',
                          icon: LucideIcons.send,
                          onPressed: isSubmitting ? null : submit,
                          isLoading: isSubmitting,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openQuestionDetail(Question question) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuestionDetailScreen(question: question),
      ),
    );
  }

  Widget _buildGroupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nhóm học tập',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tham gia hoặc tạo nhóm học tập',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    CustomButton(
                      text: 'Tạo nhóm',
                      type: ButtonType.outline,
                      size: ButtonSize.small,
                      icon: LucideIcons.plus,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGroupsGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsGrid() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (appProvider.studyGroups.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Chưa có nhóm học nào'),
            ),
          );
        }

        return Column(
          children: appProvider.studyGroups.map((group) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGroupCard(group),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildGroupCard(dynamic group) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.course,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              CustomBadge(
                text: '${group.members} thành viên',
                type: BadgeType.outline,
                size: BadgeSize.small,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.clock,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.meetTime,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Tham gia nhóm',
              size: ButtonSize.small,
              icon: LucideIcons.arrowRight,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
