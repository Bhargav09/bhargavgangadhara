CREATE OR REPLACE PACKAGE SPRIT.ESC_CACHE_REFRESH_PKG AS
TYPE email_addr_tab_type  is TABLE of varchar2(50);
PROCEDURE main;
 
PROCEDURE notify_user (     
        in_is_successful           in boolean,
        in_start_time              in varchar2,
        in_end_time                in varchar2,
        in_errmsg                  in varchar2,
        v_esc_eol_cnt              in number,
        v_esc_eol_local_cnt        in number,
        delete_cnt                 in number,
        update_cnt                 in number,
        new_cnt                    in number,
        request_id                 in number);
        
 PROCEDURE send_email (
        in_env                     in  varchar2,
        in_mail_to                 in  varchar2,
        in_mail_from_alias         in  varchar2,
        in_mail_from_email_addr    in  varchar2,
        in_mail_subject            in  varchar2,
        in_mail_text               in  varchar2,
        out_errmsg                 out varchar2 );
    
END ESC_CACHE_REFRESH_PKG;

CREATE OR REPLACE PACKAGE BODY SPRIT.ESC_CACHE_REFRESH_PKG AS

 g_pkg_name      varchar2(100) := 'SHR_ESC_CACHE_REFRESH_PKG';
 g_newline       varchar2(2)  := CHR(13)||CHR(10);
 -- g_env determines email notification recipient.
 -- Make sure the value is changed to 'prod' when put into production.
 g_env       varchar2(20) := 'prod';
 --g_env       varchar2(20) := 'dev';
 
 /*
||======================================================================
|| Main function
||======================================================================
*/
PROCEDURE main IS
  
  update_ct number        := 0;
  delete_ct number        := 0;
  new_ct    number        := 0;
  last_update_time date   := null;
  msg varchar2(500)       := null;
  sprit_side_ct number    := 0;
  esc_side_ct   number    := 0;
  refresh_id_num    number    := 0;
  ct            number    := 0;
  v_now         varchar2(100);
  v_adm_comment varchar2(100);
  v_start_time  varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
  v_errmsg      varchar2(1000);

  
  -- cursor to fetch recently modified data from esc db
  CURSOR esc_eol_db_cur(last_updated date) IS
  SELECT * 
  FROM ESC_EOL_PID_SPRIT_V
  WHERE UPDATE_TIMESTAMP > last_updated;
  
  esc_eol_db_cur_rec esc_eol_db_cur%ROWTYPE;
  
  -- cursor to fetch active pid
  CURSOR esc_eol_active_pid_cur(npid varchar2, last_updated date) IS
  SELECT * 
  FROM ESC_EOL_PID_SPRIT_V
  WHERE pid = npid and active_flag = 'Y' and UPDATE_TIMESTAMP < last_updated;
  
  esc_eol_active_pid_cur_rec esc_eol_active_pid_cur%ROWTYPE;
  
  -- cursor to get record in sprit db
  CURSOR spirt_cache_db_cur(p_id varchar2, req_id varchar2) IS
  SELECT * 
  FROM esc_eol_pid_cache
  WHERE REQUEST_ID = req_id and PID = p_id;
    
  spirt_cache_db_cur_rec spirt_cache_db_cur%ROWTYPE;
  
  -- cursor to find sprit db - esc db
  CURSOR spirt_esc_diff_cur IS  
  SELECT esc_eol_pid_cache.request_id as request_id,esc_eol_pid_cache.pid as pid
  FROM esc_eol_pid_cache
  LEFT OUTER JOIN ESC_EOL_PID_SPRIT_V
  ON ESC_EOL_PID_SPRIT_V.request_id = esc_eol_pid_cache.request_id
  and ESC_EOL_PID_SPRIT_V.pid = esc_eol_pid_cache.pid
  where ESC_EOL_PID_SPRIT_V.request_id is null and ESC_EOL_PID_SPRIT_V.pid is null;
  
  spirt_esc_diff_cur_rec spirt_esc_diff_cur%ROWTYPE;  
  
BEGIN
dbms_output.put_line ('--- Running Main ---');  
 
 -- select last auto refresh time
 select LAST_UPDATED_TIME
 into last_update_time
 from  auto_refrsh_detail
 where LAST_UPDATED_FOR = 'ESC';
  
-- open cursor to fetch modified records
 OPEN esc_eol_db_cur(last_update_time);
    LOOP
         FETCH esc_eol_db_cur INTO esc_eol_db_cur_rec;
         EXIT WHEN esc_eol_db_cur%NOTFOUND;
              
         OPEN spirt_cache_db_cur(esc_eol_db_cur_rec.pid, esc_eol_db_cur_rec.request_id);
         FETCH spirt_cache_db_cur INTO spirt_cache_db_cur_rec;
         
           -- update if record found, insert if not found
           if spirt_cache_db_cur%FOUND then
                  dbms_output.put_line('found: PID -> '|| esc_eol_db_cur_rec.pid || ' Request ID -> ' || esc_eol_db_cur_rec.request_id );
                  
                  -- set update and delete count      
                  IF spirt_cache_db_cur_rec.ACTIVE_FLAG = 'Y' AND esc_eol_db_cur_rec.ACTIVE_FLAG = 'N' THEN
                    delete_ct := delete_ct + 1;
                    v_adm_comment := 'Deleted by SPRIT script';
                  ELSE
                    update_ct := update_ct + 1;
                    v_adm_comment := 'Updated by SPRIT script';
                  END IF;                  
                  
                  -- update the sprit table with modified values
                  update esc_eol_pid_cache
                  set PID_DESCRIPTION = esc_eol_db_cur_rec.PID_DESCRIPTION,
                  ACTIVE_FLAG = esc_eol_db_cur_rec.ACTIVE_FLAG,
                  PB_FINAL_URL = esc_eol_db_cur_rec.PB_FINAL_URL,
                  PB_NUMBER = esc_eol_db_cur_rec.PB_NUMBER,
                  EO_SALES_DATE = esc_eol_db_cur_rec.EO_SALES_DATE,
                  EO_SW_AVAL_DATE = esc_eol_db_cur_rec.EO_SW_AVAL_DATE,
                  EO_SW_LICENSE_AVAL_DATE = esc_eol_db_cur_rec.EO_SW_LICENSE_AVAL_DATE,
                  EO_SW_MAINTENANCE_DATE = esc_eol_db_cur_rec.EO_SW_MAINTENANCE_DATE,
                  EO_SECURITY_VUL_SUPPORT_DATE = esc_eol_db_cur_rec.EO_SECURITY_VUL_SUPPORT_DATE,
                  EO_LAST_SUPPORT_DATE = esc_eol_db_cur_rec.EO_LAST_SUPPORT_DATE,
                  CREATE_TIMESTAMP = esc_eol_db_cur_rec.CREATE_TIMESTAMP,
                  CREATE_USER = esc_eol_db_cur_rec.CREATE_USER,
                  UPDATE_TIMESTAMP = esc_eol_db_cur_rec.UPDATE_TIMESTAMP,
                  UPDATE_USER = esc_eol_db_cur_rec.UPDATE_USER, 
                  ADM_TIMESTAMP = sysdate,
                  ADM_COMMENT = v_adm_comment                
                  where request_id = esc_eol_db_cur_rec.request_id and
                        pid = esc_eol_db_cur_rec.pid;
                   
                                   
           else
                dbms_output.put_line('not found: PID -> '|| esc_eol_db_cur_rec.pid || ' Request ID -> ' || esc_eol_db_cur_rec.request_id );

                insert into esc_eol_pid_cache values (
                 esc_eol_db_cur_rec.REQUEST_ID,
                 esc_eol_db_cur_rec.PID,
                 esc_eol_db_cur_rec.PID_DESCRIPTION,
                 esc_eol_db_cur_rec.ACTIVE_FLAG,
                 esc_eol_db_cur_rec.PB_FINAL_URL,
                 esc_eol_db_cur_rec.PB_NUMBER,
                 esc_eol_db_cur_rec.EO_SALES_DATE,
                 esc_eol_db_cur_rec.EO_SW_AVAL_DATE,
                 esc_eol_db_cur_rec.EO_SW_LICENSE_AVAL_DATE,
                 esc_eol_db_cur_rec.EO_SW_MAINTENANCE_DATE,
                 esc_eol_db_cur_rec.EO_SECURITY_VUL_SUPPORT_DATE,
                 esc_eol_db_cur_rec.EO_LAST_SUPPORT_DATE,
                 esc_eol_db_cur_rec.CREATE_TIMESTAMP,
                 esc_eol_db_cur_rec.CREATE_USER,
                 esc_eol_db_cur_rec.UPDATE_TIMESTAMP,
                 esc_eol_db_cur_rec.UPDATE_USER,
                 'SPRIT',
                 sysdate,
                 'V',
                 'Inserted by SPRIT script'    
                );
                
                new_ct := new_ct + 1;
           end if;
 
         CLOSE spirt_cache_db_cur;
         
         if esc_eol_db_cur_rec.ACTIVE_FLAG = 'N' then
         
            OPEN esc_eol_active_pid_cur(esc_eol_db_cur_rec.pid, last_update_time);
            FETCH esc_eol_active_pid_cur INTO esc_eol_active_pid_cur_rec;
            dbms_output.put_line('in N ' );

           -- update if record found, insert if not found
           if esc_eol_active_pid_cur%FOUND then
         
              dbms_output.put_line('found other reqid ' );
              select count(*) into ct
              from esc_eol_pid_cache where pid = esc_eol_active_pid_cur_rec.pid
              and request_id = esc_eol_active_pid_cur_rec.request_id;  
              
              if ct = 0 then
               dbms_output.put_line('insert:' );

               insert into esc_eol_pid_cache values (
                 esc_eol_active_pid_cur_rec.REQUEST_ID,
                 esc_eol_active_pid_cur_rec.PID,
                 esc_eol_active_pid_cur_rec.PID_DESCRIPTION,
                 esc_eol_active_pid_cur_rec.ACTIVE_FLAG,
                 esc_eol_active_pid_cur_rec.PB_FINAL_URL,
                 esc_eol_active_pid_cur_rec.PB_NUMBER,
                 esc_eol_active_pid_cur_rec.EO_SALES_DATE,
                 esc_eol_active_pid_cur_rec.EO_SW_AVAL_DATE,
                 esc_eol_active_pid_cur_rec.EO_SW_LICENSE_AVAL_DATE,
                 esc_eol_active_pid_cur_rec.EO_SW_MAINTENANCE_DATE,
                 esc_eol_active_pid_cur_rec.EO_SECURITY_VUL_SUPPORT_DATE,
                 esc_eol_active_pid_cur_rec.EO_LAST_SUPPORT_DATE,
                 esc_eol_active_pid_cur_rec.CREATE_TIMESTAMP,
                 esc_eol_active_pid_cur_rec.CREATE_USER,
                 esc_eol_active_pid_cur_rec.UPDATE_TIMESTAMP,
                 esc_eol_active_pid_cur_rec.UPDATE_USER,
                 'SPRIT',
                 sysdate,
                 'V',
                 'Inserted by SPRIT script'     
                );
                
                new_ct := new_ct + 1;
              else
                dbms_output.put_line('update:' ); 
                update esc_eol_pid_cache
                  set PID_DESCRIPTION = esc_eol_active_pid_cur_rec.PID_DESCRIPTION,
                  ACTIVE_FLAG = esc_eol_active_pid_cur_rec.ACTIVE_FLAG,
                  PB_FINAL_URL = esc_eol_active_pid_cur_rec.PB_FINAL_URL,
                  PB_NUMBER = esc_eol_active_pid_cur_rec.PB_NUMBER,
                  EO_SALES_DATE = esc_eol_active_pid_cur_rec.EO_SALES_DATE,
                  EO_SW_AVAL_DATE = esc_eol_active_pid_cur_rec.EO_SW_AVAL_DATE,
                  EO_SW_LICENSE_AVAL_DATE = esc_eol_active_pid_cur_rec.EO_SW_LICENSE_AVAL_DATE,
                  EO_SW_MAINTENANCE_DATE = esc_eol_active_pid_cur_rec.EO_SW_MAINTENANCE_DATE,
                  EO_SECURITY_VUL_SUPPORT_DATE = esc_eol_active_pid_cur_rec.EO_SECURITY_VUL_SUPPORT_DATE,
                  EO_LAST_SUPPORT_DATE = esc_eol_active_pid_cur_rec.EO_LAST_SUPPORT_DATE,
                  CREATE_TIMESTAMP = esc_eol_active_pid_cur_rec.CREATE_TIMESTAMP,
                  CREATE_USER = esc_eol_active_pid_cur_rec.CREATE_USER,
                  UPDATE_TIMESTAMP = esc_eol_active_pid_cur_rec.UPDATE_TIMESTAMP,
                  UPDATE_USER = esc_eol_active_pid_cur_rec.UPDATE_USER,
                  ADM_TIMESTAMP = sysdate,
                  ADM_COMMENT = 'Updated by SPRIT script'                       
                  where request_id = esc_eol_active_pid_cur_rec.request_id and
                        pid = esc_eol_active_pid_cur_rec.pid;
                        
                  update_ct := update_ct + 1;
              end if;     
           
           end if;
           
           CLOSE esc_eol_active_pid_cur;
         end if;
         --   dbms_output.put_line(v_org_rec.empno||' '||v_org_rec.ename);
    END LOOP;
 CLOSE esc_eol_db_cur;
 
 -- delete diff records from sprit
 open spirt_esc_diff_cur; 
 LOOP
         FETCH spirt_esc_diff_cur INTO spirt_esc_diff_cur_rec;
         EXIT WHEN spirt_esc_diff_cur%NOTFOUND;
         
         delete from esc_eol_pid_cache where pid = spirt_esc_diff_cur_rec.pid and request_id = spirt_esc_diff_cur_rec.request_id; 
         --dbms_output.put_line('found: PID -> '|| spirt_esc_diff_cur_rec.pid || ' Request ID -> ' || spirt_esc_diff_cur_rec.request_id );
 END LOOP;
 close spirt_esc_diff_cur;

 -- store delta- in log
  msg :=   'New records: '||to_char(new_ct)
         ||'-- Updated records: '||to_char(update_ct)
         ||'-- Deleted records: '||to_char(delete_ct);  
 
  select REFRESH_ID_SEQ.nextval into refresh_id_num from dual;
  
  insert into esc_eol_refresh_log     
  values (refresh_id_num,
          msg,
          'SPRIT',
          sysdate);
   
 commit;       
 -- update last update time
 update auto_refrsh_detail
 set LAST_UPDATED_TIME = sysdate,
     ADM_TIMESTAMP = sysdate,
     ADM_COMMENT = 'Updated by auto refresh script', 
     REFRESH_ID = refresh_id_num
 where LAST_UPDATED_FOR = 'ESC';
 dbms_output.put_line('refresh id:' ||refresh_id_num); 
       
  -- notify user about refresh        
   select count(*) into 
   sprit_side_ct from esc_eol_pid_cache;   
   
   select count(*) into 
   esc_side_ct from ESC_EOL_PID_SPRIT_V;
   
   v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
   notify_user(true,
               v_start_time,
               v_now,
               v_errmsg,
               esc_side_ct, 
               sprit_side_ct,
               delete_ct,
               update_ct,
               new_ct,
               refresh_id_num);     
               
  commit;                    
EXCEPTION
    WHEN OTHERS THEN
    rollback;
    v_errmsg := substr(SQLERRM, 1, 200);
    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss');
    
    select REFRESH_ID_SEQ.nextval into refresh_id_num from dual;
  
    insert into esc_eol_refresh_log     
    values (refresh_id_num,
          v_errmsg,
          'SPRIT',
          sysdate);
    commit;
          
    notify_user(false,
               v_start_time,
               v_now,
               v_errmsg,
               esc_side_ct, 
               sprit_side_ct,
               delete_ct,
               update_ct,
               new_ct,
               refresh_id_num);          
END main;


/*
||======================================================================
|| Send email notification.
||======================================================================
*/
PROCEDURE send_email (
        in_env                      in  varchar2,
        in_mail_to                  in  varchar2,
        in_mail_from_alias          in  varchar2,
        in_mail_from_email_addr     in  varchar2,
        in_mail_subject             in  varchar2,
        in_mail_text                in  varchar2,
        out_errmsg                  out varchar2 )
IS

    v_proc_name               varchar2(100) := g_pkg_name || '.send_email';
    c                         utl_tcp.connection;
    rc                        integer;
    v_now                     varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_mail_to_email_addr_tab  email_addr_tab_type;

  
BEGIN

    if( LOWER(in_env) = 'prod' ) then
     v_mail_to_email_addr_tab := email_addr_tab_type('sprit-cron-job-notification@cisco.com');
 else
     v_mail_to_email_addr_tab := email_addr_tab_type('sprit-cron-job-notification@cisco.com');
 end if;
 
 v_mail_to_email_addr_tab := email_addr_tab_type(in_mail_to||'@cisco.com');
  

    c := utl_tcp.open_connection('outbound.cisco.com', 25);             -- open the SMTP port 25 on local machine
    rc := utl_tcp.write_line(c, 'HELO malone.cisco.com');       -- PERFORMS HANDSHAKING WITH SMTP SERVER
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
        raise;
END send_email;
/*
||======================================================================
|| Notify the user of status of this process.
||======================================================================
*/
PROCEDURE notify_user (
     
        in_is_successful                in boolean,
        in_start_time                   in varchar2,
        in_end_time                     in varchar2,
        in_errmsg                       in varchar2,
        v_esc_eol_cnt                   in number,
        v_esc_eol_local_cnt             in number,
        delete_cnt                      in number,
        update_cnt                      in number,
        new_cnt                         in number,
        request_id                      in number        
         )
IS

    v_proc_name                 varchar2(100) := g_pkg_name || '.notify_user';
    v_now                       varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_mail_from_alias           varchar2(50) := '"SHR-ESC-PID-CACHE-Refresh-Mailer"';
    v_mail_from_email_addr      varchar2(50) := 'sprit-notification@cisco.com';
    v_mail_subject              varchar2(100);
    v_mail_body                 varchar2(30000);
    v_send_email_ret_errmsg     varchar2(1000);
    v_msg                       varchar2(2000);
    v_loginid                   varchar2(50);
    v_db                        varchar2(50);
    send_email_EXCP             exception;

BEGIN

    select user into v_loginid from dual;
    select global_name into v_db from global_name;
 
    v_mail_body := 'This is an automated email from ' || v_loginid || '@' || v_db || ' DBMS_JOB. '||g_newline||
                   'Please do not send response unless error occured... ' ||
                   g_newline;

    if( in_is_successful ) then
        v_mail_subject := 'ESC-EOL-CACHE Auto Fresh: Successfully Finished';
        v_mail_body    :=
                 v_mail_body || g_newline ||
                 '*** Process Successfully Finished ***' || g_newline;
                 
        v_mail_body :=
        v_mail_body || g_newline ||
        'Package Name: ' || g_pkg_name || g_newline ||
        'Start Time  : ' || in_start_time || g_newline ||
        'End Time    : ' || in_end_time || g_newline||
        'Total Record in SPRIT: ' || v_esc_eol_local_cnt || g_newline||
        'Total Record in ESC: ' || v_esc_eol_cnt || g_newline||
        'New Records: '  || new_cnt|| g_newline||
        'Updated Records: ' || update_cnt|| g_newline||
        'Deleted Records: ' || delete_cnt|| g_newline||
        'Refresh ID: '   || request_id;       
    else
        v_mail_subject := 'ESC-EOL-CACHE Auto Fresh: FAILED';
        v_mail_body    :=
                v_mail_body || g_newline || g_newline ||
                '*** Process failed ***' || g_newline ||
                'Error: ' || in_errmsg || g_newline ||g_newline ||
                'Detail error message is logged in esc_eol_refresh_log table, Please use refresh_id '
                 ||request_id || ' to view log'                
                 || g_newline ;
    end if;    
     
     send_email(
                g_env,
                'sprit-cron-job-notification', -- change this to 'in_submitted_by' variable.
                v_mail_from_alias,
                v_mail_from_email_addr,
                v_mail_subject,
                v_mail_body,
                v_send_email_ret_errmsg ); 

EXCEPTION
    
    when send_email_EXCP then
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := 'FAILED.'; 
        --log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;
    when OTHERS then
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := substr(sqlerrm, 1, 200);
        --log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;

END notify_user;

--------------------------------------------------------------------------------


END ESC_CACHE_REFRESH_PKG;
/
