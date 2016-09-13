
set escape on;

CREATE OR REPLACE PACKAGE SHR_RDA.SHR_YPUBLISH_LOG_PKG AS

/* Copyright (c) 2010-2011 by cisco Systems, Inc. All rights reserved. */

/*
||======================================================================
|| File: SHR_ypub_LOG_PKG.pkb
||
|| Author: Nadia Lee
|| Created: May 2005
||
|| Function:
||   - This package contains two main_* procedures that yPublish calls
||     to update the status of 1) sprit-submitted XML file acceptance,
||     and 2) CCO transaction status on each image for the transaction.
||   - When yPublish calls main_upd_ypublish_image_log procedure to update
||     the CCO transaction status on each image, this package also
||     1) updates SHR_IMAGE.is_posted_to_cco (for IOS only),
||     2) CSPR_IMAGE_POSTING_STATUS.cco_transaction_status with 'Success'
||        or 'Fail'.
||     3) When all images CCO transaction status is updated by yPublish,
||        this package updates CSPR_YPUBLISH_TRANS_LOG.transaction_status
||        with 'Success' or 'Fail', calls java servlet to process the
||        very last steps of posting process owned by SPRIT such as
||        unlocking /release directory, send out README file, send
||        transaction status email notification to user.
||
|| NOTE:
|| - Two main procedures yPublish calls:
||    1) main_upd_ypublish_xml_log:
||          - updates CSPR_YPUBLISH_TRANS_LOG table.
||    2) main_upd_ypublish_image_log:
||          - updates CSPR_YPUBLISH_IMAGE_LOG, SHR_IMAGE,
||            CSPR_IMAGE_POSTING_STATUS, and calls Java servlet.
||======================================================================
*/
    
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
            in_os_type              in varchar2,
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
            
PROCEDURE do_upd_ypublish_message_log ( 
            in_trans_id                     in  number,
            in_image_id                     in  number,
            in_message                      in  varchar2, 
            in_created_by                   in  varchar2,
            out_status_code                 in  out number,
            out_status_msg                  in  out varchar2);            

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

END SHR_YPUBLISH_LOG_PKG;
/

CREATE OR REPLACE PACKAGE BODY SHR_RDA.SHR_YPUBLISH_LOG_PKG AS

/* Copyright (c) 2005-2007 by cisco Systems, Inc. All rights reserved. */

/*
||=================================================================
|| File: SHR_YPUBLISH_LOG_PKG.pkb
||
|| Author: Nadia Lee
|| Created: May 2005
||
|| Function:
||   - This package contains two main_* procedures that yPublish
||     calls to update the status of 1) sprit-submitted XML file
||     acceptance, and 2) CCO transaction satus on each image
||     for the transaction.
||   - When yPublish calls main_ypub_image_log procedure to update
||     the CCO transaction status on each image, this procedure
||     also does the following updates:
||
||     1) updates SHR_IMAGE.is_posted_to_cco (for IOS only),
||     2) cspr_image_posting_status.cco_transaction_status with
||        'Success' or 'Fail'.
||     3) When all images CCO transaction status is updated by
||        yPublish, this procedure updates
||        CSPR_YPUBLISH_TRANS_LOG.transaction_status with
||        'Success' or 'Fail', calls java servlet to process the 
||        very last steps of posting process owned by SPRIT such as
||        unlocking /release directory, send out README file, send 
||        transaction status email notification to user.
||
|| NOTE:
|| -  yPublish calls these two main procedures:
||    1) main_upd_ypublish_xml_log: 
||          - To update CSPR_YPUBLISH_TRANS_LOG table.
||    2) main_upd_ypublish_image_log: 
||          - To updates CSPR_YPUBLISH_IMAGE_LOG, SHR_IMAGE, and
||            cspr_image_posting_status tables, then calls Java servlet.
||=================================================================
*/
    VERBOSE         boolean         := true;
    g_pkg_name      varchar2(100)   := 'SHR_YPUBLISH_LOG_PKG';
    g_newline       varchar2(2)     := CHR(13)||CHR(10);
    -- g_env determines email notification recipient.
    -- Make sure the value is changed to 'prod' when put into production.
--    g_env           varchar2(20)    := 'prod';
     g_env           varchar2(20)    := 'dev';

    ---------------------------------------------------
    -- 100-199 : 
    --  - Errors for CSPR_ypub_TRANS_LOG on
    --  - transaction level.
    --
    -- 300-399 : 
    --  - Errors for CSPR_ypub_IMAGE_LOG on
    --  - image level.

    ---------------------------------------------------
    g_success_code                number := 0;
    g_success_msg                 varchar2(50) := 'Success';
    g_fail_msg                    varchar2(50) := 'Fail';

    g_trans_log_success_code      number := 0;
    g_trans_log_success_msg       varchar2(50) := 'Update Successful.';
    g_trans_log_invalid_trans_id  number := 100;
    g_trans_log_invalid_param     number := 110;
    g_trans_log_unknown_error     number := 199;

    g_image_log_success_code      number := 0;
    g_image_log_success_msg       varchar2(50) := 'Update Successful.';
    g_image_log_invalid_trans_id  number := 300;
    g_image_log_invalid_image_id  number := 310;
    g_image_log_invalid_param     number := 320;
    g_image_log_unknown_error     number := 390;
    
    g_post_status_invalid_image_id number := 510;
    g_post_status_unknown_error    number := 590;
    
    g_http_unknown_error          number   := 810;
    g_unknown_db_env              number   := 820;
    g_http_error                  number   := 830;
    
/*
||=================================================================
|| - Main procedure yPublish calls to update the status of
||   SPRIT-submitted XML acceptance status by yPublish. 
|| - Updates CSPR_YPUBLISH_TRANS_LOG table.
|| - One record in CSPR_YPUBLISH_TRANS_LOG table per transaction.
||=================================================================
*/
PROCEDURE main_upd_ypublish_xml_log( 
            in_trans_id             in  number,
            in_xml_response         in  varchar2, 
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         out number,
            out_status_msg          out varchar2 )
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.main_upd_ypublish_xml_log] ';
    v_is_xml_accepted   varchar2(4000);
    v_adm_userid        varchar2(4000);
BEGIN

    out_status_code := g_trans_log_success_code;
    out_status_msg  := g_trans_log_success_msg;

    ---------------------------------------------------------
    -- Validate all parameters.
    -- If any one of them is invalid, return and terminate the process 
    ---------------------------------------------------------
    validate_trans_log_param ( 
            in_trans_id,
            in_xml_response,
            in_is_xml_accepted,
            in_updated_by,
            out_status_code,
            out_status_msg ) ;

    if( out_status_code > 0 ) then
        log_ypub_trans_error (
            in_trans_id,
            in_xml_response,
            in_is_xml_accepted,
            in_updated_by,
            out_status_code,
            out_status_msg );
        return;
    end if;

    ---------------------------------------------------------
    -- Make update to yPublish log tablle.
    ---------------------------------------------------------
    v_is_xml_accepted   := trim(in_is_xml_accepted);
    v_adm_userid        := trim(in_updated_by);
    
    do_upd_ypub_trans_log( 
            in_trans_id,
            in_xml_response,
            v_is_xml_accepted,
            v_adm_userid,
            out_status_code,
            out_status_msg );


    if( out_status_code = g_trans_log_success_code ) then
        out_status_msg  := g_trans_log_success_msg;
    end if;
    
    commit;

    return;
    
EXCEPTION
    when OTHERS then
        rollback;

        out_status_code := g_trans_log_unknown_error;
        out_status_msg  :=
            v_proc_name ||
            'Unknow error. ' || substr(sqlerrm,1,500);

        log_ypub_trans_error (
            in_trans_id,
            in_xml_response,
            in_is_xml_accepted,
            in_updated_by,
            out_status_code,
            out_status_msg );
        return;

END main_upd_ypublish_xml_log;

/*
||=================================================================
|| Main procedure yPublish calls to update the posting process 
|| status of each image per transaction.  This procedure is called once
|| per image, multiple times per transaction.
|| 
|| for each image:
|| ---------------
|| 1. Update one record in CSPR_YPUBLISH_IMAGE_LOG table.
|| 2. Update one record in cspr_image_posting_status with 'Success' or 'Fail'.
|| 3. For all OS type, update cspr_image_posting_status.cco_transaction_time 
||    for all transaction status.
|| 4. For all OS type, update cspr_image_posting_status.cco_posted_time 
||    if transaction status = 'Post' or 'Repost'
|| 5. For all OS type, update cspr_image_posting_status.cco_posted_by 
||    if transaction status = 'Post' or 'Repost'
|| 6. If IOS, update SHR_IAMGE.is_posted_to_cco,
||    If image is posted now, and SHR_IAMGE.is_posted_to_cco current 
||    value is NOT 'Y', then update it to 'Y'.
|| 7. For all OS types, update cspr_image_process_status.md5_checksum.
|| 
|| If this image is the LAST image processed by yPub:
|| --------------------------------------------------
|| 8. Update one record in CSPR_YPUBLISH_TRANS_LOG.transaction_status
||    with 'Success' or 'Fail'.
||
|| When all done:
|| --------------
|| 9. Call java servlet (get_servlet_url()) to do the following:
||   - unlock the directory if this is first time positng
||   - send out README file to user group.
||   - Send email notification for CCO transaction successful/failed status.
||=================================================================
*/

PROCEDURE main_upd_ypublish_image_log( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code        in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            in_cco_download_url     in  varchar2,
            out_status_code         out number,
            out_status_msg          out varchar2 )
IS

    no_md5_checksum number := -1;
  
BEGIN

    main_upd_ypublish_image_log (
        in_trans_id,
        in_image_id,
        in_ypub_status_code,
        in_ypub_status_log,
        in_is_published,
        in_updated_by,
        in_cco_download_url,
        no_md5_checksum,
        out_status_code,
        out_status_msg);
        
END main_upd_ypublish_image_log;

PROCEDURE main_upd_ypublish_image_log( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            in_cco_download_url     in  varchar2,
            in_md5_checksum         in varchar2,
            out_status_code         out number,
            out_status_msg          out varchar2 )
IS

    no_acl_user_list varchar2(2000) := '';
  
BEGIN

    main_upd_ypublish_image_log (
        in_trans_id,
        in_image_id,
        in_ypub_status_code,
        in_ypub_status_log,
        in_is_published,
        in_updated_by,
        in_cco_download_url,
        in_md5_checksum,
        no_acl_user_list,
        null,
        out_status_code,
        out_status_msg);
        
END main_upd_ypublish_image_log;

PROCEDURE main_upd_ypublish_image_log( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code        in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
             in_cco_download_url     in  varchar2,
            in_md5_checksum         in varchar2,
            in_acl_user_list        in varchar2,
            in_published_date       in date,
            out_status_code         out number,
            out_status_msg          out varchar2 )
IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    v_proc_name             varchar2(200) := '[' || g_pkg_name || '.main_upd_ypublish_image_log] ';
    v_status_code           number := 0;
    v_status_msg            varchar2(500) := 'Update Successful.';
    v_os_type               shr_os_type.os_type_name%type;    
    v_all_image_processed   boolean := false;
    v_image_status          varchar2(20);
    v_trans_status          varchar2(20);
    v_trans_userid          cspr_ypublish_trans_log.created_by%type;
    v_sprit_status_code     number         := g_success_code;
    v_sprit_status_msg        varchar2(4000) := g_success_msg;
    notify_user_exception   exception;
    v_acl_user_list         varchar2(2000);
    v_acl_user              varchar2(50);
    v_pos                   number;
BEGIN

    out_status_code := g_image_log_success_code;
    out_status_msg  := g_image_log_success_msg;
    
    ---------------------------------------------------------
    -- Step 1. Update CSPR_YPUBLISH_IMAGE_LOG regarding image 
    -- transaction status, either success or fail.
    ---------------------------------------------------------
    process_upd_ypub_image_log( in_trans_id,
                        in_image_id,
                        in_ypub_status_code,
                        in_ypub_status_log,
                        in_is_published,
                        in_updated_by,
                        out_status_code,
                        out_status_msg );
    ---------------------------------------------------------
    -- Step 2. update cspr_image_posting_status table. Columns:
    --  a) tranaction_status, 'Success', 'Fail'.
    --  b) cco_transaction_time for all transaction status.
    --  c) cco_posted_time if 'Post' or 'REPORT'.
    --  d) cco_posted_by if 'Post' or 'REPORT'.
    --  e) md5_checksum.
    ---------------------------------------------------------


    if( out_status_code > 0 ) then
        return;
    end if;

    process_upd_cspr_image_status ( 
            in_trans_id,
            in_image_id,
            in_updated_by,
            in_cco_download_url,
            in_md5_checksum,
            out_status_code,
            out_status_msg );

    if( out_status_code > 0 ) then
        return;
    end if;

    ---------------------------------------------------------
    -- Step 3. If IOS, update SHR_IMAGE.is_posted_to_cco.
    --   If SHR_IMAGE.is_posted_to_cco current value is NOT 'Y', 
    --   then update it to 'Y'.
    ---------------------------------------------------------
    v_os_type      := get_os_type (in_trans_id, in_image_id );
    v_trans_userid := get_trans_userid(in_trans_id);
    

    if( v_os_type='IOS' and
        in_is_published = 'Y' )
    then
        do_upd_ios_image (  in_trans_id,
                            in_image_id,
                            'Y',            -- SHR_IMAGE.is_posted_to_cco
                            v_trans_userid, -- SHR_IMAGE.cco_posted_by
                            in_updated_by,
                            out_status_code,
                            out_status_msg  );
    end if;  -- If IOS

    ---------------------------------------------------------
    -- Step 4. update CSPR_YPUBLISH_TRANS_LOG table. 
    --
    -- IF this the is last image for the transaction, i.e.,
    -- transaction is completed ....
    ---------------------------------------------------------

    v_all_image_processed := is_all_image_processed ( in_trans_id );


    if( v_all_image_processed ) then
            debug_output( v_proc_name || 'DEBUG 1A. v_all_image_processed TRUE ');
    else
            debug_output( v_proc_name || 'DEBUG 1B. v_all_image_processed FALSE ');
    end if;
        
    if( v_all_image_processed ) then

        v_trans_status := get_trans_status( in_trans_id );

        do_upd_trans_log_trans_status (
                in_trans_id,
                v_trans_status,
                in_updated_by,
                out_status_code,
                out_status_msg );
        
        -- Check if the transaction is from the Auto Publish
        update auto_publish_release_queue
            set cco_transaction_status = v_trans_status
        where 
            transaction_id = in_trans_id;
            
        commit;
        
        ---------------------------------------------------------
        -- Step 5. Call java servlet (get_servlet_url()) to finish up the  
        -- final processes of CCO transaction and send out email
        -- notification to users.
        ---------------------------------------------------------
        begin  -- handling notify_user

            --if( v_os_type='IOS' ) then
                notify_user( in_trans_id, 
                             in_image_id,
                             v_trans_status,
                             in_updated_by,
                             v_os_type,
                             out_status_code,
                             out_status_msg );
            --end if;
            
            if( out_status_code <> g_success_code ) then
                raise notify_user_exception;
            end if;
            
        exception
            when notify_user_exception then
                v_sprit_status_code := out_status_code;
                v_sprit_status_msg  :=
                    v_proc_name ||  
                    'Error raised from notify_user #1. ' || substr(out_status_msg,1,500);

                log_ypub_image_error (
                    in_trans_id,
                    in_image_id,
                    in_ypub_status_code,
                    in_ypub_status_log,
                    in_is_published,
                    in_updated_by,
                    v_sprit_status_code,
                    v_sprit_status_msg );
                
                out_status_code := g_image_log_success_code;
                out_status_msg  := g_success_msg;

            when others then
                v_sprit_status_code := out_status_code;
                v_sprit_status_msg  := 
                    v_proc_name ||  
                    'Error raised from notify_user #2. ' || substr(out_status_msg,1,500);

                log_ypub_image_error (
                    in_trans_id,
                    in_image_id,
                    in_ypub_status_code,
                    in_ypub_status_log,
                    in_is_published,
                    in_updated_by,
                    v_sprit_status_code,
                    v_sprit_status_msg );
                
                out_status_code := g_image_log_success_code;
                out_status_msg  := g_success_msg;
        end; -- handling notify_user

    end if;  -- if( v_all_image_processed )
    
    if( out_status_code = g_image_log_success_code ) then
        out_status_msg  := g_image_log_success_msg;
    end if;

    if( v_os_type = 'ION Patch' or v_os_type = 'ION Maintenance Pack') then
        proc_upd_pts_db_for_ion( in_trans_id, 
            in_image_id,
            in_ypub_status_code,
            in_ypub_status_log,
            in_is_published,
            in_updated_by,
            v_os_type);

    end if;
    
    if ( v_os_type = 'IOX' ) then
        proc_upd_iox( in_trans_id, 
            in_image_id,
            in_ypub_status_code,
            in_ypub_status_log,
            in_is_published,
            in_updated_by);
    end if;
    
    if ( in_is_published = 'Y' AND  in_acl_user_list IS NOT NULL) then 
        v_acl_user_list :=  trim(in_acl_user_list);
        while instr(v_acl_user_list, ':') <> 0
        loop
            v_pos := instr(v_acl_user_list, ':');
            v_acl_user := trim( substr(v_acl_user_list, 1, v_pos - 1) );
            v_acl_user_list :=  trim(substr(v_acl_user_list, v_pos + 1));
    
            
            if( v_acl_user IS NOT NULL) then
                insert into image_acl_post_history ( acl_post_history_id, image_id, user_id, transaction_id, transaction_status, acl_url, posted_time, 
                    created_date, created_by, adm_timestamp, adm_userid, adm_flag, adm_comment )
                values (  image_acl_post_history_seq.nextval, in_image_id, v_acl_user, in_trans_id, in_is_published, in_cco_download_url, in_published_date,
                    sysdate, 'ypublish', sysdate, 'ypublish', 'V', 'Created by ypublish stored procedure' );
            end if;
        end loop ;  
        
            if( v_acl_user_list IS NOT NULL) then
                insert into image_acl_post_history ( acl_post_history_id, image_id, user_id, transaction_id, transaction_status, acl_url, posted_time, 
                    created_date, created_by, adm_timestamp, adm_userid, adm_flag, adm_comment )
                values (  image_acl_post_history_seq.nextval, in_image_id, v_acl_user_list, in_trans_id, in_is_published, in_cco_download_url, in_published_date,
                    sysdate, 'ypublish', sysdate, 'ypublish', 'V', 'Created by ypublish stored procedure' );
            end if;
    end if;

    commit;    
    return;    
    
EXCEPTION
    when OTHERS then
        rollback;
        out_status_code := g_image_log_unknown_error;
        out_status_msg  :=  
            v_proc_name ||  
            'Unknow error. ' || substr(out_status_msg,1,500) || substr(sqlerrm,1,500);
        
        log_ypub_image_error (
            in_trans_id,
            in_image_id,
            in_ypub_status_code,
            in_ypub_status_log,
            in_is_published,
            in_updated_by,
            out_status_code,
            out_status_msg );

        return;

END main_upd_ypublish_image_log;

PROCEDURE proc_upd_pts_db_for_ion( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            in_os_type                in  shr_os_type.os_type_name%type)
IS
    v_ion_patch_id          varchar2(30);
    v_ion_tarball_id        varchar2(50);
    v_user_id                varchar2(8);
    v_ion_post_type            varchar2(25);
    v_ion_post_status        varchar2(25);
    v_status_msg            varchar2(1000);
    v_siis_change_state_ret number;
    v_status                number;
    some_error_from_pts_side exception;
BEGIN
    -- if the OS is ION, Call PTS stored procedure
    begin 
            select
                  patch_id, tarball_id
            into
                v_ion_patch_id, v_ion_tarball_id
            from
                ion_patch
            where
                 image_id  = in_image_id ;
    
            select
                  CREATED_BY
            into
                v_user_id
            from 
                 cspr_ypublish_trans_log
            where
                 transaction_id = in_trans_id;

                         
            select
                  cco_transaction_type, cco_transaction_status
            into 
                 v_ion_post_type, v_ion_post_status
            from 
                 cspr_image_posting_status
            where
                 image_id = in_image_id;
            
            if( v_ion_post_status = 'Success' and 
                (v_ion_post_type = 'Post' or v_ion_post_type = 'Delete') ) then
                if( v_ion_post_type = 'Post' ) then
                    v_ion_post_type := 'POSTED';
                else 
                     v_ion_post_type := 'REMOVED';
                end if;
                v_siis_change_state_ret := siis_change_state(v_ion_patch_id, v_ion_tarball_id,v_user_id,v_ion_post_type);
                if(v_siis_change_state_ret < 1) then
            
                    raise some_error_from_pts_side;
                end if; 
            end if;    
    exception 
         when OTHERS then
        log_ypub_image_error (
            in_trans_id,
            in_image_id,
            in_ypub_status_code,
            'Failed to update the PTS database (post_type=' || v_ion_post_type || ', patch_id=' ||
                    v_ion_patch_id || ', tarball_id=' || v_ion_tarball_id || ', userid=' || v_user_id || ') Error=' || substr(sqlerrm,1,200),
            in_is_published,
            in_updated_by,
            v_status,
            v_status_msg
            );
    end;
    
    return;
     
END;

PROCEDURE proc_upd_iox( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2)
IS
    v_status_msg varchar2(1000);
    v_status     number;
    v_proc_name  varchar2(200) := '[' || g_pkg_name || '.proc_upd_iox] ';
    v_trans_time date;
    v_trans_type varchar2(20);
    v_is_posted_to_cco varchar2(1) := 'N';
    
BEGIN
    v_trans_time := get_trans_time( in_trans_id, in_image_id );
    v_trans_type := get_trans_type(in_trans_id);
    
    if ( lower(v_trans_type) = 'post' and in_is_published = 'Y' ) then 
      v_is_posted_to_cco := 'Y';
    end if;
    
    -- Update iox_cco is_posted_to_cco flag.
    begin 
            update
                iox_cco
            set
                is_posted_to_cco = v_is_posted_to_cco,
                cco_post_time = v_trans_time,
                adm_userid = trim(in_updated_by),
                adm_timestamp = sysdate,
                adm_flag = 'V',
                adm_comment = g_pkg_name || ' - UPDATED'
            where
                 image_id  = in_image_id ;

    exception 
         when OTHERS then
             v_status := g_post_status_unknown_error;
            v_status_msg  := v_proc_name ||  
                'Unknown error while updating iox_cco table.  ' || substr(sqlerrm,1,200);
            log_ypub_image_error (
                in_trans_id,
                in_image_id,
                in_ypub_status_code,
                in_ypub_status_log,
                in_is_published,
                in_updated_by,
                v_status,
                v_status_msg
            );
    end;
    
    return;
     
END;

/*
||=================================================================
||  Make actual update to cspr_image_posting_status table.
||=================================================================
*/
PROCEDURE debug_output ( 
            in_msg                  in  varchar2 )
IS

BEGIN
    if( VERBOSE ) then
        dbms_output.put_line ( in_msg );
    end if;
    
    return;
    
EXCEPTION 
    when others then
        null;
        return;    
END;
                    
/*
||=================================================================
||  Make actual update to cspr_image_posting_status table.
||=================================================================
*/
PROCEDURE do_upd_cspr_image_posting_stat ( 
            in_image_id             in  number,
            in_cco_trans_status     in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )

IS
    v_proc_name     varchar2(200) := '[' || g_pkg_name || '.do_upd_cspr_image_posting_stat] ';

BEGIN

    update 
        cspr_image_posting_status
    set
        cco_transaction_status = in_cco_trans_status,
        adm_userid = trim(in_updated_by),
        adm_timestamp = sysdate,
        adm_flag = 'V',
        adm_comment = g_pkg_name || ' - UPDATED'
    where
        image_id = in_image_id;
        
EXCEPTION
    when no_data_found then
        rollback;
        out_status_code := g_post_status_invalid_image_id;
        out_status_msg  :=
            v_proc_name ||  
            'Image ID ' || in_image_id || ' not found in cspr_image_posting_status table.';
        return;
        
    when others then
        rollback;
        out_status_code := g_post_status_unknown_error;
        out_status_msg  :=
            v_proc_name ||  
            'Unknown error while updating cspr_image_posting_status table. ' ||
            substr(sqlerrm,1,500);
        return;
                
END do_upd_cspr_image_posting_stat;


/*
||=================================================================
||  Update SHR_IMAGE.is_posted_to_cco.
||=================================================================
*/
PROCEDURE do_upd_ios_image ( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_is_post_cco          in  varchar2,
            in_cco_posted_by        in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )

IS
    v_proc_name     varchar2(200) := '[' || g_pkg_name || '.do_upd_ios_image] ';

BEGIN

    update 
        shr_image
    set
        is_posted_to_cco = in_is_post_cco,
--        cco_posted_time = sysdate,
        cco_posted_by   = trim(in_cco_posted_by),
        adm_userid = trim(in_updated_by),
        adm_timestamp = sysdate,
        adm_flag = 'V',
        adm_comment = g_pkg_name || ' - UPDATED'
    where
        image_id = in_image_id;

    return;
            
EXCEPTION
    when others then
        rollback;
        out_status_code := g_post_status_unknown_error;
        out_status_msg  :=
            v_proc_name ||  
            'Unknown error while updating SHR_IMAGE.is_posted_to_cco. ' ||
            'in_image_id=' || in_image_id || '. ' ||
            substr(sqlerrm,1,500);

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            out_status_code,
            out_status_msg );

        return;

END do_upd_ios_image;

/*
||=================================================================
||  Make update to CSPR_YPUBLISH_TRANS_LOG.transaction_status.
||=================================================================
*/
PROCEDURE do_upd_trans_log_trans_status ( 
            in_trans_id             in  number,
            in_trans_status         in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )
IS
    v_proc_name             varchar2(200) := '[' || g_pkg_name || '.do_upd_trans_log_trans_status] ';
    v_action_type           varchar2(20);
    v_transaction_type      varchar2(20); 
    
BEGIN

    update 
        cspr_ypublish_trans_log
    set
        transaction_status = trim(in_trans_status),
        adm_userid = trim(in_updated_by),
        adm_timestamp = sysdate,
        adm_flag = 'V',
        adm_comment = g_pkg_name || ' - UPDATED'
    where
        transaction_id = in_trans_id ;
        
    select 
    	      transaction_type  
    into  
    	      v_transaction_type 
    from 
    	      cspr_ypublish_trans_log 
    where 
    	      transaction_id = in_trans_id;
    	      
    	
    	
    if(v_transaction_type='OptOut'and in_trans_status ='Fail') Then
            select 
    	            action_type  
    	    into  
    	             v_action_type 
    	    from  
    	             cspr_ypublish_trans_log 
    	    where 
    	        transaction_id = in_trans_id;
                
    		update 
    		       cspr_latest_release_optout 
    		set 
    		       adm_flag = (
    		       select 
    		             decode(v_action_type, 'Add', 'D', 
    		                                   'Remove', 'V') 
    		       from 
    		             cspr_ypublish_trans_log 
    		       where 
    		             transaction_id = in_trans_id
    		       ),
                       adm_userid = trim(in_updated_by),
                       adm_timestamp = sysdate,
                       adm_comment = g_pkg_name || ' - UPDATED' 
    		 where 
    		       transaction_id = in_trans_id;
    	end if;
    	
    	
    
    
    if(v_transaction_type='OptOut' or  v_transaction_type='DvdMajorRelMdf') then
          commit;
    end if;    
    
    out_status_code := g_success_code;
    out_status_msg  := g_success_msg;
    
    return;
            
EXCEPTION
    when no_data_found then
         begin
         --out_status_code := 'No data found';
         out_status_msg  := 'No data found'; 
         end; 
    when value_error then    
         begin        
         rollback;
         out_status_msg  := 'An arithmetic, conversion, truncation, or size-constraint error occurs '||
         substr(sqlerrm,1,500);
         end;
    when others then
        rollback;
        out_status_code := g_trans_log_unknown_error;
        out_status_msg  :=
            out_status_msg || ' ' ||
            v_proc_name ||
            'Unknown error while updating CSPR_YPUBLISH_TRANS_LOG.transaction_status '||
            'with ''' || in_trans_status || '''. ' ||
            substr(sqlerrm,1,500);
      

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            out_status_code,
            out_status_msg );

        return;
        
END do_upd_trans_log_trans_status;

/*
||=================================================================
||  Make actual update to CSPR_ypub_IMAGE_LOG table.
||=================================================================
*/
PROCEDURE do_upd_ypub_image_log ( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )
IS
    v_proc_name     varchar2(200) := '[' || g_pkg_name || '.do_upd_ypub_image_log] ';

BEGIN

    --------------------------------------------------
    -- Update all columns exception ypublish_xml_response.    
    --------------------------------------------------
    update 
        cspr_ypublish_image_log
    set
        ypublish_status_code = in_ypub_status_code,
        ypublish_status_log = trim(in_ypub_status_log),
        is_published = trim(in_is_published),
        adm_userid = trim(in_updated_by),
        adm_timestamp = sysdate,
        adm_flag = 'V',
        adm_comment = g_pkg_name || ' - UPDATED'
    where
        transaction_id = in_trans_id
        and image_id = in_image_id;

    return;
            
EXCEPTION
    when others then
        rollback;
        out_status_code := g_image_log_unknown_error;
        out_status_msg  :=
            v_proc_name ||  
            'Unknown error while updating CSPR_YPUBLISH_IMAGE_LOG table. ' ||
            substr(sqlerrm,1,500);
        log_ypub_image_error (
            in_trans_id,
            in_image_id,
            in_ypub_status_code,
            in_ypub_status_log,
            in_is_published,
            in_updated_by,
            out_status_code,
            out_status_msg );

        return;
                
END do_upd_ypub_image_log;

/*
||=================================================================
||  Make actual update to CSPR_YPUBLISH_TRANS_LOG table from yPublish.
||=================================================================
*/
PROCEDURE do_upd_ypub_trans_log ( 
            in_trans_id             in  number,
            in_xml_response         in  varchar2,
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )
IS
    v_proc_name    varchar2(200) := '[' || g_pkg_name || '.do_upd_ypub_trans_log] ';
    
BEGIN

    update 
        cspr_ypublish_trans_log
    set
        ypublish_xml_response = trim(in_xml_response),
        is_ypublish_accepted = trim(in_is_xml_accepted),
        adm_userid = trim(in_updated_by),
        adm_timestamp = sysdate,
        adm_flag = 'V',
        adm_comment = g_pkg_name || ' - UPDATED'
    where
        transaction_id = in_trans_id ;

    out_status_code := g_success_code;
    out_status_msg  := g_success_msg;
    
    return;
        
EXCEPTION
    when others then
        rollback;
        out_status_code := g_trans_log_unknown_error;
        out_status_msg  :=
            out_status_msg || ' ' ||
            v_proc_name ||
            'Unknown error while updating CSPR_YPUBLISH_TRANS_LOG table with XML response. ' ||
            substr(sqlerrm,1,500);

        log_ypub_trans_error (
            in_trans_id,
            in_xml_response,
            in_is_xml_accepted,
            in_updated_by,
            out_status_code,
            out_status_msg );

        return;

END do_upd_ypub_trans_log;

/*
||=================================================================
|| Log error occured during updating CSPR_ypub_IAMGE_LOG.
||=================================================================
*/
PROCEDURE log_ypub_image_error ( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            io_status_code          in out number,
            io_status_msg           in out varchar2 )
IS
    v_proc_name             varchar2(200) := '[' || g_pkg_name || '.log_ypub_image_error] ';
    v_ypub_status_log       cspr_ypublish_image_error.ypublish_status_log%type;
    v_is_published          cspr_ypublish_image_error.is_published%type;
    v_updated_by            cspr_ypublish_image_error.created_by%type;

BEGIN

    ----------------------------------------------------------
    -- Get the maximum substring to store in error table.
    -- This way, we can prevent too large value for the column error.
    ----------------------------------------------------------
    v_ypub_status_log   := substr(in_ypub_status_log, 1, 4000 );
    v_is_published      := substr(in_is_published, 1, 20);
    v_updated_by        := substr(in_updated_by, 1, 20);

/*    
   debug_output( v_proc_name ||
       'in_trans_id=' || in_trans_id ||
       ', in_image_id=' || in_image_id ||
       ', io_status_code=' || io_status_code ||
       ', v_is_published=' || v_is_published);
    
   debug_output ( v_proc_name ||
       'io_status_msg=' || io_status_msg ||
       ', v_updated_by=' || v_updated_by ||
       ', v_ypub_status_log='|| substr(v_ypub_status_log,1, 50) );
*/

    insert into cspr_ypublish_image_error (
        transaction_id,
        image_id,
        ypublish_status_code,
        ypublish_status_log,
        is_published,
        error_code,
        error_msg,
        created_by,
        created_date,
        adm_userid,
        adm_timestamp,
        adm_flag,
        adm_comment )
    values (
        in_trans_id,
        in_image_id,
        in_ypub_status_code,
        v_ypub_status_log,
        v_is_published,
        io_status_code,
        io_status_msg,
        v_updated_by,
        sysdate,
        v_updated_by,
        sysdate,
        'V',
        g_pkg_name || ' - CREATED' );
        
    commit;

    return;
    
EXCEPTION
    when others then
        rollback;
        -- Don't assign new out_status_code in order to keep the
        -- original error code that makes more sense to yPublish.
        io_status_msg :=
            io_status_msg || ' ' ||
            v_proc_name ||  
            substr(sqlerrm, 1,500) ;
           
        dbms_output.put_line ( v_proc_name || 'ERROR==>' ||
            substr(sqlerrm,1,200) ) ;
        return;
        
END log_ypub_image_error;

/*
||=================================================================
|| Log error occured during updating CSPR_ypub_TRANS_LOG.
||=================================================================
*/
PROCEDURE log_ypub_trans_error ( 
            in_trans_id             in  number,
            in_xml_response         in  varchar2,
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )
IS
    v_proc_name             varchar2(200) := '[' || g_pkg_name || '.log_ypub_trans_error] ';
    v_xml_response          cspr_ypublish_trans_error.ypublish_xml_response%type;
    v_is_xml_accepted       cspr_ypublish_trans_error.is_ypublish_accepted%type;
    v_updated_by            cspr_ypublish_trans_error.created_by%type;

BEGIN

    debug_output(v_proc_name || 'BEGIN' );
    
    ----------------------------------------------------------
    -- Get the maximum substring to store in error table.
    -- This way, we can prevent too large value for the column error.
    ----------------------------------------------------------
    v_xml_response      := substr(in_xml_response, 1, 4000 );
    v_is_xml_accepted   := substr(in_is_xml_accepted, 1, 20);
    v_updated_by        := substr(in_updated_by, 1, 20);
    out_status_msg      := substr(out_status_msg, 1, 4000);            
    
    insert into cspr_ypublish_trans_error values (
        in_trans_id,
        v_xml_response,
        v_is_xml_accepted,
        out_status_code,
        out_status_msg,
        v_updated_by,
        sysdate,
        v_updated_by,
        sysdate,
        'V',
        g_pkg_name || ' - CREATED' );

    commit;
    
    return;


EXCEPTION
    when others then
        rollback;

        -- Don't assign new out_status_code in order to keep the
        -- original error code that makes more sense to yPublish.
        out_status_msg :=
            out_status_msg || ' ' ||
            v_proc_name ||  
            substr(sqlerrm, 1,500) ;
            
        dbms_output.put_line ( v_proc_name || 'ERROR==>' ||
            substr(sqlerrm,1,200) ) ;
        return;
        
END log_ypub_trans_error;

/*
||=================================================================
|| Send email notification to SPRIT dev team to alert them
|| of something not going well such as SPRIT server is down.
||=================================================================
*/
PROCEDURE notify_alert (
            in_trans_id             in  number,
            in_rel_id               in  number,
            in_image_id             in  number,
            in_errmsg               in  varchar2 ) 
IS

    v_proc_name               varchar2(200) := '[' ||g_pkg_name || '.notify_alert] ';

    v_mail_from_alias          varchar2(100) := '"SPRIT_ALERT_NOTIFICATION"';
    v_mail_to_email_addr_tab  email_addr_tab_type := email_addr_tab_type(  'aadvani@cisco.com', 'rruddara@cisco.com', 'aselvara@cisco.com' );
    v_mail_from_email_addr    varchar2(100) := 'SHR_YPUBLISH_LOG_PKG Notification';
    
    v_mail_subject            varchar2(100) := 'SPRIT Failure Notification';
    v_mail_body               varchar2(30000);
    v_send_mail_ret_errmsg    varchar2(1000);
    v_errmsg                  varchar2(2000);
    v_schema                  varchar2(50);
    v_db                      varchar2(50);
    SEND_MAIL_EXCP            exception;

BEGIN

    select user into v_schema from dual;
    select global_name into v_db from global_name;
    
    v_mail_body :=
        'This is an automated email from ' || v_schema || '@' || v_db || '. ' || g_pkg_name ||
        '. Please do not reply.' || g_newline || g_newline ||
        '***** SPRIT DEV TEAM, Problem has occurred. ' || g_newline ||
        'Error has occured during or after the posting for the following CCO publishing transaction. ' || g_newline || g_newline ||
        'Database       : ' || v_schema || '@' || v_db || g_newline ||
        'Transaction ID : ' || in_trans_id || g_newline ||    
        'Release ID     : ' || in_rel_id || g_newline ||    
        'Image ID       : ' || in_image_id  || g_newline || g_newline ||
        'Error Message ' || g_newline ||
        '=============' || g_newline ||
        in_errmsg || g_newline || g_newline ||
        'Please check CSPR_YPUBLISH_TRANS_ERROR and CSPR_YPUBLISH_IMAGE_ERROR tables. ' || g_newline ;
    
        send_mail(
               g_env,
               v_mail_from_alias,
               v_mail_from_email_addr,
               v_mail_subject,
               v_mail_body,
               v_send_mail_ret_errmsg );
   

    if( v_send_mail_ret_errmsg is not null ) then
        raise SEND_MAIL_EXCP;
    end if;

EXCEPTION
    when SEND_MAIL_EXCP then
        v_errmsg := v_proc_name || '. SEND_MAIL_EXCEPTION ===> ' || substr(sqlerrm, 1, 500);

    when OTHERS then
        v_errmsg := v_proc_name || ' ===> ' || substr(sqlerrm, 1, 500);

END notify_alert;

/*
||=================================================================
|| Call java servlet (get_servlet_url()) to finish up posting transaction.
|| -- send out email notificatiaon to users
|| -- .....
||=================================================================
*/
PROCEDURE notify_user(
            in_trans_id             in  number,
            in_image_id                in  number,
            in_trans_status         in  varchar2,
            in_updated_by           in  varchar2,
            in_os_type              in varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 ) 
IS

    v_proc_name          varchar2(200) := '[' || g_pkg_name || '.notify_user] ';
    req                  utl_http.req;
    resp                 utl_http.resp;
    name                 VARCHAR2(256);
    value                VARCHAR2(32000);
    i                    integer;
    v_db_env             varchar2(20)  := '';
    v_param              varchar2(1000) := '';
    v_url                varchar2(4000):= '';
    v_rel_id_tab         relIdTabTyp;
    v_rel_id             varchar2(10)  := '';
    v_userid             varchar2(10)  := '';
    v_repost             varchar2(1)   := '';
    v_successful         varchar2(1);
    v_trans_status         varchar2(1);
    v_trans_type          varchar2(20);
    v_is_first_time_post varchar2(1);
    
    v_http_resp_code     number;
    v_http_resp          varchar2(4000) := '';
    
    v_sprit_status_code  number         := g_success_code;
    v_sprit_status_msg     varchar2(4000) := '';
    
    UNKNOWN_DB_ENV                  exception;
    http_exception                       exception;

BEGIN

    v_db_env             := get_db_env;
    v_rel_id_tab         := get_release_id( in_trans_id );
    v_userid             := get_trans_userid( in_trans_id );
--    v_repost             := get_servlet_repost_flag( in_trans_id, v_rel_id );
    v_trans_status       := upper(substr(in_trans_status,1,1));
    v_trans_type         := get_trans_type(in_trans_id);
    v_is_first_time_post := get_trans_is_first_time_post(in_trans_id);

    if( v_trans_status='S') then
        v_successful := 'Y';
    else
        v_successful := 'N';
    end if;

    ----------------------------------------------------------------
    --     releaseNumberId : non-IOS can have more than one releaseId
    --                    per transaction.
    --  user - user id of whoever posting. 
    --  repost  - "Y" value if it is repost, otherwise "N" 
    -- transactionId - transaction id
    -- successful - "Y" if transaction is successful, otherwise "N" 
    ----------------------------------------------------------------
    v_param :=
        'user=' || v_userid ||
        '\&posttype=' || v_trans_type ||
        '\&firsttimepost=' || v_is_first_time_post ||
        '\&transactionId=' || in_trans_id ||
        '\&successful=' || v_successful ||
        '\&ostype=' ||in_os_type;

    for j in 1..v_rel_id_tab.count loop
        v_param :=v_param ||'\&releaseNumberId=' || v_rel_id_tab(j);
    end loop;

    ---------------------------------------------------------
    -- Make URL to call SPRIT servlet.
    ---------------------------------------------------------
    v_url := get_servlet_url( in_trans_id );
    v_url := v_url || '?' || v_param;

    debug_output ( v_proc_name || 'DEBUG 6A. v_url=' || v_url);

    
    --=============================================================
    -- Call SPRIT Servlet to send out final notification from SPRIT
    -- . notification is sent out only when first time posting.
    --
    -- next several lines along with all the utl_http exceptions
    -- in the exception block ,  replace all the commented block below.
    --=============================================================
    req := utl_http.begin_request(v_url);
    utl_http.set_header(req, 'User-Agent', 'Mozilla/4.0');
    resp := utl_http.get_response(req);
    
    v_http_resp_code := resp.status_code;
    v_http_resp      := substr(resp.reason_phrase,1,2000);

    debug_output( v_proc_name || 'v_http_resp_code=' || v_http_resp_code );
    debug_output( v_proc_name || 'v_http_resp=' || v_http_resp );

    -------------------------------------------------------
    -- status code 200 means successful.
    -- . If not successful, take first 3000 characters from
    --   the java server error. 
    -- . This 2500 char will be appened with other messages
    --   which must not exceed 4000 all together.
    -------------------------------------------------------
    if( v_http_resp_code <> 200 ) then

        begin
            loop
                utl_http.read_line(resp, value, TRUE);
                i := 1;
       
                while i < length(value) loop
                    if( length(v_http_resp) < 2500 ) then
                        v_http_resp := v_http_resp || substr(value,i,i+150);
                    end if;
--                    dbms_output.put_line(substr(value,i,i+150));
                    i := i + 150;
                end loop;
            end loop;
        exception
            when others then
                null;
                debug_output (v_proc_name || 'DEBUG 5. http. ' || v_sprit_status_msg );
        end; -- begin

        -- End response before raising exception.
        utl_http.end_response(resp);
        raise http_exception;

    end if;
    
    -----------------------------------------------------
    -- End response normally.
    -----------------------------------------------------
    utl_http.end_response(resp);


/*    
    ---------------------------------------------------------
    -- Call SPRIT Servlet to send out final notification from SPRIT
    -- . notification is sent out only when first time posting.
    ---------------------------------------------------------
    begin
        req := utl_http.begin_request(v_url);
    exception
        when others then
            v_sprit_status_msg := 'Error with utl_http.begin_request. Http connection refused. ';
            debug_output(v_proc_name || 'DEBUG 1. http. ' || v_sprit_status_msg );
            raise http_exception;
    end;
*/
    ----------------------------------------------------------------
    -- Commented. Don't need it.
    ----------------------------------------------------------------
--       utl_http.set_header(req, 'siteauthkey', 'MTAxOkNDRjZBRTBCRUY');
/*

    begin
         utl_http.set_header(req, 'User-Agent', 'Mozilla/4.0');
    exception
        when others then
            v_sprit_status_msg := 'Error with utl_http.set_header User-Agent. ';
            debug_output (v_proc_name || 'DEBUG 2. http. ' || v_sprit_status_msg );
            raise http_exception;
    end;
*/
/*
    ----------------------------------------------------------------
    -- User authentication.
    -- . Commented out.
    -- . Java servlet doesn't require user authentication now.    
    ----------------------------------------------------------------
    begin
        utl_http.set_header(req, 'user', 'dummy_name');
        utl_http.set_header(req, 'password', 'dummy_pw');
    exception
        when others then
            v_sprit_status_msg := 'Error with utl_http.set_header user, password. ';
            debug_output (v_proc_name || 'DEBUG 3. http. ' || v_sprit_status_msg );
            raise http_exception;
    end;
*/

/*
    ----------------------------------------------------------------
    -- Http get response.
    ----------------------------------------------------------------
    begin
        resp := utl_http.get_response(req);
    exception
        when others then
            v_sprit_status_msg := 'Error with utl_http.get_response. ';
            debug_output (v_proc_name || 'DEBUG 4. http. ' || v_sprit_status_msg );
            raise http_exception;
    end;

    debug_output(v_proc_name || 'DEBUG 7');
*/
/*
   ------------------------------------------------------------
   -- Read HTTP response code and reason phrase   
   ------------------------------------------------------------
    begin  
        v_http_resp := substr(resp.reason_phrase,1,2000);
        debug_output(v_proc_name || 'DEBUG 7C. HTTP response status code: ' || resp.status_code);
        debug_output(v_proc_name || 'DEBUG 7D. HTTP response reason phrase: ' || substr(resp.reason_phrase,1,150) );
    exception 
        when others then
            v_sprit_status_msg := 'Error reading response status code and reason. ';
            debug_output (v_proc_name || 'DEBUG 4. http. ' || v_sprit_status_msg );
            raise http_exception;
    end;        
*/    
/*     
   ------------------------------------------------------------
   -- Comment Out. 
   -- . This block causes error with  
   --       utl_http.read_line(resp, value, TRUE);
   ------------------------------------------------------------
   ------------------------------------------------------------
   -- Read HTTP response
   ------------------------------------------------------------
    begin
        loop
            utl_http.read_line(resp, value, TRUE);
            i := 1;
   
            while i < length(value) loop
                if( length(v_http_resp) < 4000 - 255 ) then
                    v_http_resp := v_http_resp || substr(value,i,i+254);
                end if;
                dbms_output.put_line(substr(value,i,i+254));
                i := i + 150;
            end loop;
        end loop;
    exception
        when others then
            debug_output (v_proc_name || 'DEBUG 5. http. ' || v_sprit_status_msg );
            utl_http.end_response(resp);
    end;
*/

/*
    begin
        utl_http.end_response(resp);
    exception
        when others then
            v_sprit_status_msg := 'Error with utl_http.end_response. ';
            debug_output (v_proc_name || 'DEBUG 6. http. ' || v_sprit_status_msg );
            raise http_exception;
    end;
*/
    debug_output (v_proc_name || 'FINISHED.');
    
EXCEPTION
    WHEN UNKNOWN_DB_ENV THEN
    
        v_sprit_status_code := g_unknown_db_env;
        v_sprit_status_msg  :=
            v_proc_name || 'UNKNOWN_DB_ENV. DB: ' || v_db_env || g_newline || g_newline ||
            'URL            : ' || v_url || '  ' || g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- This is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;

    WHEN utl_http.request_failed THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg  := 
            v_proc_name || 'UTL_HTTP.REQUEST_FAILED EXCEPTION.' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;
                    
    WHEN utl_http.bad_argument THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg  :=
            v_proc_name || 'UTL_HTTP.BAD_ARGUMENT EXCEPTION.' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;

    WHEN utl_http.bad_url THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg  := 
            v_proc_name || 'UTL_HTTP.BAD_URL EXCEPTION.' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;

    WHEN utl_http.protocol_error THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg  := 
            v_proc_name || 'UTL_HTTP.PROTOCOL_ERROR EXCEPTION.' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;

    WHEN utl_http.unknown_scheme THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg  :=
            v_proc_name || 'UTL_HTTP.UNKNOWN_SCHEME EXCEPTION.' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;
        
    WHEN utl_http.header_not_found THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg  := 
            v_proc_name || 'UTL_HTTP.HEADER_NOT_FOUND EXCEPTION.' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;
        
    WHEN utl_http.illegal_call THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg  := 
            v_proc_name || 'UTL_HTTP.ILLEGAL_CALL EXCEPTION.' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;
        
    WHEN utl_http.http_client_error THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg :=
            v_proc_name || 'UTL_HTTP.HTTP_CLIENT_ERROR EXCEPTION.' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;

    WHEN utl_http.http_server_error THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg :=
            v_proc_name || 'UTL_HTTP.HTTP_SERVER_ERROR EXCEPTION.' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;

    WHEN utl_http.too_many_requests THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg := 
            v_proc_name || 'UTL_HTTP.TOO_MANY_REQUESTS EXCEPTION.' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;
/*
    WHEN utl_http.partial_multibyte_exceptions THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg := 'UTL_HTTP.PARTIAL_MULTIBYTE_EXCEPTIONS EXCEPTION.';

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;
*/
    WHEN utl_http.transfer_timeout THEN
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg  := 
            v_proc_name || 'UTL_HTTP.TRANSFER_TIMEOUT EXCEPTION.' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;
        
    WHEN utl_http.end_of_body THEN
        utl_http.end_response(resp);

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;

    WHEN http_exception THEN  -- User defined exception
        v_sprit_status_code := g_http_error;
        v_sprit_status_msg  := 
            v_proc_name || 'User-Defined HTTP_EXCEPTION. ' || g_newline ||g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);

        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 
                    
        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );

        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;

    WHEN others THEN
        v_sprit_status_code := g_http_unknown_error;
        v_sprit_status_msg  :=
            v_proc_name || 'OTHERS EXCEPTION. Unknown error.  ' || g_newline ||
            'URL            : ' || v_url ||  g_newline ||
            'HTTP_RESP_CODE : ' || v_http_resp_code || g_newline ||
            'HTTP_RESP      : ' || substr(v_http_resp,1,1000) || g_newline ||
            'SQLERRM        : ' || substr(sqlerrm,1,1000);
        
        notify_alert ( in_trans_id, 
                       v_rel_id,
                       in_image_id,
                       v_sprit_status_msg ); 

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            v_sprit_status_code,
            v_sprit_status_msg );
            
        -- http error is sprit internal issue. don't sent this
        -- error back to ypublish.
        out_status_code := g_success_code;
        out_status_msg  := g_success_msg;
        return;
            
END notify_user;


/*
||=================================================================
|| Make update to one record in CSPR_YPUBLISH_IMAGE_LOG table.
|| - When error occurs, creates a record in CSPR_YPUBLISH_IMAGE_ERROR table
||   to stored the passed data and to log the error. 
||=================================================================
*/
PROCEDURE process_upd_ypub_image_log( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code        in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.process_upd_ypub_image_log] ';
    v_status_code       number := 0;
    v_status_msg        varchar2(500) := 'Update Successful.';
    v_adm_userid        varchar2(4000);
    v_os_type           shr_os_type.os_type_name%type;    
    v_trans_status      varchar2(20);
    v_all_image_processed    boolean := false;
    
BEGIN
    ---------------------------------------------------------
    -- Validate all parameters.
    -- If any one of them is invalid, return and terminate the process 
    ---------------------------------------------------------
    validate_image_log_param ( 
            in_trans_id,
            in_image_id,
            in_ypub_status_code,
            in_ypub_status_log,
            in_is_published,
            in_updated_by,
            out_status_code,
            out_status_msg );

    if( out_status_code > 0 ) then
        log_ypub_image_error (
            in_trans_id,
            in_image_id,
            in_ypub_status_code,
            in_ypub_status_log,
            in_is_published,
            in_updated_by,
            out_status_code,
            out_status_msg );
        return;
    end if;

    ---------------------------------------------------------
    -- Make update to yPublish log tablle.
    ---------------------------------------------------------
    v_adm_userid := trim(in_updated_by);

    do_upd_ypub_image_log( 
            in_trans_id,
            in_image_id,
            in_ypub_status_code,
            in_ypub_status_log,
            in_is_published,
            in_updated_by,
            out_status_code,
            out_status_msg );

    return;            
            
EXCEPTION
    when others then
        rollback;
        out_status_code := g_image_log_unknown_error;
        out_status_msg  :=
            v_proc_name ||  
            'Unknown error while updating CSPR_YPUBLISH_IMAGE_LOG table. ' ||
            substr(sqlerrm,1,500);

        return;
                
END process_upd_ypub_image_log;
            
/*
||=================================================================
|| Update cspr_image_posting_status table per image
||  a) transaction_status 'Success' or 'Fail'.
||=================================================================
*/
PROCEDURE process_upd_cspr_image_status ( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_updated_by           in  varchar2,
            in_cco_download_url     in  varchar2,
            in_md5_checksum         in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )

IS
    v_proc_name     varchar2(200) := '[' || g_pkg_name || '.process_upd_cspr_image_status] ';
    v_image_status  varchar2(20)  := null;
    v_trans_userid  varchar2(20);
    v_trans_type    cspr_image_posting_status.cco_transaction_type%type;
    v_trans_time    date;
    /*in_cco_download_url     varchar2(2000); */

BEGIN

    v_image_status := get_image_status( in_trans_id, in_image_id );
    --v_image_status := 'Success';
    v_trans_time   := get_trans_time( in_trans_id, in_image_id );
    v_trans_type   := get_image_trans_type(in_image_id);
    v_trans_userid := get_trans_userid(in_trans_id);

    if( lower(v_trans_type) = 'post' and lower(v_image_status) = 'success' ) then
        update 
            cspr_image_posting_status
        set
            cco_first_posted_time = (
                select created_date 
                from cspr_ypublish_trans_log 
                where transaction_id = in_trans_id ) --v_trans_time
        where 
            image_id = in_image_id
            and cco_first_posted_time is null;
        
    end if;
        
    if ( lower(v_trans_type) = 'post' and lower(v_image_status) = 'success' ) then

        update 
            cspr_image_posting_status
        set
            cco_transaction_status = v_image_status,
            cco_transaction_time = v_trans_time,
            cco_posted_time = v_trans_time,
            cco_posted_by = v_trans_userid,
            adm_userid = trim(in_updated_by),
            adm_timestamp = sysdate,
            adm_flag = 'V',
            cco_download_url = in_cco_download_url, 
            md5_checksum = in_md5_checksum,
            adm_comment = g_pkg_name || ' - UPDATED'
        where
            image_id = in_image_id;
    elsif ( lower(v_trans_type) = 'repost' and lower(v_image_status) = 'success' ) then

        update 
            cspr_image_posting_status
        set
            cco_transaction_status = v_image_status,
            cco_transaction_time = v_trans_time,
            cco_posted_time = v_trans_time,
            cco_posted_by = v_trans_userid,
            adm_userid = trim(in_updated_by),
            adm_timestamp = sysdate,
            adm_flag = 'V',
            cco_download_url = in_cco_download_url,
            adm_comment = g_pkg_name || ' - UPDATED'
        where
            image_id = in_image_id;
    else            
        update 
            cspr_image_posting_status
        set
            cco_transaction_status = v_image_status,
            cco_transaction_time = v_trans_time,
            adm_userid = trim(in_updated_by),
            adm_timestamp = sysdate,
            adm_flag = 'V',
            adm_comment = g_pkg_name || ' - UPDATED'
        where
            image_id = in_image_id;
     end if;

    return;
            
EXCEPTION
    when no_data_found then
        rollback;
        out_status_code := g_post_status_invalid_image_id;
        out_status_msg  :=
            v_proc_name ||  
            'Image ID ' || in_image_id || ' not found in cspr_image_posting_status table.';

        log_ypub_image_error (
            in_trans_id,
            in_image_id,
            null,
            null,
            null,
            in_updated_by,
            out_status_code,
            out_status_msg );
            
        return;
        
    when others then
        rollback;
        out_status_code := g_post_status_unknown_error;
        out_status_msg  :=
            v_proc_name ||  
            'Unknown error while updating cspr_image_posting_status table. ' ||
            substr(sqlerrm,1,500);

        log_ypub_image_error (
            in_trans_id,
            in_image_id,
            null,
            null,
            null,
            in_updated_by,
            out_status_code,
            out_status_msg );

        return;
                
END process_upd_cspr_image_status;

/*
||=================================================================
|| Send a mail to cisromm and oscar user notifying the status of the process.
||
|| in  in_env:                       - Indicates database environment, It determines
||                                 the email recipients.
||                                 value: 'prod', 'dev', 'test'.
|| in  in_mail_from_alias:      - alias for email sender.
||                                 Ex: 'CISROMM-OSCAR mailer'
|| in  n_mail_from_email_addr - Email address for param in_mail_from_alias.
|| in  in_mail_subject          - Email subject.
|| in  in_mail_text              - Email body.
|| out out_errmsg              - Error message
||
||=================================================================
*/
PROCEDURE SEND_MAIL (
                 in_env                  in  varchar2,
                 in_mail_from_alias      in  varchar2,
                 in_mail_from_email_addr in  varchar2,
                 in_mail_subject           in  varchar2,
                 in_mail_text              in  varchar2,
                 out_errmsg                out varchar2 ) 
IS
    v_proc_name               varchar2(100) := '[' || g_pkg_name || 'send_mail] ';
    c                         utl_tcp.connection;
    rc                        integer;
    v_now                     varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_mail_to_email_addr_tab  email_addr_tab_type := email_addr_tab_type( 'aadvani@cisco.com', 'rruddara@cisco.com', 'aselvara@cisco.com' );

  
BEGIN

    c := utl_tcp.open_connection('127.0.0.1', 25);             -- open the SMTP port 25 on local machine
    rc := utl_tcp.write_line(c, 'HELO local.cisco.com');       -- PERFORMS HANDSHAKING WITH SMTP SERVER
    dbms_output.put_line(utl_tcp.get_line(c, TRUE));
    rc := utl_tcp.write_line(c, 'MAIL FROM: '||in_mail_from_alias);
    dbms_output.put_line(utl_tcp.get_line(c, TRUE));
    
    for i in 1..v_mail_to_email_addr_tab.count loop
        rc := utl_tcp.write_line(c, 'RCPT TO: '||v_mail_to_email_addr_tab(i));
        dbms_output.put_line(utl_tcp.get_line(c, TRUE));
    end loop;
    
    rc := utl_tcp.write_line(c, 'DATA');
    dbms_output.put_line(utl_tcp.get_line(c, TRUE));
  
    rc := utl_tcp.write_line(c, 'Date: '||v_now);
    rc := utl_tcp.write_line(c, 'From: '||in_mail_from_alias||' <'||in_mail_from_email_addr||'>');
    rc := utl_tcp.write_line(c, 'MIME-Version: 1.0');
    for i in 1..v_mail_to_email_addr_tab.count loop
        rc := utl_tcp.write_line(c, 'To: '||v_mail_to_email_addr_tab(i)||' <'||v_mail_to_email_addr_tab(i)||'>');
    end loop;

    rc := utl_tcp.write_line(c, 'Subject: '||in_mail_subject);
    rc := utl_tcp.write_line(c, 'Content-Type: multipart/mixed;');     -- INDICATES THAT THE BODY CONSISTS OF MORE THAN ONE PART
    rc := utl_tcp.write_line(c, ' boundary="-----SECBOUND"');          -- SEPERATOR USED TO SEPERATE THE BODY PARTS
    rc := utl_tcp.write_line(c, '');                                   -- INSERTS A BLANK LINE. PART OF THE MIME FORMAT AND NONE OF THEM SHOULD BE REMOVED.
    rc := utl_tcp.write_line(c, '-------SECBOUND');
    rc := utl_tcp.write_line(c, 'Content-Type: text/plain');           -- 1ST BODY PART. EMAIL TEXT MESSAGE
    rc := utl_tcp.write_line(c, 'Content-Transfer-Encoding: 7bit');
    rc := utl_tcp.write_line(c, '');

    rc := utl_tcp.write_line(c, '');
    rc := utl_tcp.write_line(c, in_mail_text);
    rc := utl_tcp.write_line(c, '');
    rc := utl_tcp.write_line(c, '*** End of Message ***');
    rc := utl_tcp.write_line(c, '');
    rc := utl_tcp.write_line(c, '.');                    -- Email message must end with '.''

    dbms_output.put_line(utl_tcp.get_line(c, TRUE));
    rc := utl_tcp.write_line(c, 'QUIT');                 -- ENDS EMAIL TRANSACTION
    dbms_output.put_line(utl_tcp.get_line(c, TRUE));
    utl_tcp.close_connection(c);                         -- CLOSE SMTP PORT CONNECTION

EXCEPTION
    WHEN OTHERS THEN
        raise_application_error( -20101, v_proc_name || ' ===> ' || substr(sqlerrm, 1, 1300) );
END SEND_MAIL;

/*
||=================================================================
|| - Validate all parameters for CSPR_ypub_IMAGE_LOG table.
|| - If INVALUD, store all the passed data in 
||   CSPR_ypub_IMAGE_ERROR table.
||=================================================================
*/
PROCEDURE validate_image_log_param( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.validate_image_log_param] ';
    
BEGIN

    ------------------------------------------------
    -- Validate in_trans_id
    ------------------------------------------------
    validate_trans_id_image_id( 
            in_trans_id,
            in_image_id,
            in_ypub_status_code,
            in_ypub_status_log,
            in_is_published,
            in_updated_by,
            out_status_code,
            out_status_msg );

    if( out_status_code > 0 ) then
        return;
    end if;
        
    ------------------------------------------------
    -- Validate in_ypub_status_code.
    ------------------------------------------------
    if( in_ypub_status_code is null )
    then

        out_status_code := g_image_log_invalid_param;
        out_status_msg  := 'Invalid IN_ypub_STATUS_CODE: null.';
        return;
    end if;

    ------------------------------------------------
    -- Validate in_ypub_status_log.
    ------------------------------------------------
    if( in_ypub_status_log is null 
        or nvl(length(trim(in_ypub_status_log)),0) = 0 )
    then
        out_status_code := g_image_log_invalid_param;
        out_status_msg  := 'Invalid IN_ypub_STATUS_LOG: null or empty.';
        return;
    end if;

    if( nvl(length(trim(in_ypub_status_log)),0) > 4000 )
    then
        out_status_code := g_image_log_invalid_param;
        out_status_msg  := 'Invalid IN_ypub_STATUS_LOG. ' ||
            'Value is too large. Maximum length is 4000.';
        return;
    end if;

    ------------------------------------------------
    -- Validate in_is_published.
    ------------------------------------------------
    if( in_is_published is null 
        or nvl(length(trim(in_is_published)),0) = 0 )
    then
        out_status_code := g_image_log_invalid_param;
        out_status_msg  := 'Invalid IN_IS_PUBLISHED: null or empty.';
        return;
    end if;

    if( nvl(length(trim(in_is_published)),0) > 1  )
    then
        out_status_code := g_image_log_invalid_param;
        out_status_msg  :=
            'Invalid IN_IS_PUBLISHED: ' || in_is_published || '. ' ||
            'Valid values: Y, N.' ;
        return;
    end if;

    if( trim(in_is_published) <> 'Y'
        and trim(in_is_published) <> 'N' )
    then
        out_status_code := g_image_log_invalid_param;
        out_status_msg  :=
            'Invalid IN_IS_PUBLISHED: ' || in_is_published || '. ' ||
            'Valid values: Y, N.' ;
        return;
    end if;

    ------------------------------------------------
    -- Validate in_updated_by
    ------------------------------------------------
    if( in_updated_by is null 
        or nvl(length(trim(in_updated_by)),0) = 0 )
    then
        out_status_code := g_image_log_invalid_param;
        out_status_msg  := 'Invalid IN_UPDATED_BY: null or empty.';
        return;
    end if;

    if( nvl(length(trim(in_updated_by)),0) > 8  )
    then
        out_status_code := g_image_log_invalid_param;
        out_status_msg  := 
            'Invalid IN_UPDATED_BY: ' || in_updated_by || '. ' ||
            'Maximum length is 8.' ;
        return;
    end if;

    out_status_code := g_success_code;
    out_status_msg  := g_success_msg;
    
    return;

EXCEPTION 
    when others then
        out_status_code := g_image_log_invalid_param;
        out_status_msg  :=
            v_proc_name ||
            'Unknown Error when validating image log parameters. ' ||
            substr(sqlerrm, 1, 500);
        return;
        
END validate_image_log_param;
/*
||=================================================================
|| - Validate all parameters for CSPR_ypub_TRANS_LOG table.
|| - If INVALUD, store all the passed data in 
||   CSPR_ypub_XML_ERROR table.
||=================================================================
*/
PROCEDURE validate_trans_log_param( 
            in_trans_id             in  number,
            in_xml_response         in  varchar2,
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.validate_trans_log_param] ';
    
BEGIN

    ------------------------------------------------
    -- Validate in_trans_id
    ------------------------------------------------
    validate_trans_id( 
            in_trans_id,
            in_xml_response,
            in_is_xml_accepted,
            in_updated_by,
            out_status_code,
            out_status_msg );

    if( out_status_code > 0 ) then
        return;
    end if;

    ------------------------------------------------
    -- Validate in_xml_response.
    ------------------------------------------------
    
    if( in_xml_response is null 
        or nvl(length(trim(in_xml_response)),0) = 0 )
    then
        out_status_code := g_trans_log_invalid_param;
        out_status_msg  := 'Invalid IN_XML_RESPONSE: null or empty.';
        return;
    end if;
    
    if( nvl(length(trim(in_xml_response)),0) > 4000 )
    then
        out_status_code := g_trans_log_invalid_param;
        out_status_msg  :=
            'Invalid IN_XML_RESPONSE: Value is too large. Maximum length is 4000.';
        return;
    end if;

    ------------------------------------------------
    -- Validate in_is_xml_accepted.
    ------------------------------------------------
    if( in_is_xml_accepted is null 
        or nvl(length(trim(in_is_xml_accepted)),0) = 0 )
    then
        out_status_code := g_trans_log_invalid_param;
        out_status_msg  := 'Invalid IN_IS_XML_ACCEPTED: null or empty.';
        return;
    end if;
    
    if( trim(in_is_xml_accepted) <> 'Y'
        and trim(in_is_xml_accepted) <> 'N' )
    then
        out_status_code := g_trans_log_invalid_param;
        out_status_msg  :=
            'Invalid IN_IS_XML_ACCEPTED: ' || in_is_xml_accepted ||
            '. Valid values: Y, N.';
        return;
    end if;

    ------------------------------------------------
    -- Validate in_updated_by.
    -- Allows only upto 8 characters.
    ------------------------------------------------
    if( in_updated_by is null 
        or nvl(length(trim(in_updated_by)),0) = 0 )
    then
        out_status_code := g_trans_log_invalid_param;
        out_status_msg  := 'Invalid IN_UPDATED_BY: null or empty.';
        return;
    end if;
    
    if( nvl(length(trim(in_updated_by)),0) > 8  )
    then
        out_status_code := g_trans_log_invalid_param;
        out_status_msg  :=
             'Invalid IN_UPDATED_BY: ' || in_updated_by ||
             '. Maximum length is 8.';
        return;
    end if;

    out_status_code := g_success_code;
    out_status_msg  := g_success_msg;
    
    return;

EXCEPTION 
    when others then
        out_status_code := g_trans_log_unknown_error;
        out_status_msg  :=
            v_proc_name ||
            'Unknown Error when validating xml log parameters. ' ||
            substr(sqlerrm, 1, 500);
        return;
        
END validate_trans_log_param;

/*
||================================================================
|| - Validate in_trans_id from CSPR_ypub_TRANS_LOG table.
|| - If INVALUD, store all the passed data in 
||   CSPR_ypub_XML_ERROR table.
||================================================================
*/
PROCEDURE validate_trans_id( 
            in_trans_id             in  number,
            in_xml_response         in  varchar2,
            in_is_xml_accepted      in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.validate_trans_id] ';
    v_exist             number := 0;
    
BEGIN

    if( in_trans_id is null ) then
        out_status_code := g_trans_log_invalid_trans_id;
        out_status_msg  := 'Invalid Transaction ID: null.'; 
        return;
    end if;
       
     
    select 
        1
    into
        v_exist
    from
        cspr_ypublish_trans_log
    where
        transaction_id = in_trans_id;
        
    if( v_exist = 0 ) then
        raise no_data_found;
    end if;
            
    out_status_code := g_success_code;
    out_status_msg  := g_success_msg; 

    return;

EXCEPTION 
    when no_data_found then
        out_status_code := g_trans_log_invalid_trans_id;
        out_status_msg  := 'Invalid Transaction ID: ' || in_trans_id ||'.'; 
        return;
                
    when others then
        out_status_code := g_trans_log_unknown_error;
        out_status_msg  :=
            v_proc_name ||
            'Unknown error when validating Transaction ID. ' ||
            substr(sqlerrm,1,500);
        return;
        
END validate_trans_id;

/*
||=================================================================
|| - Validate in_trans_id and image_id from CSPR_ypub_IMAGE_LOG table.
|| - If INVALUD, store all the passed data in 
||   CSPR_ypub_IMAGE_ERROR table.
||=================================================================
*/
PROCEDURE validate_trans_id_image_id( 
            in_trans_id             in  number,
            in_image_id             in  number,
            in_ypub_status_code     in  number,
            in_ypub_status_log      in  varchar2,
            in_is_published         in  varchar2,
            in_updated_by           in  varchar2,
            out_status_code         in out number,
            out_status_msg          in out varchar2 )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.validate_trans_id_image_id] ';
    v_exist             number := 0;
    
BEGIN

    ---------------------------------------------------------
    -- Checking for NULL in_trans_id and NULL in_image_id.
    ---------------------------------------------------------
    if( in_trans_id is null ) then
        out_status_code := g_image_log_invalid_trans_id;
        out_status_msg  := 'Invalid Transaction ID: null.'; 
        return;
    end if;

    if( in_image_id is null ) then
        out_status_code := g_image_log_invalid_image_id;
        out_status_msg  := 'Invalid Image ID: null.'; 
        return;
    end if;

    ---------------------------------------------------------
    -- Validate transaction ID.
    ---------------------------------------------------------
    BEGIN
        select 
            1
        into
            v_exist
        from
            cspr_ypublish_image_log
        where
            transaction_id = in_trans_id
            and rownum = 1;

        if( v_exist = 0 ) then
            raise no_data_found;
        end if;

    EXCEPTION 
        when no_data_found then
            out_status_code := g_image_log_invalid_trans_id;
            out_status_msg  := 'Invalid Tranaction ID: ' || in_trans_id || '.';
            return;
            
        when others then
            out_status_code := g_image_log_unknown_error;
            out_status_msg  := 
                v_proc_name ||
                'Unknown error when validating Transaction ID: ' ||
                in_trans_id || '. ' ||
                substr(sqlerrm,1,500);
                
            return;
    END;
                
    ---------------------------------------------------------
    -- Validate Image ID.
    ---------------------------------------------------------
    BEGIN
        select 
            1
        into
            v_exist
        from
            cspr_ypublish_image_log
        where
            transaction_id = in_trans_id
            and image_id = in_image_id ;
            
        if( v_exist = 0 ) then
            raise no_data_found;
        end if;

    EXCEPTION 
        when no_data_found then
            out_status_code := g_image_log_invalid_image_id;
            out_status_msg  := 'Invalid Image ID: ' || in_image_id || '.';
            return;
            
        when others then
            out_status_code := g_image_log_unknown_error;
            out_status_msg  :=
                v_proc_name ||
                'Unknown error when validating Image ID: ' || in_image_id || '. ' ||
                substr(sqlerrm,1,500);
                
            return;
    END;

    out_status_code := g_success_code;
    out_status_msg  := g_success_msg;
    
    return;

EXCEPTION 
    when others then
        out_status_code := g_image_log_unknown_error;
        out_status_msg  :=
            v_proc_name ||
            'Unknown error when validating Transaction ID ' ||
            in_trans_id || ', Image ID ' || in_image_id || '. ' ||
            substr(sqlerrm,1,500);
        return;
        
END validate_trans_id_image_id;


/*
||=================================================================
|| - do_upd_dvd_major_release_log for  DVDMajorReleaseMDFNavigation
||=================================================================
*/
PROCEDURE do_upd_dvd_major_release_log ( 
            in_trans_id                     in  number,
            in_release_number          	    in  varchar2, 
            in_software_type_mdf_id         in  number,
            in_is_published                 in  varchar2,
            in_ypub_status_code     	    in  number,
            in_ypub_status_log              in  varchar2,
            in_updated_by                   in  varchar2,
            out_status_code                 in  out number,
            out_status_msg                  in  out varchar2 )            
IS
    v_proc_name    varchar2(200) := '[' || g_pkg_name || '.do_upd_dvd_major_release_log] ';
    v_os_type_id   shr_os_type.os_type_id%type;
    --v_release_number shr_release_number.release_number%type;
    
BEGIN

    -- v_release_number := get_rel_number_id(in_software_type_mdf_id, in_release_number);
    select 
	        so.os_type_id 
    into 	
	        v_os_type_id
    from 
	        shr_os_type so,
	        shr_ostype_mdfswtype sm
    where 
	        so.os_type_id = sm.os_type_id
	        and sm.mdf_swt_concept_id = in_software_type_mdf_id
	        and sm.adm_flag ='V'
	        and so.adm_flag ='V';
    IF(v_os_type_id=1) then         
    update 
        cspr_ypublish_dvdmajor_rel_log
    set
        is_published         = trim(in_is_published),
        ypublish_status_code = in_ypub_status_code,
        ypublish_status_log  = trim(in_ypub_status_log),
        adm_timestamp        = sysdate,
        adm_userid           = trim(in_updated_by),
        adm_flag = 'V',
        adm_comment = g_pkg_name || ' - UPDATED'
    where
        transaction_id         = in_trans_id 
        and release_number  in(
            select
                 distinct release_number   
            from  
                sds_release      
            where 
               release_number1 = in_release_number    
               or release_number2 =   in_release_number)
        and mdf_swt_concept_id = in_software_type_mdf_id;
    ELSE
          update 
               cspr_ypublish_dvdmajor_rel_log
          set
              is_published         = trim(in_is_published),
              ypublish_status_code = in_ypub_status_code,
              ypublish_status_log  = trim(in_ypub_status_log),
              adm_timestamp        = sysdate,
              adm_userid           = trim(in_updated_by),
              adm_flag = 'V',
              adm_comment = g_pkg_name || ' - UPDATED'
          where
              transaction_id         = in_trans_id 
              and release_number_id = 
        	 (select 
                	cr.release_number_id 
              
       		  from 
                	cspr_release_number cr, 
                	shr_ostype_mdfswtype sm
        	  where 
                	cr.release_name= in_release_number 
                	and sm.mdf_swt_concept_id = in_software_type_mdf_id
                	and cr.os_type_id = sm.os_type_id
                	and cr.adm_flag='V'
                	and sm.adm_flag='V');
    END IF; 
       
    commit;
    out_status_code := g_success_code;
    out_status_msg  := g_success_msg;
    
    return;
        
EXCEPTION
    when no_data_found then
         begin
         --out_status_code := 'No data found';
         out_status_msg  := ' No data found'; 
         end; 
    when others then
        rollback;
        out_status_code := g_trans_log_unknown_error;
        out_status_msg  :=
            out_status_msg || ' ' ||
            v_proc_name ||
            'Unknown error while updating CSPR_YPUBLISH_DVDMAJOR_REL_LOG table with Ypublish response. ' ||
            substr(sqlerrm,1,500);
            
        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_updated_by,
            out_status_code,
            out_status_msg );   

        return;

END do_upd_dvd_major_release_log;

PROCEDURE do_upd_ypublish_message_log ( 
            in_trans_id                     in  number,
            in_image_id                     in  number,
            in_message                      in  varchar2, 
            in_created_by                   in  varchar2,
            out_status_code                 in  out number,
            out_status_msg                  in  out varchar2)

IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    v_proc_name             varchar2(200) := '[' || g_pkg_name || '.do_upd_ypublish_message_log] ';
    v_message               cspr_ypublish_message_log.message%type;
    v_created_by            cspr_ypublish_message_log.created_by%type;
    v_status_code           number := 0;

BEGIN

    debug_output(v_proc_name || 'BEGIN' );
    
    ------------------------------------------------
    -- Validate in_trans_id
    ------------------------------------------------
    validate_trans_id_image_id( 
            in_trans_id
            ,in_image_id
            ,null --in_ypub_status_code,
            ,null --in_ypub_status_log,
            ,null --in_is_published
            ,in_created_by
            ,out_status_code
            ,out_status_msg );

    if( out_status_code > 0 ) then
        return;
    end if;

    ----------------------------------------------------------
    -- Get the maximum substring to store in error table.
    -- This way, we can prevent too large value for the column error.
    ----------------------------------------------------------
    
    --v_xml_response      := substr(in_xml_response, 1, 4000 );
    --v_is_xml_accepted   := substr(in_is_xml_accepted, 1, 20);
    --v_createde_by        := substr(in_created_by, 1, 20);
    out_status_msg      := substr(out_status_msg, 1, 4000);            
    
    INSERT INTO cspr_ypublish_message_log( 
        message_id     
       ,transaction_id 
       ,image_id 
       ,message  
       ,created_by 
       ,created_date 
       ,adm_userid   
       ,adm_timestamp 
       ,adm_flag      
       ,adm_comment
       )
      values (
         CSPR_YPUBLISH_MESSAGE_LOG_SEQ.nextval
        ,in_trans_id
        ,in_image_id
        ,in_message
        ,in_created_by
        ,sysdate
        ,in_created_by
        ,sysdate
        ,'V'
        ,g_pkg_name || ' - CREATED'
        );

    commit;
    
    return;


EXCEPTION
        when OTHERS then
        rollback;

        out_status_code := g_trans_log_unknown_error;
        out_status_msg  := v_proc_name ||'Unknow error. ' || substr(sqlerrm,1,500);

        log_ypub_trans_error (
            in_trans_id,
            null,
            null,
            in_created_by,
            out_status_code,
            out_status_msg );
        return;
    
END do_upd_ypublish_message_log;

/*
||=================================================================
|| - Return OS type from 
||=================================================================
*/
FUNCTION get_os_type( 
            in_trans_id             number,
            in_image_id             number  )
return varchar2  IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.validate_image_log_param] ';
    v_os_type           shr_os_type.os_type_name%type;
    
BEGIN
    select
        ot.os_type_name
    into
        v_os_type
    from
        shr_os_type                ot,
        cspr_ypublish_image_log    il 
    where
        il.transaction_id = in_trans_id
        and il.image_id = in_image_id
        and il.os_type_id = ot.os_type_id   ;      
        
    return v_os_type;

EXCEPTION 
    when others then
        return null;
        
END get_os_type;

/*
||=================================================================
|| - Return Database environment.
|| - 'DEV', 'TEST', 'PROD'.
||=================================================================
*/
FUNCTION get_db_env return varchar2 IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_db_env] ';
    v_db_env            varchar2(20);
    v_schema            varchar2(20);
    
BEGIN

    select *    into v_db_env from global_name;
     select user into v_schema from dual;

    if( instr(v_db_env, 'PROD') > 0 ) then      
        v_db_env := 'PROD';
    elsif( instr(v_db_env, 'TEST') > 0 ) then
        v_db_env := 'TEST';
    -- shr_rda@DEVRDA is used for TEST.
    elsif( instr(v_db_env, 'DEV') > 0 and instr(v_schema, 'DEV') = 0) then
        v_db_env := 'TEST';
    elsif( instr(v_db_env, 'DEV') > 0 ) then
        v_db_env := 'DEV';
    else
        v_db_env := v_db_env;
    end if;
    
    return v_db_env;
    
EXCEPTION 
    when others then
        return null;
        
END get_db_env;

/*
||=================================================================
|| - return release id for the transaction id. 
||=================================================================
*/
FUNCTION get_release_id ( 
            in_trans_id             number ) return relIdTabTyp
IS
    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_release_id] ';
    v_rel_id_tab        relIdTabTyp;
    v_cnt               number := 0;
    
    cursor rel_id_cur is
        select
            distinct release_number_id
        from
            cspr_ypublish_image_log  
        where
            transaction_id = in_trans_id; 
    
BEGIN

    for c in rel_id_cur loop
        v_cnt := v_cnt + 1;
        v_rel_id_tab(v_cnt) := c.release_number_id;
    end loop;

    return v_rel_id_tab;
    
EXCEPTION 
    when others then
          dbms_output.put_line( v_proc_name || 'Error: ' || substr(sqlerrm,1,200) );
        return v_rel_id_tab;
        
END get_release_id;

/*
||=================================================================
|| - Return servlet URL 
||=================================================================
*/
FUNCTION get_servlet_url( 
            in_trans_id             number )
return varchar2  IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_servlet_url] ';
    v_url               cspr_ypublish_trans_log.environment_url%type;
    
BEGIN

--    debug_output( v_proc_name || 'in_trans_id=' || in_trans_id );

    select
        tlog.environment_url
    into
        v_url
    from
        cspr_ypublish_trans_log    tlog 
    where
        tlog.transaction_id = in_trans_id ;

--    debug_output( v_proc_name || 'v_url=' || v_url );
            
    return v_url;

EXCEPTION 
    when others then
        dbms_output.put_line( v_proc_name || 'returning null' );
        return null;
        
END get_servlet_url;

/*
||=================================================================
|| - return transaction userid for the transaction id. 
|| - This information exists only in CSPR_YPUBLISH_TRNAS_LOG.created_by.
||=================================================================
*/
FUNCTION get_trans_userid (
            in_trans_id             number ) return varchar2

IS
    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_trans_userid] ';
    v_userid            varchar2(20);    

BEGIN

    select
        created_by
    into
        v_userid
    from
        cspr_ypublish_trans_log  
    where
        transaction_id = in_trans_id;
        
    return v_userid;

EXCEPTION 
    when others then
        return null;
        
END get_trans_userid;

/*
||=================================================================
|| - Returns  CSPR_YPUBLISH_TRANS_LOG.transaction_type
||=================================================================
*/
FUNCTION get_trans_type( 
            in_trans_id             number )
return varchar2  IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_trans_type] ';
    v_trans_type        varchar2(20)  := '';

BEGIN

    select
        transaction_type
    into
        v_trans_type
    from
        cspr_ypublish_trans_log    
    where
        transaction_id = in_trans_id ;

    return v_trans_type;

EXCEPTION 
    when no_data_found then
        return v_trans_type;
    when others then
        return null;
        
END get_trans_type;

/*
||=================================================================
|| - Returns  CSPR_YPUBLISH_TRANS_LOG.is_first_time_post
||=================================================================
*/
FUNCTION get_trans_is_first_time_post( 
            in_trans_id             number )
return varchar2  IS

    v_proc_name            varchar2(200) := '[' || g_pkg_name || '.get_trans_is_first_time_post] ';
    v_is_first_time_post   varchar2(20)  := '';

BEGIN

    select
        decode(is_first_time_post, null, 'N', is_first_time_post)
    into
        v_is_first_time_post
    from
        cspr_ypublish_trans_log    
    where
        transaction_id = in_trans_id ;

    return v_is_first_time_post;

EXCEPTION 
    when no_data_found then
        return v_is_first_time_post;
    when others then
        return null;
        
END get_trans_is_first_time_post;


/*
||=================================================================
|| - Returns true if all images for the transaction is processed.
|| - Returns false otherwise. 
||=================================================================
*/
FUNCTION is_all_image_processed( 
            in_trans_id             number )
return boolean IS

    v_proc_name             varchar2(200) := '[' || g_pkg_name || '.is_all_image_processed] ';
    v_all_image_processed   varchar2(20)  := 'YES';
    
BEGIN

    select
        'NO'
    into
        v_all_image_processed
    from
        cspr_ypublish_image_log 
    where
        transaction_id = in_trans_id
        and ypublish_status_code is null;

    if( v_all_image_processed = 'YES' ) then
        return true;
    else
        return false;
    end if;   
        

EXCEPTION 
    when no_data_found then
        return true;
    when others then
        return null;
        
END is_all_image_processed;

/*
||=================================================================
|| - return repost flag for Java servlet's 'repost' parameter. 
||=================================================================
*/
FUNCTION get_servlet_repost_flag (
            in_trans_id             number,
            in_rel_id               number ) return varchar2
IS
    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_servlet_repost_flag] ';
    v_repost_flag       varchar2(10) := 'N';

BEGIN

    select
        'Y'
    into
        v_repost_flag
    from
        cspr_ypublish_image_log   ilog
    where
        ilog.transaction_id = 
             (select
                  max( ilog2.transaction_id)
              from
                  cspr_ypublish_image_log   ilog2
              where 
                  ilog2.transaction_id < in_trans_id
                  and release_number_id = in_rel_id
             )
        and ilog.release_number_id = in_rel_id
        and rownum = 1;

    return v_repost_flag;
            
EXCEPTION 
    when no_data_found then
        return 'N';
    when others then
        return null;
        
END get_servlet_repost_flag;

/*
||=================================================================
|| - Returns  image status,  'Success', or 'Fail'.
||=================================================================
*/
FUNCTION get_trans_status( 
            in_trans_id             number )
return varchar2  IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_trans_status] ';
    v_trans_status      varchar2(20)  := 'Success';

BEGIN

    select
        'Fail'
    into
        v_trans_status
    from
        cspr_ypublish_image_log    
    where
        transaction_id = in_trans_id
        and is_published = 'N'
        and rownum = 1;

    return v_trans_status;

EXCEPTION 
    when no_data_found then
        return v_trans_status;
    when others then
        return null;
        
END get_trans_status;

/*
||=================================================================
|| - Returns  transaction time from image log.
||=================================================================
*/
FUNCTION get_trans_time( 
            in_trans_id             number,
            in_image_id             number )
RETURN date IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_trans_time] ';
    v_trans_time        date;

BEGIN

    select
        adm_timestamp
    into
        v_trans_time
    from
        cspr_ypublish_image_log    
    where
        image_id = in_image_id
        and transaction_id = in_trans_id;

    return v_trans_time;

EXCEPTION 
    when no_data_found then
        return null;
    when others then
        return null;
        
END get_trans_time;

/*
||=================================================================
|| - Returns  cspr_image_posting_status.cco_transaction_type.
||=================================================================
*/
FUNCTION get_image_trans_type( 
            in_image_id             number )
return varchar2  IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_image_trans_type] ';
    v_trans_type        varchar2(20)  := 'Success';

BEGIN

    select
        cco_transaction_type
    into
        v_trans_type
    from
        cspr_image_posting_status    
    where
        image_id = in_image_id;

    return v_trans_type;

EXCEPTION 
    when no_data_found then
        return null;
    when others then
        return null;
        
END get_image_trans_type;

/*
||=================================================================
|| - Returns  image status, 'Success', or 'Fail'.
||=================================================================
*/
FUNCTION get_image_status( 
            in_trans_id             number,
            in_image_id             number )
return varchar2  IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_image_status] ';
    v_image_status      varchar2(20)  := null;

BEGIN

    select
        DECODE( is_published, 'Y', 'Success', 'N', 'Fail', null )
    into
        v_image_status
    from
        cspr_ypublish_image_log    
    where
        transaction_id = in_trans_id
        and image_id = in_image_id ;
        
    return v_image_status;

EXCEPTION 
    when no_data_found then
        return null;
    when others then
        return null;
        
END get_image_status;

END SHR_YPUBLISH_LOG_PKG;
/
