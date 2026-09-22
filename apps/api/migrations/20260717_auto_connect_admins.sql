-- Tự động kết nối đồng hành giữa Viện Trưởng và các Phó Viện Trưởng đang hoạt động
INSERT INTO mkw_class_links (id, tutor_id, student_id, status, link_type)
SELECT 
    'lnk-adm-mig-' || u1.id || '-' || u2.id,
    u1.id, 
    u2.id, 
    'active', 
    'admin_connection'
FROM mkw_users u1
CROSS JOIN mkw_users u2
WHERE u1.role = 'truong_vien' 
  AND u2.role = 'pho_vien' 
  AND u1.is_active = TRUE 
  AND u2.is_active = TRUE
ON CONFLICT (tutor_id, student_id) DO NOTHING;
