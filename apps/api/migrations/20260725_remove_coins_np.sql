-- Migration to clean up legacy coins and NP columns, ensuring ruby is the single source of currency truth.

-- 1. Drop legacy columns from mkw_users if exist
ALTER TABLE mkw_users DROP COLUMN IF EXISTS coins CASCADE;

-- 2. Drop legacy columns from mkw_player_profiles if exist
ALTER TABLE mkw_player_profiles DROP COLUMN IF EXISTS coins CASCADE;

-- 3. Drop legacy columns from mkw_rewards if exist
ALTER TABLE mkw_rewards DROP COLUMN IF EXISTS cost_coins CASCADE;

-- 4. Drop legacy columns from mkw_reward_redemptions if exist
ALTER TABLE mkw_reward_redemptions DROP COLUMN IF EXISTS cost_coins CASCADE;

-- 5. Drop legacy columns from mkw_class_rewards if exist
ALTER TABLE mkw_class_rewards DROP COLUMN IF EXISTS cost_coins CASCADE;

-- 6. Drop legacy columns from mkw_class_reward_redemptions if exist
ALTER TABLE mkw_class_reward_redemptions DROP COLUMN IF EXISTS cost_coins CASCADE;

-- 7. Drop legacy columns from mkw_challenges if exist
ALTER TABLE mkw_challenges DROP COLUMN IF EXISTS reward_coins CASCADE;

-- 8. Drop legacy columns from mkw_game_settings if exist
ALTER TABLE mkw_game_settings DROP COLUMN IF EXISTS base_coins CASCADE;
ALTER TABLE mkw_game_settings DROP COLUMN IF EXISTS boss_completion_bonus_np;
