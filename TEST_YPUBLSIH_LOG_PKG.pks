CREATE OR REPLACE PACKAGE TEST_YPUBLSIH_LOG_PKG AS
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
