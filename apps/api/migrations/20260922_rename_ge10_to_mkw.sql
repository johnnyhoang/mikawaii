-- Migration: Rename all mkw_* tables, functions, and permissions to mkw_* for Mikawaii Academy
BEGIN;

-- 1. Rename all tables
ALTER TABLE IF EXISTS ge10_users RENAME TO mkw_users;
ALTER TABLE IF EXISTS ge10_class_links RENAME TO mkw_class_links;
ALTER TABLE IF EXISTS ge10_player_profiles RENAME TO mkw_player_profiles;
ALTER TABLE IF EXISTS ge10_pet_states RENAME TO mkw_pet_states;
ALTER TABLE IF EXISTS ge10_category_stats RENAME TO mkw_category_stats;
ALTER TABLE IF EXISTS ge10_history_logs RENAME TO mkw_history_logs;
ALTER TABLE IF EXISTS ge10_school_reward_templates RENAME TO mkw_school_reward_templates;
ALTER TABLE IF EXISTS ge10_reward_redemptions RENAME TO mkw_reward_redemptions;
ALTER TABLE IF EXISTS ge10_user_challenges RENAME TO mkw_user_challenges;
ALTER TABLE IF EXISTS ge10_daily_missions RENAME TO mkw_daily_missions;
ALTER TABLE IF EXISTS ge10_game_settings RENAME TO mkw_game_settings;
ALTER TABLE IF EXISTS ge10_custom_questions RENAME TO mkw_custom_questions;
ALTER TABLE IF EXISTS ge10_question_stats RENAME TO mkw_question_stats;
ALTER TABLE IF EXISTS ge10_student_question_performance RENAME TO mkw_student_question_performance;
ALTER TABLE IF EXISTS ge10_lessons RENAME TO mkw_lessons;
ALTER TABLE IF EXISTS ge10_user_lessons_progress RENAME TO mkw_user_lessons_progress;
ALTER TABLE IF EXISTS ge10_exploration_progress RENAME TO mkw_exploration_progress;
ALTER TABLE IF EXISTS ge10_riddle_history RENAME TO mkw_riddle_history;
ALTER TABLE IF EXISTS ge10_audit_logs RENAME TO mkw_audit_logs;
ALTER TABLE IF EXISTS ge10_skip_reviews RENAME TO mkw_skip_reviews;
ALTER TABLE IF EXISTS ge10_game_sessions RENAME TO mkw_game_sessions;
ALTER TABLE IF EXISTS ge10_grade_lesson_progress RENAME TO mkw_grade_lesson_progress;
ALTER TABLE IF EXISTS ge10_grade_quiz_results RENAME TO mkw_grade_quiz_results;
ALTER TABLE IF EXISTS ge10_topics RENAME TO mkw_topics;
ALTER TABLE IF EXISTS ge10_activities RENAME TO mkw_activities;
ALTER TABLE IF EXISTS ge10_user_activity_progress RENAME TO mkw_user_activity_progress;
ALTER TABLE IF EXISTS ge10_tutor_quests RENAME TO mkw_tutor_quests;
ALTER TABLE IF EXISTS ge10_handbook_pages RENAME TO mkw_handbook_pages;
ALTER TABLE IF EXISTS ge10_english_island_items RENAME TO mkw_english_island_items;
ALTER TABLE IF EXISTS ge10_subject_exam_blueprints RENAME TO mkw_subject_exam_blueprints;
ALTER TABLE IF EXISTS ge10_challenge_templates RENAME TO mkw_challenge_templates;
ALTER TABLE IF EXISTS ge10_class_rewards RENAME TO mkw_class_rewards;
ALTER TABLE IF EXISTS ge10_class_reward_redemptions RENAME TO mkw_class_reward_redemptions;
ALTER TABLE IF EXISTS ge10_mission_definitions RENAME TO mkw_mission_definitions;
ALTER TABLE IF EXISTS ge10_profile_mission_assignments RENAME TO mkw_profile_mission_assignments;
ALTER TABLE IF EXISTS ge10_learning_events RENAME TO mkw_learning_events;
ALTER TABLE IF EXISTS ge10_mission_reward_ledger RENAME TO mkw_mission_reward_ledger;
ALTER TABLE IF EXISTS ge10_textbook_mappings RENAME TO mkw_textbook_mappings;
ALTER TABLE IF EXISTS ge10_curriculum_textbooks RENAME TO mkw_curriculum_textbooks;
ALTER TABLE IF EXISTS ge10_match_pairs RENAME TO mkw_match_pairs;
ALTER TABLE IF EXISTS ge10_lesson_question_analytics RENAME TO mkw_lesson_question_analytics;
ALTER TABLE IF EXISTS ge10_reference_exams RENAME TO mkw_reference_exams;

-- 2. Stored Function
CREATE OR REPLACE FUNCTION mkw_process_ruby_transaction(p_user_id VARCHAR, p_amount INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    current_ruby INTEGER;
BEGIN
    SELECT ruby INTO current_ruby
    FROM mkw_player_profiles 
    WHERE user_id = p_user_id 
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    IF current_ruby + p_amount < 0 THEN
        RETURN FALSE;
    END IF;

    UPDATE mkw_player_profiles
    SET ruby = ruby + p_amount, server_updated_at = NOW()
    WHERE user_id = p_user_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- 3. Lock Mikawaii Academy application data behind authenticated Express API with RLS
DO $$
DECLARE
  target_table regclass;
BEGIN
  FOR target_table IN
    SELECT c.oid::regclass
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relkind = 'r'
      AND c.relname LIKE 'mkw\_%' ESCAPE '\'
  LOOP
    EXECUTE format('REVOKE ALL PRIVILEGES ON TABLE %s FROM anon, authenticated', target_table);
    EXECUTE format('ALTER TABLE %s ENABLE ROW LEVEL SECURITY', target_table);
  END LOOP;
END $$;

COMMIT;
