-- Migration: Dọn dẹp profile trùng lặp và tạo UNIQUE INDEX để ngăn chặn tạo trùng lặp trong tương lai.
-- Cập nhật: 2026-07-17

DO $$
DECLARE
    r RECORD;
    v_primary_id VARCHAR(255);
    v_duplicate_id VARCHAR(255);
BEGIN
    -- 1. Duyệt qua từng nhóm tài khoản bị trùng lặp vai trò (role)
    FOR r IN 
        SELECT account_id, role 
        FROM mkw_users 
        GROUP BY account_id, role 
        HAVING COUNT(*) > 1
    LOOP
        -- Lấy ID của profile được tạo đầu tiên làm profile chính để giữ lại
        SELECT id INTO v_primary_id 
        FROM mkw_users 
        WHERE account_id = r.account_id AND role = r.role 
        ORDER BY created_at ASC 
        LIMIT 1;

        -- Duyệt qua các profile trùng lặp khác (profile phụ cần xóa)
        FOR v_duplicate_id IN 
            SELECT id 
            FROM mkw_users 
            WHERE account_id = r.account_id AND role = r.role AND id <> v_primary_id
        LOOP
            RAISE NOTICE 'Merging duplicate profile % into primary profile % for account % (% role)', 
                v_duplicate_id, v_primary_id, r.account_id, r.role;

            -- Cập nhật các bảng liên kết để trỏ sang profile chính

            -- Bảng mkw_class_links (đảm bảo không gây lỗi trùng khoá)
            BEGIN
                UPDATE mkw_class_links SET tutor_id = v_primary_id WHERE tutor_id = v_duplicate_id;
            EXCEPTION WHEN OTHERS THEN
                DELETE FROM mkw_class_links WHERE tutor_id = v_duplicate_id;
            END;

            BEGIN
                UPDATE mkw_class_links SET student_id = v_primary_id WHERE student_id = v_duplicate_id;
            EXCEPTION WHEN OTHERS THEN
                DELETE FROM mkw_class_links WHERE student_id = v_duplicate_id;
            END;

            -- Gộp Ruby và XP tích luỹ từ profile phụ sang profile chính trước khi xoá
            UPDATE mkw_player_profiles p_main
            SET 
                xp = p_main.xp + COALESCE(p_dup.xp, 0),
                ruby = p_main.ruby + COALESCE(p_dup.ruby, 0),
                level = GREATEST(p_main.level, COALESCE(p_dup.level, 1))
            FROM mkw_player_profiles p_dup
            WHERE p_main.user_id = v_primary_id AND p_dup.user_id = v_duplicate_id;

            -- Xoá bản ghi khoá chính trùng lặp trong các bảng 1-1
            DELETE FROM mkw_player_profiles WHERE user_id = v_duplicate_id;
            DELETE FROM mkw_pet_states WHERE user_id = v_duplicate_id;
            DELETE FROM mkw_user_challenges WHERE user_id = v_duplicate_id;
            DELETE FROM mkw_daily_missions WHERE user_id = v_duplicate_id;

            -- Cập nhật các bảng nhật ký và hoạt động khác sang profile chính
            UPDATE mkw_category_stats SET user_id = v_primary_id WHERE user_id = v_duplicate_id;
            UPDATE mkw_history_logs SET user_id = v_primary_id WHERE user_id = v_duplicate_id;
            UPDATE mkw_reward_redemptions SET user_id = v_primary_id WHERE user_id = v_duplicate_id;
            UPDATE mkw_custom_questions SET user_id = v_primary_id WHERE user_id = v_duplicate_id;
            UPDATE mkw_student_question_performance SET student_id = v_primary_id WHERE student_id = v_duplicate_id;
            UPDATE mkw_user_lessons_progress SET user_id = v_primary_id WHERE user_id = v_duplicate_id;
            UPDATE mkw_exploration_progress SET user_id = v_primary_id WHERE user_id = v_duplicate_id;
            UPDATE mkw_riddle_history SET profile_id = v_primary_id WHERE profile_id = v_duplicate_id;
            UPDATE mkw_audit_logs SET actor_id = v_primary_id WHERE actor_id = v_duplicate_id;
            UPDATE mkw_skip_reviews SET student_id = v_primary_id WHERE student_id = v_duplicate_id;
            UPDATE mkw_game_sessions SET user_id = v_primary_id WHERE user_id = v_duplicate_id;
            UPDATE mkw_grade_lesson_progress SET user_id = v_primary_id WHERE user_id = v_duplicate_id;
            UPDATE mkw_grade_quiz_results SET user_id = v_primary_id WHERE user_id = v_duplicate_id;
            UPDATE mkw_user_activity_progress SET user_id = v_primary_id WHERE user_id = v_duplicate_id;

            -- Cuối cùng, xoá profile phụ khỏi bảng users
            DELETE FROM mkw_users WHERE id = v_duplicate_id;
        END LOOP;
    END LOOP;
END $$;

-- 2. Tạo UNIQUE INDEX trên cặp (account_id, role) để chặn triệt để việc tạo trùng lặp
CREATE UNIQUE INDEX IF NOT EXISTS mkw_users_account_role_uniq_idx ON mkw_users (account_id, role);
