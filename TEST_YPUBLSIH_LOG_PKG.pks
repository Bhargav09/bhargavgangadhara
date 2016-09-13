CREATE OR REPLACE PACKAGE TEST_YPUBLSIH_LOG_PKG AS

/* Copyright (c) 2005 by cisco Systems, Inc. All rights reserved. */

/*
||=================================================================
|| File: TEST_YPUBLSIH_LOG_PKG.pks
||
|| Author: Nadia Lee
|| Created: March 2005
||
|| Function:
||   Used to test SHR_YPUBLISH_LOG_PKB. 
||
|| Usage: TEST_YPUBLISH_LOG_PKG.main
||
||=================================================================
*/

    PROCEDURE main;
    PROCEDURE do_xml_log_test ( 
            in_test_case            in  varchar2,
            in_trans_id             in  number,
            in_xml_response         in  varchar2,
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_sprit_code          out number,
            out_sprit_msg           out varchar2 ) ;

    PROCEDURE do_image_log_test( 
            in_test_case            in  varchar2,
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypublish_status_code in  number,
            in_ypublish_status_log  in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            out_sprit_code          out number,
            out_sprit_msg           out varchar2 );
   
END TEST_YPUBLSIH_LOG_PKG;
/
