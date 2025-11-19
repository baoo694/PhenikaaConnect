import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/event.dart';
import '../models/course.dart';
import '../services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  // Current User
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Posts
  List<Post> _posts = [];
  List<Post> get posts => _posts;

  // Questions
  List<Question> _questions = [];
  List<Question> get questions => _questions;

  // Study Groups
  List<StudyGroup> _studyGroups = [];
  List<StudyGroup> get studyGroups => _studyGroups;

  // Class schedules
  List<ClassSchedule> _classSchedules = [];
  List<ClassSchedule> get classSchedules => _classSchedules;

  // Events
  List<Event> _events = [];
  List<Event> get events => _events;

  // Clubs
  List<Map<String, dynamic>> _clubs = [];
  List<Map<String, dynamic>> get clubs => _clubs;

  // Announcements
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> get announcements => _announcements;
  
  // Read/unread announcement tracking (persisted locally)
  Set<String> _readAnnouncementIds = {};
  int get unreadAnnouncementsCount {
    if (_announcements.isEmpty) return 0;
    return _announcements.where((a) {
      final id = (a['id'] ?? '').toString();
      return id.isNotEmpty && !_readAnnouncementIds.contains(id);
    }).length;
  }
  bool isAnnouncementRead(String announcementId) {
    if (announcementId.isEmpty) return true;
    return _readAnnouncementIds.contains(announcementId);
  }

  // Locations
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> get locations => _locations;

  // Courses
  List<Course> _courses = [];
  List<Course> get courses => _courses;

  // Selected Tab
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  // Selected Sub Tab (for screens with multiple tabs)
  int _selectedSubTabIndex = 0;
  int get selectedSubTabIndex => _selectedSubTabIndex;

  // Theme Mode
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isScheduleLoading = false;
  bool get isScheduleLoading => _isScheduleLoading;
  bool _isCoursesLoading = false;
  bool get isCoursesLoading => _isCoursesLoading;

  // Notification Settings
  List<Map<String, dynamic>> _notificationSettings = [
    {'id': 1, 'label': 'Thông báo từ trường', 'enabled': true},
    {'id': 2, 'label': 'Tin nhắn mới', 'enabled': true},
    {'id': 3, 'label': 'Cập nhật sự kiện', 'enabled': true},
    {'id': 4, 'label': 'Q&A trả lời', 'enabled': false},
    {'id': 5, 'label': 'Nhắc nhở lịch học', 'enabled': true},
  ];
  List<Map<String, dynamic>> get notificationSettings => _notificationSettings;

  // Initialize provider
  Future<void> initialize() async {
    await loadCurrentUser();
    
    // Test all tables first
    await SupabaseService.testTables();
    
    await loadPosts();
    await loadQuestions();
    await loadStudyGroups();
    await loadEvents();
    await loadClubs();
    await _loadReadAnnouncementIdsFromPrefs();
    await loadAnnouncements();
    await loadLocations();
    await loadClassSchedule();
    await loadCourses();
  }

  // Load current user
  Future<void> loadCurrentUser() async {
    _currentUser = await SupabaseService.getCurrentUser();
    notifyListeners();
  }

  // Load posts
  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _posts = await SupabaseService.getPosts();
      print('Loaded ${_posts.length} posts from Supabase');
    } catch (e) {
      print('Error loading posts: $e');
      _posts = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // Load questions
  Future<void> loadQuestions() async {
    _questions = await SupabaseService.getQuestions();
    notifyListeners();
  }

  // Load study groups
  Future<void> loadStudyGroups() async {
    _studyGroups = await SupabaseService.getStudyGroups();
    notifyListeners();
  }

  // Load events
  Future<void> loadEvents() async {
    try {
      _events = await SupabaseService.getEvents();
      print('Loaded ${_events.length} events from Supabase');
    } catch (e) {
      print('Error loading events: $e');
      _events = [];
    }
    notifyListeners();
  }

  // Load clubs
  Future<void> loadClubs() async {
    try {
      _clubs = await SupabaseService.getClubs();
      print('Loaded ${_clubs.length} clubs from Supabase');
    } catch (e) {
      print('Error loading clubs: $e');
      _clubs = [];
    }
    notifyListeners();
  }

  // Load announcements
  Future<void> loadAnnouncements() async {
    try {
      _announcements = await SupabaseService.getAnnouncements();
      print('Loaded ${_announcements.length} announcements from Supabase');
    } catch (e) {
      print('Error loading announcements: $e');
      _announcements = [];
    }
    notifyListeners();
  }

  // Mark one announcement as read
  Future<void> markAnnouncementRead(String announcementId) async {
    if (announcementId.isEmpty) return;
    if (_readAnnouncementIds.contains(announcementId)) return;
    _readAnnouncementIds.add(announcementId);
    await _saveReadAnnouncementIdsToPrefs();
    notifyListeners();
  }

  // Optionally clear read status (not exposed in UI yet)
  Future<void> markAllAnnouncementsUnread() async {
    _readAnnouncementIds.clear();
    await _saveReadAnnouncementIdsToPrefs();
    notifyListeners();
  }

  Future<void> _loadReadAnnouncementIdsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('read_announcement_ids') ?? <String>[];
      _readAnnouncementIds = list.toSet();
    } catch (_) {
      _readAnnouncementIds = {};
    }
  }

  Future<void> _saveReadAnnouncementIdsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('read_announcement_ids', _readAnnouncementIds.toList());
    } catch (_) {
      // ignore persistence errors silently
    }
  }

  // Load locations
  Future<void> loadLocations() async {
    try {
      _locations = await SupabaseService.getLocations();
      print('Loaded ${_locations.length} locations from Supabase');
    } catch (e) {
      print('Error loading locations: $e');
      _locations = [];
    }
    notifyListeners();
  }

  // Load class schedule
  Future<void> loadClassSchedule() async {
    final userId = _currentUser?.id;
    if (userId == null) {
      _classSchedules = [];
      _isScheduleLoading = false;
      notifyListeners();
      return;
    }

    _isScheduleLoading = true;
    notifyListeners();

    try {
      _classSchedules = await SupabaseService.getClassSchedules(userId: userId);
    } catch (e) {
      print('Error loading class schedule: $e');
      _classSchedules = [];
    }

    _isScheduleLoading = false;
    notifyListeners();
  }

  List<ClassSchedule> getSchedulesForDay(String day) {
    final normalizedDay = day.toLowerCase();
    final schedules = _classSchedules
        .where((schedule) => schedule.day.toLowerCase() == normalizedDay)
        .toList();
    schedules.sort((a, b) {
      final aStart = a.startTime ?? DateTime(1970, 1, 1);
      final bStart = b.startTime ?? DateTime(1970, 1, 1);
      return aStart.compareTo(bStart);
    });
    return schedules;
  }

  Future<void> loadCourses() async {
    final userId = _currentUser?.id;
    if (userId == null) {
      _courses = [];
      _isCoursesLoading = false;
      notifyListeners();
      return;
    }

    _isCoursesLoading = true;
    notifyListeners();

    try {
      _courses = await SupabaseService.getCourses(userId: userId);
      print('Loaded ${_courses.length} courses from Supabase');
    } catch (e) {
      print('Error loading courses: $e');
      _courses = [];
    }

    _isCoursesLoading = false;
    notifyListeners();
  }

  // Create post
  Future<bool> createPost(String content, {String? imageBase64}) async {
    final post = await SupabaseService.createPost(content, imageBase64: imageBase64);
    if (post != null) {
      _posts.insert(0, post);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Toggle post like
  Future<bool> togglePostLike(String postId) async {
    // Optimistic update to avoid list rebuild/scroll jump
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return false;

    final original = _posts[index];
    final toggled = original.copyWith(
      liked: !original.liked,
      likes: original.liked ? (original.likes - 1) : (original.likes + 1),
    );
    _posts[index] = toggled;
    notifyListeners();

    final success = await SupabaseService.togglePostLike(postId);
    if (!success) {
      // Revert if failed
      _posts[index] = original;
      notifyListeners();
      return false;
    }
    return true;
  }

  // Create comment for a post
  Future<bool> createComment(String postId, String content) async {
    final success = await SupabaseService.createComment(postId, content);
    if (success) {
      await loadPosts();
      return true;
    }
    return false;
  }

  Future<bool> createQuestionReply(String questionId, String content) async {
    final success = await SupabaseService.createQuestionReply(questionId, content);
    if (success) {
      await loadQuestions();
      return true;
    }
    return false;
  }

  Future<bool> markQuestionSolution(String questionId, String replyId) async {
    final success = await SupabaseService.markQuestionSolution(questionId, replyId);
    if (success) {
      await loadQuestions();
      return true;
    }
    return false;
  }

  // Create question
  Future<bool> createQuestion(Map<String, dynamic> questionData) async {
    final question = await SupabaseService.createQuestion(questionData);
    if (question != null) {
      _questions.insert(0, question);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Create study group
  Future<bool> createStudyGroup(Map<String, dynamic> groupData) async {
    final group = await SupabaseService.createStudyGroup(groupData);
    if (group != null) {
      _studyGroups.insert(0, group);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Create event
  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    final event = await SupabaseService.createEvent(eventData);
    if (event != null) {
      _events.insert(0, event);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Join event
  Future<bool> joinEvent(String eventId) async {
    final success = await SupabaseService.joinEvent(eventId);
    if (success) {
      await loadEvents(); // Reload to get updated attendee count
      return true;
    }
    return false;
  }

  // Leave event
  Future<bool> leaveEvent(String eventId) async {
    final success = await SupabaseService.leaveEvent(eventId);
    if (success) {
      await loadEvents(); // Reload to get updated attendee count
      return true;
    }
    return false;
  }

  // Join club
  Future<bool> joinClub(String clubId) async {
    final success = await SupabaseService.joinClub(clubId);
    if (success) {
      await loadClubs(); // Reload to get updated member count
      return true;
    }
    return false;
  }

  // Leave club
  Future<bool> leaveClub(String clubId) async {
    final success = await SupabaseService.leaveClub(clubId);
    if (success) {
      await loadClubs(); // Reload to get updated member count
      return true;
    }
    return false;
  }

  // Methods
  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    // Reset sub tab index when switching main tabs
    _selectedSubTabIndex = 0;
    notifyListeners();
  }

  void setSelectedSubTab(int index) {
    _selectedSubTabIndex = index;
    notifyListeners();
  }

  void setSelectedTabWithSubTab(int tabIndex, int subTabIndex) {
    _selectedTabIndex = tabIndex;
    _selectedSubTabIndex = subTabIndex;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Authentication methods
  // Trả về null nếu thành công; trả về thông điệp lỗi nếu thất bại
  Future<String?> signUp(String email, String password, Map<String, dynamic> userData) async {
    final errorMessage = await SupabaseService.signUp(email, password, userData);
    if (errorMessage == null) {
      await loadCurrentUser();
    }
    return errorMessage;
  }

  Future<bool> signIn(String email, String password) async {
    final success = await SupabaseService.signIn(email, password);
    if (success) {
      await loadCurrentUser();
    }
    return success;
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    _currentUser = null;
    _isScheduleLoading = false;
    _isCoursesLoading = false;
    _classSchedules = [];
    _courses = [];
    notifyListeners();
  }

  void toggleNotification(int settingId) {
    final index = _notificationSettings.indexWhere((setting) => setting['id'] == settingId);
    if (index != -1) {
      _notificationSettings[index]['enabled'] = !_notificationSettings[index]['enabled'];
      notifyListeners();
    }
  }
}
