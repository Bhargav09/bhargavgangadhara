--Copyright (c) 2006-2007 by Cisco Systems, Inc.
CREATE OR REPLACE PROCEDURE SPRIT.proc_product_certification
 (  p_image_id                IN cspr_certification.image_id%type
   ,p_mdf_concept_id          IN cspr_certification.mdf_concept_id%type
   ,p_certification_name      IN cspr_certification.certification_name%type
    --not required in case of Create,Delete but mandatory when it's Update.
   ,p_certification_name_old  IN cspr_certification.certification_name%type
   ,p_certification_url       IN cspr_certification.certification_url%type
   ,p_certification_url_old   IN cspr_certification.certification_url%type
   ,p_userid                  IN cspr_certification.adm_userid%type   --any valid cisco userid
   ,p_adm_comment             IN cspr_certification.adm_comment%type  --optional
   ,p_action                  IN  varchar2                            -- 'Create', 'Update','Delete'
   ,p_out_message             OUT VARCHAR2                            --'Success' or some error message
 ) IS

 --Declare Variables
    v_certification_id        cspr_certification.certification_id%type;
    v_image_id                cspr_certification.image_id%type;
    v_mdf_concept_id          cspr_certification.mdf_concept_id%type;
    v_certification_name      cspr_certification.certification_name%type;
    v_certification_name_old  cspr_certification.certification_name%type ;
    v_certification_url       cspr_certification.certification_url%type;
    v_certification_url_old   cspr_certification.certification_url%type;
    v_userid                  cspr_certification.adm_userid%type;
    v_adm_flag                cspr_certification.adm_flag%type;
    v_adm_comment             cspr_certification.adm_comment%type;
    v_action                  varchar2(6);
    v_auto_seq_id             number;

    NULL_PARAMETER           EXCEPTION;
    INVALID_ACTION           EXCEPTION;

 BEGIN
        --trim off spaces
    v_image_id                  := trim(p_image_id);
    v_mdf_concept_id            := trim(p_mdf_concept_id);
    v_certification_name        := trim(p_certification_name);
    v_certification_name_old    := trim(p_certification_name_old);
    v_certification_url         := trim(p_certification_url);
    v_certification_url_old     := trim(p_certification_url_old);
    v_userid                    := trim(p_userid);
    v_adm_comment               := trim(p_adm_comment);
    v_action                    := trim(p_action);

    p_out_message := 'Success';

   --DBMS_OUTPUT.PUT_LINE('Here 1');
    IF(v_action is NULL) THEN
       raise INVALID_ACTION;
    END IF;

   --DBMS_OUTPUT.PUT_LINE('Here 1');
    IF(v_action = 'Update') THEN
      IF(v_image_id is NULL OR  v_mdf_concept_id  is NULL
        OR v_certification_name is NULL OR  v_certification_name_old  is NULL
        OR v_certification_url is NULL  OR v_certification_url_old IS NULL OR  v_userid is NULL
        OR  v_action is NULL ) THEN
        raise NULL_PARAMETER;
      END IF;
    ELSIF(v_image_id is NULL OR  v_mdf_concept_id  is NULL
       OR v_certification_name is NULL
       OR v_certification_url is NULL  OR  v_userid is NULL
       OR  v_action is NULL ) THEN
  -- DBMS_OUTPUT.PUT_LINE('Here 2');
       raise NULL_PARAMETER;
  -- DBMS_OUTPUT.PUT_LINE('Here 3');
    END IF;


    BEGIN
       IF(v_action = 'Update') THEN
         UPDATE cspr_certification
         SET  certification_name= v_certification_name
             ,certification_url = v_certification_url
             ,adm_userid        = v_userid
             ,adm_comment       = nvl(v_adm_comment,'Updated by SPRIT-CVD API')
         WHERE
              image_id           = v_image_id
         AND  mdf_concept_id     = v_mdf_concept_id
         AND  certification_name = v_certification_name_old
         AND    certification_url = v_certification_url_old
         AND  adm_flag='V'
         ;
         IF(SQL%ROWCOUNT < 1) THEN
           p_out_message := 'Result: No valid record with adm_flag=V exitst to Update';
         END IF;
       ELSIF(v_action = 'Delete') THEN
         UPDATE cspr_certification
         SET  adm_flag          = 'D'
             ,adm_timestamp     = sysdate
             ,adm_userid        = v_userid
             ,adm_comment       = nvl(v_adm_comment,'Deleted by SPRIT-CVD API')
         WHERE
              image_id           = v_image_id
         AND  mdf_concept_id     = v_mdf_concept_id
         AND  certification_name = v_certification_name
         AND    certification_url  = v_certification_url
         AND  adm_flag='V'
         ;
         IF(SQL%ROWCOUNT < 1) THEN
           p_out_message := 'Result: No valid record with adm_flag=V exitst to Delete';
         END IF;
       ELSIF(v_action = 'Create') THEN
         BEGIN
           SELECT certification_id, adm_flag INTO v_certification_id, v_adm_flag
           FROM   cspr_certification
           WHERE
                  image_id           = v_image_id
           AND    mdf_concept_id     = v_mdf_concept_id
           AND    certification_name = v_certification_name
           AND    certification_url  = v_certification_url
           ;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                BEGIN
                  NULL;
                END;
         END; -- end of select block
         IF(v_certification_id > 0 and v_adm_flag = 'V') THEN
           p_out_message := 'No record creatd in SPRIT as Certification already exists';
         ELSIF(v_certification_id > 0 and v_adm_flag ='D') THEN
           UPDATE cspr_certification
           SET  adm_flag          = 'V'
               ,adm_timestamp     = sysdate
               ,adm_userid        = v_userid
               ,adm_comment       = nvl(v_adm_comment,'Created by SPRIT-CVD API')
           WHERE
                image_id           = v_image_id
           AND  mdf_concept_id     = v_mdf_concept_id
           AND  certification_name = v_certification_name
         AND    certification_url  = v_certification_url
           ;
         ELSE
           INSERT INTO cspr_certification
                      (certification_id
                       ,image_id
                       ,mdf_concept_id
                       ,certification_name
                       ,certification_url
                       ,created_by
                       ,created_date
                       ,adm_userid
                       ,adm_timestamp
                       ,adm_flag
                       ,adm_comment
                      )
                VALUES( cspr_certification_seq.nextval
                       ,v_image_id
                       ,v_mdf_concept_id
                       ,v_certification_name
                       ,v_certification_url
                       ,v_userid
                       ,sysdate   -- created date
                       ,v_userid  -- adm_userid
                       ,sysdate   -- adm_timestamp
                       ,'V'       -- adm_flag
                       ,nvl(v_adm_comment,'Created by SPRIT-CVD API')
                      );
         END IF; -- end of certification_id > 0 check
      ELSE
        raise INVALID_ACTION;
      END IF; --end of Update if

      BEGIN  --begining of auto post populate block

      Insert into auto_publish_release_queue
       (release_queue_id
       ,release_number_id
       ,release_number
       ,os_type_id
       ,transaction_id
       ,pred_transaction_id
       ,cco_transaction_type
       ,cco_transaction_status
       ,no_of_attempts
       ,next_posting_time
       ,error_message
       ,is_populated
       ,is_metadata_check_done
       ,created_by
       ,created_date
       ,adm_userid
       ,adm_timestamp
       ,adm_flag
       ,adm_comment 
       ,requested_source)
 Select auto_publish_release_queue_seq.nextval release_queue_id
       ,release_number_id
       ,release_number
       ,os_type_id
       ,transaction_id
       ,pred_transaction_id
       ,cco_transaction_type
       ,cco_transaction_status
       ,no_of_attempts
       ,next_posting_time
       ,error_message
       ,is_populated
       ,is_metadata_check_done
       ,created_by
       ,created_date
       ,adm_userid
       ,adm_timestamp
       ,adm_flag
       ,adm_comment
       ,requested_source
 FROM ( Select distinct
             srn.release_number_id                      release_number_id
             ,srn.release_number                         release_number
             ,smr.os_type_id                             os_type_id
             ,null                                   transaction_id
             ,null                                   pred_transaction_id
             ,'Repost'                               cco_transaction_type
             ,null                                   cco_transaction_status
             ,null                                   no_of_attempts
             ,null                                   next_posting_time
             ,null                                   error_message
             ,null                                   is_populated
             ,null                                   is_metadata_check_done
             ,cs.created_by                             created_by
             ,sysdate                                created_date
             ,cs.adm_userid                             adm_userid
             ,sysdate                                adm_timestamp
             ,'V'                                    adm_flag
             ,'Inserted through CVD API'             adm_comment
             ,'CVD'                                  requested_source
        from cspr_image_posting_status cips
              ,shr_image                  si
              ,shr_release_number        srn
              ,shr_major_release         smr
              ,cspr_certification         cs
       where cips.IMAGE_ID=si.IMAGE_ID
       and   si.image_id = cs.image_id
       and   si.RELEASE_NUMBER_ID = srn.RELEASE_NUMBER_ID
       and   smr.major_release_id=srn.major_release_id
       and   si.image_id          = v_image_id
       UNION
       Select distinct
             crn.release_number_id                      release_number_id
             ,crn.release_name                         release_number
             ,crn.os_type_id                             os_type_id
             ,null                                   transaction_id
             ,null                                   pred_transaction_id
             ,'Repost'                               cco_transaction_type
             ,null                                   cco_transaction_status
             ,null                                   no_of_attempts
             ,null                                   next_posting_time
             ,null                                   error_message
             ,null                                   is_populated
             ,null                                   is_metadata_check_done
             ,cs.created_by                             created_by
             ,sysdate                                created_date
             ,cs.adm_userid                             adm_userid
             ,sysdate                                adm_timestamp
             ,'V'                                    adm_flag
             ,'Inserted through CVD API'             adm_comment
             ,'CVD'                                  requested_source
       from cspr_image_posting_status            cips
            ,cspr_image                          ci
            ,cspr_release_number                crn
            ,cspr_certification                  cs
      where cips.IMAGE_ID        = ci.IMAGE_ID
      and   ci.image_id          = cs.image_id
      and   ci.RELEASE_NUMBER_ID = crn.RELEASE_NUMBER_ID
      and   ci.image_id          = v_image_id
    )
   ;

Insert into auto_publish_image_queue
 (release_queue_id
  ,  image_id
   , image_name
    ,created_by
    ,created_date
    ,adm_userid
    ,adm_timestamp
    ,adm_flag
    ,adm_comment
  )
Select
    auto_publish_release_queue_seq.currval release_queue_id
    ,image_id
    ,image_name
    ,created_by
    ,created_date
    ,adm_userid
    ,adm_timestamp
    ,adm_flag
    ,adm_comment
From( Select
           si.image_id                              image_id
           ,si.image_name                            image_name
             ,cs.created_by                             created_by
             ,sysdate                                created_date
             ,cs.adm_userid                             adm_userid
           ,sysdate                               adm_timestamp
           ,'V'                                   adm_flag
           ,'Inserted through CVD API'            adm_comment
       from cspr_image_posting_status cips
              ,shr_image                  si
              ,shr_release_number        srn
              ,shr_major_release         smr
              ,cspr_certification         cs
       where cips.IMAGE_ID=si.IMAGE_ID
       and   si.image_id = cs.image_id
       and   si.RELEASE_NUMBER_ID = srn.RELEASE_NUMBER_ID
       and   smr.major_release_id=srn.major_release_id
       and   si.image_id          = v_image_id
       UNION
       Select
           ci.image_id                               image_id
           ,ci.image_name                             image_name
             ,cs.created_by                             created_by
             ,sysdate                                created_date
             ,cs.adm_userid                             adm_userid
           ,sysdate                               adm_timestamp
           ,'V'                                   adm_flag
           ,'Inserted through CVD API'            adm_comment
      from cspr_image_posting_status            cips
            ,cspr_image                          ci
            ,cspr_release_number                crn
            ,cspr_certification                  cs
      where cips.IMAGE_ID        = ci.IMAGE_ID
      and   ci.image_id          = cs.image_id
      and   ci.RELEASE_NUMBER_ID = crn.RELEASE_NUMBER_ID
      and   ci.image_id          = v_image_id
    )
    ;

    END; --end of auto post populate block

       EXCEPTION
       WHEN OTHERS THEN
          BEGIN
            select auto_publish_release_queue_seq.currval into v_auto_seq_id from dual;
            p_out_message := v_action|| 'seq value is '||v_auto_seq_id||'  '||substr(sqlerrm,1,512);
          END;
    END;

         --DBMS_OUTPUT.PUT_LINE('OSTYPE ID '||v_os_type_id);
         --DBMS_OUTPUT.PUT_LINE('OSTYPE NAME '||v_os_type_name);
         --DBMS_OUTPUT.PUT_LINE('bu designator '||v_ed_bu_designator);
         --DBMS_OUTPUT.PUT_LINE('inside insert , Number of rows '||SQL%ROWCOUNT);

     --p_out_message := 'Result: '||p_out_message||' '||SQL%ROWCOUNT;

     commit;

     EXCEPTION
     WHEN NULL_PARAMETER THEN
      BEGIN
       p_out_message := 'Warning: NULL parameters found check parameters value! '
                        ||' Image_id   =' || v_image_id
                        ||' mdf_concept_id    =' || v_mdf_concept_id
                        ||' certification_name           =' || v_certification_name
                        ||' certification_name_old           =' || v_certification_name_old
                        ||' certification_url     =' || v_certification_url
                        ||' certification_url_old     =' || v_certification_url_old
                        ||' userid       =' || v_userid
                        ||' action               =' || v_action
                       ;
      END;

     WHEN INVALID_ACTION THEN
       BEGIN
         p_out_message := 'Error: Action is invalid,Action must be Create,Update or Delete';
       END;

     WHEN OTHERS THEN
      BEGIN
         p_out_message := substr(sqlerrm,1,512);
         --RAISE_APPLICATION_ERROR(-20001, p_out_message);
      END;

END;
/
