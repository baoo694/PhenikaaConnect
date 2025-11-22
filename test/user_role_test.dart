import 'package:flutter_test/flutter_test.dart';
import 'package:phenikaa_connect_app/models/user.dart';

void main() {
  group('User role parsing', () {
    test('parseUserRole maps strings correctly', () {
      expect(parseUserRole('admin'), UserRole.admin);
      expect(parseUserRole('club_leader'), UserRole.clubLeader);
      expect(parseUserRole(null), UserRole.user);
      expect(parseUserRole('unknown'), UserRole.user);
    });

    test('User.fromJson hydrates role properties', () {
      final json = {
        'id': '1',
        'name': 'Admin',
        'student_id': 'S001',
        'major': 'IT',
        'year': '2024',
        'email': 'admin@example.com',
        'phone': '123456',
        'role': 'admin',
        'account_status': 'active',
        'is_locked': false,
        'metadata': {'department': 'ICT'},
      };

      final user = User.fromJson(json);
      expect(user.role, UserRole.admin);
      expect(user.accountStatus, 'active');
      expect(user.metadata['department'], 'ICT');
    });
  });
}

