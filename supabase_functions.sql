-- Supabase Functions and Procedures
-- These functions help with common operations like incrementing/decrementing counters

-- Function to increment likes count
CREATE OR REPLACE FUNCTION increment_likes(post_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE posts 
    SET likes_count = likes_count + 1 
    WHERE id = post_id;
END;
$$ LANGUAGE plpgsql;

-- Function to decrement likes count
CREATE OR REPLACE FUNCTION decrement_likes(post_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE posts 
    SET likes_count = GREATEST(likes_count - 1, 0) 
    WHERE id = post_id;
END;
$$ LANGUAGE plpgsql;

-- Function to increment comments count
CREATE OR REPLACE FUNCTION increment_comments(post_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE posts 
    SET comments_count = comments_count + 1 
    WHERE id = post_id;
END;
$$ LANGUAGE plpgsql;

-- Function to decrement comments count
CREATE OR REPLACE FUNCTION decrement_comments(post_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE posts 
    SET comments_count = GREATEST(comments_count - 1, 0) 
    WHERE id = post_id;
END;
$$ LANGUAGE plpgsql;

-- Function to increment shares count
CREATE OR REPLACE FUNCTION increment_shares(post_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE posts 
    SET shares_count = shares_count + 1 
    WHERE id = post_id;
END;
$$ LANGUAGE plpgsql;

-- Function to increment replies count for questions
CREATE OR REPLACE FUNCTION increment_question_replies(question_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE questions 
    SET replies_count = replies_count + 1 
    WHERE id = question_id;
END;
$$ LANGUAGE plpgsql;

-- Function to decrement replies count for questions
CREATE OR REPLACE FUNCTION decrement_question_replies(question_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE questions 
    SET replies_count = GREATEST(replies_count - 1, 0) 
    WHERE id = question_id;
END;
$$ LANGUAGE plpgsql;

-- Function to increment members count for study groups
CREATE OR REPLACE FUNCTION increment_study_group_members(group_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE study_groups 
    SET members_count = members_count + 1 
    WHERE id = group_id;
END;
$$ LANGUAGE plpgsql;

-- Function to decrement members count for study groups
CREATE OR REPLACE FUNCTION decrement_study_group_members(group_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE study_groups 
    SET members_count = GREATEST(members_count - 1, 0) 
    WHERE id = group_id;
END;
$$ LANGUAGE plpgsql;

-- Function to increment attendees count for events
CREATE OR REPLACE FUNCTION increment_event_attendees(event_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE events 
    SET attendees_count = attendees_count + 1 
    WHERE id = event_id;
END;
$$ LANGUAGE plpgsql;

-- Function to decrement attendees count for events
CREATE OR REPLACE FUNCTION decrement_event_attendees(event_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE events 
    SET attendees_count = GREATEST(attendees_count - 1, 0) 
    WHERE id = event_id;
END;
$$ LANGUAGE plpgsql;

-- Function to increment members count for clubs
CREATE OR REPLACE FUNCTION increment_club_members(club_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE clubs 
    SET members_count = members_count + 1 
    WHERE id = club_id;
END;
$$ LANGUAGE plpgsql;

-- Function to decrement members count for clubs
CREATE OR REPLACE FUNCTION decrement_club_members(club_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE clubs 
    SET members_count = GREATEST(members_count - 1, 0) 
    WHERE id = club_id;
END;
$$ LANGUAGE plpgsql;

-- Triggers to automatically update counters

-- Trigger for comments
CREATE OR REPLACE FUNCTION handle_comment_insert()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM increment_comments(NEW.post_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION handle_comment_delete()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM decrement_comments(OLD.post_id);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_comment_insert
    AFTER INSERT ON comments
    FOR EACH ROW EXECUTE FUNCTION handle_comment_insert();

CREATE TRIGGER on_comment_delete
    AFTER DELETE ON comments
    FOR EACH ROW EXECUTE FUNCTION handle_comment_delete();

-- Trigger for question replies
CREATE OR REPLACE FUNCTION handle_question_reply_insert()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM increment_question_replies(NEW.question_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION handle_question_reply_delete()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM decrement_question_replies(OLD.question_id);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_question_reply_insert
    AFTER INSERT ON question_replies
    FOR EACH ROW EXECUTE FUNCTION handle_question_reply_insert();

CREATE TRIGGER on_question_reply_delete
    AFTER DELETE ON question_replies
    FOR EACH ROW EXECUTE FUNCTION handle_question_reply_delete();

-- Trigger for study group members
CREATE OR REPLACE FUNCTION handle_study_group_member_insert()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM increment_study_group_members(NEW.group_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION handle_study_group_member_delete()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM decrement_study_group_members(OLD.group_id);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_study_group_member_insert
    AFTER INSERT ON study_group_members
    FOR EACH ROW EXECUTE FUNCTION handle_study_group_member_insert();

CREATE TRIGGER on_study_group_member_delete
    AFTER DELETE ON study_group_members
    FOR EACH ROW EXECUTE FUNCTION handle_study_group_member_delete();

-- Trigger for event attendees
CREATE OR REPLACE FUNCTION handle_event_attendee_insert()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM increment_event_attendees(NEW.event_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION handle_event_attendee_delete()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM decrement_event_attendees(OLD.event_id);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_event_attendee_insert
    AFTER INSERT ON event_attendees
    FOR EACH ROW EXECUTE FUNCTION handle_event_attendee_insert();

CREATE TRIGGER on_event_attendee_delete
    AFTER DELETE ON event_attendees
    FOR EACH ROW EXECUTE FUNCTION handle_event_attendee_delete();

-- Trigger for club members
CREATE OR REPLACE FUNCTION handle_club_member_insert()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM increment_club_members(NEW.club_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION handle_club_member_delete()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM decrement_club_members(OLD.club_id);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_club_member_insert
    AFTER INSERT ON club_members
    FOR EACH ROW EXECUTE FUNCTION handle_club_member_insert();

CREATE TRIGGER on_club_member_delete
    AFTER DELETE ON club_members
    FOR EACH ROW EXECUTE FUNCTION handle_club_member_delete();
