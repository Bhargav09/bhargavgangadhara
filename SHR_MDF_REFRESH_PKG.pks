
    TYPE email_addr_tab_type  is TABLE of varchar2(50);

    PROCEDURE main;
    
    PROCEDURE check_e2e( out_err_msg   out varchar2 );
    PROCEDURE upd_primary_mdf_modified( out_cnt out number );
    PROCEDURE upd_primary_mdf_new( out_cnt out number );
    PROCEDURE upd_primary_mdf_deleted( out_cnt out number );
    PROCEDURE get_primary_mdf_tot_deleted( out_cnt out number );
    PROCEDURE get_primary_mdf_tot( out_cnt out number );    

    PROCEDURE upd_secondary_mdf_modified( out_cnt out number );
    PROCEDURE upd_secondary_mdf_new( out_cnt out number );
    PROCEDURE upd_secondary_mdf_deleted( out_cnt out number );
    PROCEDURE get_secondary_mdf_tot_deleted( out_cnt out number );
    PROCEDURE get_secondary_mdf_tot( out_cnt out number );    
    
    PROCEDURE verify_refresh_primary_mdf( out_cnt out number );
    PROCEDURE verify_refresh_secondary_mdf( out_cnt out number ); 
    
    PROCEDURE log_mdf_refresh ( 
            in_proc_name    varchar2,
            in_msg          varchar2 );

    PROCEDURE notify_user (
        in_primary_mdf_upd_cnt          in number,
        in_primary_mdf_new_cnt          in number,
        in_primary_mdf_del_cnt          in number,
        in_primary_discrepancy_cnt      in number,
        in_primary_tot_del_cnt          in number,
        in_primary_tot_cnt              in number,
        in_secondary_mdf_upd_cnt        in number,
        in_secondary_mdf_new_cnt        in number,
        in_secondary_mdf_del_cnt        in number,
        in_secondary_discrepancy_cnt    in number,
        in_secondary_tot_del_cnt        in number,
        in_secondary_tot_cnt            in number,
        in_is_successful                in boolean,
        in_start_time                   in varchar2,
        in_end_time                     in varchar2,
        in_errmsg                       in varchar2 ) ;

    PROCEDURE send_email (
        in_env                      in  varchar2,
        in_mail_from_alias          in  varchar2,
        in_mail_from_email_addr     in  varchar2,
        in_mail_subject             in  varchar2,
        in_mail_text                in  varchar2,
        out_errmsg                  out varchar2 );
        
    PROCEDURE cleanup_log_table;  
    
    
END SHR_MDF_REFRESH_PKG;
/
