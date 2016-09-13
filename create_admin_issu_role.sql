-------------------------------------------------------------------
-- Copyright (c) 2006-2007 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: Create a role in SHR_RDA database to grant SPRIT-ISSU 
--           master list management.
--
-- Created by :   nadialee 
-- Created at:    Aug 2006  
-------------------------------------------------------------------

insert into sprit_roles
values ( SPRIT_ROLES_SEQ.nextval, 'adminIssu', 'sluteman', sysdate, 'nadialee', 'V', 'Manually created');

insert into sprit_roles
values ( SPRIT_ROLES_SEQ.nextval, 'adminIssu', 'slaligam', sysdate, 'nadialee', 'V', 'Manually created');

insert into sprit_roles
values ( SPRIT_ROLES_SEQ.nextval, 'adminIssu', 'mamatha', sysdate, 'nadialee', 'V', 'Manually created');

insert into sprit_roles
values ( SPRIT_ROLES_SEQ.nextval, 'adminIssu', 'motaz', sysdate, 'nadialee', 'V', 'Manually created');

insert into sprit_roles
values ( SPRIT_ROLES_SEQ.nextval, 'adminIssu', 'kirramas', sysdate, 'nadialee', 'V', 'Manually created');

insert into sprit_roles
values ( SPRIT_ROLES_SEQ.nextval, 'adminIssu', 'mesehar', sysdate, 'nadialee', 'V', 'Manually created');

insert into sprit_roles
values ( SPRIT_ROLES_SEQ.nextval, 'adminIssu', 'arshkhan', sysdate, 'nadialee', 'V', 'Manually created');

insert into sprit_roles
values ( SPRIT_ROLES_SEQ.nextval, 'adminIssu', 'rilmille', sysdate, 'nadialee', 'V', 'Manually created');

insert into sprit_roles
values ( SPRIT_ROLES_SEQ.nextval, 'adminIssu', 'rqiu', sysdate, 'nadialee', 'V', 'Manually created');

insert into sprit_roles
values ( SPRIT_ROLES_SEQ.nextval, 'adminIssu', 'huajin', sysdate, 'nadialee', 'V', 'Manually created');

insert into sprit_roles
values ( SPRIT_ROLES_SEQ.nextval, 'adminIssu', 'dkhatua', sysdate, 'nadialee', 'V', 'Manually created');

commit;
