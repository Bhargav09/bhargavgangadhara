-------------------------------------------------------------------
-- Copyright (c) 2006-2007 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: Populate shr_issu_image table with ISSU capable images
--           for SPRIT-ISSU rollout. 
--
-- Created by :   nadialee 
-- Created at:    Oct 5, 2006  
-------------------------------------------------------------------
----------------------------------------------------------         
-- Commented out only to prevent accidental truncation in 
-- production environment after sprit-issu initial rollout.        
----------------------------------------------------------
-- truncate table shr_issu_image; 

insert into shr_issu_image values (
    shr_issu_image_seq.nextval,
    'c10k2-p11-mz',
    1,   -- OS TYPE ID 
    sysdate,
    'nadialee',
    sysdate,
    'nadialee',
    'V',
    'MANUALLY CREATED FOR SPRIT-ISSU ROLLOUT'
    );

insert into shr_issu_image values (
    shr_issu_image_seq.nextval,
    'c10k2-p11u2-mz',
    1,   -- OS TYPE ID 
    sysdate,
    'nadialee',
    sysdate,
    'nadialee',
    'V',
    'MANUALLY CREATED FOR SPRIT-ISSU ROLLOUT'
    );

insert into shr_issu_image values (
    shr_issu_image_seq.nextval,
    'c10k2-k91p11-mz',
    1,   -- OS TYPE ID 
    sysdate,
    'nadialee',
    sysdate,
    'nadialee',
    'V',
    'MANUALLY CREATED FOR SPRIT-ISSU ROLLOUT'
    );
    
insert into shr_issu_image values (
    shr_issu_image_seq.nextval,
    'c10k2-k91p11u2-mz',
    1,   -- OS TYPE ID 
    sysdate,
    'nadialee',
    sysdate,
    'nadialee',
    'V',
    'MANUALLY CREATED FOR SPRIT-ISSU ROLLOUT'
    );
    
commit;    
