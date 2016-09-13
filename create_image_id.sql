--Copyright (c) 2006 by Cisco Systems, Inc. -kdharmal
--Create image_id , os_type_id column in ION_PATCH table.

ALTER TABLE ION_PATCH 
ADD IMAGE_ID NUMBER NULL;

ALTER TABLE ION_PATCH 
ADD OS_TYPE_ID INTEGER NULL;




		

