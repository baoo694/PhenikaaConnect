import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/question_form_sheet.dart';
import '../models/post.dart';
import '../models/course.dart';
import '../services/group_reminder_service.dart';
import '../services/supabase_service.dart';
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
  String _courseSearchQuery = '';
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
    return RefreshIndicator(
      onRefresh: _refreshScheduleData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isScheduleLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final schedules = appProvider.getSchedulesForDay(_selectedDay);

        if (schedules.isEmpty) {
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
                  'Chưa có lớp cho ${_dayInVietnamese(_selectedDay)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Thêm dữ liệu vào bảng class_schedules để hiển thị lịch học.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: schedules.map((cls) => _buildClassCard(cls)).toList(),
        );
      },
    );
  }

  Widget _buildClassCard(ClassSchedule cls) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _buildScheduleGradient(cls.color),
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

  LinearGradient _buildScheduleGradient(String? color) {
    final colors = _gradientColors(color);
    return LinearGradient(
      colors: colors,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  List<Color> _gradientColors(String? color) {
    final baseColor = _colorFromHex(color);
    return [
      baseColor,
      Color.lerp(baseColor, Colors.black, 0.2) ?? baseColor,
    ];
  }

  Color _colorFromHex(String? color) {
    if (color == null || color.isEmpty) {
      return const Color(0xFF3B82F6);
    }
    var cleaned = color.replaceAll('#', '').trim();
    if (cleaned.length == 3) {
      cleaned = cleaned.split('').map((char) => '$char$char').join();
    }
    if (cleaned.length == 6) {
      cleaned = 'ff$cleaned';
    } else if (cleaned.length != 8) {
      cleaned = 'ff3b82f6';
    }
    try {
      return Color(int.parse(cleaned, radix: 16));
    } catch (_) {
      return const Color(0xFF3B82F6);
    }
  }

  String _dayInVietnamese(String day) {
    const mapping = {
      'Monday': 'Thứ 2',
      'Tuesday': 'Thứ 3',
      'Wednesday': 'Thứ 4',
      'Thursday': 'Thứ 5',
      'Friday': 'Thứ 6',
      'Saturday': 'Thứ 7',
      'Sunday': 'Chủ nhật',
    };
    return mapping[day] ?? day;
  }

  Widget _buildCoursesTab() {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Fixed header section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: CustomCard(
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
                              'Môn học của tôi',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Quản lý và truy cập tài liệu môn học',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomInput(
                    hintText: 'Tìm kiếm môn học...',
                    prefixIcon: LucideIcons.search,
                    onChanged: (value) {
                      setState(() {
                        _courseSearchQuery = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Scrollable courses list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshCoursesData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: _buildCoursesGrid(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesGrid() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.isCoursesLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final courses = appProvider.courses;
        if (courses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  LucideIcons.bookOpen,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bạn chưa có môn học nào',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Thêm môn học trong bảng courses của Supabase để hiển thị tại đây.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final query = _courseSearchQuery.trim().toLowerCase();
        final filteredCourses = query.isEmpty
            ? courses
            : courses.where((course) {
                return course.name.toLowerCase().contains(query) ||
                    course.code.toLowerCase().contains(query) ||
                    course.instructor.toLowerCase().contains(query);
              }).toList();

        if (filteredCourses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Không tìm thấy môn học phù hợp với "$_courseSearchQuery".',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredCourses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final course = filteredCourses[index];
            return _buildCourseCard(course);
          },
        );
      },
    );
  }

  Widget _buildCourseCard(Course course) {
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
                colors: _gradientColors(course.color),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    CustomBadge(
                      text: course.code,
                      type: BadgeType.outline,
                      size: BadgeSize.small,
                    ),
                    const SizedBox(width: 8),
                    CustomBadge(
                      text: '${course.members} thành viên',
                      type: BadgeType.secondary,
                      size: BadgeSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressBar(course.progress, colorHex: course.color),
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

  Widget _buildProgressBar(int progress, {String? colorHex}) {
    final progressColor = _colorFromHex(colorHex);
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
            progressColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQnATab() {
    return Column(
      children: [
        // Fixed header section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: CustomCard(
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
                            'Diễn đàn hỏi đáp',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Đặt câu hỏi và hỗ trợ bạn bè trong lớp học.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomButton(
                      text: 'Đặt câu hỏi',
                      type: ButtonType.outline,
                      size: ButtonSize.small,
                      icon: LucideIcons.plus,
                      onPressed: () => _showAskQuestionSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomInput(
                  hintText: 'Tìm kiếm câu hỏi...',
                  prefixIcon: LucideIcons.search,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildQuestionFilters(context),
              ],
            ),
          ),
        ),
        // Scrollable questions list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshQuestionsData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: _buildQuestionsList(),
            ),
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredQuestions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _buildQuestionCard(filteredQuestions[index]);
          },
        );
      },
    );
  }

  Widget _buildQuestionCard(Question question) {
    final currentUserId =
        Provider.of<AppProvider>(context, listen: false).currentUser?.id;
    final isOwner = question.userId != null && question.userId == currentUserId;

    return CustomCard(
      margin: EdgeInsets.zero,
      onTap: () => _openQuestionDetail(question),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAvatar(
            initials: question.author.isNotEmpty ? question.author[0] : 'Q',
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
          if (isOwner) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditQuestionSheet(question);
                } else if (value == 'delete') {
                  _confirmDeleteQuestion(question);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Chỉnh sửa'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Xóa câu hỏi'),
                ),
              ],
            ),
          ],
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
    showQuestionFormSheet(context);
  }

  void _showEditQuestionSheet(Question question) {
    showQuestionFormSheet(context, editingQuestion: question);
  }

  void _openQuestionDetail(Question question) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuestionDetailScreen(question: question),
      ),
    );
  }

  void _confirmDeleteQuestion(Question question) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa câu hỏi'),
          content: const Text('Bạn có chắc chắn muốn xóa câu hỏi này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await Provider.of<AppProvider>(context,
                        listen: false)
                    .deleteQuestion(question.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Đã xóa câu hỏi'
                          : 'Không thể xóa câu hỏi',
                    ),
                    backgroundColor: success ? null : Colors.red,
                  ),
                );
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateGroupSheet(BuildContext context, {StudyGroup? editingGroup}) {
    final nameController =
        TextEditingController(text: editingGroup?.name ?? '');
    final descriptionController =
        TextEditingController(text: editingGroup?.description ?? '');
    final maxMembersController =
        TextEditingController(text: editingGroup?.maxMembers.toString() ?? '10');
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;
    String? selectedCourse = editingGroup?.course;
    String? selectedLocation = editingGroup?.location;
    DateTime? selectedDateTime;
    if (editingGroup != null && editingGroup.meetTime.isNotEmpty) {
      try {
        selectedDateTime =
            DateFormat('dd/MM/yyyy HH:mm').parse(editingGroup.meetTime);
      } catch (_) {
        selectedDateTime = null;
      }
    }
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final courses = appProvider.allCourses;
    final locations = appProvider.locations;
    final isEditing = editingGroup != null;

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
                DateTime? effectiveDateTime = selectedDateTime;
                if (effectiveDateTime == null && editingGroup != null) {
                  try {
                    effectiveDateTime = DateFormat('dd/MM/yyyy HH:mm')
                        .parse(editingGroup.meetTime);
                  } catch (_) {
                    effectiveDateTime = null;
                  }
                }
                if (effectiveDateTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn ngày giờ gặp'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (selectedCourse == null || selectedLocation == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn đủ thông tin nhóm'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                modalSetState(() => isSubmitting = true);

                final maxMembers = int.tryParse(maxMembersController.text.trim()) ?? 10;
                if (maxMembers < 2 || maxMembers > 50) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Số lượng thành viên tối đa phải từ 2-50 người'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final payload = {
                  'name': nameController.text.trim(),
                  'course': selectedCourse,
                  'meet_time':
                      DateFormat('dd/MM/yyyy HH:mm').format(effectiveDateTime),
                  'location': selectedLocation,
                  'description': descriptionController.text.trim(),
                  'max_members': maxMembers,
                };

                final provider =
                    Provider.of<AppProvider>(context, listen: false);
                StudyGroup? createdGroup;
                bool success;

                if (isEditing) {
                  success =
                      await provider.updateStudyGroup(editingGroup!.id, payload);
                  if (success) {
                    createdGroup = editingGroup!.copyWith(
                      name: payload['name'] as String?,
                      course: payload['course'] as String?,
                      meetTime: payload['meet_time'] as String?,
                      location: payload['location'] as String?,
                      description: payload['description'] as String?,
                    );
                  }
                } else {
                  createdGroup = await provider.createStudyGroup(payload);
                  success = createdGroup != null;
                }

                modalSetState(() => isSubmitting = false);

                if (success && context.mounted) {
                  Navigator.of(context).pop();
                  if (createdGroup != null && createdGroup.isJoined) {
                    GroupReminderService.scheduleReminder(createdGroup);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing
                          ? 'Đã cập nhật nhóm'
                          : 'Tạo nhóm thành công'),
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing
                          ? 'Không thể cập nhật nhóm'
                          : 'Không thể tạo nhóm'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                        Text(
                          isEditing ? 'Chỉnh sửa nhóm' : 'Tạo nhóm học mới',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          labelText: 'Tên nhóm',
                          controller: nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên nhóm';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedCourse,
                          items: courses
                              .map<DropdownMenuItem<String>>(
                                (course) => DropdownMenuItem<String>(
                                  value: course.name,
                                  child: Text(course.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            modalSetState(() {
                              selectedCourse = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Môn học / Chủ đề',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn môn học';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final now = DateTime.now();
                            final date = await showDatePicker(
                              context: context,
                              initialDate: now,
                              firstDate: now,
                              lastDate: DateTime(now.year + 1),
                            );
                            if (date == null) return;
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time == null) return;
                            modalSetState(() {
                              selectedDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          },
                          icon: const Icon(LucideIcons.calendar),
                          label: Text(
                            selectedDateTime == null
                                ? 'Chọn ngày & giờ gặp'
                                : DateFormat('dd/MM/yyyy HH:mm')
                                    .format(selectedDateTime!),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedLocation,
                          items: locations
                              .map<DropdownMenuItem<String>>(
                                (loc) => DropdownMenuItem<String>(
                                  value: loc['name']?.toString(),
                                  child: Text(loc['name']?.toString() ?? 'Không tên'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            modalSetState(() {
                              selectedLocation = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Địa điểm',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn địa điểm';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomInput(
                          labelText: 'Mô tả nhóm',
                          controller: descriptionController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        CustomInput(
                          labelText: 'Số lượng thành viên tối đa',
                          controller: maxMembersController,
                          keyboardType: TextInputType.number,
                          hintText: '10',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập số lượng thành viên';
                            }
                            final num = int.tryParse(value.trim());
                            if (num == null || num < 2 || num > 50) {
                              return 'Số lượng phải từ 2-50 người';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: isEditing ? 'Lưu thay đổi' : 'Tạo nhóm',
                            icon: isEditing ? LucideIcons.save : LucideIcons.send,
                            onPressed: isSubmitting ? null : submit,
                            isLoading: isSubmitting,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Fixed header section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: CustomCard(
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
                              'Nhóm học tập',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tham gia hoặc tạo nhóm học tập',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomButton(
                        text: 'Tạo nhóm',
                        type: ButtonType.outline,
                        size: ButtonSize.small,
                        icon: LucideIcons.plus,
                        onPressed: () => _showCreateGroupSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Scrollable groups list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshGroupsData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: _buildGroupsGrid(),
              ),
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

  Widget _buildGroupCard(StudyGroup group) {
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
              GestureDetector(
                onTap: () => _showGroupMembers(group),
                child: CustomBadge(
                  text: '${group.members}/${group.maxMembers} thành viên',
                  type: group.members >= group.maxMembers 
                      ? BadgeType.error 
                      : BadgeType.outline,
                  size: BadgeSize.small,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (group.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              group.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ],
          const SizedBox(height: 12),
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (group.isOwner) ...[
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Chỉnh sửa',
                    type: ButtonType.outline,
                    size: ButtonSize.small,
                    icon: LucideIcons.edit,
                    onPressed: () => _showCreateGroupSheet(
                      context,
                      editingGroup: group,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'Xóa nhóm',
                    type: ButtonType.error,
                    size: ButtonSize.small,
                    icon: LucideIcons.trash,
                    onPressed: () => _confirmDeleteGroup(group),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: group.isJoined ? 'Rời nhóm' : 'Tham gia nhóm',
                size: ButtonSize.small,
                icon: group.isJoined
                    ? LucideIcons.logOut
                    : LucideIcons.arrowRight,
                type: group.isJoined ? ButtonType.outline : ButtonType.primary,
                onPressed: () => group.isJoined
                    ? _handleLeaveGroup(group)
                    : _handleJoinGroup(group),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleJoinGroup(StudyGroup group) async {
    // Check if group is full
    if (group.members >= group.maxMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nhóm đã đầy, không thể tham gia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final success = await appProvider.joinStudyGroup(group.id);
    if (!mounted) return;
    if (success) {
      GroupReminderService.scheduleReminder(group);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tham gia nhóm "${group.name}"')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tham gia nhóm'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLeaveGroup(StudyGroup group) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final success = await appProvider.leaveStudyGroup(group.id);
    if (!mounted) return;
    if (success) {
      GroupReminderService.cancelReminder(group.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn đã rời nhóm "${group.name}"')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể rời nhóm'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDeleteGroup(StudyGroup group) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa nhóm'),
          content: Text('Bạn chắc chắn muốn xóa nhóm "${group.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final appProvider =
                    Provider.of<AppProvider>(context, listen: false);
                final success = await appProvider.deleteStudyGroup(group.id);
                if (!mounted) return;
                if (success) {
                  GroupReminderService.cancelReminder(group.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa nhóm')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không thể xóa nhóm'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshScheduleData() {
    return context.read<AppProvider>().loadClassSchedule();
  }

  Future<void> _refreshCoursesData() {
    return context.read<AppProvider>().loadCourses();
  }

  Future<void> _refreshQuestionsData() {
    return context.read<AppProvider>().loadQuestions();
  }

  Future<void> _refreshGroupsData() {
    return context.read<AppProvider>().loadStudyGroups();
  }

  void _showGroupMembers(StudyGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: SupabaseService.getGroupMembers(group.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final members = snapshot.data ?? [];
                final appProvider = Provider.of<AppProvider>(context, listen: false);
                final creatorId = group.creatorId;

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Thành viên nhóm',
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
                      const SizedBox(height: 8),
                      Text(
                        '${members.length}/${group.maxMembers} thành viên',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: members.isEmpty
                            ? const Center(
                                child: Text('Chưa có thành viên nào'),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: members.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final member = members[index];
                                  final isCreator = member['user_id'] == creatorId;
                                  return ListTile(
                                    leading: CustomAvatar(
                                      initials: (member['name'] as String)[0],
                                      radius: 20,
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          member['name'] ?? 'Unknown',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (isCreator) ...[
                                          const SizedBox(width: 8),
                                          const CustomBadge(
                                            text: 'Trưởng nhóm',
                                            type: BadgeType.primary,
                                            size: BadgeSize.small,
                                          ),
                                        ],
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (member['major'] != null && (member['major'] as String).isNotEmpty)
                                          Text(
                                            '${member['major']} • ${member['year']}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        if (member['student_id'] != null && (member['student_id'] as String).isNotEmpty)
                                          Text(
                                            'MSSV: ${member['student_id']}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
