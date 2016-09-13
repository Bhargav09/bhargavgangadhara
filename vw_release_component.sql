/*
    Copyright (c) 2008 by Cisco Systems, Inc.
    created by holchen
*/
CREATE OR REPLACE VIEW VW_RELEASE_COMPONENT_VIEW
as
select 
os_type_id,
release_number_id, 
sm.MAJOR_RELEASE_ID, 
major_release_number,
major_release_number RELEASE_COMPONENT_1,
major_release_number||A RELEASE_COMPONENT_2,
z RELEASE_COMPONENT_3,
p RELEASE_COMPONENT_4,
o RELEASE_COMPONENT_5,
A RELEASE_COMPONENT_6
from shr_major_release sm,
     shr_release_number sr
     where sm.major_release_id=sr.major_release_id
     and sm.adm_flag='V'
     and sr.adm_flag='V'
order by major_release_number     