-- Canonical LearningContext migration: grade + subject are data attributes.
-- Existing canonical content is Grade 9. Grade-specific source files are not
-- imported here; their compatibility adapters will write explicit context.

BEGIN;

ALTER TABLE mkw_lessons ADD COLUMN IF NOT EXISTS grade_tier INTEGER;
UPDATE mkw_lessons SET grade_tier = 9 WHERE grade_tier IS NULL;
ALTER TABLE mkw_lessons ALTER COLUMN grade_tier SET NOT NULL;

ALTER TABLE mkw_custom_questions ADD COLUMN IF NOT EXISTS grade_tier INTEGER;
UPDATE mkw_custom_questions
SET grade_tier = COALESCE(
  grade_tier,
  CASE WHEN metadata->>'gradeTier' ~ '^(6|7|8|9|10|11|12)$'
    THEN (metadata->>'gradeTier')::INTEGER END,
  9
);
ALTER TABLE mkw_custom_questions ALTER COLUMN grade_tier SET NOT NULL;

ALTER TABLE mkw_topics ADD COLUMN IF NOT EXISTS grade_tier INTEGER;
UPDATE mkw_topics SET grade_tier = 9 WHERE grade_tier IS NULL;
ALTER TABLE mkw_topics ALTER COLUMN grade_tier SET NOT NULL;

ALTER TABLE mkw_activities
  ADD COLUMN IF NOT EXISTS grade_tier INTEGER,
  ADD COLUMN IF NOT EXISTS subject VARCHAR(50);
UPDATE mkw_activities activity
SET grade_tier = COALESCE(activity.grade_tier, topic.grade_tier, 9),
    subject = COALESCE(activity.subject, topic.subject)
FROM mkw_topics topic
WHERE topic.id = activity.topic_id
  AND (activity.grade_tier IS NULL OR activity.subject IS NULL);
UPDATE mkw_activities SET grade_tier = 9 WHERE grade_tier IS NULL;
UPDATE mkw_activities SET subject = 'english' WHERE subject IS NULL;
ALTER TABLE mkw_activities ALTER COLUMN grade_tier SET NOT NULL;
ALTER TABLE mkw_activities ALTER COLUMN subject SET NOT NULL;

ALTER TABLE mkw_grade_lesson_progress ADD COLUMN IF NOT EXISTS subject VARCHAR(50);
ALTER TABLE mkw_grade_quiz_results ADD COLUMN IF NOT EXISTS subject VARCHAR(50);
-- These tables are empty in the production preflight. Future writes must pass subject explicitly.
UPDATE mkw_grade_lesson_progress SET subject = 'english' WHERE subject IS NULL;
UPDATE mkw_grade_quiz_results SET subject = 'english' WHERE subject IS NULL;
ALTER TABLE mkw_grade_lesson_progress ALTER COLUMN subject SET NOT NULL;
ALTER TABLE mkw_grade_quiz_results ALTER COLUMN subject SET NOT NULL;
ALTER TABLE mkw_game_sessions ADD COLUMN IF NOT EXISTS grade_tier INTEGER;
UPDATE mkw_game_sessions SET grade_tier = 9 WHERE grade_tier IS NULL;
ALTER TABLE mkw_game_sessions ALTER COLUMN grade_tier SET NOT NULL;
ALTER TABLE mkw_grade_lesson_progress DROP CONSTRAINT IF EXISTS mkw_grade_lesson_progress_pkey;
ALTER TABLE mkw_grade_lesson_progress ADD PRIMARY KEY (user_id, grade_tier, subject, lesson_id);

CREATE INDEX IF NOT EXISTS idx_mkw_lessons_context ON mkw_lessons (grade_tier, subject);
CREATE INDEX IF NOT EXISTS idx_mkw_questions_context ON mkw_custom_questions (grade_tier, subject);
CREATE INDEX IF NOT EXISTS idx_mkw_topics_context ON mkw_topics (grade_tier, subject);
CREATE INDEX IF NOT EXISTS idx_mkw_activities_context ON mkw_activities (grade_tier, subject);
CREATE INDEX IF NOT EXISTS idx_mkw_lesson_progress_context ON mkw_grade_lesson_progress (user_id, grade_tier, subject);
CREATE INDEX IF NOT EXISTS idx_mkw_quiz_results_context ON mkw_grade_quiz_results (user_id, grade_tier, subject);
CREATE INDEX IF NOT EXISTS idx_mkw_game_sessions_context ON mkw_game_sessions (user_id, grade_tier, subject);

COMMIT;
