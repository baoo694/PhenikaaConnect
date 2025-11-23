import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/club_leader_service.dart';
import '../services/supabase_service.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class ClubLeaderEventFormSheet extends StatefulWidget {
  final Event? event;
  final String clubId;

  const ClubLeaderEventFormSheet({
    super.key,
    this.event,
    required this.clubId,
  });

  @override
  State<ClubLeaderEventFormSheet> createState() => _ClubLeaderEventFormSheetState();
}

class _ClubLeaderEventFormSheetState extends State<ClubLeaderEventFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategory;
  String? _selectedLocation;
  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = false;
  bool _isLoadingLocations = true;

  final List<String> _categories = [
    'Học thuật',
    'Văn hóa',
    'Thể thao',
    'Nghề nghiệp',
  ];

  @override
  void initState() {
    super.initState();
    _loadLocations();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description ?? '';
      _maxAttendeesController.text = widget.event!.maxAttendees != null ? widget.event!.maxAttendees.toString() : '';
      _selectedLocation = widget.event!.location;
      _selectedCategory = widget.event!.category;
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.event!.date);
        final timeParts = widget.event!.time.split(':');
        if (timeParts.length >= 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          _timeController.text = widget.event!.time;
        }
      } catch (e) {
        print('Error parsing date/time: $e');
      }
    }
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoadingLocations = true);
    final locations = await SupabaseService.getLocations();
    setState(() {
      _locations = locations;
      _isLoadingLocations = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_titleController.text.isEmpty ||
        _selectedLocation == null ||
        _selectedDate == null ||
        _timeController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = context.read<AppProvider>().currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    bool success;
    if (widget.event != null) {
      // Update
      success = await ClubLeaderService.updateEvent(
        eventId: widget.event!.id,
        title: _titleController.text,
        description: _descriptionController.text,
        eventDate: _selectedDate!,
        eventTime: _timeController.text,
        location: _selectedLocation!,
        category: _selectedCategory!,
        maxAttendees: _maxAttendeesController.text.isEmpty
            ? null
            : int.tryParse(_maxAttendeesController.text),
      );
    } else {
      // Create
      success = await ClubLeaderService.createEvent(
        clubId: widget.clubId,
        organizerId: user.id,
        title: _titleController.text,
        description: _descriptionController.text,
        eventDate: _selectedDate!,
        eventTime: _timeController.text,
        location: _selectedLocation!,
        category: _selectedCategory!,
        visibility: VisibilityScope.campus,
        maxAttendees: _maxAttendeesController.text.isNotEmpty
            ? int.tryParse(_maxAttendeesController.text)
            : null,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.event != null
                ? 'Đã cập nhật sự kiện. Đang chờ admin duyệt lại.'
                : 'Đã tạo sự kiện. Đang chờ admin duyệt.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.event != null ? 'Có lỗi xảy ra khi cập nhật' : 'Có lỗi xảy ra khi tạo sự kiện'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Sửa sự kiện' : 'Tạo sự kiện'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(LucideIcons.check),
              onPressed: _submit,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInput(
                controller: _titleController,
                hintText: 'Tên sự kiện',
                labelText: 'Tên sự kiện *',
                prefixIcon: LucideIcons.type,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên sự kiện';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _descriptionController,
                hintText: 'Mô tả sự kiện...',
                labelText: 'Mô tả',
                prefixIcon: LucideIcons.fileText,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ngày *',
                          prefixIcon: const Icon(LucideIcons.calendar),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Chọn ngày',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Giờ *',
                          prefixIcon: const Icon(LucideIcons.clock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _timeController.text.isEmpty ? 'Chọn giờ' : _timeController.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoadingLocations)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  decoration: InputDecoration(
                    labelText: 'Địa điểm *',
                    prefixIcon: const Icon(LucideIcons.mapPin),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _locations.map<DropdownMenuItem<String>>((location) {
                    return DropdownMenuItem<String>(
                      value: location['name'] as String,
                      child: Text(location['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn địa điểm';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Danh mục *',
                  prefixIcon: const Icon(LucideIcons.tag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn danh mục';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _maxAttendeesController,
                hintText: 'Số lượng người tham gia tối đa (tùy chọn)',
                labelText: 'Số lượng tối đa',
                prefixIcon: LucideIcons.users,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: widget.event != null ? 'Cập nhật' : 'Tạo sự kiện',
                icon: LucideIcons.plus,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

