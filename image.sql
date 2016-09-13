--Copyright (c) 2004 by Cisco Systems, Inc.
CREATE OR REPLACE VIEW IMAGE ( IMAGE, 
RELEASE, MAINTENANCE, MRENUMBER, ED_DESIGNATOR, 
ED_RENUMBER, OBSOLETE ) AS SELECT DISTINCT i.image_name, m.major_release_number, r.z, r.p, r.a, r.o,
i.is_obsolete
FROM shr_image i,
shr_release_number r,
shr_major_release m
WHERE r.major_release_id = m.major_release_id
AND i.release_number_id = r.release_number_id
AND i.is_obsolete = 'N' AND i.is_in_image_list = 'Y' and r.release_type_id in (1,4,5)
AND i.adm_flag = 'V' AND r.adm_flag = 'V' AND m.adm_flag = 'V';
