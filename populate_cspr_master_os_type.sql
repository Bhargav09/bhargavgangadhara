-- Copyright (c) 2007-2008 by Cisco Systems, Inc.
/*
 	Current Release - IOSXE 
 	Last updated by - rakkamat
 	Last updated date - Dec, 20 2007 
 */
 
 /*
 	Update PRODUCTIZATION Flag in SHR_OS_TYPE
 */
 
 UPDATE SHR_OS_TYPE SET PRODUCTIZATION = 'Y', CREATED_BY_APP = 'CISROMM' WHERE OS_TYPE_NAME IN ('IOS','IOX','CatOS','IOSXE');
  