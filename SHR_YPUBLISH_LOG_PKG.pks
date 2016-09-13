CREATE OR REPLACE PACKAGE SHR_RDA.SHR_YPUBLISH_LOG_PKG AS

    TYPE relIdTabTyp          is TABLE of number index by binary_integer;
    TYPE email_addr_tab_type  is TABLE of varchar2(50);

    PROCEDURE main_upd_ypublish_xml_log( 
            in_trans_id             in  number,
            in_xml_response         in  varchar2,
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         out number,
            out_status_msg          out varchar2 );

    PROCEDURE main_upd_ypublish_image_log( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            in_cco_download_url     in  varchar2,
            in_md5_checksum         in  varchar2, 
            out_status_code         out number,
            out_status_msg          out varchar2 );
            
    PROCEDURE main_upd_ypublish_image_log( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            in_cco_download_url     in  varchar2,
            in_md5_checksum         in  varchar2, 
            in_acl_user_list        in  varchar2, 
            in_published_date       in  date,
            out_status_code         out number,
            out_status_msg          out varchar2 );
            
    PROCEDURE main_upd_ypublish_image_log( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            in_cco_download_url     in  varchar2, 
            out_status_code         out number,
            out_status_msg          out varchar2 );

    PROCEDURE proc_upd_iox( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2 );
            
    PROCEDURE proc_upd_pts_db_for_ion( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            in_os_type                in  shr_os_type.os_type_name%type);

    PROCEDURE debug_output ( 
            in_msg                  in  varchar2 );

    PROCEDURE do_upd_ypub_trans_log ( 
            in_trans_id             in  number,
            in_xml_response         in  varchar2,
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 ) ;
            
    PROCEDURE do_upd_ypub_image_log ( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 );

    PROCEDURE do_upd_cspr_image_posting_stat ( 
            in_image_id             in  number,
            in_cco_trans_status     in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 );

    PROCEDURE do_upd_ios_image ( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_is_post_cco          in  varchar2,
            in_cco_posted_by        in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 );

    PROCEDURE do_upd_trans_log_trans_status ( 
            in_trans_id             in  number,
            in_trans_status         in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 ) ;

    PROCEDURE log_ypub_image_error ( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            io_status_code          in out number,
            io_status_msg           in out varchar2 );

    PROCEDURE log_ypub_trans_error ( 
            in_trans_id             in  number,
            in_xml_response         in  varchar2, 
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 ) ;

    PROCEDURE notify_alert (
            in_trans_id             in  number,
            in_rel_id               in  number,
            in_image_id             in  number,
            in_errmsg               in  varchar2 );
            
    PROCEDURE notify_user (
            in_trans_id             in  number,
            in_image_id                in  number,
            in_trans_status         in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 ) ;

    PROCEDURE process_upd_cspr_image_status ( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_updated_by           in  varchar2,
            in_cco_download_url     in  varchar2,
            in_md5_checksum         in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 ) ;
            
    PROCEDURE process_upd_ypub_image_log( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code        in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 ) ;

    PROCEDURE send_mail (
                 in_env                  in  varchar2,
                 in_mail_from_alias      in  varchar2,
                 in_mail_from_email_addr in  varchar2,
                 in_mail_subject           in  varchar2,
                 in_mail_text              in  varchar2,
                 out_errmsg                out varchar2 );

    PROCEDURE validate_image_log_param( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 ) ;

    PROCEDURE validate_trans_id_image_id( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 ) ;

    PROCEDURE validate_trans_id( 
            in_trans_id             in  number,
            in_xml_response         in  varchar2,
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 );

    PROCEDURE validate_trans_log_param( 
            in_trans_id             in  number,
            in_xml_response         in  varchar2,
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 ) ;
    
    PROCEDURE do_upd_dvd_major_release_log ( 
                in_trans_id                     in  number,
                in_release_number          	    in  varchar2, 
                in_software_type_mdf_id         in  number,
                in_is_published                 in  varchar2,
                in_ypub_status_code     	    in  number,
                in_ypub_status_log              in  varchar2,
                in_updated_by                   in  varchar2,
                out_status_code                 in  out number,
            out_status_msg                  in  out varchar2 );   

    FUNCTION get_db_env return varchar2;

    FUNCTION get_os_type( 
            in_trans_id             number,
            in_image_id             number  ) return varchar2 ;

/*
    FUNCTION get_release_id ( 
            in_trans_id             number ) return number;

*/
    FUNCTION get_release_id ( 
            in_trans_id             number ) return relIdTabTyp;

    FUNCTION get_servlet_repost_flag (
            in_trans_id             number,
            in_rel_id               number ) return varchar2;
    
    FUNCTION get_trans_userid (
            in_trans_id             number ) return varchar2;

    FUNCTION is_all_image_processed( 
            in_trans_id             number ) return boolean;

    FUNCTION get_image_status( 
            in_trans_id             number,
            in_image_id             number )  return varchar2;

    FUNCTION get_servlet_url( 
            in_trans_id             number )  return varchar2;
            
    FUNCTION get_trans_status( 
            in_trans_id             number )  return varchar2;

    FUNCTION get_trans_type( 
            in_trans_id             number )  return varchar2;

    FUNCTION get_trans_is_first_time_post( 
            in_trans_id             number )  return varchar2;

    FUNCTION get_trans_time( 
            in_trans_id             number,
            in_image_id             number )  return date;

    FUNCTION get_image_trans_type( 
            in_image_id             number )  return varchar2;
    
    FUNCTION get_rel_number_id( 
                in_software_type_mdf_id number,
            in_release_number       varchar2 )  return number;  

END SHR_YPUBLISH_LOG_PKG;
/
