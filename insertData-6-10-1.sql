--Copyright (c) 2008 by Cisco Systems, Inc.
/*
        Current Release - Sprit 6.10.1 
        Last updated by - cchebrol
        Last updated date - Feb 13, 2008 
 */
 
 -- INSERT validation criteria to CSPR_METADATA
 
INSERT INTO CSPR_METADATA 
    VALUES (CSPR_METADATA_SEQ.NEXTVAL, 
            'CSPR_RELEASE_NOTES.SOURCE_LOCATION', 
            'CSPR_RELEASE_NOTES.SOURCE_LOCATION', 
            'CSPR_RELEASE_NOTES.SOURCE_LOCATION', 
            'CSPR_RELEASE_NOTES', 
            'SOURCE_LOCATION', 
            'CSPR_RELEASE_NOTES SOURCE_LOCATION VALIDATION', 
            ' FROM CSPR_RELEASE_NOTES, CSPR_IMAGE WHERE CSPR_RELEASE_NOTES.RELEASE_NUMBER_ID = CSPR_IMAGE.RELEASE_NUMBER_ID AND CSPR_RELEASE_NOTES.ADM_FLAG = ''V'' AND CSPR_IMAGE.ADM_FLAG = ''V'' AND CSPR_IMAGE.IMAGE_ID IN ', 
            'N', 
            'cchebrol', 
            sysdate, 
            'cchebrol', 
            sysdate, 
            'V', 
            'Manually Populated for DOCPUBLISH validation');
 
INSERT INTO CSPR_METADATA 
    VALUES (CSPR_METADATA_SEQ.NEXTVAL, 
            'CSPR_IMAGE_NOTES.SOURCE_LOCATION', 
            'CSPR_IMAGE_NOTES.SOURCE_LOCATION', 
            'CSPR_IMAGE_NOTES.SOURCE_LOCATION', 
            'CSPR_IMAGE_NOTES', 
            'SOURCE_LOCATION', 
            'CSPR_IMAGE_NOTES SOURCE_LOCATION VALIDATION', 
            ' FROM CSPR_IMAGE_NOTES, CSPR_IMAGE WHERE CSPR_IMAGE.IMAGE_ID = CSPR_IMAGE_NOTES.IMAGE_ID AND CSPR_IMAGE_NOTES.ADM_FLAG = ''V'' AND CSPR_IMAGE.ADM_FLAG = ''V'' AND CSPR_IMAGE.IMAGE_ID IN ', 
            'N', 
            'cchebrol', 
            sysdate, 
            'cchebrol', 
            sysdate, 
            'V', 
            'Manually Populated for DOCPUBLISH validation');

            
            
-- INSERT data to CSPR_SOFTWARE_METADATA

begin
 for os in (select distinct os_type_id from CSPR_SOFTWARE_METADATA where adm_flag = 'V') loop
     for mt in (select metadata_id from cspr_metadata 
                where metadata_name in ('CSPR_RELEASE_NOTES.SOURCE_LOCATION', 'CSPR_IMAGE_NOTES.SOURCE_LOCATION') 
                and adm_flag = 'V'
               ) loop  
        INSERT INTO CSPR_SOFTWARE_METADATA(
                 SOFTWARE_METADATA_ID,
                 OS_TYPE_ID,
                 METADATA_ID,
                 IS_BU_REQUIRED,
                 CREATED_BY,
                 CREATED_DATE,
                 ADM_USERID,
                 ADM_TIMESTAMP,
                 ADM_FLAG,
                 ADM_COMMENT
       )
      VALUES (
              CSPR_SOFTWARE_METADATA_SEQ.NEXTVAL,
              os.os_type_id ,
              mt.metadata_id,
              'N',
             'aselvara',
             sysdate,
             'aselvara',
             sysdate,
             'V',
             'WCM API - Source Location'
    );
   end loop;
 end loop;
 
end;
