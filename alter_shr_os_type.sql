--Copyright (c) 2007-2008 by Cisco Systems, Inc. 
/*
 	Current Release - IOSXE 
 	Last updated by - rakkamat
 	Last updated date - Dec, 20 2007 
 */
 
  -- Add column to SHR_OS_TYPE table --
 ALTER TABLE SHR_OS_TYPE ADD CREATED_BY_APP VARCHAR2(20);
 
 -- Add column to SHR_OS_TYPE table --
ALTER TABLE SHR_OS_TYPE ADD PRODUCTIZATION CHAR(1) DEFAULT 'N';

-- Add Check Contraint to Productization --
ALTER TABLE SHR_OS_TYPE ADD CONSTRAINT CHK_SHR_OS_TYPE_PRODUCTIZATION CHECK (PRODUCTIZATION IN ('Y','N')); 
  