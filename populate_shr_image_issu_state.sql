-------------------------------------------------------------------
-- Copyright (c) 2006-2007 by cisco Systems, Inc. All rights reserved.
--
-- Funciton:
--  1. back-populate shr_image_issu_state with all entries from shr_image.
--
-- Created by :   nadialee 
-- Created at:    Sept 2006 
-------------------------------------------------------------------
----------------------------------------------------------
-- Commented out only to prevent accidental truncation in 
-- production environment after sprit-issu initial rollout.
----------------------------------------------------------
-- truncate table shr_image_issu_state;

insert into shr_image_issu_state 
select
i.image_id,
ot.os_type_id,  
is1.issu_state_id, 
sysdate,
'nadialee',
sysdate,
'nadialee',
i.adm_flag,
'Back populated from SHR_IAMGE for SPRIT-ISSU' 
from 
    shr_image        i,
    shr_os_type      ot,
    shr_issu_state   is1
where 
    ot.os_type_name = 'IOS'
    and is1.issu_state = 'UNKNOWN'

commit;
