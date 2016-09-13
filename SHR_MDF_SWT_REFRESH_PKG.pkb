CREATE OR REPLACE PACKAGE BODY SHR_MDF_SWT_REFRESH_PKG AS

/* Copyright (c) 2005 by cisco Systems, Inc. All rights reserved. */
	
/*
||======================================================================
|| File: SHR_MDF_SWT_REFRESH_PKG.pkb
||
|| 
|| Business Data Loading Rules :
|| -----------------------------
|| - Load Data from Cisco.com MDF Software Type Branch
|| -- Cisco.com Software Type View          : vw_software_type_attr
|| -- Cisco.com Products have Software Type : vw_prod_has_swtype
|| -- Cisco.com MDF Connection Details      : e2erepro/composition@authcprd
|| 
|| -- New Software Types for SPRIT needs to informed to the user
|| -- Load Software Type in SHR_OS_TYPE, if publishing system is SPRIT.
|| -- if software type is under IOS branch, then mark Publishing SPRIT-IOS
|| -- for new Software Type being to be managed by SPRIT, 
||      email submitted by explaining him the process to go about it.
|| -- Use the Display column name if it exists, otherwsie use ConceptName by 
||    removing the SWT characters in the start
|| -- Mark Software Type 'EOS' if no Cisco Products exists for it.
|| -- Mark all the IOS Software Type as SPRIT-IOS
|| -- Check if the Non-IOS images mapped to products, relationship no longer exists 
||    in shr_mdf_prod_has_swtype, email the Release PM of publishing PM about it.
||
|| following Software Types to OS Type have been manually mapped inside shr_os_type table
|| for IOS Mapping.
||
|| 280805685, -- IOS Boot Images
|| 280805682, -- IOS Field Programmable Devices
|| 280805681, -- IOS for MSFC
|| 280805684, -- IOS Field Diagnostic Images
|| 280805680  -- IOS Software
||
|| for ION Mapping.
|| 280805692 -- IOS Software Modularity Maintenance Packs
|| 280805693 -- IOS Software Modularity Patches
||
|| for IOS XR mapping
|| 280805694 -- IOSXR Software
|| Function:
||   - Refreshes MDF tables from e2e views.
||   - Refresh frequency is 1 day.
||     Logic is embedded to picked changes from e2e made during
||     past 2 days.
||   - We are NOT deleting/removing any records from our tables,
||     When a record is deleted from e2e views, we mark adm_flag=D
||     in SHR_RDA MDF tables.
||
||
|| NOTE from Shridhar regarding e2e views:
||   In the rare event of refresh failure on E2E Reporting DB side of it..
||   and we(e2e) end up with a state where there the underlying views 
||   are not available. With no data to view, 
||   SPRIT should avoid truncating entire table. 

|| Author: Ashok Advani
|| Created: July 2006
||
||======================================================================
*/
    g_pkg_name      varchar2(100) := 'SHR_MDF_SWT_REFRESH_PKG';
    g_newline       varchar2(2)  := CHR(13)||CHR(10);
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
    
    v_mdf_swt_upd_cnt       number := 0;
    v_mdf_swt_new_cnt       number := 0;
    v_mdf_swt_del_cnt       number := 0;
    v_mdf_swt_del_tot_cnt   number := 0;
    v_mdf_swt_tot_cnt       number := 0;

    v_prod_swt_upd_cnt     number := 0;
    v_prod_swt_new_cnt     number := 0;
    v_prod_swt_del_cnt     number := 0;
    v_prod_swt_del_tot_cnt number := 0;
    v_prod_swt_tot_cnt     number := 0;
    
    v_mdf_swt_discrepancy_cnt   number := 0;
    v_prod_swt_discrepancy_cnt number := 0;
	v_update_software_metadata boolean := FALSE;
    
BEGIN

    log_mdf_refresh (v_proc_name, 'Started.');
    dbms_output.put_line ( g_newline || g_newline ||  v_proc_name || 'Started at ' || v_start_time );
    
    ---------------------------------------------------------
    -- e2e views are empty. Terminate.
    -- commits records to log file.
    ---------------------------------------------------------

    check_e2e_swt( v_e2e_err_msg );
    if( v_e2e_err_msg is not null ) then
        commit;
        raise e2e_exception;
    end if;

    ---------------------------------------------------------
    -- e2e views are validated ... Continue.
    ---------------------------------------------------------

    upd_mdf_swt_modified( v_mdf_swt_upd_cnt );
    upd_mdf_swt_new( v_mdf_swt_new_cnt );
    upd_mdf_swt_deleted( v_mdf_swt_del_cnt );
    get_mdf_swt_tot_deleted( v_mdf_swt_del_tot_cnt );
    get_mdf_swt_tot( v_mdf_swt_tot_cnt );
    verify_refresh_mdf_swt( v_mdf_swt_discrepancy_cnt );
    
    upd_prod_swt_modified( v_prod_swt_upd_cnt );
    upd_prod_swt_new( v_prod_swt_new_cnt );
    upd_prod_swt_deleted( v_prod_swt_del_cnt );
    get_prod_swt_tot_deleted( v_prod_swt_tot_cnt );
    get_prod_swt_tot( v_prod_swt_tot_cnt );
    verify_refresh_prod_swt( v_prod_swt_discrepancy_cnt );
    update_software_metadata(v_update_software_metadata);
	
	if (v_update_software_metadata) then
       commit;
	end if;   

    log_mdf_refresh (v_proc_name, 'Successfully finished.' );

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );

    notify_user( 
        v_mdf_swt_upd_cnt,
        v_mdf_swt_new_cnt,
        v_mdf_swt_del_cnt,
        v_mdf_swt_discrepancy_cnt,
        v_mdf_swt_del_tot_cnt,
        v_mdf_swt_tot_cnt,
        v_prod_swt_upd_cnt,
        v_prod_swt_new_cnt,
        v_prod_swt_del_cnt,
        v_prod_swt_discrepancy_cnt,
        v_prod_swt_del_tot_cnt,
        v_prod_swt_tot_cnt,
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

        notify_user( 
            v_mdf_swt_upd_cnt,
            v_mdf_swt_new_cnt,
            v_mdf_swt_del_cnt,
            v_mdf_swt_discrepancy_cnt,
            v_mdf_swt_del_tot_cnt,
            v_mdf_swt_tot_cnt,
            v_prod_swt_upd_cnt,
            v_prod_swt_new_cnt,
            v_prod_swt_del_cnt,
            v_prod_swt_discrepancy_cnt,
            v_prod_swt_del_tot_cnt,
            v_prod_swt_tot_cnt,
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
            v_mdf_swt_upd_cnt,
            v_mdf_swt_new_cnt,
            v_mdf_swt_del_cnt,
            v_mdf_swt_discrepancy_cnt,
            v_mdf_swt_del_tot_cnt,
            v_mdf_swt_tot_cnt,
            v_prod_swt_upd_cnt,
            v_prod_swt_new_cnt,
            v_prod_swt_del_cnt,
            v_prod_swt_discrepancy_cnt,
            v_prod_swt_del_tot_cnt,
            v_prod_swt_tot_cnt,
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
PROCEDURE check_e2e_swt( out_err_msg   out varchar2 )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.check_e2e_swt] ';
	v_cnt_mdf_swt       number := 0;
	v_cnt_prod_swt      number := 0;
    e2e_exception       exception;
	
BEGIN

    ---------------------------------------------------------
    -- Validate vw_products_attr.
    ---------------------------------------------------------
    select
        count(*)
    into 
        v_cnt_mdf_swt
    from
        vw_software_type_attr@authcprd;
    
    
    if( v_cnt_mdf_swt < 1 )then
        out_err_msg := 'VW_SOFTWARE_TYPE_ATTR is empty.';
        raise e2e_exception;
    end if;

    ---------------------------------------------------------
    -- Validate vw_secondary_parent_rels.
    ---------------------------------------------------------
    select
        count(*)
    into 
        v_cnt_prod_swt
    from
        vw_prod_has_swtype@authcprd;
    
    if( v_cnt_prod_swt < 1 ) then
        out_err_msg := 'VW_PROD_HAS_SWTYPE is empty.';
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

END check_e2e_swt;

/*
||--======================================================================
|| - Update primary mdf table if record has been changed.
|| - We are not depending on last_modifed_date.	
||======================================================================
*/
PROCEDURE upd_mdf_swt_modified( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.upd_mdf_swt_modified] ';
    v_mdf_swt_id        number;
    v_mdf_swt_name      shr_mdf_swtype_attr.mdf_swt_concept_name%type;
    v_now               varchar2(100);
    v_msg               varchar2(1000);
	v_leaf              number;
    v_os_type_id        number;
	v_os_type_count     number;
    cursor modified_mdf_cur is
        select

-- get columns from shr_mdf_swtype_attr
            s.mdf_swt_concept_id           s_mdf_swt_id,
            s.mdf_swt_concept_name         s_mdf_swt_name,
            s.mdf_swt_concept_desc         s_mdf_swt_desc,
            s.mdf_swt_parent_concept_id    s_mdf_pid,
            s.mdf_swt_parent_concept_name  s_mdf_pname,
            s.level_no                     s_level_no,
            s.lifecycle                    s_lifecycle,
            s.publishing_system            s_publishing_system,
            s.mdf_swt_concept_display_name s_mdf_swt_display_name,
            s.submitted_by                 s_submitted_by,
            s.last_modified_date           s_last_modified_date,
            s.is_leaf_node                 s_is_leaf_node,
			
-- get columns from vw_software_type_attr
            a.concept_id                   a_mdf_swt_id,
            a.concept_name                 a_mdf_swt_name,
            a.description                  a_mdf_swt_desc,
            a.parent_concept_id            a_mdf_pid,
            a.parent_concept_name          a_mdf_pname,
            a.level_no                     a_level_no,
            a.mdf_lifecycle                a_lifecycle,
            a.publishing_system            a_publishing_system,
            a.display_name                 a_mdf_swt_display_name,
            a.submitted_by                 a_submitted_by,
            a.last_modified_date           a_last_modified_date,
            a.is_leaf_node                 a_is_leaf_node
        from
            shr_mdf_swtype_attr         s,
            vw_software_type_attr@authcprd   a
        where
            s.mdf_swt_concept_id = a.concept_id
            and s.adm_flag = 'V' ;
--            and trunc(a.last_modified_date) > trunc(sysdate) - 10;
    
	
BEGIN

    out_cnt := 0;

    for c in modified_mdf_cur loop

	    /** -- just check for Last modified date as comparing all fields while loading can 
		    -- complicate the whole data loading aspect of it
        if(    c.s_mdf_swt_name         <> c.a_mdf_swt_name  
            or c.s_mdf_swt_desc         <> c.a_mdf_swt_desc
            or c.s_mdf_pid              <> c.a_mdf_pid
            or c.s_mdf_pname            <> c.a_mdf_pname
            or c.s_level_no             <> c.a_level_no
            or c.s_lifecycle            <> c.a_lifecycle
            or c.s_publishing_system    <> c.a_publishing_system
            or c.s_mdf_swt_display_name <> c.a_mdf_swt_display_name
            or c.s_submitted_by         <> c.a_submitted_by 
            or c.s_last_modified_date   <> c.a_last_modified_date
          )
		  */
		-- Comparing if the last modified date is not the same as VW_SOFTWARE_TYPE_ATTR 
        if(
            c.s_last_modified_date   <> c.a_last_modified_date
          )		  
        then
            out_cnt     := out_cnt + 1;
            v_mdf_swt_id    := c.a_mdf_swt_id;
			
			if ((c.a_mdf_swt_display_name = 'N/A') or (c.a_mdf_swt_display_name is null)) then
			   if (instr(c.a_mdf_swt_name, 'SWT') = 0) then
			      v_mdf_swt_name  :=  c.a_mdf_swt_name;
			   else 
			      v_mdf_swt_name  := substr(c.a_mdf_swt_name, 5, length(c.a_mdf_swt_name)-4);
			   end if;	  				  
			else
			   v_mdf_swt_name  := c.a_mdf_swt_display_name;
			end if;

            update
                shr_mdf_swtype_attr
            set
                mdf_swt_concept_name         = v_mdf_swt_name,
                mdf_swt_concept_desc         = c.a_mdf_swt_desc,
                mdf_swt_parent_concept_id    = c.a_mdf_pid,
                mdf_swt_parent_concept_name  = c.a_mdf_pname,
                level_no                     = c.a_level_no,
                lifecycle                    = upper(c.a_lifecycle),
                publishing_system            = c.a_publishing_system,
                mdf_swt_concept_display_name = v_mdf_swt_name,
                submitted_by                 = c.a_submitted_by,
                last_modified_date           = c.a_last_modified_date,
                adm_timestamp                = sysdate,
                adm_flag                     = 'V',
                adm_comment                  = 'UPDATED FROM VW_SOFTWARE_TYPE_ATTR',
				is_leaf_node                 = c.a_is_leaf_node
            where
                mdf_swt_concept_id = v_mdf_swt_id;

        end if;

        -- need to put in the rule is the Publishing System to SPRIT, 
		-- addition to SHR_OS_TYPE Table 
		-- and Email Submitted By User
	    if ((c.s_publishing_system = 'SIPS') AND (c.a_publishing_system = 'SPRIT')) then
		    
		   -- Check to see whether the Software Type is the leaf now before adding to Shr_os_type table
		   
		   if ((c.a_is_leaf_node = 'Y') and ((v_mdf_swt_name not like 'IOS%') and
		                                     (v_mdf_swt_name not like '%CatOS%')))  then

  		       -- update shr_os_type
			   -- set mdf_swt_concept_id = v_mdf_swt_id, 
			   --    adm_flag = 'V'
			   -- where upper(trim(os_type_name)) = upper(trim(v_mdf_swt_name));
			   
               select count(os_type_id) into v_os_type_count
			   from shr_os_type
			   where upper(trim(os_type_name)) = upper(trim(v_mdf_swt_name));
			   
			   if (v_os_type_count = 0) then
			   		  		
		          insert into shr_os_type 
			        (os_type_id,
                     os_type_name,
                     description,
                     adm_timestamp,
                     adm_userid,
                     adm_flag,
                     adm_comment,
                     created_by,
                     created_date)
                  values (
                    shr_os_type_seq.nextval,
	                v_mdf_swt_name,
                    c.a_mdf_swt_desc,
                    sysdate,
   	  		        c.a_submitted_by,
                    'V',
                    'CREATED BY VW_SOFTWARE_TYPE_ATTR',
			        c.a_submitted_by,
       			    sysdate) ;
					
				  insert into shr_ostype_mdfswtype 
			          (OSTYPE_MDFSWTYPE_ID,
                       OS_TYPE_ID,
                       MDF_SWT_CONCEPT_ID,
                       LAST_MODIFIED_DATE,
                       ADM_CREATED_AT,
                       ADM_TIMESTAMP,
                       ADM_FLAG,
                       ADM_COMMENT
					  )
                  values 
				      (shr_ostype_mdfswtype_seq.nextval,
                       shr_os_type_seq.currval,
					   v_mdf_swt_id,
                       sysdate,
                       sysdate,
					   sysdate,
                       'V',
                       'CREATED BY VW_SOFTWARE_TYPE_ATTR'
			           ) ;
					   
				  elsif (v_os_type_count = 1) then
				  
				     update shr_ostype_mdfswtype 
				     set os_type_id = (select os_type_id from shr_os_type where upper(trim(os_type_name)) = upper(trim(v_mdf_swt_name)) and rownum < 2)
				     where mdf_swt_concept_id = v_mdf_swt_id;
				  
				     if SQL%NOTFOUND then
				    
					   insert into shr_ostype_mdfswtype 
			             (OSTYPE_MDFSWTYPE_ID,
                          OS_TYPE_ID,
                          MDF_SWT_CONCEPT_ID,
                          LAST_MODIFIED_DATE,
                          ADM_CREATED_AT,
                          ADM_TIMESTAMP,
                          ADM_FLAG,
                          ADM_COMMENT
					     )
                        values 
				         (shr_ostype_mdfswtype_seq.nextval,
	                      (select os_type_id from shr_os_type where upper(trim(os_type_name)) = upper(trim(v_mdf_swt_name)) and rownum < 2),
					      v_mdf_swt_id,
                          sysdate,
                          sysdate,
					      sysdate,
                          'V',
                          'CREATED BY VW_SOFTWARE_TYPE_ATTR'
			              ) ;
					   
				   	  end if; -- sql%notfound
					   

	              end if;		   
 			      -- this call below sends email to submitter of the software type

  			      send_mail_to_swtype_submitter (c.a_mdf_swt_name,
                                                 c.a_mdf_swt_desc,
			     		                         c.a_submitted_by);
												 
			end if;	-- Software Type Leaf Node - v_leaf = 1								 

	     end if;  -- if publishing system changed from SIPS to SPRIT.		   
			                     
    end loop;
    commit;

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_msg := 'Software MDF - SHR_MDF_SWTYPE_ATTR . Modified: ' || out_cnt || ' records. ';
    
    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line ( v_proc_name || v_msg || v_now);
    
EXCEPTION
    when OTHERS then
        rollback;
        v_msg := 
            'cnt=' || out_cnt ||
            ', mdf_swt_concept_id=' || v_mdf_swt_id ||
            ', mdf_swt_concept_name=' || v_mdf_swt_name ||
            '==>'|| substr(sqlerrm, 1,200);
            
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
            
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg );
        dbms_output.put_line( v_proc_name || 'Terminated at ' || v_now );
        raise;

END upd_mdf_swt_modified;

/*
||======================================================================
|| - Create new mdf software concepts. 
||======================================================================
*/
PROCEDURE upd_mdf_swt_new( out_cnt out number )
IS

    v_proc_name             varchar2(200) := '[' || g_pkg_name || '.upd_mdf_swt_new] ';
    v_mdf_swt_id            number;
    v_mdf_swt_name          shr_mdf_swtype_attr.mdf_swt_concept_name%type;
    v_now                   varchar2(100);
    v_msg                   varchar2(1000);
	v_leaf                  number;                 
    v_os_type_id            number;
	v_os_type_count         number;
	    
    cursor new_mdf_swt_cur is
        select
            a.*
        from
            shr_mdf_swtype_attr              s,
            vw_software_type_attr@authcprd   a
        where
            a.concept_id = s.mdf_swt_concept_id(+)
            and s.mdf_swt_concept_id is null;
    
    cursor revived_mdf_swt_cur is
        select
            a.*
        from
            shr_mdf_swtype_attr              s,
            vw_software_type_attr@authcprd   a
        where
            a.concept_id = s.mdf_swt_concept_id
            and s.adm_flag = 'D' ;
	
BEGIN

    out_cnt := 0;

    ------------------------------------------------------
    -- NDF not in sRDA at all.
    ------------------------------------------------------
    for c in new_mdf_swt_cur loop

        out_cnt         := out_cnt + 1;
        v_mdf_swt_id    := c.concept_id;
		
		if ((c.display_name = 'N/A') or (c.display_name is null)) then
			if (instr(c.concept_name, 'SWT') = 0) then
			   v_mdf_swt_name  :=  c.concept_name;
			else 
			   v_mdf_swt_name  := substr(c.concept_name, 5, length(c.concept_name)-4);
			end if;	  				  
		else
			v_mdf_swt_name  := c.display_name;
		end if;
		
		dbms_output.put_line('CN - ' || c.concept_name || '; DN - ' || c.display_name || '; MN - ' || v_mdf_swt_name);  
		
        -- v_mdf_swt_name  := c.concept_name;
        
        insert into shr_mdf_swtype_attr
		   (  mdf_swt_concept_id,
              mdf_swt_concept_name,
              mdf_swt_parent_concept_id,
              mdf_swt_parent_concept_name,
              level_no,
              lifecycle,
              publishing_system,
              mdf_swt_concept_display_name,
              last_modified_date,
              adm_created_at,
              adm_timestamp,
              adm_flag,
              adm_comment,
              mdf_swt_concept_desc,
              submitted_by,
			  is_leaf_node
			)                  
		 values (
              c.concept_id,
	          v_mdf_swt_name,
              c.parent_concept_id,
	          c.parent_concept_name,
              c.level_no,
			  upper(c.mdf_lifecycle),
			  c.publishing_system,
			  v_mdf_swt_name,
              c.last_modified_date,
              sysdate,
			  sysdate,
              'V',
              'CREATED FROM VW_SOFTWARE_TYPE_ATTR',
			  c.description,
			  c.submitted_by,
			  c.is_leaf_node 
			) ;
			
		    -- dbms_output.put_line('step ' ||  out_cnt || ' - ' || c.concept_name || '\n');
			
    -- ADD -- Rule to insert if Publishing System is SPRIT and email to Submitted By

        -- need to put in the rule is the Publishing System to SPRIT, 
		-- addition to SHR_OS_TYPE Table 
		-- and Email Submitted By User
	    if (c.publishing_system = 'SPRIT') then
		
		   -- Check to see whether the Software Type is the leaf now before adding to Shr_os_type table
           -- select count(concept_id) into v_leaf
           -- from vw_software_type_attr@authcprd
           -- start with concept_id = v_mdf_swt_id
           -- connect by parent_concept_id = prior concept_id;
		   
		   if ((c.is_leaf_node = 'Y') and ((v_mdf_swt_name not like 'IOS%') and
		                                   (v_mdf_swt_name not like '%CatOS%')))then

  		       -- update shr_os_type
			   -- set mdf_swt_concept_id = v_mdf_swt_id, 
			   --    adm_flag = 'V'
			   -- where upper(trim(os_type_name)) = upper(trim(v_mdf_swt_name));
			   
		       dbms_output.put_line('step inside 1 ' || v_mdf_swt_name ||' \n');
					   
               select count(os_type_id) 
			   into v_os_type_count
			   from shr_os_type
			   where upper(trim(os_type_name)) = upper(trim(v_mdf_swt_name));

			   if (v_os_type_count = 0) then
			   		  		
		          insert into shr_os_type 
			        (os_type_id,
                     os_type_name,
                     description,
                     adm_timestamp,
                     adm_userid,
                     adm_flag,
                     adm_comment,
                     created_by,
                     created_date)
                  values (
                     shr_os_type_seq.nextval,
                     v_mdf_swt_name,
                     c.description,
                     sysdate,
                     c.submitted_by,
                     'V',
                     'CREATED BY VW_SOFTWARE_TYPE_ATTR',
                     c.submitted_by,
                     sysdate) ;					
                     		       dbms_output.put_line('step inside 2 \n');				  
  		          insert into shr_ostype_mdfswtype 
			          (OSTYPE_MDFSWTYPE_ID,
                       OS_TYPE_ID,
                       MDF_SWT_CONCEPT_ID,
                       LAST_MODIFIED_DATE,
                       ADM_CREATED_AT,
                       ADM_TIMESTAMP,
                       ADM_FLAG,
                       ADM_COMMENT
					  )
                  values 
				      (shr_ostype_mdfswtype_seq.nextval,
	                   shr_os_type_seq.currval,
					   v_mdf_swt_id,
                       sysdate,
                       sysdate,
					   sysdate,
                       'V',
                       'CREATED BY VW_SOFTWARE_TYPE_ATTR'
			           ) ;
					   
				  elsif (v_os_type_count = 1) then
				  
				     update shr_ostype_mdfswtype 
				     set os_type_id = (select os_type_id from shr_os_type where upper(trim(os_type_name)) = upper(trim(v_mdf_swt_name)) and rownum < 2)
				     where mdf_swt_concept_id = v_mdf_swt_id;
				  
				     if SQL%NOTFOUND then
				    
					   insert into shr_ostype_mdfswtype 
			             (OSTYPE_MDFSWTYPE_ID,
                          OS_TYPE_ID,
                          MDF_SWT_CONCEPT_ID,
                          LAST_MODIFIED_DATE,
                          ADM_CREATED_AT,
                          ADM_TIMESTAMP,
                          ADM_FLAG,
                          ADM_COMMENT
					     )
                        values 
				         (shr_ostype_mdfswtype_seq.nextval,
	                      (select os_type_id from shr_os_type where upper(trim(os_type_name)) = upper(trim(v_mdf_swt_name)) and rownum < 2),
					      v_mdf_swt_id,
                          sysdate,
                          sysdate,
					      sysdate,
                          'V',
                          'CREATED BY VW_SOFTWARE_TYPE_ATTR'
			              ) ;
					   
				   	  end if; -- sql%notfound
					   
	              end if; 		   
			   
			      -- this call below sends email to submitter of the software type
			      send_mail_to_swtype_submitter (v_mdf_swt_name,
                                                 c.description,
			     		                         c.submitted_by);
			end if;	-- Software Type Leaf Node - v_leaf = 1								 

	     end if;	-- Publishing System SPRIT	   

                
    end loop;
    commit;

    ------------------------------------------------------
    -- In sRDA. Previously deleted, and not revived again.
    ------------------------------------------------------
    for c in revived_mdf_swt_cur loop

        out_cnt     := out_cnt + 1;
        v_mdf_swt_id    := c.concept_id;
        v_mdf_swt_name  := c.concept_name;

	
        update
             shr_mdf_swtype_attr
        set
             mdf_swt_concept_name         = c.concept_name,
             mdf_swt_concept_desc         = c.description,
             mdf_swt_parent_concept_id    = c.parent_concept_id,
             mdf_swt_parent_concept_name  = c.parent_concept_name,
             level_no                     = c.level_no,
             lifecycle                    = upper(c.mdf_lifecycle),
             publishing_system            = c.publishing_system,
             mdf_swt_concept_display_name = c.display_name,
             submitted_by                 = c.submitted_by,
             last_modified_date           = c.last_modified_date,
             adm_timestamp                = sysdate,
             adm_flag                     = 'V',
             adm_comment                  = 'REVIVED FROM VW_SOFTWARE_TYPE_ATTR'
         where
             mdf_swt_concept_id = v_mdf_swt_id;
			 
		if (c.publishing_system = 'SPRIT') then		
            --- ADD ADD
		    update shr_ostype_mdfswtype 
            set adm_flag = 'V',
                adm_comment = 'REVIVED FROM CISCO.COM MDF VW_SOFTWARE_TYPE_ATTR'
            where mdf_swt_concept_id = v_mdf_swt_id;							   
	     end if;	 
            
    end loop;
    commit;
    
    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF Software Type. New/Revived: ' || out_cnt || ' records.';

    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line ( v_proc_name || v_msg || v_now);

    
EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := 
            'cnt=' || out_cnt ||
            ', mdf_swt_id=' || v_mdf_swt_id ||
            ', mdf_swt_name=' || v_mdf_swt_name ||
            '==>'|| substr(sqlerrm, 1,200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;        

END upd_mdf_swt_new;

/*
||======================================================================
|| - Flag deleted mdf concept. 
||======================================================================
*/
PROCEDURE upd_mdf_swt_deleted( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.upd_primary_mdf_deleted] ';
    v_mdf_swt_id        number;
    v_mdf_swt_name      shr_mdf_swtype_attr.mdf_swt_concept_name%type;
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
    cursor del_mdf_cur is
        select
            s.*
        from
            shr_mdf_swtype_attr       s,
            vw_software_type_attr@authcprd   a
        where
            s.mdf_swt_concept_id = a.concept_id(+)
            and a.concept_id is null ;
   
	
BEGIN

    out_cnt := 0;

    for c in del_mdf_cur loop

        out_cnt     := out_cnt + 1;
        v_mdf_swt_id    := c.mdf_swt_concept_id;
        v_mdf_swt_name  := c.mdf_swt_concept_name;
        
        update
            shr_mdf_swtype_attr
        set
            adm_timestamp = sysdate,
            adm_flag = 'D',
            adm_comment = 'DELETED FROM VW_SOFTWARE_TYPE_ATTR'
        where 
            mdf_swt_concept_id = v_mdf_swt_id;

	    if (c.publishing_system = 'SPRIT') then		
		    update shr_ostype_mdfswtype 
            set adm_flag = 'D',
                adm_comment = 'DELETED BY VW_SOFTWARE_TYPE_ATTR'
            where mdf_swt_concept_id = v_mdf_swt_id;							   
	     end if;		   
			
			
    end loop;
    commit;

    
    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF Software Type. Deleted: ' || out_cnt || ' records. ';
    
    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || v_msg || v_now );

EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := 
            'cnt=' || out_cnt ||
            ', mdf_id=' || v_mdf_swt_id ||
            ', mdf_name=' || v_mdf_swt_name ||
            '==>'|| substr(sqlerrm, 1,200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg  || v_now);
        raise;
        
END upd_mdf_swt_deleted;

/*
||======================================================================
|| - Get total count of deleted primary MDF parents from the DB.
||======================================================================
*/
PROCEDURE get_mdf_swt_tot_deleted( out_cnt out number )
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
        shr_mdf_swtype_attr
    where
        adm_flag = 'D' ;

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF Software Type. Total deleted from DB: ' || out_cnt || ' records. ';
    
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
        
END get_mdf_swt_tot_deleted;

/*
||======================================================================
|| - Get total count of MDF Software Type from the DB.
||======================================================================
*/
PROCEDURE get_mdf_swt_tot( out_cnt out number )
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
        shr_mdf_swtype_attr
    where
        adm_flag = 'V' ;

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF Software Type. Total count: ' || out_cnt || ' records. ';
    
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
        
END get_mdf_swt_tot;


/*
||======================================================================
|| - Update second mdf table if record has been changed,
|| - We don't depend on last_modified_date.
||======================================================================
*/
PROCEDURE upd_prod_swt_modified( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.upd_prod_swt_modified] ';
    v_mdf_swt_id        number;
    v_mdf_swt_name      shr_mdf_secondary_parent_rels.mdf_concept_name%type;
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
    -- We don't depend on last_modified_date.

    cursor modified_prod_swt_cur is
        select
            s.mdf_swt_concept_id       s_swtid,
            s.mdf_swt_concept_name     s_swtname,
	        s.mdf_concept_id           s_mid,
            s.mdf_concept_name         s_mname,
            a.swtype_concept_id        a_swtid,
            a.swtype_concept_name      a_swtname,
            a.product_concept_id       a_mid,
            a.product_concept_name     a_mname
        from
            shr_mdf_prod_has_swtype       s,
            vw_prod_has_swtype@authcprd   a
        where
            s.mdf_swt_concept_id = a.swtype_concept_id
            and s.mdf_concept_id = a.product_concept_id
            and ( s.mdf_concept_name <> a.product_concept_name
                  or s.mdf_swt_concept_name <> a.swtype_concept_name
                );
	
BEGIN

    out_cnt := 0;

    for c in modified_prod_swt_cur loop
       
        out_cnt     := out_cnt + 1;
        v_mdf_swt_id    := c.s_swtid;
        v_mdf_swt_name  := c.s_swtname;

        update
            shr_mdf_prod_has_swtype
        set
            mdf_concept_name      = c.a_mname,
            mdf_swt_concept_name  = c.a_swtname,
            last_modified_date    = sysdate, --- LAST_MODIFIED date not provided by VW_PROD_HAS_SWTYPE, so being populated by SYSDATE
            adm_timestamp         = sysdate,
            adm_flag              = 'V',
            adm_comment           = 'UPDATED FROM VW_PROD_HAS_SWTYPE'
        where
            mdf_swt_concept_id = c.s_swtid
        and mdf_concept_id = c.s_mid;
            
    end loop;
    commit;

    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
    v_msg := 'MDF - Prod has Software Type. Modified: ' || out_cnt || ' records.';
    
    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || v_msg );

EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := 
            'cnt=' || out_cnt ||
            ', mdf_id=' || v_mdf_swt_id ||
            ', mdf_name=' || v_mdf_swt_name ||
            '==>'|| substr(sqlerrm, 1,200);
    
        log_mdf_refresh (v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;
        
END upd_prod_swt_modified;

/*
||======================================================================
|| - Create new secondary mdf parents. 
||======================================================================
*/
PROCEDURE upd_prod_swt_new( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.upd_prod_swt_new] ';
    v_mdf_swt_id        number;
    v_mdf_swt_name      shr_mdf_swtype_attr.mdf_swt_concept_name%type;
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
    cursor new_prod_swt_cur is
        select
            a.*
        from
            shr_mdf_prod_has_swtype             s,
            vw_prod_has_swtype@authcprd         a
        where
            a.swtype_concept_id = s.mdf_swt_concept_id(+)
            and a.product_concept_id = s.mdf_concept_id(+)
            and s.mdf_concept_id is null
            and s.mdf_swt_concept_id is null;
	
    cursor revived_prod_swt_cur is
        select
            a.*
        from
            shr_mdf_prod_has_swtype             s,
            vw_prod_has_swtype@authcprd         a
        where
            a.swtype_concept_id = s.mdf_swt_concept_id
            and a.product_concept_id = s.mdf_concept_id
            and s.adm_flag = 'D' ;

BEGIN

    out_cnt := 0;

    for c in new_prod_swt_cur loop

        out_cnt         := out_cnt + 1;
        v_mdf_swt_id    := c.swtype_concept_id;
        v_mdf_swt_name  := c.swtype_concept_name;
        
        insert into shr_mdf_prod_has_swtype values (
            c.product_concept_id,
            c.product_concept_name,
            c.swtype_concept_id,
            c.swtype_concept_name,
	        null,
	        c.product_lifecycle,
            sysdate,
            sysdate,
            sysdate,
            'V',
            'CREATED FROM VW_PROD_HAS_SWTYPE' ) ;
                
    end loop;
    commit;

    for c in revived_prod_swt_cur loop

        out_cnt         := out_cnt + 1;
        v_mdf_swt_id    := c.swtype_concept_id;
        v_mdf_swt_name  := c.swtype_concept_name;
        
        update
            shr_mdf_prod_has_swtype
        set
            mdf_swt_concept_name = c.swtype_concept_name,
            mdf_concept_name = c.product_concept_name,
            last_modified_date = sysdate,
            adm_timestamp = sysdate,
            adm_flag = 'V',
            adm_comment = 'REVIVED FROM VW_PROD_HAS_SWTYPE'
        where
            mdf_swt_concept_id = c.swtype_concept_id
            and mdf_concept_id = c.product_concept_id;            
    end loop;
    commit;


    v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_msg := 'MDF Prod has Software Type . New/Revived: ' || out_cnt || ' records. ';

    log_mdf_refresh (v_proc_name, v_msg );
    dbms_output.put_line( v_proc_name || v_msg || v_now );
    
EXCEPTION
    when OTHERS then
        rollback;
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
        v_msg :=
            'cnt=' || out_cnt ||
            ', mdf_id=' || v_mdf_swt_id ||
            ', mdf_name=' || v_mdf_swt_name ||
            '==>'|| substr(sqlerrm, 1,200);
        
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;
        
END upd_prod_swt_new;

/*
||======================================================================
|| - Update deleted flag for deleted mdf secondary parents. 
||======================================================================
*/
PROCEDURE upd_prod_swt_deleted( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.upd_prod_swt_deleted] ';
    v_mdf_swt_id        number;
    v_mdf_swt_name      shr_mdf_swtype_attr.mdf_swt_concept_name%type;
    v_mdf_id            number;
    v_now               varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_msg               varchar2(1000);
    
    cursor del_prod_swt_cur is
        select
            s.*
        from
            shr_mdf_prod_has_swtype             s,
            vw_prod_has_swtype@authcprd         a
        where
            s.mdf_concept_id = a.product_concept_id(+)
            and s.mdf_swt_concept_id = a.swtype_concept_id(+)
            and a.product_concept_id is null
            and a.swtype_concept_id is null; 
	
BEGIN

    out_cnt := 0;

    for c in del_prod_swt_cur loop

        out_cnt        := out_cnt + 1;
        v_mdf_id       := c.mdf_concept_id;
        v_mdf_swt_id   := c.mdf_swt_concept_id;
        v_mdf_swt_name := c.mdf_swt_concept_name;
        
        update
            shr_mdf_prod_has_swtype
        set
            adm_timestamp = sysdate,
            adm_flag = 'D',
            adm_comment = 'DELETED FROM VW_PROD_HAS_SWTYPE'
        where 
            mdf_concept_id = c.mdf_concept_id
            and mdf_swt_concept_id = c.mdf_swt_concept_id;

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
            ', mdf_swt_id=' || v_mdf_swt_id ||
            ', mdf_swt_name=' || v_mdf_swt_name ||
            '==>'|| substr(sqlerrm, 1,200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;
                
END upd_prod_swt_deleted;

/*
||======================================================================
|| - Get total count of deleted secondary MDF parents from the DB.
||======================================================================
*/
PROCEDURE get_prod_swt_tot_deleted( out_cnt out number )
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
        shr_mdf_prod_has_swtype
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
        
END get_prod_swt_tot_deleted;

/*
||======================================================================
|| - Get total count of secondary MDF parents from the DB.
||======================================================================
*/
PROCEDURE get_prod_swt_tot( out_cnt out number )
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
        shr_mdf_prod_has_swtype
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
        
END get_prod_swt_tot;


/*
||======================================================================
|| - Verify MDF refresh for primary mdf parent by comparing 
||   SHR_MDF_PRODUCGS_ATTR to VW_PRODUCTS_ATTR. 
||======================================================================
*/
PROCEDURE verify_refresh_mdf_swt( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.verify_refresh_mdf_swt] ';
    v_mdf_swt_id        number;
    v_mdf_swt_name      shr_mdf_swtype_attr.mdf_swt_concept_name%type;
    v_now               varchar2(100);
    v_msg               varchar2(1000);
    
    cursor descrepant_mdf is
        select   -- Record match, but info not-match
            s.*
        from
            shr_mdf_swtype_attr       s,
            vw_software_type_attr@authcprd   a
        where
            s.mdf_swt_concept_id = a.concept_id
            and ( s.mdf_swt_concept_name <> a.concept_name 
                  or s.mdf_swt_parent_concept_id <> a.parent_concept_id
                  or s.mdf_swt_parent_concept_name <> a.parent_concept_name
                  or s.lifecycle <> a.mdf_lifecycle
                  or s.publishing_system <> a.publishing_system
                  or s.mdf_swt_concept_display_name <> a.display_name
                  or s.submitted_by <> a.submitted_by
                  or s.last_modified_date <> a.last_modified_date
                )
            and s.adm_flag = 'V' 
        UNION
        select   -- record in both sRDA and e2e, but sRDA marked delete
            s.*
        from
            shr_mdf_swtype_attr       s,
            vw_software_type_attr@authcprd   a
        where
            a.concept_id = s.mdf_swt_concept_id
            and s.adm_flag = 'D'
        UNION
        select   -- extra record in sRDA
            s.*
        from
            shr_mdf_swtype_attr       s,
            vw_software_type_attr@authcprd   a
        where
            s.adm_flag = 'V'
            and s.mdf_swt_concept_id = a.concept_id(+)
            and a.concept_id is null
        UNION
        select   -- extra record in e2e, not in sRDA
            s.*
        from
            shr_mdf_swtype_attr       s,
            vw_software_type_attr@authcprd   a
        where
            a.concept_id = s.mdf_swt_concept_id(+)
            and a.concept_id is null ;

BEGIN

    out_cnt := 0;

    for c in descrepant_mdf loop

        BEGIN
            out_cnt         := out_cnt + 1;
            v_mdf_swt_id    := c.mdf_swt_concept_id;
            v_mdf_swt_name  := c.mdf_swt_concept_name;
            
            v_msg := 
                'cnt=' || out_cnt ||
                '. Discrepancy in primary mdf==>' ||
                c.mdf_swt_concept_id || ', ' || c.mdf_swt_concept_name;
                
            log_mdf_refresh ( v_proc_name, v_msg );
                
        EXCEPTION
            when others then
                rollback;
                v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
                v_msg := 
                    'cnt=' || out_cnt ||
                    ', mdf_id=' || v_mdf_swt_id ||
                    ', mdf_name=' || v_mdf_swt_name ||
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
            ', mdf_swt_id=' || v_mdf_swt_id ||
            ', mdf_swt_name=' || v_mdf_swt_name ||
            '==>'|| substr(sqlerrm, 1,200);

        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg  || v_now );
        raise;
        
END verify_refresh_mdf_swt;

/*
||======================================================================
|| - Verify MDF refresh for secondary mdf parents by comparing 
||   SHR_MDF_SECONDARY_PARENT_RELS to VW_SECONDARY_PARENT_RELS. 
||======================================================================
*/
PROCEDURE verify_refresh_prod_swt( out_cnt out number )
IS

    v_proc_name         varchar2(200) := '[' || g_pkg_name || '.verify_refresh_prod_swt] ';
    v_mdf_id            shr_mdf_prod_has_swtype.mdf_concept_id%type;
    v_mdf_name          shr_mdf_prod_has_swtype.mdf_concept_name%type;
    v_mdf_swt_id        shr_mdf_prod_has_swtype.mdf_swt_concept_id%type;
    v_mdf_swt_name      shr_mdf_prod_has_swtype.mdf_swt_concept_name%type;
    v_now               varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_msg               varchar2(1000);
    
    cursor descrepant_mdf is
        select
            s.*
        from
            shr_mdf_prod_has_swtype       s,
            vw_prod_has_swtype@authcprd   a
        where
            s.mdf_concept_id = a.product_concept_id
            and s.mdf_swt_concept_id = a.swtype_concept_id
            and ( s.mdf_concept_name <> a.product_concept_name 
                  or s.mdf_swt_concept_name <> a.swtype_concept_name 
                )
            and s.adm_flag = 'V'
        UNION
        select   -- record in both sRDA and e2e, but sRDA marked delete
            s.*
        from
            shr_mdf_prod_has_swtype       s,
            vw_prod_has_swtype@authcprd   a
        where
            a.product_concept_id = s.mdf_concept_id
            and a.swtype_concept_id = s.mdf_swt_concept_id
            and s.adm_flag = 'D'
        UNION
        select   -- extra record in sRDA
            s.*
        from
            shr_mdf_prod_has_swtype       s,
            vw_prod_has_swtype@authcprd   a
        where
            s.adm_flag = 'V'
            and s.mdf_concept_id = a.product_concept_id(+)
            and s.mdf_swt_concept_id = a.swtype_concept_id(+)
            and a.product_concept_id is null 
        UNION
        select   -- extra record in e2e, not in sRDA
            s.*
        from
            shr_mdf_prod_has_swtype       s,
            vw_prod_has_swtype@authcprd   a
        where
            a.product_concept_id = s.mdf_concept_id(+)
            and a.swtype_concept_id = s.mdf_swt_concept_id(+)
            and s.mdf_concept_id is null ;

BEGIN

    out_cnt := 0;

    for c in descrepant_mdf loop

        BEGIN
            out_cnt         := out_cnt + 1;
            v_mdf_id        := c.mdf_concept_id;
            v_mdf_name      := c.mdf_concept_name;
            v_mdf_swt_id    := c.mdf_swt_concept_id;
            v_mdf_swt_name  := c.mdf_swt_concept_name;
            
            v_msg := 
                'cnt='|| out_cnt ||
                '. Discrepancy in secondary mdf==>' ||
                'mdf_concept_id=' || v_mdf_id ||
                ', mdf_name=' || v_mdf_name ||
                ', srda_2nd_parent_id=' || v_mdf_swt_id ||
                ', srda_2nd_parent_name=' || v_mdf_swt_name;

            log_mdf_refresh ( v_proc_name, v_msg );
                            
        EXCEPTION
            when others then
                rollback;
                v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
                v_msg := 
                    'cnt=' || out_cnt ||
                    ', mdf_id=' || v_mdf_id ||
                    ', mdf_name=' || v_mdf_name ||
                    ', mdf_swt_id=' || v_mdf_swt_id ||
                    ', mdf_swt_name=' || v_mdf_swt_name ||
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
            ', srda_2nd_parent_id=' || v_mdf_swt_id ||
            ', srda_2nd_parent_name=' || v_mdf_swt_name ||
            '==>'|| substr(sqlerrm, 1,200);

        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;
        
END verify_refresh_prod_swt;

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
        in_mdf_swt_upd_cnt              in number,
        in_mdf_swt_new_cnt              in number,
        in_mdf_swt_del_cnt              in number,
        in_mdf_swt_discrepancy_cnt      in number,
        in_mdf_swt_tot_del_cnt          in number,
        in_mdf_swt_tot_cnt              in number,
        in_prod_swt_upd_cnt             in number,
        in_prod_swt_new_cnt             in number,
        in_prod_swt_del_cnt             in number,
        in_prod_swt_discrepancy_cnt     in number,
        in_prod_swt_tot_del_cnt         in number,
        in_prod_swt_tot_cnt             in number,
        in_is_successful                in boolean,
        in_start_time                   in varchar2,
        in_end_time                     in varchar2,
        in_errmsg                       in varchar2 )
IS

    v_proc_name                 varchar2(100) := g_pkg_name || '.notify_user';

    v_now                       varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
	v_mail_from_alias	        varchar2(50) := '"SHR-MDF-Refresh-Mailer"';
	v_mail_from_email_addr      varchar2(50) := 'aadvani@cisco.com';
	
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
        'Software Type    table: ' || g_newline ||
        '------------------------' || g_newline ||
        'Updated Records              : ' || in_mdf_swt_upd_cnt || g_newline ||
        'New Records                  : ' || in_mdf_swt_new_cnt || g_newline ||
        'Deleted Records              : ' || in_mdf_swt_del_cnt || g_newline ||
        'Discrepant Records           : ' || in_mdf_swt_discrepancy_cnt || g_newline ||
        'Total Deleted Records from DB: ' || in_mdf_swt_tot_del_cnt || g_newline ||
        'Total Records from DB        : ' || in_mdf_swt_tot_cnt || g_newline ||
        g_newline || 
        'Product_Software Type table:   ' || g_newline ||
        '-------------------------------' || g_newline ||
        'Updated Records              : ' || in_prod_swt_upd_cnt || g_newline ||
        'New Records                  : ' || in_prod_swt_new_cnt || g_newline ||
        'Deleted Records              : ' || in_prod_swt_del_cnt || g_newline ||
        'Discrepant Records           : ' || in_prod_swt_discrepancy_cnt || g_newline ||
        'Total Deleted Records from DB: ' || in_prod_swt_tot_del_cnt || g_newline ||
        'Total Records from DB        : ' || in_prod_swt_tot_cnt || g_newline ||
        g_newline ||
        'For more detail information or error, please look at SHR_MDF_REFRESH_LOG table.' ||
        g_newline;
	
        send_email(
	           g_env,
			   'aadvani', -- change this CSPR-ENG later
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
	    v_mail_to_email_addr_tab := email_addr_tab_type('aadvani@cisco.com');
	else
	    v_mail_to_email_addr_tab := email_addr_tab_type('aadvani@cisco.com');
	end if;
	
	v_mail_to_email_addr_tab := email_addr_tab_type(in_mail_to||'@cisco.com');
		

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

/*
||======================================================================
|| Update the following metadata across the following object.field 
|| 1. shr_mdf_swtype_attr.MDF_SWT_PARENT_CONCEPT_NAME
|| 2. shr_mdf_prod_has_swtype.MDF_CONCEPT_NAME
|| 3. shr_mdf_prod_has_swtype.MDF_SWT_CONCEPT_NAME
|| 4. shr_mdf_prod_has_swtype.PRODUCT_LIFECYCLE
|| 5. shr_mdf_prod_has_swtype.SWT_LIFECYCLE
||
|| Calculate EOS for Software Types if no Software Type Data within
|| shr_mdf_prod_has_swtype
||
|| Mark IOS Software Type Publishing System as SPRIT IOS
||======================================================================
*/
PROCEDURE update_software_metadata(out_flag out boolean )

IS

	v_proc_name               varchar2(100) := g_pkg_name || '.update_software_metadata';
    v_now                     varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_msg                     varchar2(2000);
	v_leaf                    varchar2(10);
  
BEGIN

     for swtype in 
	 
       (select *
        from   shr_mdf_swtype_attr s
        where  s.adm_flag = 'V') loop
		
		-- update shr_mdf_swtype_attr.MDF_SWT_PARENT_CONCEPT_NAME
		update shr_mdf_swtype_attr
		set mdf_swt_parent_concept_name = swtype.mdf_swt_concept_name
		where mdf_swt_parent_concept_id = swtype.mdf_swt_concept_id;
		





        -- ADD ADD remove this comment
		-- update shr_os_type for Name and Desc Updates 
		
		update shr_os_type
		set os_type_name = swtype.mdf_swt_concept_name,
		    description = swtype.mdf_swt_concept_desc  
        where os_type_id in (select os_type_id 
		                     from shr_ostype_mdfswtype 
							 where mdf_swt_concept_id = swtype.mdf_swt_concept_id
							 )
		and swtype.publishing_system = 'SPRIT';
          
		-- update shr_mdf_prod_has_swtype for swtype, and concept name
		update shr_mdf_prod_has_swtype
		set mdf_swt_concept_name = swtype.mdf_swt_concept_name,
		    swt_lifecycle = swtype.lifecycle  
        where mdf_swt_concept_id = swtype.mdf_swt_concept_id
		and   adm_flag = 'V';
		
		if SQL%NOTFOUND then		
 		   
 		   update shr_mdf_swtype_attr
		   set lifecycle = 'EOS'
		   where mdf_swt_concept_id = swtype.mdf_swt_concept_id
		   and is_leaf_node = 'Y';

			  
        end if;

     end loop;
	 			
     for product in 
	 
       (select *
        from   shr_mdf_products_attr s
        where  s.adm_flag = 'V') loop
				
		-- update shr_mdf_prod_has_swtype for product lifecycle, and concept name
		update shr_mdf_prod_has_swtype
		set mdf_concept_name = product.mdf_concept_name,
		    product_lifecycle = product.lifecycle  
        where mdf_concept_id = product.mdf_concept_id;
		
     end loop;
	 
	 		-- update shr_mdf_swtype_attr.MDF_SWT_PARENT_CONCEPT_NAME
     update shr_mdf_swtype_attr
	 set publishing_system = 'SPRIT-IOS'
	 where is_leaf_node = 'Y'
	 and   (mdf_swt_concept_name like 'IOS%' or mdf_swt_concept_name like 'CatOS%')
	 and (publishing_system = 'SPRIT' or publishing_system = 'SPRIT-IOS') ;
	 
	 out_flag := TRUE;
	 
EXCEPTION

    when OTHERS then
        v_now := TO_CHAR( SYSDATE, 'mm/dd/rrrr   hh24:mi:ss' );
        v_msg := substr(sqlerrm, 1, 200);
        log_mdf_refresh( v_proc_name, 'Terminated. ' || v_msg );
        dbms_output.put_line( v_proc_name || 'ERROR==>' || v_msg || v_now );
        raise;
	 						
END update_software_metadata; 			

PROCEDURE send_mail_to_swtype_submitter (
	    in_mdf_swt_name  in  varchar2,
        in_mdf_swt_desc  in  varchar2,
		in_submitted_by  in  varchar2)

IS

	v_proc_name               varchar2(100) := g_pkg_name || '.send_mail_to_swtype_submitter';
    v_now                     varchar2(100) := TO_CHAR( SYSDATE, 'mm/dd/rrrr hh24:mi:ss' );
    v_mail_to_email_addr_tab  email_addr_tab_type;
  
	v_mail_from_alias	        varchar2(50) := '"SHR-MDF-Refresh-Mailer"';
	v_mail_from_email_addr      varchar2(50) := 'aadvani@cisco.com';
	
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
                   'Please do not reply to this email. ' ||
                   g_newline;


    v_mail_body :=
        v_mail_body || g_newline ||
        'Recently you have requested a Software Type to be managed in SPRIT' ||
        g_newline ||
        'Software Type Name        : ' || in_mdf_swt_name || 
        g_newline ||
        'Software Type Description : ' || in_mdf_swt_desc ||
        g_newline ||
        'A case has been opened with Release Tools - SPRIT, a SPRIT team member will follow up to gather additional details for the software to be managed in SPRIT.' || 
        g_newline ||
        g_newline ||
        'SPRIT Team' || 
        g_newline;
	
        send_email(
	           g_env,
			   'aadvani', -- change this to 'in_submitted_by' variable.
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

END send_mail_to_swtype_submitter;


END SHR_MDF_SWT_REFRESH_PKG;
/
