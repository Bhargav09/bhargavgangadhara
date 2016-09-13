CREATE OR REPLACE PACKAGE BODY SHR_RDA.SHR_MDF_REFRESH_PKG AS

    g_pkg_name                  varchar2(100) := 'SHR_MDF_REFRESH_PKG';
    g_newline                   varchar2(2)   := CHR(13)||CHR(10);
    g_min_percent_to_refresh    number        := 90;
    -- g_env determines email notification recipient.
    -- Make sure the value is changed to 'prod' when put into production.
--	g_env						 varchar2(20) := 'prod';
	g_env						 varchar2(20) := 'dev';


    my_exception    exception;
    
/*
||======================================================================
|| Insert/Update/Delete-flag MDF tables.						
||======================================================================
*/
PROCEDURE main IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.main] ';
    v_start_time        varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_now               varchar2(100);
    v_e2e_err_msg       varchar2(200);
    v_msg               varchar2(1000);
    v_errmsg            varchar2(1000);
    e2e_exception       exception;
    
    v_primary_upd_cnt       number := 0;
    v_primary_new_cnt       number := 0;
    v_primary_del_cnt       number := 0;
    v_primary_del_tot_cnt   number := 0;
    v_primary_tot_cnt       number := 0;

    v_secondary_upd_cnt     number := 0;
    v_secondary_new_cnt     number := 0;
    v_secondary_del_cnt     number := 0;
    v_secondary_del_tot_cnt number := 0;
    v_secondary_tot_cnt     number := 0;
    
    v_primary_discrepancy_cnt   number := 0;
    v_secondary_discrepancy_cnt number := 0;
    
BEGIN

    log_mdf_refresh (v_proc_name, 'Started.');
    dbms_output.put_line ( g_newline || g_newline ||  v_proc_name || 'Started at ' || v_start_time );
    
    ---------------------------------------------------------
    -- e2e views are empty. Terminate.
    -- commits records to log file.
    ---------------------------------------------------------

    check_e2e( v_e2e_err_msg );
    if( v_e2e_err_msg is not null ) then
        commit;
        raise e2e_exception;
    end if;

    ---------------------------------------------------------
    -- e2e views are validated ... Continue.
    ---------------------------------------------------------

    upd_primary_mdf_modified( v_primary_upd_cnt );
    upd_primary_mdf_new( v_primary_new_cnt );
    upd_primary_mdf_deleted( v_primary_del_cnt );
    get_primary_mdf_tot_deleted( v_primary_del_tot_cnt );
    get_primary_mdf_tot( v_primary_tot_cnt );
    verify_refresh_primary_mdf( v_primary_discrepancy_cnt );
    
    upd_secondary_mdf_modified( v_secondary_upd_cnt );
    upd_secondary_mdf_new( v_secondary_new_cnt );
    upd_secondary_mdf_deleted( v_secondary_del_cnt );
    get_secondary_mdf_tot_deleted( v_secondary_del_tot_cnt );
    get_secondary_mdf_tot( v_secondary_tot_cnt );
    verify_refresh_secondary_mdf( v_secondary_discrepancy_cnt );

    commit;

    log_mdf_refresh (v_proc_name, 'Successfully finished.' );

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );

    notify_user( 
        v_primary_upd_cnt,
        v_primary_new_cnt,
        v_primary_del_cnt,
        v_primary_discrepancy_cnt,
        v_primary_del_tot_cnt,
        v_primary_tot_cnt,
        v_secondary_upd_cnt,
        v_secondary_new_cnt,
        v_secondary_del_cnt,
        v_secondary_discrepancy_cnt,
        v_secondary_del_tot_cnt,
        v_secondary_tot_cnt,
        true,
        v_start_time,
        v_now,
        v_errmsg );
        
    dbms_output.put_line( v_proc_name || 'Successfully finished at ' || v_now);
    
    
EXCEPTION
    when e2e_exception then

        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' ); 

        log_mdf_refresh (v_proc_name, 'Terminated. ' || v_e2e_err_msg );

        dbms_output.put_line(
            v_proc_name || 'ERROR==>' ||
            v_e2e_err_msg );
        dbms_output.put_line(
            v_proc_name || 'Terminated at ' || v_now );

       get_primary_mdf_tot( v_primary_tot_cnt );
       get_secondary_mdf_tot( v_secondary_tot_cnt );

        notify_user( 
            v_primary_upd_cnt,
            v_primary_new_cnt,
            v_primary_del_cnt,
            v_primary_discrepancy_cnt,
            v_primary_del_tot_cnt,
            v_primary_tot_cnt,
            v_secondary_upd_cnt,
            v_secondary_new_cnt,
            v_secondary_del_cnt,
            v_secondary_discrepancy_cnt,
            v_secondary_del_tot_cnt,
            v_secondary_tot_cnt,
            false,
            v_start_time,
            v_now,
            v_e2e_err_msg );

    when others then
        rollback;

        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' ); 
        v_msg := substr(sqlerrm,1,200);
        log_mdf_refresh (v_proc_name, 'Terminated. ' || v_msg );

        dbms_output.put_line (v_proc_name || 'ERROR==>' || v_msg );
        dbms_output.put_line (v_proc_name || 'Terminated at ' || v_now);

        notify_user( 
            v_primary_upd_cnt,
            v_primary_new_cnt,
            v_primary_del_cnt,
            v_primary_discrepancy_cnt,
            v_primary_del_tot_cnt,
            v_primary_tot_cnt,
            v_secondary_upd_cnt,
            v_secondary_new_cnt,
            v_secondary_del_cnt,
            v_secondary_discrepancy_cnt,
            v_secondary_del_tot_cnt,
            v_secondary_tot_cnt,
            false,
            v_start_time,
            v_now,
            v_msg );

END main;

/*
||======================================================================
|| - Check e2e views before MDF data refresh begins.
||
|| - In rare failure of e2e, their views are without data. 
||======================================================================
*/
PROCEDURE check_e2e( out_err_msg   out varchar2 )
IS

    v_proc_name             varchar2(200) := '[' || g_pkg_name || '.check_e2e] ';
	v_cnt_primary_srda      number := 0;
	v_cnt_secondary_srda    number := 0;
	v_cnt_primary_e2e       number := 0;
	v_cnt_secondary_e2e     number := 0;
    e2e_exception           exception;
	
BEGIN

    ---------------------------------------------------------
    -- Validate vw_products_attr.
    ---------------------------------------------------------
    select
        count(*)
    into 
        v_cnt_primary_srda
    from
        shr_mdf_products_attr
    where
        adm_flag = 'V';

    select
        count(*)
    into 
        v_cnt_primary_e2e
    from
        vw_products_attr@authcprd;
    
    if( v_cnt_primary_e2e < 1 )then
        out_err_msg := 'VW_PRODUCTS_ATTR is empty.';
        raise e2e_exception;
    end if;

    if( v_cnt_primary_e2e/v_cnt_primary_srda * 100 < g_min_percent_to_refresh )then
        out_err_msg := 'VW_PRODUCTS_ATTR@e2e: ''' ||v_cnt_primary_e2e ||
            ''' records did not meet the expected minimum ' || g_min_percent_to_refresh || '% of' ||
            ' SHR_MDF_PRODUCTS_ATTR ''' || v_cnt_primary_srda || ''' records. ' ||
            ' Refresh cancelled.';
        raise e2e_exception;
    end if;

    ---------------------------------------------------------
    -- Validate vw_secondary_parent_rels.
    ---------------------------------------------------------
    select
        count(*)
    into 
        v_cnt_secondary_srda
    from
        shr_mdf_secondary_parent_rels
    where
        adm_flag = 'V';

    select
        count(*)
    into 
        v_cnt_secondary_e2e
    from
        vw_secondary_parent_rels@authcprd;
    
    if( v_cnt_secondary_e2e < 1 ) then
        out_err_msg := 'VW_SECONDARY_PARENT_RELS is empty.';
        raise e2e_exception;
    end if;
    
    if( v_cnt_secondary_e2e/v_cnt_secondary_srda * 100 < g_min_percent_to_refresh )then
        out_err_msg := 'VW_SECONDARY_PARENT_RELS@e2e: ' ||v_cnt_secondary_e2e ||
            ' records is less than ' || g_min_percent_to_refresh || '% of ' ||
            ' SHR_MDF_SECONDARY_PARENT_RELS ' || v_cnt_secondary_srda || ' records. ' ||
            ' Refresh cancelled.';
        raise e2e_exception;
    end if;

    out_err_msg := null;

    return;
    

EXCEPTION
    when e2e_exception then
        rollback;
        log_mdf_refresh( v_proc_name, 'Terminated. ' || out_err_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || out_err_msg );
        return;
    when OTHERS then
        rollback;
        log_mdf_refresh( v_proc_name, 'Terminated. ' ||  out_err_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || out_err_msg );
        return;

END check_e2e;

/*
||--======================================================================
|| - Update primary mdf table if record has been changed.
|| - We are not depending on last_modifed_date.	
||======================================================================
*/
PROCEDURE upd_primary_mdf_modified( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.upd_primary_mdf_modified] ';
    v_mdf_id            number;
    v_mdf_name          shr_mdf_products_attr.mdf_concept_name%type;
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
    cursor modified_mdf_cur is
        select
            s.mdf_concept_id            s_mdf_id,
            s.mdf_concept_name          s_mdf_name,
            s.mdf_parent_concept_id     s_pid,
            s.mdf_parent_concept_name   s_pname,
            s.lifecycle                 s_lifecycle,
            s.internal_launch_date      s_internal_launch_date,
            s.external_launch_date      s_external_launch_date,
            s.eol_date                  s_eol_date,
            s.last_date_of_support      s_last_date_of_support,
            s.obsolete_date             s_obsolete_date,
            s.metaclass                 s_metaclass,
            s.last_modified_date        s_last_modified_date,
            a.mdf_concept_id            a_mdf_id,
            a.mdf_concept_name          a_mdf_name,
            a.mdf_parent_concept_id     a_pid,
            a.mdf_parent_concept_name   a_pname,
            a.lifecycle                 a_lifecycle,
            a.internal_launch_date      a_internal_launch_date,
            a.external_launch_date      a_external_launch_date,
            a.eol_date                  a_eol_date,
            a.last_date_of_support      a_last_date_of_support,
            a.obsolete_date             a_obsolete_date,
            a.metaclass                 a_metaclass,
            a.last_modified_date        a_last_modified_date
        from
            shr_mdf_products_attr       s,
            vw_products_attr@AUTHCPRD   a
        where
            s.mdf_concept_id = a.mdf_concept_id
            and s.adm_flag = 'V' ;
--            and trunc(a.last_modified_date) > trunc(sysdate) - 10;
    
	
BEGIN

    out_cnt := 0;

    for c in modified_mdf_cur loop

        if( c.s_mdf_name <> c.a_mdf_name
            or c.s_pid <> c.a_pid
            or c.s_pname <> c.a_pname
            or c.s_lifecycle <> c.a_lifecycle
            or c.s_internal_launch_date <> c.a_internal_launch_date
            or c.s_external_launch_date <> c.a_external_launch_date
            or c.s_eol_date <> c.a_eol_date
            or c.s_last_date_of_support <> c.a_last_date_of_support
            or c.s_obsolete_date <> c.a_obsolete_date
            or c.s_metaclass <> c.a_metaclass
            or c.s_last_modified_date <> c.a_last_modified_date 
          )
        then
            out_cnt     := out_cnt + 1;
            v_mdf_id    := c.a_mdf_id;
            v_mdf_name  := c.a_mdf_name;

            update
                shr_mdf_products_attr
            set
                mdf_concept_name = c.a_mdf_name,
                mdf_parent_concept_id = c.a_pid,
                mdf_parent_concept_name = c.a_pname,
                lifecycle = c.a_lifecycle,
                internal_launch_date = c.a_internal_launch_date,
                external_launch_date = c.a_external_launch_date,
                eol_date = c.a_eol_date,
                last_date_of_support = c.a_last_date_of_support,
                obsolete_date = c.a_obsolete_date,
                metaclass = c.a_metaclass,
                last_modified_date = c.a_last_modified_date,
                adm_timestamp = sysdate,
                adm_flag = 'V',
                adm_comment = 'UPDATED FROM VW_PRODUCTS_ATTR'
            where
                mdf_concept_id = v_mdf_id;
        end if;
                  
    end loop;
    commit;

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_msg := 'MDF primary parent. Modified: ' || out_cnt || ' records. ';
    
    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line ( v_proc_name || v_msg || v_now);
    
EXCEPTION
    when OTHERS then
        rollback;
        v_msg := 
            'cnt=' || out_cnt ||
            ', mdf_id=' || v_mdf_id ||
            ', mdf_name=' || v_mdf_name ||
            '==>'|| substr(sqlerrm, 1,200);
            
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
            
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg );
        dbms_output.put_line( v_proc_name || 'Terminated at ' || v_now );
        raise;

END upd_primary_mdf_modified;

/*
||======================================================================
|| - Create new primary mdf concept. 
||======================================================================
*/
PROCEDURE upd_primary_mdf_new( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.upd_primary_mdf_new] ';
    v_mdf_id            number;
    v_mdf_name          shr_mdf_products_attr.mdf_concept_name%type;
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
    cursor new_mdf_cur is
        select
            a.*
        from
            shr_mdf_products_attr       s,
            vw_products_attr@AUTHCPRD   a
        where
            a.mdf_concept_id = s.mdf_concept_id(+)
            and s.mdf_concept_id is null;
    
    cursor revived_mdf_cur is
        select
            a.*
        from
            shr_mdf_products_attr       s,
            vw_products_attr@AUTHCPRD   a
        where
            a.mdf_concept_id = s.mdf_concept_id
            and s.adm_flag = 'D' ;
	
BEGIN

    out_cnt := 0;

    ------------------------------------------------------
    -- NDF not in sRDA at all.
    ------------------------------------------------------
    for c in new_mdf_cur loop

        out_cnt       := out_cnt + 1;
        v_mdf_id    := c.mdf_concept_id;
        v_mdf_name  := c.mdf_concept_name;
        
        insert into shr_mdf_products_attr values (
            c.mdf_concept_id,
            c.mdf_concept_name,
            c.mdf_parent_concept_id,
            c.mdf_parent_concept_name,
            c.lifecycle,
            c.internal_launch_date,
            c.external_launch_date,
            c.eol_date,
            c.last_date_of_support,
            c.obsolete_date,
            c.metaclass,
            c.last_modified_date,
            sysdate,
            sysdate,
            'V',
            'CREATED FROM VW_PRODUCTS_ATTR'  ) ;
                

    end loop;
    commit;

    ------------------------------------------------------
    -- In sRDA. Previously deleted, and not revived again.
    ------------------------------------------------------
    for c in revived_mdf_cur loop

        out_cnt     := out_cnt + 1;
        v_mdf_id    := c.mdf_concept_id;
        v_mdf_name  := c.mdf_concept_name;
        
        update
            shr_mdf_products_attr
        set
            mdf_concept_name = c.mdf_concept_name,
            mdf_parent_concept_id = c.mdf_parent_concept_id,
            mdf_parent_concept_name = c.mdf_parent_concept_name,
            lifecycle = c.lifecycle,
            internal_launch_date = c.internal_launch_date,
            external_launch_date = c.external_launch_date,
            eol_date = c.eol_date,
            last_date_of_support = c.last_date_of_support,
            obsolete_date = c.obsolete_date,
            metaclass = c.metaclass,
            last_modified_date = c.last_modified_date,
            adm_timestamp = sysdate,
            adm_flag = 'V',
            adm_comment = 'REVIVED FROM VW_PRODUCTS_ATTR'
        where
            mdf_concept_id = v_mdf_id;
            
    end loop;
    commit;
    
    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF primary parent. New/Revived: ' || out_cnt || ' records.';

    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line ( v_proc_name || v_msg || v_now);

    
EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := 
            'cnt=' || out_cnt ||
            ', mdf_id=' || v_mdf_id ||
            ', mdf_name=' || v_mdf_name ||
            '==>'|| substr(sqlerrm, 1,200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;        

END upd_primary_mdf_new;

/*
||======================================================================
|| - Flag deleted mdf concept. 
||======================================================================
*/
PROCEDURE upd_primary_mdf_deleted( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.upd_primary_mdf_deleted] ';
    v_mdf_id            number;
    v_mdf_name          shr_mdf_products_attr.mdf_concept_name%type;
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
    cursor del_mdf_cur is
        select
            s.*
        from
            shr_mdf_products_attr       s,
            vw_products_attr@AUTHCPRD   a
        where
            s.mdf_concept_id = a.mdf_concept_id(+)
            and a.mdf_concept_id is null ;
   
	
BEGIN

    out_cnt := 0;

    for c in del_mdf_cur loop

        out_cnt     := out_cnt + 1;
        v_mdf_id    := c.mdf_concept_id;
        v_mdf_name  := c.mdf_concept_name;
        
        update
            shr_mdf_products_attr
        set
            adm_timestamp = sysdate,
            adm_flag = 'D',
            adm_comment = 'DELETED FROM VW_PRODUCTS_ATTR'
        where 
            mdf_concept_id = v_mdf_id;

    end loop;
    commit;

    
    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF primary parent. Deleted: ' || out_cnt || ' records. ';
    
    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || v_msg || v_now );

EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := 
            'cnt=' || out_cnt ||
            ', mdf_id=' || v_mdf_id ||
            ', mdf_name=' || v_mdf_name ||
            '==>'|| substr(sqlerrm, 1,200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg  || v_now);
        raise;
        
END upd_primary_mdf_deleted;

/*
||======================================================================
|| - Get total count of deleted primary MDF parents from the DB.
||======================================================================
*/
PROCEDURE get_primary_mdf_tot_deleted( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_primary_mdf_tot_deleted] ';
    v_now               varchar2(100);
    v_msg               varchar2(1000);
	
BEGIN

    out_cnt := 0;
    
    select
        count(*)
    into
        out_cnt
    from
        shr_mdf_products_attr
    where
        adm_flag = 'D' ;

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF primary parents. Total deleted from DB: ' || out_cnt || ' records. ';
    
    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || v_msg || v_now );

EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := substr(sqlerrm, 1,200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg  || v_now);
        raise;
        
END get_primary_mdf_tot_deleted;

/*
||======================================================================
|| - Get total count of primary MDF parents from the DB.
||======================================================================
*/
PROCEDURE get_primary_mdf_tot( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_primary_mdf_tot] ';
    v_now               varchar2(100);
    v_msg               varchar2(1000);
	
BEGIN

    out_cnt := 0;
    
    select
        count(*)
    into
        out_cnt
    from
        shr_mdf_products_attr
    where
        adm_flag = 'V' ;

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF primary parents. Total count: ' || out_cnt || ' records. ';
    
    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || v_msg || v_now );

EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := substr(sqlerrm, 1,200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg  || v_now);
        raise;
        
END get_primary_mdf_tot;


/*
||======================================================================
|| - Update second mdf table if record has been changed,
|| - We don't depend on last_modified_date.
||======================================================================
*/
PROCEDURE upd_secondary_mdf_modified( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.upd_secondary_mdf_modified] ';
    v_mdf_id            number;
    v_mdf_name          shr_mdf_secondary_parent_rels.mdf_concept_name%type;
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
    -- We don't depend on last_modified_date.
    cursor modified_mdf_cur is
        select
            s.mdf_concept_id           s_mid,
            s.mdf_concept_name         s_mname,
            s.secondary_parent_id      s_pid,
            s.secondary_parent_name    s_pname,
            s.last_modified_date       s_last_modified_date,
            a.mdf_concept_id           a_mid,
            a.mdf_concept_name         a_mname,
            a.secondary_parent_id      a_pid,
            a.secondary_parent_name    a_pname,
            a.last_modified_date       a_last_modified_date
        from
            shr_mdf_secondary_parent_rels       s,
            vw_secondary_parent_rels@AUTHCPRD   a
        where
            s.mdf_concept_id = a.mdf_concept_id
            and s.secondary_parent_id = a.secondary_parent_id
            and ( s.mdf_concept_name <> a.mdf_concept_name
                  or s.secondary_parent_name <> a.secondary_parent_name
                  or s.last_modified_date <> a.last_modified_date 
                );
	
BEGIN

    out_cnt := 0;

    for c in modified_mdf_cur loop
       
        out_cnt     := out_cnt + 1;
        v_mdf_id    := c.s_mid;
        v_mdf_name  := c.s_mname;

        update
            shr_mdf_secondary_parent_rels
        set
            mdf_concept_name = c.a_mname,
            secondary_parent_name = c.a_pname,
            last_modified_date = c.a_last_modified_date,
            adm_timestamp = sysdate,
            adm_flag = 'V',
            adm_comment = 'UPDATED FROM VW_SECONDARY_PARENT_RELS'
        where
            mdf_concept_id = c.s_mid
            and secondary_parent_id = c.s_pid;
            
    end loop;
    commit;

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF secondary parent. Modified: ' || out_cnt || ' records.';
    
    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || v_msg );

EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := 
            'cnt=' || out_cnt ||
            ', mdf_id=' || v_mdf_id ||
            ', mdf_name=' || v_mdf_name ||
            '==>'|| substr(sqlerrm, 1,200);
    
        log_mdf_refresh (v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;
        
END upd_secondary_mdf_modified;

/*
||======================================================================
|| - Create new secondary mdf parents. 
||======================================================================
*/
PROCEDURE upd_secondary_mdf_new( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.upd_secondary_mdf_new] ';
    v_mdf_id            number;
    v_mdf_name          shr_mdf_products_attr.mdf_concept_name%type;
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
    cursor new_mdf_cur is
        select
            a.*
        from
            shr_mdf_secondary_parent_rels       s,
            vw_secondary_parent_rels@AUTHCPRD   a
        where
            a.mdf_concept_id = s.mdf_concept_id(+)
            and a.secondary_parent_id = s.secondary_parent_id(+)
            and s.mdf_concept_id is null
            and s.secondary_parent_id is null;
	
    cursor revived_mdf_cur is
        select
            a.*
        from
            shr_mdf_secondary_parent_rels       s,
            vw_secondary_parent_rels@AUTHCPRD   a
        where
            a.mdf_concept_id = s.mdf_concept_id
            and a.secondary_parent_id = s.secondary_parent_id
            and s.adm_flag = 'D' ;

BEGIN

    out_cnt := 0;

    for c in new_mdf_cur loop

        out_cnt     := out_cnt + 1;
        v_mdf_id    := c.mdf_concept_id;
        v_mdf_name  := c.mdf_concept_name;
        
        insert into shr_mdf_secondary_parent_rels values (
            c.mdf_concept_id,
            c.mdf_concept_name,
            c.secondary_parent_id,
            c.secondary_parent_name,
            c.last_modified_date,
            sysdate,
            sysdate,
            'V',
            'CREATED FROM VW_SECONDARY_PARENT_RELS' ) ;
                
    end loop;
    commit;

    for c in revived_mdf_cur loop

        out_cnt     := out_cnt + 1;
        v_mdf_id    := c.mdf_concept_id;
        v_mdf_name  := c.mdf_concept_name;
        
        update
            shr_mdf_secondary_parent_rels
        set
            mdf_concept_name = c.mdf_concept_name,
            secondary_parent_name = c.secondary_parent_name,
            last_modified_date = c.last_modified_date,
            adm_timestamp = sysdate,
            adm_flag = 'V',
            adm_comment = 'REVIVED FROM VW_SECONDARY_PARENT_RELS'
        where
            mdf_concept_id = c.mdf_concept_id
            and secondary_parent_id = c.secondary_parent_id;
            
    end loop;
    commit;


    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_msg := 'MDF secondary parent. New/Revived: ' || out_cnt || ' records. ';

    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || v_msg || v_now );
    
EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
        v_msg :=
            'cnt=' || out_cnt ||
            ', mdf_id=' || v_mdf_id ||
            ', mdf_name=' || v_mdf_name ||
            '==>'|| substr(sqlerrm, 1,200);
        
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;
        
END upd_secondary_mdf_new;

/*
||======================================================================
|| - Update deleted flag for deleted mdf secondary parents. 
||======================================================================
*/
PROCEDURE upd_secondary_mdf_deleted( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.upd_secondary_mdf_deleted] ';
    v_mdf_id            number;
    v_sid               number;
    v_mdf_name          shr_mdf_products_attr.mdf_concept_name%type;
    v_now               varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_msg               varchar2(1000);
    
    cursor del_mdf_cur is
        select
            s.*
        from
            shr_mdf_secondary_parent_rels       s,
            vw_secondary_parent_rels@AUTHCPRD   a
        where
            s.mdf_concept_id = a.mdf_concept_id(+)
            and s.secondary_parent_id = a.secondary_parent_id(+)
            and a.mdf_concept_id is null
            and a.secondary_parent_id is null; 
	
BEGIN

    out_cnt := 0;

    for c in del_mdf_cur loop

        out_cnt     := out_cnt + 1;
        v_mdf_id    := c.mdf_concept_id;
        v_sid       := c.secondary_parent_id;
        v_mdf_name  := c.mdf_concept_name;
        
        update
            shr_mdf_secondary_parent_rels
        set
            adm_timestamp = sysdate,
            adm_flag = 'D',
            adm_comment = 'DELETED FROM VW_SECONDARY_PARENT_RELS'
        where 
            mdf_concept_id = c.mdf_concept_id
            and secondary_parent_id = c.secondary_parent_id;

    end loop;
    commit;

    
    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF secondary parent. Deleted: ' || out_cnt || ' records. ';

    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || v_msg || v_now );

EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := 
            'cnt=' || out_cnt ||
            ', mdf_id=' || v_mdf_id ||
            ', mdf_name=' || v_mdf_name ||
            '==>'|| substr(sqlerrm, 1,200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;
                
END upd_secondary_mdf_deleted;

/*
||======================================================================
|| - Get total count of deleted secondary MDF parents from the DB.
||======================================================================
*/
PROCEDURE get_secondary_mdf_tot_deleted( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_secondary_mdf_tot_deleted] ';
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
BEGIN

    out_cnt := 0;
    
    select
        count(*)
    into
        out_cnt
    from
        shr_mdf_secondary_parent_rels
    where
        adm_flag = 'D' ;

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF secondary parents. Deleted from DB: ' || out_cnt || ' records. ';
    
    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || v_msg || v_now );

EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := substr(sqlerrm, 1,200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg  || v_now);
        raise;
        
END get_secondary_mdf_tot_deleted;

/*
||======================================================================
|| - Get total count of secondary MDF parents from the DB.
||======================================================================
*/
PROCEDURE get_secondary_mdf_tot( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.get_secondary_mdf_tot] ';
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
BEGIN

    out_cnt := 0;
    
    select
        count(*)
    into
        out_cnt
    from
        shr_mdf_secondary_parent_rels
    where
        adm_flag = 'V' ;

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF secondary parents. Total count: ' || out_cnt || ' records. ';
    
    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || v_msg || v_now );

EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := substr(sqlerrm, 1,200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg  || v_now);
        raise;
        
END get_secondary_mdf_tot;


/*
||======================================================================
|| - Verify MDF refresh for primary mdf parent by comparing 
||   SHR_MDF_PRODUCGS_ATTR to VW_PRODUCTS_ATTR. 
||======================================================================
*/
PROCEDURE verify_refresh_primary_mdf( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.verify_refresh_primary_mdf] ';
    v_mdf_id            number;
    v_mdf_name          shr_mdf_products_attr.mdf_concept_name%type;
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
    cursor descrepant_mdf is
        select   -- Record match, but info not-match
            s.*
        from
            shr_mdf_products_attr       s,
            vw_products_attr@AUTHCPRD   a
        where
            s.mdf_concept_id = a.mdf_concept_id
            and ( s.mdf_concept_name <> a.mdf_concept_name 
                  or s.mdf_parent_concept_id <> a.mdf_parent_concept_id
                  or s.mdf_parent_concept_name <> a.mdf_parent_concept_name
                  or s.lifecycle <> a.lifecycle
                  or s.internal_launch_date <> a.internal_launch_date
                  or s.external_launch_date <> a.external_launch_date
                  or s.eol_date <> a.eol_date
                  or s.last_date_of_support <> a.last_date_of_support
                  or s.obsolete_date <> a.obsolete_date
                  or s.metaclass <> a.metaclass
                  or s.last_modified_date <> a.last_modified_date
                )
            and s.adm_flag = 'V' 
        UNION
        select   -- record in both sRDA and e2e, but sRDA marked delete
            s.*
        from
            shr_mdf_products_attr       s,
            vw_products_attr@AUTHCPRD   a
        where
            a.mdf_concept_id = s.mdf_concept_id
            and s.adm_flag = 'D'
        UNION
        select   -- extra record in sRDA
            s.*
        from
            shr_mdf_products_attr       s,
            vw_products_attr@AUTHCPRD   a
        where
            s.adm_flag = 'V'
            and s.mdf_concept_id = a.mdf_concept_id(+)
            and a.mdf_concept_id is null
        UNION
        select   -- extra record in e2e, not in sRDA
            s.*
        from
            shr_mdf_products_attr       s,
            vw_products_attr@AUTHCPRD   a
        where
            a.mdf_concept_id = s.mdf_concept_id(+)
            and a.mdf_concept_id is null ;

BEGIN

    out_cnt := 0;

    for c in descrepant_mdf loop

        BEGIN
            out_cnt       := out_cnt + 1;
            v_mdf_id    := c.mdf_concept_id;
            v_mdf_name  := c.mdf_concept_name;
            
            v_msg := 
                'cnt=' || out_cnt ||
                '. Discrepancy in primary mdf==>' ||
                c.mdf_concept_id || ', ' || c.mdf_concept_name;
                
            log_mdf_refresh ( v_proc_name, v_msg );
                
        EXCEPTION
            when others then
                rollback;
                v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
                v_msg := 
                    'cnt=' || out_cnt ||
                    ', mdf_id=' || v_mdf_id ||
                    ', mdf_name=' || v_mdf_name ||
                    '==>'|| substr(sqlerrm, 1,200);

                log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
                dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
                raise;
        END;
    end loop;

    
    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF primary parent. Discrepancy: ' || out_cnt ||' records. '; 
 
    log_mdf_refresh( v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || 'For detail discrepancy, see shr_mdf_refresh_log table.');
    dbms_output.put_line( v_proc_name || v_msg || v_now );

EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := 
            'cnt=' || out_cnt ||
            ', mdf_id=' || v_mdf_id ||
            ', mdf_name=' || v_mdf_name ||
            '==>'|| substr(sqlerrm, 1,200);

        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg  || v_now );
        raise;
        
END verify_refresh_primary_mdf;

/*
||======================================================================
|| - Verify MDF refresh for secondary mdf parents by comparing 
||   SHR_MDF_SECONDARY_PARENT_RELS to VW_SECONDARY_PARENT_RELS. 
||======================================================================
*/
PROCEDURE verify_refresh_secondary_mdf( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.verify_refresh_secondary_mdf] ';
    v_mdf_id            shr_mdf_secondary_parent_rels.mdf_concept_id%type;
    v_mdf_name          shr_mdf_secondary_parent_rels.mdf_concept_name%type;
    v_pid               shr_mdf_secondary_parent_rels.secondary_parent_id%type;
    v_pname             shr_mdf_secondary_parent_rels.secondary_parent_name%type;
    v_now               varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_msg               varchar2(1000);
    
    cursor descrepant_mdf is
        select
            s.*
        from
            shr_mdf_secondary_parent_rels       s,
            vw_secondary_parent_rels@AUTHCPRD   a
        where
            s.mdf_concept_id = a.mdf_concept_id
            and s.secondary_parent_id = a.secondary_parent_id
            and ( s.mdf_concept_name <> a.mdf_concept_name 
                  or s.secondary_parent_id <> a.secondary_parent_id
                  or s.secondary_parent_name <> a.secondary_parent_name
                  or s.last_modified_date <> a.last_modified_date 
                )
            and s.adm_flag = 'V'
        UNION
        select   -- record in both sRDA and e2e, but sRDA marked delete
            s.*
        from
            shr_mdf_secondary_parent_rels       s,
            vw_secondary_parent_rels@AUTHCPRD   a
        where
            a.mdf_concept_id = s.mdf_concept_id
            and a.secondary_parent_id = s.secondary_parent_id
            and s.adm_flag = 'D'
        UNION
        select   -- extra record in sRDA
            s.*
        from
            shr_mdf_secondary_parent_rels       s,
            vw_secondary_parent_rels@AUTHCPRD   a
        where
            s.adm_flag = 'V'
            and s.mdf_concept_id = a.mdf_concept_id(+)
            and s.secondary_parent_id = a.secondary_parent_id(+)
            and a.mdf_concept_id is null 
        UNION
        select   -- extra record in e2e, not in sRDA
            s.*
        from
            shr_mdf_secondary_parent_rels       s,
            vw_secondary_parent_rels@AUTHCPRD   a
        where
            a.mdf_concept_id = s.mdf_concept_id(+)
            and a.secondary_parent_id = s.secondary_parent_id(+)
            and s.mdf_concept_id is null ;

BEGIN

    out_cnt := 0;

    for c in descrepant_mdf loop

        BEGIN
            out_cnt       := out_cnt + 1;
            v_mdf_id    := c.mdf_concept_id;
            v_mdf_name  := c.mdf_concept_name;
            v_pid       := c.secondary_parent_id;
            v_pname     := c.secondary_parent_name;
            
            v_msg := 
                'cnt='|| out_cnt ||
                '. Discrepancy in secondary mdf==>' ||
                'mdf_concept_id=' || v_mdf_id ||
                ', mdf_name=' || v_mdf_name ||
                ', srda_2nd_parent_id=' || v_pid ||
                ', srda_2nd_parent_name=' || v_pname;

            log_mdf_refresh ( v_proc_name, v_msg );
                            
        EXCEPTION
            when others then
                rollback;
                v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
                v_msg := 
                    'cnt=' || out_cnt ||
                    ', mdf_id=' || v_mdf_id ||
                    ', mdf_name=' || v_mdf_name ||
                    ', srda_2nd_parent_id=' || v_pid ||
                    ', srda_2nd_parent_name=' || v_pname ||
                    '==>'|| substr(sqlerrm, 1,200);

                log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
                dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg  || v_now );
                raise;
        END;
    end loop;

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF Secondary parent. Discrepancy: ' || out_cnt || ' records. '; 
 
    log_mdf_refresh( v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || 'For detail discrepancy, see shr_mdf_refresh_log table.');
    dbms_output.put_line( v_proc_name || v_msg || v_now );
    
EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := 
            'cnt=' || out_cnt ||
            ', mdf_id=' || v_mdf_id ||
            ', mdf_name=' || v_mdf_name ||
            ', srda_2nd_parent_id=' || v_pid ||
            ', srda_2nd_parent_name=' || v_pname ||
            '==>'|| substr(sqlerrm, 1,200);

        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;
        
END verify_refresh_secondary_mdf;

/*
||======================================================================
|| Create record in shr_mdf_refresh_log table.
||======================================================================
*/
PROCEDURE log_mdf_refresh ( 
            in_proc_name    varchar2,
            in_msg          varchar2 ) 
IS
    v_proc_name     varchar2(200) := '[' || g_pkg_name || '.log_mdf_refresh] ';

BEGIN
    
    insert into shr_mdf_refresh_log values (
        in_proc_name, 
        in_msg,
        sysdate );
        
    commit;
    
EXCEPTION
    when others then
        rollback;
        dbms_output.put_line ( v_proc_name || 'ERROR==>' ||
            substr(sqlerrm, 1,200) );
        raise;
        
END log_mdf_refresh;

/*
||======================================================================
|| Clean up shr_mdf_refresh_log table.
|| delete all records older than 5 days.
||======================================================================
*/

PROCEDURE cleanup_log_table IS  
    v_proc_name     varchar2(200) := '[' || g_pkg_name || '.cleanup_log_table] ';

BEGIN
    
    delete 
        shr_mdf_refresh_log
    where
        trunc(adm_timestamp) < trunc(sysdate) - 5;
        
    commit;
    

EXCEPTION
    when others then
        rollback;
        dbms_output.put_line ( v_proc_name || 'ERROR==>' ||
            substr(sqlerrm, 1,200) );
        raise;
        
END cleanup_log_table;


/*
||======================================================================
|| Notify the user of status of this process.
||======================================================================
*/
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
        in_errmsg                       in varchar2 )
IS

    v_proc_name                 varchar2(100) := g_pkg_name || '.notify_user';

    v_now                       varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
	v_mail_from_alias	        varchar2(50) := '"SHR-MDF-Refresh-Mailer"';
	v_mail_from_email_addr      varchar2(50) := 'nadialee@cisco.com';
	
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
        v_mail_subject := 'sRDA-MDF Auto Fresh: Successfully Finished';
        v_mail_body    :=
                 v_mail_body || g_newline ||
                 '*** Process Successfully Finished ***' || g_newline;
    else
        v_mail_subject := 'sRDA-MDF Auto Fresh: FAILED';
        v_mail_body    :=
                v_mail_body || g_newline || g_newline ||
                '*** Process failed ***' || g_newline ||
                'Error: ' || g_newline ||
                in_errmsg || g_newline || g_newline ||
                'At the time of process termiantion, the following information was collected:'|| g_newline;
    end if;

    v_mail_body :=
        v_mail_body || g_newline ||
        'Package Name: ' || g_pkg_name || g_newline ||
        'Start Time  : ' || in_start_time || g_newline ||
        'End Time    : ' || in_end_time || g_newline ||
         g_newline ||
        'Primary MDF Parent table: ' || g_newline ||
        '------------------------' || g_newline ||
        'Updated Records              : ' || in_primary_mdf_upd_cnt || g_newline ||
        'New Records                  : ' || in_primary_mdf_new_cnt || g_newline ||
        'Deleted Records              : ' || in_primary_mdf_del_cnt || g_newline ||
        'Discrepant Records           : ' || in_primary_discrepancy_cnt || g_newline ||
        'Total Deleted Records from DB: ' || in_primary_tot_del_cnt || g_newline ||
        'Total Records from DB        : ' || in_primary_tot_cnt || g_newline ||
        g_newline || 
        'Secondary MDF Parent table: ' || g_newline ||
        '--------------------------' || g_newline ||
        'Updated Records              : ' || in_secondary_mdf_upd_cnt || g_newline ||
        'New Records                  : ' || in_secondary_mdf_new_cnt || g_newline ||
        'Deleted Records              : ' || in_secondary_mdf_del_cnt || g_newline ||
        'Discrepant Records           : ' || in_secondary_discrepancy_cnt || g_newline ||
        'Total Deleted Records from DB: ' || in_secondary_tot_del_cnt || g_newline ||
        'Total Records from DB        : ' || in_secondary_tot_cnt || g_newline ||
        g_newline ||
        'For more detail information or error, please look at SHR_MDF_REFRESH_LOG table.' ||
        g_newline;
	
        send_email(
	           g_env,
	           v_mail_from_alias,
			   v_mail_from_email_addr,
               v_mail_subject,
               v_mail_body,
               v_send_email_ret_errmsg );
   

EXCEPTION
    when send_email_EXCP then
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := 'FAILED.'; 
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;

    when OTHERS then
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := substr(sqlerrm, 1, 200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;

END notify_user;

/*
||======================================================================
|| Send email notification.
||======================================================================
*/
PROCEDURE send_email (
        in_env                      in  varchar2,
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
	    v_mail_to_email_addr_tab := email_addr_tab_type( 'nadialee@cisco.com', 'aadvani@cisco.com', 'aselvara@cisco.com' );
	else
	    v_mail_to_email_addr_tab := email_addr_tab_type( 'nadialee@cisco.com', 'aadvani@cisco.com', 'aselvara@cisco.com' );
	end if;
		

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
        raise;
END send_email;


END SHR_MDF_REFRESH_PKG;
/
