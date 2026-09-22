-- Migration: Rename mkw_family_links to mkw_class_links safely, handling pre-existence
DO $$
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'mkw_family_links') THEN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'mkw_class_links') THEN
      -- If both exist, and mkw_class_links has no rows, drop it to let mkw_family_links be renamed
      IF (SELECT COUNT(*) FROM mkw_class_links) = 0 THEN
        DROP TABLE mkw_class_links CASCADE;
        EXECUTE 'ALTER TABLE mkw_family_links RENAME TO mkw_class_links';
      ELSE
        -- If both tables contain data, copy rows from family to class then drop family
        EXECUTE 'INSERT INTO mkw_class_links SELECT * FROM mkw_family_links ON CONFLICT DO NOTHING';
        DROP TABLE mkw_family_links CASCADE;
      END IF;
    ELSE
      EXECUTE 'ALTER TABLE mkw_family_links RENAME TO mkw_class_links';
    END IF;
  END IF;
END $$;
