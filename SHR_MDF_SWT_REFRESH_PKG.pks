CREATE OR REPLACE PACKAGE SHR_MDF_SWT_REFRESH_PKG AS

/* Copyright (c) 2006 by cisco Systems, Inc. All rights reserved. */

/*
||======================================================================
|| File: SHR_MDF_SWT_REFRESH_PKG.pks
||
|| Author: Ashok Advani
|| Created: June 2006
||
|| Business Rules :
|| ----------------
|| - Load Data from Cisco.com MDF Software Type Branch
|| -- Cisco.com Software Type View          : vw_software_type_attr
|| -- Cisco.com Products have Software Type : vw_prod_has_swtype
|| -- Cisco.com MDF Connection Details      : e2erepro/composition@authcprd
|| 
|| - Data Loading Rules :
|| ----------------------
|| -- New Software Types for SPRIT needs to informed to the user
|| -- Load Software Type in SHR_OS_TYPE, if publishing system is SPRIT.
|| -- if software type is under IOS branch, then mark Publishing SPRIT-IOS
|| -- for new Software Type being to be managed by SPRIT, 
||      email submitted by explaining him the process to go about it.
|| -- Use the Display column name if it exists, otherwsie use ConceptName by 
||    removing the SWT characters in the start
|| -- Mark Software Type 'EOS' if no Cisco Products exists for it.
|| -- Mark all the IOS Software Type as SPRIT-IOS
||
||
|| NOTE from Shridhar regarding e2e views:
||   In the rare event of refresh failure on E2E Reporting DB side of it..
||   and we(e2e) end up with a state where there the underlying views 
||   are not available. With no data to view, 
||   SPRIT should avoid truncating entire table. 
||======================================================================
*/
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
