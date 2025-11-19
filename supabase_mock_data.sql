-- Mock Data for Phenikaa Connect App
-- Insert sample data into Supabase tables

-- Insert sample users
INSERT INTO users (id, email, student_id, name, major, year, phone, interests) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'nguyen.van.a@phenikaa.edu.vn', 'PH12345', 'Nguyễn Văn A', 'Khoa học máy tính', 'Năm 3', '0123456789', ARRAY['Lập trình', 'AI', 'Machine Learning']),
('550e8400-e29b-41d4-a716-446655440002', 'tran.thi.b@phenikaa.edu.vn', 'PH12346', 'Trần Thị B', 'Quản trị kinh doanh', 'Năm 2', '0123456790', ARRAY['Marketing', 'Tài chính', 'Khởi nghiệp']),
('550e8400-e29b-41d4-a716-446655440003', 'le.van.c@phenikaa.edu.vn', 'PH12347', 'Lê Văn C', 'Kỹ thuật điện tử', 'Năm 4', '0123456791', ARRAY['Robotics', 'IoT', 'Bền vững']),
('550e8400-e29b-41d4-a716-446655440004', 'pham.thi.d@phenikaa.edu.vn', 'PH12348', 'Phạm Thị D', 'Thiết kế đồ họa', 'Năm 1', '0123456792', ARRAY['UI/UX', 'Illustration', 'Branding']),
('550e8400-e29b-41d4-a716-446655440005', 'hoang.van.e@phenikaa.edu.vn', 'PH12349', 'Hoàng Văn E', 'Khoa học máy tính', 'Năm 3', '0123456793', ARRAY['Web Development', 'Mobile App', 'Database']);

-- Insert sample posts
INSERT INTO posts (id, user_id, content, likes_count, comments_count, shares_count) VALUES
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Hôm nay học về Machine Learning, rất thú vị! Ai có kinh nghiệm về TensorFlow không?', 15, 8, 3),
('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'Chia sẻ một số tips học Marketing hiệu quả cho các bạn năm 1, 2. Hy vọng sẽ hữu ích!', 23, 12, 7),
('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'Project IoT của mình đã hoàn thành! Cảm ơn các bạn đã hỗ trợ trong quá trình làm.', 31, 18, 5),
('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', 'Thiết kế logo mới cho CLB Design, các bạn thấy thế nào?', 42, 25, 12),
('660e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', 'Tìm bạn cùng học Flutter, có ai quan tâm không?', 8, 5, 2);

-- Insert sample post likes
INSERT INTO post_likes (post_id, user_id) VALUES
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002'),
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003'),
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005'),
('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),
('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003'),
('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001'),
('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002'),
('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001'),
('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002'),
('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440003');

-- Insert sample comments
INSERT INTO comments (post_id, user_id, content) VALUES
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Mình cũng đang học ML, có thể trao đổi thêm không?'),
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003', 'TensorFlow khá khó nhưng rất mạnh, bạn có thể thử PyTorch xem'),
('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Cảm ơn bạn đã chia sẻ, rất hữu ích!'),
('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'Chúc mừng bạn! Project trông rất ấn tượng'),
('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'Logo đẹp quá! Bạn có thể chia sẻ quá trình thiết kế không?');

-- Insert sample questions
INSERT INTO questions (id, user_id, course, title, content, replies_count, solved) VALUES
('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Machine Learning', 'Làm sao để optimize model accuracy?', 'Mình đang làm project ML nhưng accuracy chỉ đạt 75%. Có cách nào để cải thiện không?', 3, false),
('770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'Marketing', 'Chiến lược marketing cho startup', 'Các bạn có kinh nghiệm về marketing cho startup không? Cần lời khuyên về digital marketing.', 2, true),
('770e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'IoT', 'Kết nối sensor với Arduino', 'Mình gặp vấn đề khi kết nối DHT22 với Arduino Uno. Có ai biết cách fix không?', 1, false),
('770e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', 'Design', 'Nguyên tắc thiết kế UI/UX', 'Mình mới học UI/UX, có nguyên tắc nào quan trọng cần nhớ không?', 4, false),
('770e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', 'Flutter', 'State management trong Flutter', 'Nên dùng Provider hay Bloc cho state management? Ưu nhược điểm của từng cách?', 2, false);

-- Insert sample question replies
INSERT INTO question_replies (question_id, user_id, content, is_solution) VALUES
('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Bạn thử tăng số lượng features hoặc sử dụng ensemble methods xem', false),
('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003', 'Có thể thử cross-validation để kiểm tra overfitting', false),
('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', 'Feature engineering cũng rất quan trọng, bạn thử normalize data chưa?', false),
('770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Digital marketing hiệu quả nhất là content marketing + SEO', true),
('770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003', 'Social media marketing cũng rất quan trọng cho startup', false);

-- Insert sample study groups
INSERT INTO study_groups (id, creator_id, course, name, description, meet_time, location, max_members, members_count) VALUES
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Machine Learning', 'ML Study Group', 'Nhóm học Machine Learning cùng nhau, chia sẻ kiến thức và làm project', 'Thứ 3, 5 - 19:00', 'Thư viện tầng 3', 8, 5),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'Marketing', 'Marketing Club', 'Nhóm học Marketing, thảo luận case study và chiến lược', 'Thứ 2, 4 - 18:30', 'Phòng học A101', 10, 7),
('880e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'IoT', 'IoT Developers', 'Nhóm phát triển IoT, làm project thực tế', 'Thứ 6 - 19:00', 'Lab IoT', 6, 4),
('880e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', 'Design', 'Design Workshop', 'Workshop thiết kế, chia sẻ kinh nghiệm UI/UX', 'Chủ nhật - 14:00', 'Studio Design', 12, 9),
('880e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', 'Flutter', 'Flutter Study Group', 'Nhóm học Flutter development', 'Thứ 7 - 15:00', 'Phòng máy tính', 8, 6);

-- Insert study group members
INSERT INTO study_group_members (group_id, user_id) VALUES
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002'),
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003'),
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004'),
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005'),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002'),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440003'),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004'),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440005');

-- Insert sample class schedules
INSERT INTO class_schedules (id, user_id, day_of_week, start_time, end_time, subject, room, instructor, color) VALUES
('aa1e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Monday', '07:30:00', '09:00:00', 'Giải tích 2', 'A101', 'TS. Nguyễn Minh', '#3B82F6'),
('aa1e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Monday', '09:15:00', '11:00:00', 'Cấu trúc dữ liệu', 'Lab B203', 'ThS. Phạm Hoàng', '#6366F1'),
('aa1e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'Tuesday', '08:00:00', '09:30:00', 'Xác suất thống kê', 'A205', 'TS. Lê Hồng', '#10B981'),
('aa1e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001', 'Wednesday', '13:30:00', '15:30:00', 'Lập trình Flutter', 'Lab C101', 'ThS. Đinh Quang', '#F59E0B'),
('aa1e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440001', 'Thursday', '07:30:00', '09:30:00', 'Hệ điều hành', 'B102', 'TS. Nguyễn An', '#EF4444'),
('aa1e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440001', 'Friday', '09:45:00', '11:15:00', 'Kỹ năng mềm', 'A302', 'TS. Trần Mai', '#0EA5E9'),
('aa1e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440002', 'Monday', '10:00:00', '12:00:00', 'Nguyên lý Marketing', 'C201', 'ThS. Lưu Hạnh', '#EC4899'),
('aa1e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440002', 'Wednesday', '08:00:00', '09:30:00', 'Quản trị tài chính', 'B301', 'TS. Hà Yến', '#84CC16'),
('aa1e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440002', 'Friday', '13:30:00', '15:00:00', 'Kỹ năng thuyết trình', 'A401', 'ThS. Võ Nam', '#F97316');

-- Insert sample courses (per user)
INSERT INTO courses (id, user_id, name, code, instructor, questions, members, progress, color) VALUES
('cc1e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Cấu trúc dữ liệu', 'CS201', 'ThS. Phạm Hoàng', 12, 45, 65, '#6366F1'),
('cc1e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Lập trình Flutter', 'CS305', 'ThS. Đinh Quang', 8, 38, 40, '#F97316'),
('cc1e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'Hệ điều hành', 'CS210', 'TS. Nguyễn An', 6, 42, 55, '#0EA5E9'),
('cc1e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001', 'Xác suất thống kê', 'MA203', 'TS. Lê Hồng', 4, 35, 80, '#10B981'),
('cc1e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440002', 'Chiến lược Marketing', 'MK202', 'TS. Trương Lan', 10, 50, 70, '#EC4899'),
('cc1e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440002', 'Phân tích tài chính', 'FN301', 'TS. Hà Yến', 5, 32, 45, '#84CC16'),
('cc1e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440002', 'Kỹ năng thuyết trình', 'SK105', 'ThS. Võ Nam', 2, 28, 90, '#FBBF24');

-- Insert sample events
INSERT INTO events (id, organizer_id, title, description, event_date, event_time, location, category, max_attendees, attendees_count) VALUES
('990e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'AI Workshop 2024', 'Workshop về trí tuệ nhân tạo và ứng dụng thực tế', '2024-12-15', '09:00:00', 'Hội trường A', 'Học thuật', 100, 45),
('990e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'Startup Pitch Competition', 'Cuộc thi pitch ý tưởng khởi nghiệp', '2024-12-20', '14:00:00', 'Phòng họp lớn', 'Khởi nghiệp', 50, 23),
('990e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'IoT Exhibition', 'Triển lãm các sản phẩm IoT của sinh viên', '2024-12-25', '10:00:00', 'Sảnh chính', 'Triển lãm', 200, 78),
('990e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', 'Design Portfolio Review', 'Đánh giá portfolio thiết kế của sinh viên', '2024-12-30', '15:00:00', 'Studio Design', 'Nghệ thuật', 30, 18),
('990e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', 'Flutter Meetup', 'Gặp gỡ và chia sẻ kinh nghiệm Flutter', '2025-01-05', '19:00:00', 'Phòng máy tính', 'Công nghệ', 40, 25);

-- Insert event attendees
INSERT INTO event_attendees (event_id, user_id) VALUES
('990e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
('990e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002'),
('990e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003'),
('990e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002'),
('990e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),
('990e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003'),
('990e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001'),
('990e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004'),
('990e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002'),
('990e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005');

-- Insert sample locations
INSERT INTO locations (id, name, type, building, floor, description, popular) VALUES
('aa0e8400-e29b-41d4-a716-446655440001', 'Thư viện chính', 'Thư viện', 'Tòa A', 'Tầng 1-5', 'Thư viện chính của trường với đầy đủ tài liệu', true),
('aa0e8400-e29b-41d4-a716-446655440002', 'Phòng máy tính A101', 'Phòng học', 'Tòa A', 'Tầng 1', 'Phòng máy tính với 50 máy', true),
('aa0e8400-e29b-41d4-a716-446655440003', 'Lab IoT', 'Phòng thí nghiệm', 'Tòa B', 'Tầng 2', 'Phòng thí nghiệm IoT và Robotics', false),
('aa0e8400-e29b-41d4-a716-446655440004', 'Studio Design', 'Phòng học', 'Tòa C', 'Tầng 3', 'Studio thiết kế với đầy đủ thiết bị', false),
('aa0e8400-e29b-41d4-a716-446655440005', 'Hội trường A', 'Hội trường', 'Tòa A', 'Tầng 1', 'Hội trường lớn cho các sự kiện', true),
('aa0e8400-e29b-41d4-a716-446655440006', 'Cafeteria', 'Ăn uống', 'Tòa D', 'Tầng 1', 'Căng tin của trường', true),
('aa0e8400-e29b-41d4-a716-446655440007', 'Phòng họp lớn', 'Phòng họp', 'Tòa A', 'Tầng 2', 'Phòng họp cho các cuộc họp quan trọng', false),
('aa0e8400-e29b-41d4-a716-446655440008', 'Sảnh chính', 'Sảnh', 'Tòa A', 'Tầng 1', 'Sảnh chính của trường', true);

-- Insert sample clubs
INSERT INTO clubs (id, name, description, category, members_count, active) VALUES
('bb0e8400-e29b-41d4-a716-446655440001', 'CLB Lập trình', 'Câu lạc bộ lập trình và phát triển phần mềm', 'Công nghệ', 25, true),
('bb0e8400-e29b-41d4-a716-446655440002', 'CLB Design', 'Câu lạc bộ thiết kế đồ họa và UI/UX', 'Nghệ thuật', 18, true),
('bb0e8400-e29b-41d4-a716-446655440003', 'CLB Khởi nghiệp', 'Câu lạc bộ khởi nghiệp và kinh doanh', 'Kinh doanh', 22, true),
('bb0e8400-e29b-41d4-a716-446655440004', 'CLB Robotics', 'Câu lạc bộ robotics và IoT', 'Kỹ thuật', 15, true),
('bb0e8400-e29b-41d4-a716-446655440005', 'CLB Marketing', 'Câu lạc bộ marketing và truyền thông', 'Truyền thông', 20, true);

-- Insert club members
INSERT INTO club_members (club_id, user_id, role) VALUES
('bb0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'president'),
('bb0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440005', 'admin'),
('bb0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', 'president'),
('bb0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'member'),
('bb0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 'president'),
('bb0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'member'),
('bb0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440003', 'president'),
('bb0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001', 'member'),
('bb0e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440002', 'president'),
('bb0e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440004', 'member');

-- Insert sample announcements
INSERT INTO announcements (id, title, content, priority, target_audience, created_by) VALUES
('cc0e8400-e29b-41d4-a716-446655440001', 'Thông báo nghỉ học ngày 25/12', 'Trường sẽ nghỉ học ngày 25/12 để sinh viên có thời gian nghỉ ngơi. Các lớp học sẽ được bù vào tuần sau.', 'high', 'all', '550e8400-e29b-41d4-a716-446655440001'),
('cc0e8400-e29b-41d4-a716-446655440002', 'Đăng ký học kỳ mới', 'Sinh viên có thể đăng ký học kỳ mới từ ngày 1/1/2025. Vui lòng hoàn thành đăng ký trước ngày 15/1.', 'normal', 'all', '550e8400-e29b-41d4-a716-446655440001'),
('cc0e8400-e29b-41d4-a716-446655440003', 'Cuộc thi lập trình Phenikaa 2025', 'Cuộc thi lập trình Phenikaa sẽ được tổ chức vào tháng 2/2025. Đăng ký từ ngày 1/1.', 'normal', 'Khoa học máy tính', '550e8400-e29b-41d4-a716-446655440001'),
('cc0e8400-e29b-41d4-a716-446655440004', 'Thông báo về dịch vụ thư viện', 'Thư viện sẽ mở cửa 24/7 trong thời gian thi. Sinh viên có thể sử dụng không gian học tập.', 'low', 'all', '550e8400-e29b-41d4-a716-446655440001'),
('cc0e8400-e29b-41d4-a716-446655440005', 'Workshop AI sắp tới', 'Workshop về trí tuệ nhân tạo sẽ được tổ chức vào ngày 15/12. Đăng ký miễn phí.', 'normal', 'all', '550e8400-e29b-41d4-a716-446655440001');

-- Insert sample chat rooms
INSERT INTO chat_rooms (id, name, type, created_by) VALUES
('dd0e8400-e29b-41d4-a716-446655440001', 'ML Study Group Chat', 'group', '550e8400-e29b-41d4-a716-446655440001'),
('dd0e8400-e29b-41d4-a716-446655440002', 'Marketing Club Chat', 'group', '550e8400-e29b-41d4-a716-446655440002'),
('dd0e8400-e29b-41d4-a716-446655440003', 'IoT Developers Chat', 'group', '550e8400-e29b-41d4-a716-446655440003'),
('dd0e8400-e29b-41d4-a716-446655440004', 'Design Workshop Chat', 'group', '550e8400-e29b-41d4-a716-446655440004'),
('dd0e8400-e29b-41d4-a716-446655440005', 'Flutter Study Group Chat', 'group', '550e8400-e29b-41d4-a716-446655440005');

-- Insert chat room members
INSERT INTO chat_room_members (room_id, user_id) VALUES
('dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001'),
('dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002'),
('dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003'),
('dd0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002'),
('dd0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001'),
('dd0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003'),
('dd0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001'),
('dd0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004'),
('dd0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002'),
('dd0e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005');

-- Insert sample messages
INSERT INTO messages (room_id, user_id, content, message_type) VALUES
('dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Chào mọi người! Hôm nay chúng ta sẽ học về Neural Networks', 'text'),
('dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Tuyệt! Mình đã chuẩn bị bài rồi', 'text'),
('dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440003', 'Có ai có tài liệu về CNN không?', 'text'),
('dd0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'Hôm nay chúng ta sẽ thảo luận về Digital Marketing', 'text'),
('dd0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Mình có case study hay để chia sẻ', 'text'),
('dd0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'Project IoT của mình đã hoàn thành!', 'text'),
('dd0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'Chúc mừng! Có thể demo cho mọi người xem không?', 'text'),
('dd0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', 'Workshop thiết kế sẽ bắt đầu lúc 2h chiều', 'text'),
('dd0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'Mình sẽ đến đúng giờ', 'text'),
('dd0e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', 'Buổi học Flutter hôm nay sẽ về State Management', 'text');
