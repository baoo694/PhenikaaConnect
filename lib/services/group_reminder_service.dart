import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/post.dart';

class GroupReminderService {
  GroupReminderService._();

  static GlobalKey<ScaffoldMessengerState>? _messengerKey;
  static final Map<String, Timer> _timers = {};

  static void initialize(GlobalKey<ScaffoldMessengerState> messengerKey) {
    _messengerKey = messengerKey;
  }

  static void scheduleReminder(StudyGroup group) {
    final meetDate = _parseMeetTime(group.meetTime);
    if (meetDate == null) return;
    final now = DateTime.now();
    final difference = meetDate.difference(now);
    if (difference.isNegative) return;

    cancelReminder(group.id);
    _timers[group.id] = Timer(difference, () {
      final messenger = _messengerKey?.currentState;
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'Nhắc nhở: nhóm "${group.name}" bắt đầu vào ${group.meetTime} tại ${group.location}',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
      _timers.remove(group.id);
    });
  }

  static void cancelReminder(String groupId) {
    _timers.remove(groupId)?.cancel();
  }

  static DateTime? _parseMeetTime(String meetTime) {
    if (meetTime.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy HH:mm').parse(meetTime);
    } catch (_) {
      return null;
    }
  }
}

