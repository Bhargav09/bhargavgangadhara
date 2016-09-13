CREATE OR REPLACE PACKAGE SHR_MDF_SWT_REFRESH_PKG AS

    TYPE email_addr_tab_type  is TABLE of varchar2(50);

    PROCEDURE main;
    
    PROCEDURE check_e2e_swt( out_err_msg   out varchar2 );
    PROCEDURE upd_mdf_swt_modified( out_cnt out number );
    PROCEDURE upd_mdf_swt_new( out_cnt out number );
    PROCEDURE upd_mdf_swt_deleted( out_cnt out number );

    PROCEDURE get_mdf_swt_tot_deleted( out_cnt out number );
    PROCEDURE get_mdf_swt_tot( out_cnt out number );    

    PROCEDURE upd_prod_swt_modified( out_cnt out number );
    PROCEDURE upd_prod_swt_new( out_cnt out number );
    PROCEDURE upd_prod_swt_deleted( out_cnt out number );

    PROCEDURE get_prod_swt_tot_deleted( out_cnt out number );
    PROCEDURE get_prod_swt_tot( out_cnt out number );    
    
    PROCEDURE verify_refresh_mdf_swt( out_cnt out number );
    PROCEDURE verify_refresh_prod_swt( out_cnt out number );
	
	PROCEDURE update_software_metadata(out_flag out boolean );
	
	PROCEDURE send_mail_to_swtype_submitter (
	    in_mdf_swt_name  in  varchar2,
        in_mdf_swt_desc  in  varchar2,
		in_submitted_by  in  varchar2);
 
    
    PROCEDURE log_mdf_refresh ( 
            in_proc_name    varchar2,
            in_msg          varchar2 );

    PROCEDURE notify_user (
        in_mdf_swt_upd_cnt          in number,
        in_mdf_swt_new_cnt          in number,
        in_mdf_swt_del_cnt          in number,
        in_mdf_swt_discrepancy_cnt      in number,
        in_mdf_swt_tot_del_cnt          in number,
        in_mdf_swt_tot_cnt              in number,
        in_prod_swt_upd_cnt        in number,
        in_prod_swt_new_cnt        in number,
        in_prod_swt_del_cnt        in number,
        in_prod_swt_discrepancy_cnt    in number,
        in_prod_swt_tot_del_cnt        in number,
        in_prod_swt_tot_cnt            in number,
        in_is_successful                in boolean,
        in_start_time                   in varchar2,
        in_end_time                     in varchar2,
        in_errmsg                       in varchar2 ) ;

    PROCEDURE send_email (
        in_env                      in  varchar2,
		in_mail_to                  in  varchar2,
        in_mail_from_alias          in  varchar2,
        in_mail_from_email_addr     in  varchar2,
        in_mail_subject             in  varchar2,
        in_mail_text                in  varchar2,
        out_errmsg                  out varchar2 );
        
    PROCEDURE cleanup_log_table;  
    
    
END SHR_MDF_SWT_REFRESH_PKG;
/
