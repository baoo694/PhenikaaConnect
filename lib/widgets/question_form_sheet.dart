import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/app_provider.dart';
import 'common_widgets.dart';

Future<void> showQuestionFormSheet(
  BuildContext context, {
  Question? editingQuestion,
}) async {
  final appProvider = Provider.of<AppProvider>(context, listen: false);
  final courses = appProvider.allCourses;
  final hasCourses = courses.isNotEmpty;
  final titleController =
      TextEditingController(text: editingQuestion?.title ?? '');
  final descriptionController =
      TextEditingController(text: editingQuestion?.content ?? '');
  final formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  final isEditing = editingQuestion != null;
  String? selectedCourse =
      editingQuestion?.course ?? (hasCourses ? courses.first.name : null);

  await showModalBottomSheet(
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

              final payload = {
                'title': titleController.text.trim(),
                'course': selectedCourse,
                'content': descriptionController.text.trim(),
              };

              bool success;
              if (isEditing) {
                success = await appProvider.updateQuestion(
                  editingQuestion!.id,
                  payload,
                );
              } else {
                success = await appProvider.createQuestion({
                  ...payload,
                  'solved': false,
                });
              }

              modalSetState(() => isSubmitting = false);

              if (!context.mounted) return;

              if (success) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Cập nhật câu hỏi thành công'
                          : 'Đăng câu hỏi thành công',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Không thể cập nhật câu hỏi'
                          : 'Không thể đăng câu hỏi',
                    ),
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isEditing ? 'Chỉnh sửa câu hỏi' : 'Đặt câu hỏi mới',
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
                      DropdownButtonFormField<String>(
                        value: selectedCourse,
                        items: courses
                            .map((course) => DropdownMenuItem<String>(
                                  value: course.name,
                                  child: Text(course.name),
                                ))
                            .toList(),
                        onChanged: hasCourses
                            ? (value) {
                                modalSetState(() {
                                  selectedCourse = value;
                                });
                              }
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Chủ đề / Môn học',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (!hasCourses) {
                            return 'Bạn chưa có môn học nào';
                          }
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn môn học';
                          }
                          return null;
                        },
                      ),
                      if (!hasCourses) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Hãy thêm môn học trong Supabase để đặt câu hỏi.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error,
                                  ),
                        ),
                      ],
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
                          text: isEditing ? 'Lưu thay đổi' : 'Đăng câu hỏi',
                          icon: isEditing ? LucideIcons.save : LucideIcons.send,
                          onPressed:
                              isSubmitting || !hasCourses ? null : submit,
                          isLoading: isSubmitting,
                        ),
                      ),
                      const SizedBox(height: 8),
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

