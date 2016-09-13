/**************************************************
Copyright (c) 2007 by Cisco Systems, Inc.

Created for CSCsi47343 fix. 

Author: Kelly H. (kellmill)
Date  : 05/03/2007
**************************************************/

alter table SHR_OSTYPE_MDFSWTYPE
add (	RELEASE_NOTES_MAX INTEGER,
		IMAGE_NOTES_MAX INTEGER,
		NO_OF_LATEST_RELEASES NUMBER);
		