import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/club_leader_service.dart';
import '../services/supabase_service.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class ClubLeaderActivityFormSheet extends StatefulWidget {
  final ClubActivity? activity;
  final String clubId;

  const ClubLeaderActivityFormSheet({
    super.key,
    this.activity,
    required this.clubId,
  });

  @override
  State<ClubLeaderActivityFormSheet> createState() => _ClubLeaderActivityFormSheetState();
}

class _ClubLeaderActivityFormSheetState extends State<ClubLeaderActivityFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedLocation;
  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = false;
  bool _isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
    if (widget.activity != null) {
      _titleController.text = widget.activity!.title;
      _descriptionController.text = widget.activity!.description ?? '';
      _selectedDate = widget.activity!.date;
      _selectedLocation = widget.activity!.location;
      if (widget.activity!.time != null && widget.activity!.time!.isNotEmpty) {
        _timeController.text = widget.activity!.time!;
      } else {
        _timeController.text =
            '${widget.activity!.date.hour.toString().padLeft(2, '0')}:${widget.activity!.date.minute.toString().padLeft(2, '0')}';
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
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_titleController.text.isEmpty || _selectedDate == null || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin (tiêu đề, ngày, giờ)'),
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

    // Combine date and time
    final timeParts = _timeController.text.split(':');
    final activityDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    bool success;
    if (widget.activity != null) {
      // Update
      success = await ClubLeaderService.updateClubActivity(
        activityId: widget.activity!.id,
        title: _titleController.text,
        date: activityDateTime,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        location: _selectedLocation,
      );
    } else {
      // Create
      success = await ClubLeaderService.createClubActivity(
        clubId: widget.clubId,
        creatorId: user.id,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        date: activityDateTime,
        location: _selectedLocation,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.activity != null ? 'Đã cập nhật hoạt động thành công' : 'Đã tạo hoạt động thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.activity != null ? 'Có lỗi xảy ra khi cập nhật' : 'Có lỗi xảy ra khi tạo hoạt động'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity != null ? 'Sửa hoạt động' : 'Tạo hoạt động'),
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
                hintText: 'Tiêu đề hoạt động',
                labelText: 'Tiêu đề *',
                prefixIcon: LucideIcons.type,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                controller: _descriptionController,
                hintText: 'Mô tả hoạt động...',
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
                    labelText: 'Địa điểm',
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
                ),
              const SizedBox(height: 24),
              CustomButton(
                text: widget.activity != null ? 'Cập nhật' : 'Tạo hoạt động',
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

