-- Migration: Upgrade mkw_topics with supplemental metadata fields
-- to support fully database-driven curriculum taxonomy.

ALTER TABLE mkw_topics ADD COLUMN IF NOT EXISTS ham_nguyen_to VARCHAR(50);
ALTER TABLE mkw_topics ADD COLUMN IF NOT EXISTS exam_relevance VARCHAR(20) DEFAULT 'medium';
ALTER TABLE mkw_topics ADD COLUMN IF NOT EXISTS min_questions INTEGER DEFAULT 30;
ALTER TABLE mkw_topics ADD COLUMN IF NOT EXISTS question_types VARCHAR(50)[] DEFAULT ARRAY['mcq']::VARCHAR[];
