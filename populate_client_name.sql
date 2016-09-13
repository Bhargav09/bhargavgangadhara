-------------------------------------------------------------------
-- Copyright (c) 2006-2007 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: Add a record to CLIENT_NAME table for ISSU v 7.0 
--
-- Created by :   nadialee 
-- Created at:    Sept 2006  
-------------------------------------------------------------------

insert into client_name
values ( CLIENT_NAME_SEQ.nextval, 'ISSU', sysdate, 'nadialee', sysdate, 'nadialee', 'CREATED FOR SPRIT_ISSU', 'V');

commit;
