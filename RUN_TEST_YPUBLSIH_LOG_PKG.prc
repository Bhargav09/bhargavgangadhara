CREATE OR REPLACE PROCEDURE RUN_TEST_YPUBLSIH_LOG_PKG IS

/* Copyright (c) 2005 by cisco Systems, Inc. All rights reserved. */

/*
||=================================================================
|| File: TRUN_TEST_YPUBLSIH_LOG_PKG.prc
||
|| Author: Nadia Lee
|| Created: March 2005
||
|| Function:
||   Used to run TEST_YPUBLSIH_LOG_PKG from TOAD.
||   - Simply calls TEST_YPUBLSIH_LOG_PKG.main.
||
||=================================================================
*/

	
BEGIN

	TEST_YPUBLSIH_LOG_PKG.main;
		   
   
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'TEST_YPUBLSIH_LOG. Error' || SQLERRM);
            
END RUN_TEST_YPUBLSIH_LOG_PKG;
/
