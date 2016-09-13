CREATE OR REPLACE PACKAGE BODY TEST_YPUBLSIH_LOG_PKG AS

/* Copyright (c) 2005 by cisco Systems, Inc. All rights reserved. */

/*
||=================================================================
|| File: TEST_YPUBLSIH_LOG_PKG.pkb
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

    g_pkg_name      varchar2(100) := 'TEST_YPUBLSIH_LOG_PKG';
    g_newline       varchar2(2)   := CHR(13)||CHR(10);

PROCEDURE main IS 

    v_proc_name     varchar2(200)  := '[' || g_pkg_name || '.main] ';
    v_xml_response  varchar2(8000) := 'From TEST_YPUBLSIH_LOG_PKG';
    v_sprit_code    number  := -1;
    v_sprit_msg     varchar2(500) := 'not assigned yet';
    v_ypub_code     number := 89;

    	
BEGIN

    dbms_output.put_line( g_newline || g_newline || v_proc_name || 'START ...');

/*
    v_xml_response := 'hello, hello';

    do_image_log_test ( 'HTTP TEST', v_trans_id, v_image_id, v_ypub_status_code, 'Published', 'Y', 'YPUBLISH', v_sprit_code, v_sprit_msg );

*/
--    do_image_log_test ( 'HTTP TEST', 154, 575858, 1000, 'Published', 'Y', 'YPUBLISH', v_sprit_code, v_sprit_msg );
    do_image_log_test ( 'HTTP TEST', 168, 594965, 1000, 'Published', 'Y', 'nadialee', v_sprit_code, v_sprit_msg );


EXCEPTION
    when others then
        dbms_output.put_line(
            v_proc_name || 'Error. ' ||
            substr(sqlerrm,1,500) );
            
END main;

            

PROCEDURE do_xml_log_test ( 
            in_test_case            in  varchar2,
            in_trans_id             in  number,
            in_xml_response         in  varchar2,
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_sprit_code          out number,
            out_sprit_msg           out varchar2 )
IS
    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.do_xml_log_test] ';

BEGIN

    
    shr_ypublish_log_pkg.main_upd_ypublish_xml_log( 
            in_trans_id,
            in_xml_response,
            in_is_xml_accepted,
            in_updated_by,
            out_sprit_code,
            out_sprit_msg );

    dbms_output.put_line(
        '===> [' || in_test_case || '] ' ||
        'Finished. ' ||
        'out_sprit_code: ' ||  out_sprit_code ||
        g_newline );

    dbms_output.put_line('  -->out_sprit_msg: ' || substr(out_sprit_msg,1,230) );
		
EXCEPTION
    when others then
        dbms_output.put_line(
            '===> [' || in_test_case || '] ' ||
            'Error. ' ||
            'out_sprit_code: ' ||  out_sprit_code || 
			g_newline );
        dbms_output.put_line(
		    ' out_sprit_msg: ' ||
		    substr(out_sprit_msg,1,230) || g_newline);


END do_xml_log_test;
    	
		   
PROCEDURE do_image_log_test( 
            in_test_case            in  varchar2,
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypublish_status_code in  number,
            in_ypublish_status_log  in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            out_sprit_code          out number,
            out_sprit_msg           out varchar2 )
IS
    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.do_image_log_test] ';

BEGIN

    shr_ypublish_log_pkg.main_upd_ypublish_image_log( 
            in_trans_id,
            in_image_id,
            in_ypublish_status_code,
            in_ypublish_status_log,
            in_is_published,
            in_updated_by,
            out_sprit_code,
            out_sprit_msg );

    dbms_output.put_line(
	    v_proc_name ||
        '==>[' || in_test_case || '] ' ||
        'Finished. ' ||
        'out_sprit_code: ' ||  out_sprit_code ||
        ', out_sprit_msg: ' || out_sprit_msg || 
		g_newline );

EXCEPTION
    when others then
        dbms_output.put_line(
	        v_proc_name ||
            '==>[' || in_test_case || '] ' ||
            'Error. ' ||
            'out_sprit_code: ' ||  out_sprit_code );
			
        dbms_output.put_line(
            v_proc_name ||
            ', out_sprit_msg: ' || out_sprit_msg || 
			g_newline);

        dbms_output.put_line(
            v_proc_name ||
            ', sqlerrm: ' || substr(sqlerrm,1,200) || 
			g_newline);

END do_image_log_test;
   
END TEST_YPUBLSIH_LOG_PKG;
/
