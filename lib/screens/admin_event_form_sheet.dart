import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/admin_service.dart';
import '../services/supabase_service.dart';
import '../widgets/common_widgets.dart';

class AdminEventFormSheet extends StatefulWidget {
  final Event? event;

  const AdminEventFormSheet({super.key, this.event});

  @override
  State<AdminEventFormSheet> createState() => _AdminEventFormSheetState();
}

class _AdminEventFormSheetState extends State<AdminEventFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
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
    'Triển lãm',
    'Khởi nghiệp',
    'Nghệ thuật',
    'Công nghệ',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _loadLocations();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description ?? '';
      _selectedLocation = widget.event!.location;
      _maxAttendeesController.text = widget.event!.maxAttendees != null ? widget.event!.maxAttendees.toString() : '';
      _selectedCategory = widget.event!.category;
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.event!.date);
        final timeParts = widget.event!.time.split(':');
        if (timeParts.length >= 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
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
      });
    }
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày và giờ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final eventData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'event_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'event_time': '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00',
      'location': _selectedLocation ?? '',
      'category': _selectedCategory!,
      'max_attendees': _maxAttendeesController.text.isNotEmpty
          ? int.tryParse(_maxAttendeesController.text)
          : null,
    };

    bool success;
    if (widget.event != null) {
      success = await AdminService.updateEvent(widget.event!.id, eventData);
    } else {
      success = await AdminService.createEvent(eventData);
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.event != null
                ? 'Đã cập nhật sự kiện thành công'
                : 'Đã tạo sự kiện thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Sửa sự kiện' : 'Thêm sự kiện mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
                    children: [
                      CustomInput(
                        controller: _titleController,
                        hintText: 'Tên sự kiện',
                        labelText: 'Tiêu đề',
                        prefixIcon: LucideIcons.calendar,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        controller: _descriptionController,
                        hintText: 'Mô tả sự kiện',
                        labelText: 'Mô tả',
                        prefixIcon: LucideIcons.fileText,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      // Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Ngày diễn ra',
                                  prefixIcon: const Icon(LucideIcons.calendar),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _selectedDate != null
                                      ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
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
                                  labelText: 'Giờ diễn ra',
                                  prefixIcon: const Icon(LucideIcons.clock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : 'Chọn giờ',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isLoadingLocations
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              value: _selectedLocation,
                              decoration: InputDecoration(
                                labelText: 'Địa điểm',
                                prefixIcon: const Icon(LucideIcons.mapPin),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: _locations.map<DropdownMenuItem<String>>((location) {
                                final name = (location['name'] ?? '').toString();
                                final building = (location['building'] ?? '').toString();
                                final floor = (location['floor'] ?? '').toString();
                                final displayName = building.isNotEmpty && floor.isNotEmpty
                                    ? '$name - $building, $floor'
                                    : name;
                                return DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(displayName),
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
                      // Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Danh mục',
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
                        hintText: 'Số người tối đa (tùy chọn)',
                        labelText: 'Số người tối đa',
                        prefixIcon: LucideIcons.users,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: widget.event != null ? 'Cập nhật' : 'Tạo sự kiện',
                        icon: widget.event != null ? LucideIcons.save : LucideIcons.plus,
                        onPressed: _isLoading ? null : _submitEvent,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
      ),
    );
  }
}

