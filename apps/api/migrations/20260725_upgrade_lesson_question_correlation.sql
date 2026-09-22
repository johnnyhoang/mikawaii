-- Migration: Upgrade Lesson-Question Correlation Schema
-- Date: 2026-07-25

-- 1. Upgrade mkw_lessons table
ALTER TABLE mkw_lessons ADD COLUMN IF NOT EXISTS topic_id VARCHAR(100);
ALTER TABLE mkw_lessons ADD COLUMN IF NOT EXISTS scope_code VARCHAR(150);

-- Create indexes on mkw_lessons
CREATE INDEX IF NOT EXISTS idx_mkw_lessons_topic_id ON mkw_lessons(topic_id);
CREATE INDEX IF NOT EXISTS idx_mkw_lessons_scope_code ON mkw_lessons(scope_code);

-- 2. Upgrade mkw_custom_questions table
ALTER TABLE mkw_custom_questions ADD COLUMN IF NOT EXISTS topic_id VARCHAR(100);
ALTER TABLE mkw_custom_questions ADD COLUMN IF NOT EXISTS related_lesson_ids TEXT[];
ALTER TABLE mkw_custom_questions ADD COLUMN IF NOT EXISTS pedagogical_phase VARCHAR(50) DEFAULT 'comprehension';
ALTER TABLE mkw_custom_questions ADD COLUMN IF NOT EXISTS scope_code VARCHAR(150);

-- Create indexes on mkw_custom_questions
CREATE INDEX IF NOT EXISTS idx_mkw_questions_topic_id ON mkw_custom_questions(topic_id);
CREATE INDEX IF NOT EXISTS idx_mkw_questions_scope_code ON mkw_custom_questions(scope_code);
CREATE INDEX IF NOT EXISTS idx_mkw_questions_pedagogical_phase ON mkw_custom_questions(pedagogical_phase);

-- 3. Create Lesson-Question Analytics Table for tracking post-study performance
CREATE TABLE IF NOT EXISTS mkw_lesson_question_analytics (
    id SERIAL PRIMARY KEY,
    lesson_id VARCHAR(255) REFERENCES mkw_lessons(id) ON DELETE CASCADE,
    question_id VARCHAR(255) REFERENCES mkw_custom_questions(id) ON DELETE CASCADE,
    times_attempted_post_study INTEGER DEFAULT 0,
    times_correct_post_study INTEGER DEFAULT 0,
    last_attempted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(lesson_id, question_id)
);
