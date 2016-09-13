DECLARE

v_osTypeId NUMBER;
v_admFlag  cspr_software_metadata.adm_flag%type;
v_errmsg VARCHAR2(4000);

CURSOR C1 IS
    select OS_TYPE_ID, ADM_FLAG
    from   cspr_software_metadata
    where  metadata_id = (select metadata_id 
                          from cspr_metadata 
                          where metadata_name = 'FREE_SW_PUBLISH_ALLOWED');
            
BEGIN
  FOR c1_rec IN C1 LOOP
    v_osTypeId := c1_rec.OS_TYPE_ID;
    v_admFlag := c1_rec.ADM_FLAG;
    -- insert ccats if the free_software is selected with the status adm_flag
    -- status
    BEGIN
    insert into cspr_software_metadata (software_metadata_id,
                                        os_type_id,
                                        metadata_id,
                                        is_bu_required,
                                        created_by,
                                        created_date,
                                        adm_userid,
                                        adm_timestamp,
                                        adm_flag,
                                        adm_comment,
                                        is_obsolete)
    values (cspr_software_metadata_seq.nextval,
            v_osTypeId,
            (select metadata_id
              from  cspr_metadata
              where metadata_name = 'CCATS'),
            'N',
            'spathala',
            sysdate,
            'spathala',
            sysdate,
            v_admFlag,
            'migration for Free SW',
            '');
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
     NULL;
    WHEN OTHERS THEN
     v_errmsg := SQLCODE||' cspr_software_metadata CCATS';
     
     RAISE_APPLICATION_ERROR(-20001, v_errmsg); 
    END;
  COMMIT;
    -- insert for product code if the free_software is selected with the status 
    -- adm_flag status
    BEGIN
    insert into cspr_software_metadata (software_metadata_id,
                                        os_type_id,
                                        metadata_id,
                                        is_bu_required,
                                        created_by,
                                        created_date,
                                        adm_userid,
                                        adm_timestamp,
                                        adm_flag,
                                        adm_comment,
                                        is_obsolete)
    values (cspr_software_metadata_seq.nextval,
            v_osTypeId,
            (select metadata_id
              from  cspr_metadata
              where metadata_name = 'PRODUCT_CODE'),
            'N',
            'spathala',
            sysdate,
            'spathala',
            sysdate,
            v_admFlag,
            'migration for Free SW',
            '');
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
     NULL;
    WHEN OTHERS THEN
     v_errmsg := SQLCODE||' cspr_software_metadata PRODUCT_CODE';
     
     RAISE_APPLICATION_ERROR(-20002, v_errmsg); 
    END;
  COMMIT;
    
  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('ERROR: CCATS_DATA_ANALYZE');
END;
/