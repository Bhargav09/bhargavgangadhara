     
CREATE OR REPLACE PROCEDURE SHR_RDA.PROC_SPRIT_UP_MM_COPY
/* 12/04/2003	  Sat Pande		Modified to insert into the Market Matrix tables (shr_release_pcode_group and shr_pcode) */
   ( p_RELEASE                IN    VARCHAR2
    ,p_MAINTENANCE            IN    VARCHAR2
    ,p_MRENUMBER              IN    VARCHAR2
    ,p_ED_DESIGNATOR          IN    VARCHAR2
    ,p_ED_RENUMBER            IN    VARCHAR2
    ,p_IMAGE                  IN    VARCHAR2
    ,p_OWNER                  IN    VARCHAR2
    ,p_src_RELEASE            IN    VARCHAR2
    ,p_src_MAINTENANCE        IN    VARCHAR2
    ,p_src_MRENUMBER          IN    VARCHAR2
    ,p_src_ED_DESIGNATOR      IN    VARCHAR2
    ,p_src_ED_RENUMBER        IN    VARCHAR2
    ,p_release_number_id      IN    NUMBER
    ,p_src_release_number_id  IN    NUMBER
    ,p_outmessage             OUT   VARCHAR2 )     IS

--Varibales declarations

    v_RELEASE                    shr_major_release.major_release_number%type;
    v_MAINTENANCE                shr_release_number.zabp%type;
    v_MRENUMBER                  shr_release_number.p%type;
    v_ED_DESIGNATOR              shr_release_number.a%type;
    v_ED_RENUMBER                shr_release_number.o%type;
    v_IMAGE                      shr_image.image_name%type;
    v_OWNER                      shr_image.adm_userid%type;
    v_src_RELEASE                shr_major_release.major_release_number%type;
    v_src_MAINTENANCE            shr_release_number.zabp%type;
    v_src_MRENUMBER              shr_release_number.p%type;
    v_src_ED_DESIGNATOR          shr_release_number.a%type;
    v_src_ED_RENUMBER            shr_release_number.o%type;

	v_src_release_number_id			 shr_release_number.release_number_id%type;
	v_tar_release_number_id			 shr_release_number.release_number_id%type;
	v_tar_release_type_id			 shr_release_number.release_type_id%type;
	v_image_feature_set_id		 	 shr_image_feature_set.image_feature_set_id%type;
	v_image_feature_set_id_null	 	 shr_image_feature_set.image_feature_set_id%type;
	v_image_feature_set_id_fk	 	 shr_image_feature_set.image_feature_set_id%type;

	v_image_type				 shr_image_type.image_type_name%type;

	v_src_pcode_main_price			 shr_pcode.pcode_main_price%type;
	v_src_pcode_spare_price			 shr_pcode.pcode_spare_price%type;
	v_src_pcode_prefix_main			 shr_pcode.pcode_prefix_main%type;
	v_src_pcode_prefix_spare		 shr_pcode.pcode_prefix_spare%type;
        v_src_main_orderable_comment             shr_pcode.pcode_main_orderable_comment%type;
        v_src_spare_orderable_comment            shr_pcode.pcode_spare_orderable_comment%type;
        v_src_main_orderable_instr_id            shr_pcode.pcode_main_orderable_instr_id%type;
        v_src_spare_orderable_instr_id           shr_pcode.pcode_spare_orderable_instr_id%type;
        v_src_parent_pcode_main            shr_pcode.parent_pcode_main%type;
        v_src_parent_pcode_spare           shr_pcode.parent_pcode_spare%type;


    v_image_id                        NUMBER;
    v_shr_image_feature_set           NUMBER;
    v_shr_image_feature_set_null      NUMBER;
	v_rel_pcode_grp_ct				  NUMBER;

	v_src_pcode_found 				  BOOLEAN;

	v_void_ifs_id number;
	v_void_rpg_id number;

    not_exist_exception          EXCEPTION;
    null_param_exception         EXCEPTION;
    not_insert_exception         EXCEPTION;
	no_data_for_src_rel			 EXCEPTION;
	no_data_for_tar_rel			 EXCEPTION;
	no_data_for_image_id		 EXCEPTION;
	not_rel_pcode_grp_ins_ex	 EXCEPTION;
	no_data_for_src_shr_pcode	 EXCEPTION;
	others_for_src_shr_pcode	 EXCEPTION;
	no_shr_pcode_ins_ex			 EXCEPTION;
	no_image_type				 EXCEPTION;

	v_pcode_adm_flag varchar2(1) :='V';
        --v_pcode_adm_flag := 'V';
    
    psedoexists NUMBER :=0;
    comboexists NUMBER :=0;


CURSOR c1 IS
SELECT i.image_id
      ,sifs.feature_set_id
	  ,sifs.image_feature_set_id
FROM
      shr_image_feature_set       sifs,
      shr_release_number          r,
      shr_major_release           m,
      shr_image                   i
WHERE m.major_release_id = r.major_release_id
AND   i.release_number_id=r.release_number_id
--AND   i.is_obsolete='N'
AND   i.adm_flag='V'
AND   sifs.adm_flag='V'
AND   r.release_number_id = p_src_release_number_id
/*AND   m.major_release_number||'('||r.zabp||')'||r.a||r.o =
              v_src_RELEASE||'('||v_src_MAINTENANCE||v_src_MRENUMBER||')'||v_src_ED_DESIGNATOR||v_src_ED_RENUMBER
*/
AND   i.image_name                                       =v_IMAGE
AND  sifs.image_id     =i.image_id;

CURSOR cRelPcodeGrp(cv_rel_number_id shr_release_number.release_number_id%type, cv_image_id shr_image.image_id%type) IS
SELECT DISTINCT rpg.release_pcode_group_id,
	   rpg.pcode_group_abbrev,
	   rpg.pcode_group_desc,
	   rpg.pcode_group_id
FROM
	   shr_release_pcode_group rpg,
	   shr_platform_image pi,
	   shr_platform_pcode_group ppg
WHERE pi.individual_platform_id = ppg.individual_platform_id
AND ppg.pcode_group_id = rpg.pcode_group_id
AND rpg.release_number_id = cv_rel_number_id
AND pi.image_id = cv_image_id
AND rpg.adm_flag='V'
AND pi.adm_flag='V'
AND ppg.adm_flag='V';

BEGIN

    v_RELEASE           :=trim(p_RELEASE);
    v_MAINTENANCE       :=trim(p_MAINTENANCE);
    v_MRENUMBER         :=trim(p_MRENUMBER);
    v_ED_DESIGNATOR     :=trim(p_ED_DESIGNATOR);
    v_ED_RENUMBER       :=trim(p_ED_RENUMBER);
    v_IMAGE             :=trim(p_IMAGE);
    v_OWNER             :=trim(p_OWNER);
    v_src_RELEASE       :=trim(p_src_RELEASE);
    v_src_MAINTENANCE   :=trim(p_src_MAINTENANCE);
    v_src_MRENUMBER     :=trim(p_src_MRENUMBER);
    v_src_ED_DESIGNATOR :=trim(p_src_ED_DESIGNATOR);
    v_src_ED_RENUMBER   :=trim(p_src_ED_RENUMBER);

    p_outmessage := 'Success'; --Initialize to success

    IF (v_RELEASE is NULL OR v_MAINTENANCE is NULL OR
        v_IMAGE is NULL OR v_OWNER is NULL OR v_src_RELEASE is NULL OR
        v_src_MAINTENANCE is NULL                                    )  THEN
       RAISE null_param_exception;
    END IF;

BEGIN
	 SELECT r.release_number_id INTO v_src_release_number_id
	 FROM
      	 shr_release_number          r,
      	 shr_major_release           m
	 WHERE m.major_release_id = r.major_release_id
         AND   r.release_number_id = p_src_release_number_id
	/* AND   m.major_release_number||'('||r.zabp||')'||r.a||r.o =
           v_src_RELEASE||'('||v_src_MAINTENANCE||v_src_MRENUMBER||')'||v_src_ED_DESIGNATOR||v_src_ED_RENUMBER
        */
        ;
EXCEPTION
	 WHEN NO_DATA_FOUND THEN RAISE no_data_for_src_rel;
END;

BEGIN
	 SELECT r.release_number_id,r.release_type_id INTO v_tar_release_number_id,v_tar_release_type_id
	 FROM
      	 shr_release_number          r,
      	 shr_major_release           m
	 WHERE m.major_release_id = r.major_release_id
         AND   r.release_number_id = p_release_number_id
	 /*AND   m.major_release_number||'('||r.zabp||')'||r.a||r.o =
           v_RELEASE||'('||v_MAINTENANCE||v_MRENUMBER||')'||v_ED_DESIGNATOR||v_ED_RENUMBER
         */
         ;
EXCEPTION
	 WHEN NO_DATA_FOUND THEN RAISE no_data_for_tar_rel;
END;

BEGIN
	 SELECT DISTINCT i.image_id, t.image_type_name INTO v_image_id,v_image_type
	 FROM
      	 shr_image			  	   	 i,
		 shr_release_number          r,
      	 shr_major_release           m,
      	 shr_image_type				 t
	 WHERE m.major_release_id = r.major_release_id
	 AND   i.release_number_id=r.release_number_id
	 AND   i.image_type_id = t.image_type_id
	 AND   i.adm_flag='V'
         AND   r.release_number_id = p_release_number_id
	 /*AND   m.major_release_number||'('||r.zabp||')'||r.a||r.o =
                   v_RELEASE||'('||v_MAINTENANCE||v_MRENUMBER||')'||v_ED_DESIGNATOR||v_ED_RENUMBER
         */
	 AND   i.image_name = p_image;
EXCEPTION
	 WHEN NO_DATA_FOUND THEN RAISE no_image_type;
END;

/* Needed to insert rows into shr_release_pcode_group which is at the Release level */
/* Insert records into shr_release_pcode_group only if image type is 'I' */

IF(v_image_type = 'I') THEN

  	 FOR cRec in cRelPcodeGrp(v_src_release_number_id,v_image_id) LOOP

    	 BEGIN
           	 SELECT count(*) into v_rel_pcode_grp_ct
           	 FROM
           	 	 shr_release_pcode_group
           	 WHERE release_number_id = v_tar_release_number_id
    		 AND pcode_group_id = cRec.pcode_group_id;
            EXCEPTION
           	 WHEN NO_DATA_FOUND THEN NULL;
     	 END;

		IF(v_rel_pcode_grp_ct > 0) THEN

      		 UPDATE shr_release_pcode_group
        	 SET adm_flag = 'V',
        	 	 adm_comment = 'Updated by UP_MM copy',
        		 adm_timestamp = sysdate,
        		 adm_userid = p_owner
        	 WHERE release_number_id = v_tar_release_number_id
			 AND pcode_group_id = cRec.pcode_group_id;

		ELSE

  	 	 INSERT INTO shr_release_pcode_group
  		 (release_pcode_group_id,
   		  release_number_id,
   		  pcode_group_id,
   		  pcode_group_abbrev,
   		  pcode_group_desc,
   		  adm_timestamp,
   		  adm_userid,
   		  adm_flag,
   		  adm_comment,
   		  created_by,
   		  created_date)
  		 VALUES
  		 (shr_release_pcode_group_seq.nextval,
  		  v_tar_release_number_id,
  		  cRec.pcode_group_id,
  		  cRec.pcode_group_abbrev,
  		  cRec.pcode_group_desc,
  		  sysdate,
  		  p_owner,
  		  'V',
  		  'Market Matrix record created',
  		  p_owner,
  		  sysdate);

	   END IF;

       IF(SQL%ROWCOUNT < 1) THEN
              RAISE not_rel_pcode_grp_ins_ex;
       END IF;

  	 END LOOP;

END IF;

/* The code below has been commented out since v_image_id is now populated above - Sat Pande */

/* BEGIN
	 SELECT i.image_id INTO v_image_id
	 FROM
      	 shr_release_number          r,
      	 shr_major_release           m,
      	 shr_image                   i
	 WHERE m.major_release_id = r.major_release_id
	 AND   i.release_number_id=r.release_number_id
	 --AND   i.is_obsolete='N'
	 AND   i.adm_flag='V'
         AND   r.release_number_id = p_release_number_id
	 --AND   m.major_release_number||'('||r.zabp||')'||r.a||r.o =
         --  v_RELEASE||'('||v_MAINTENANCE||v_MRENUMBER||')'||v_ED_DESIGNATOR||v_ED_RENUMBER

	 AND   i.image_name                                       = v_IMAGE;
EXCEPTION
	 WHEN NO_DATA_FOUND THEN RAISE no_data_for_image_id;
END;*/


 FOR c2 in c1 LOOP
  BEGIN

        BEGIN
         SELECT COUNT(*),image_feature_set_id INTO v_shr_image_feature_set, v_image_feature_set_id
         FROM SHR_IMAGE_FEATURE_SET
         WHERE image_id=v_image_id
         AND feature_set_id=c2.feature_set_id
		 GROUP BY image_feature_set_id;

         EXCEPTION
          WHEN NO_DATA_FOUND THEN
           BEGIN
            NULL;
           END;
        END;

        BEGIN
         SELECT COUNT(*),image_feature_set_id  INTO v_shr_image_feature_set_null, v_image_feature_set_id_null
         FROM SHR_IMAGE_FEATURE_SET
         WHERE image_id=v_image_id
         AND feature_set_id is NULL
		 GROUP BY image_feature_set_id;

         EXCEPTION
          WHEN NO_DATA_FOUND THEN
           BEGIN
            NULL;
           END;
        END;

		IF(v_shr_image_feature_set IS NULL) THEN
			 v_shr_image_feature_set := 0;
		END IF;

		IF(v_shr_image_feature_set_null IS NULL) THEN
			 v_shr_image_feature_set_null := 0;
		END IF;

  IF(v_shr_image_feature_set > 0 AND v_shr_image_feature_set_null > 0) THEN
         UPDATE SHR_IMAGE_FEATURE_SET
         SET adm_flag='V',
             adm_comment='Updated by UP_MM copy',
		 	 adm_timestamp = sysdate,
		 	 adm_userid = p_owner
         WHERE image_id=v_image_id
         AND feature_set_id=c2.feature_set_id;

         DELETE SHR_IMAGE_FEATURE_SET
         WHERE image_id=v_image_id
         AND feature_set_id is NULL;

		 v_image_feature_set_id_fk := v_image_feature_set_id;

  ELSIF(v_shr_image_feature_set > 0 AND v_shr_image_feature_set_null <= 0) THEN
         UPDATE SHR_IMAGE_FEATURE_SET
         SET adm_flag='V',
             adm_comment='Updated by UP_MM copy',
		 	 adm_timestamp = sysdate,
		 	 adm_userid = p_owner
         WHERE image_id=v_image_id
         AND feature_set_id=c2.feature_set_id;

		 v_image_feature_set_id_fk := v_image_feature_set_id;

  ELSIF(v_shr_image_feature_set <= 0 AND v_shr_image_feature_set_null > 0) THEN
         UPDATE SHR_IMAGE_FEATURE_SET
         SET adm_flag='V',
             adm_comment='Updated by UP_MM copy',
		 	 adm_timestamp = sysdate,
		 	 adm_userid = p_owner,
             feature_set_id=c2.feature_set_id
         WHERE image_id=v_image_id
         AND feature_set_id is NULL;

		 v_image_feature_set_id_fk := v_image_feature_set_id_null;

  ELSE

      INSERT INTO shr_image_feature_set
                 (image_feature_set_id
                 ,image_id
                 ,feature_set_id
                 ,adm_timestamp
                 ,adm_userid
                 ,adm_flag
                 ,adm_comment
                )
      VALUES    (
                 shr_image_feature_set_seq.nextval
                 ,v_image_id
                 ,c2.feature_set_id
                 ,sysdate
                 ,v_OWNER
                 ,'V'
                 ,'Upgrade Planner record created'
                );

      IF(SQL%ROWCOUNT < 1) THEN
        --DBMS_OUTPUT.PUT_LINE('Number of rows update is'|| SQL%ROWCOUNT);
          RAISE not_insert_exception;
      END IF;

	  SELECT shr_image_feature_set_seq.currval INTO v_image_feature_set_id_fk FROM dual;

  END IF;

---***begining of individual pseudo and combo image copy
BEGIN

FOR rec_psc IN ( SELECT 
                image_id
            ,  image_prefix_id
            ,  feature_set_name_id
            ,  runs_comp_extn_id
            ,  release_number_id
            ,  image_type_id
            ,  audit_image_id
            ,  image_name
            ,  is_in_image_list
            ,  is_built_for
            ,  is_arf_devtest_ok
            ,  is_netbooted
            ,  is_going_to_cco
            ,  is_going_to_mfg
            ,  is_cco_orderable
            ,  is_mfg_orderable
            ,  is_deferred
            ,  deferral_id
            ,  is_software_advisory
            ,  software_advisory_id
            ,  is_obsolete
            ,  on_release_archive_date
            ,  on_tftpboot_date
            ,  adm_timestamp
            ,  adm_userid
            ,  adm_flag
            ,  adm_comment
            ,  created_by
            ,  created_date
            ,  is_image_size_passed
            ,  is_posted_to_cco
            ,  cco_posted_time
            ,  image_size_compressed
            ,  image_size_uncompressed
            ,  md5chksum
            ,  cco_posted_by
            ,  is_delayed
            ,  image_build_time
            ,  cdc_access_level_id
            ,  full_image_name
            ,  ios_ion_type
            ,  mdf_swt_concept_id
            ,  image_posting_type_id
            ,  parent_image_id
            ,  is_licensed
            ,  software_advisory_url
            ,  deferral_advisory_url
            FROM shr_image
            WHERE parent_image_id IN(SELECT image_id FROM shr_image
                                     WHERE image_name=v_image
                                     AND release_number_id=p_src_release_number_id
                                     AND adm_flag='V'
                                    )
            AND adm_flag='V'                     
            )
  LOOP

    psedoexists:=0;

    SELECT COUNT(*) INTO psedoexists FROM shr_image
    WHERE image_name=rec_psc.image_name
    AND release_number_id=p_release_number_id;


  IF(psedoexists >0) THEN
     UPDATE shr_image SET 
           image_prefix_id=rec_psc.image_prefix_id
        ,  feature_set_name_id=rec_psc.feature_set_name_id
        ,  runs_comp_extn_id=rec_psc.runs_comp_extn_id
        --,  release_number_id
        ,  image_type_id=rec_psc.image_type_id
        --,  audit_image_id=
        --,  image_name=
        ,  is_in_image_list=rec_psc.is_in_image_list
        ,  is_built_for=rec_psc.is_built_for
        --,  is_arf_devtest_ok=
        --,  is_netbooted=
        ,  is_going_to_cco=rec_psc.is_going_to_cco
        ,  is_going_to_mfg=rec_psc.is_going_to_mfg
        --,  is_cco_orderable=
        --,  is_mfg_orderable=
        --,  is_deferred=
        --,  deferral_id=
        --,  is_software_advisory=
        --,  software_advisory_id=
        --,  is_obsolete=
        --,  on_release_archive_date=
        --,  on_tftpboot_date=
        ,  adm_timestamp=sysdate
        ,  adm_userid=p_owner
        ,  adm_flag=rec_psc.adm_flag
        ,  adm_comment='Resurrected through Image List Copy'
        ,  created_by=p_owner
        ,  created_date=sysdate
        --,  is_image_size_passed=
        --,  is_posted_to_cco=
        --,  cco_posted_time=
        --,  image_size_compressed=
        --,  image_size_uncompressed=
        --,  md5chksum=
        --,  cco_posted_by=
        --,  is_delayed=
        --,  image_build_time=
        ,  cdc_access_level_id=rec_psc.cdc_access_level_id
        --,  full_image_name=
        ,  ios_ion_type=rec_psc.ios_ion_type
        ,  mdf_swt_concept_id=rec_psc.mdf_swt_concept_id
        ,  image_posting_type_id=rec_psc.image_posting_type_id
        ,  parent_image_id=(SELECT image_id FROM shr_image WHERE release_number_id=p_release_number_id AND image_name=v_image)
        ,  is_licensed=rec_psc.is_licensed
        --,  software_advisory_url=
        --,  deferral_advisory_url=
        WHERE 
             release_number_id=p_release_number_id
        AND  image_name=rec_psc.image_name;
     ELSE
       INSERT INTO shr_image
            (image_id
         ,   image_prefix_id
         ,  feature_set_name_id
         ,  runs_comp_extn_id
         ,  release_number_id
         ,  image_type_id
       --,  audit_image_id=
         ,  image_name
         ,  is_in_image_list
         ,  is_built_for
       --,  is_arf_devtest_ok=
       --,  is_netbooted=
         ,  is_going_to_cco
         ,  is_going_to_mfg
       --,  is_cco_orderable=
       --,  is_mfg_orderable=
       --,  is_deferred=
       --,  deferral_id=
       --,  is_software_advisory=
       --,  software_advisory_id=
       --,  is_obsolete=
       --,  on_release_archive_date=
       --,  on_tftpboot_date=
         ,  adm_timestamp
         ,  adm_userid
         ,  adm_flag
         ,  adm_comment
         ,  created_by
         ,  created_date
       --,  is_image_size_passed=
       --,  is_posted_to_cco=
       --,  cco_posted_time=
       --,  image_size_compressed=
       --,  image_size_uncompressed=
       --,  md5chksum=
       --,  cco_posted_by=
       --,  is_delayed=
       --,  image_build_time=
         ,  cdc_access_level_id
       --,  full_image_name=
         ,  ios_ion_type
         ,  mdf_swt_concept_id
         ,  image_posting_type_id
         ,  parent_image_id
         ,  is_licensed
       --,  software_advisory_url=
       --,  deferral_advisory_url=
       )
VALUES(
            shr_image_seq.nextval
         ,  rec_psc.image_prefix_id
         ,  rec_psc.feature_set_name_id
         ,  rec_psc.runs_comp_extn_id
         ,  p_release_number_id
         ,  rec_psc.image_type_id
       --,  audit_image_id
         ,  rec_psc.image_name
         ,  rec_psc.is_in_image_list
         ,  rec_psc.is_built_for
       --,  is_arf_devtest_ok=
       --,  is_netbooted
         ,  rec_psc.is_going_to_cco
         ,  rec_psc.is_going_to_mfg
       --,  is_cco_orderable
       --,  is_mfg_orderable=
       --,  is_deferred=
       --,  deferral_id=
       --,  is_software_advisory=
       --,  software_advisory_id=
       --,  is_obsolete=
       --,  on_release_archive_date=
       --,  on_tftpboot_date=
         ,  sysdate
         ,  p_owner
         ,  rec_psc.adm_flag
         ,  'Copied through Image List Copy'
         ,  p_owner
         ,  sysdate
       --,  is_image_size_passed=
       --,  is_posted_to_cco=
       --,  cco_posted_time=
       --,  image_size_compressed=
       --,  image_size_uncompressed=
       --,  md5chksum=
       --,  cco_posted_by=
       --,  is_delayed=
       --,  image_build_time=
         ,  rec_psc.cdc_access_level_id
       --,  full_image_name=
         ,  rec_psc.ios_ion_type
         ,  rec_psc.mdf_swt_concept_id
         ,  rec_psc.image_posting_type_id
         ,  (select image_id from shr_image where release_number_id=p_release_number_id and image_name=v_image)
         ,  rec_psc.is_licensed
       --,  software_advisory_url=
       --,  deferral_advisory_url=
      );
   END IF;
     
      FOR rec_combo IN(SELECT si2.image_id combo_pseudo_image_id
                            , si1.image_id INDIVIDUAL_PSEUDO_IMAGE_ID
                       FROM shr_image si1
                           , shr_image si2
                       WHERE (si1.image_name,si2.image_name) IN (
                                                   SELECT si1.image_name INDIVIDUAL_PSEUDO_IMAGE
                                                        , si2.image_name combo_pseudo_image
                                                   FROM shr_combo_pseudo_img_fs_map m
                                                      , shr_image si1
                                                      , shr_image si2
                                                   WHERE m.adm_flag = 'V'
                                                   AND si1.adm_flag = 'V'
                                                   AND si2.adm_flag = 'V'
                                                   AND si1.image_id = m.INDIVIDUAL_PSEUDO_IMAGE_ID
                                                   AND si2.image_id = m.COMBO_PSEUDO_IMAGE_ID
                                                   AND si1.release_number_id = si2.release_number_id
                                                   AND si1.release_number_id = p_src_release_number_id
                                                   AND si2.image_id=rec_psc.image_id
                                                   --and si2.image_id=1490578
                                               )
                        AND si1.release_number_id = si2.release_number_id
                        AND si1.release_number_id = p_release_number_id
                      )
      LOOP 
  
         comboexists :=0;
    
         SELECT COUNT(*) INTO comboexists 
         FROM shr_combo_pseudo_img_fs_map
         WHERE combo_pseudo_image_id      = rec_combo.combo_pseudo_image_id
         AND   INDIVIDUAL_PSEUDO_IMAGE_ID = rec_combo.INDIVIDUAL_PSEUDO_IMAGE_ID;

         IF (comboexists>0) THEN
             UPDATE  shr_combo_pseudo_img_fs_map SET
              --COMBO_PSEUDO_IMG_FS_MAP_ID
              --,COMBO_PSEUDO_IMAGE_ID       =rec_combo.COMBO_PSEUDO_IMAGE_ID
              --,INDIVIDUAL_PSEUDO_IMAGE_ID  =rec_combo.INDIVIDUAL_PSEUDO_IMAGE_ID
               ADM_TIMESTAMP               =sysdate
              ,ADM_USERID                  =p_owner
              ,ADM_FLAG                    ='V'
              ,ADM_COMMENT                 ='Resurrected through Image List Copy'
              ,CREATED_BY                  =p_owner
              ,CREATED_DATE                =sysdate
            WHERE combo_pseudo_image_id      = rec_combo.combo_pseudo_image_id
            AND   INDIVIDUAL_PSEUDO_IMAGE_ID = rec_combo.INDIVIDUAL_PSEUDO_IMAGE_ID;
        ELSE
            INSERT INTO  shr_combo_pseudo_img_fs_map
                         (COMBO_PSEUDO_IMG_FS_MAP_ID
                          ,COMBO_PSEUDO_IMAGE_ID
                          ,INDIVIDUAL_PSEUDO_IMAGE_ID
                          ,ADM_TIMESTAMP
                          ,ADM_USERID
                          ,ADM_FLAG
                          ,ADM_COMMENT
                          ,CREATED_BY
                          ,CREATED_DATE
                         )
            VALUES
                         (COMBO_PSEUDO_IMG_FS_MAP_SEQ.nextval
                          ,rec_combo.COMBO_PSEUDO_IMAGE_ID
                          ,rec_combo.INDIVIDUAL_PSEUDO_IMAGE_ID
                          ,sysdate
                          ,p_owner
                          ,'V'
                          ,'Resurrected through Image List Copy'
                          ,p_owner
                          ,sysdate
                        );
         END IF;
     END LOOP;
 END LOOP;
 
END;  
---***end  of individual pseudo and combo image copy


/* Insert records into shr_pcode only if image type is 'I'*/

  IF(v_image_type = 'I') THEN /* Image Type 'I' */

          FOR cRec in cRelPcodeGrp(v_tar_release_number_id,v_image_id) LOOP /* Market Matrix */

		    v_void_rpg_id := cRec.release_pcode_group_id;
        	BEGIN
           	   SELECT count(*) into v_rel_pcode_grp_ct
           	   FROM
           	 	 shr_pcode
           	   WHERE image_feature_set_id = v_image_feature_set_id_fk
        	   AND release_pcode_group_id = cRec.release_pcode_group_id;
           	EXCEPTION
           	   WHEN NO_DATA_FOUND THEN NULL;
            END;

        	IF(v_rel_pcode_grp_ct > 0 ) THEN
            -- p_outmessage :='v_image_feature_set_id = '||v_image_feature_set_id || ' v_pcode_adm_flag = '||v_pcode_adm_flag ||' imageid = ' ||v_image_id;

        	   UPDATE shr_pcode
        	   	 SET adm_flag = 'V',
        	 	 adm_comment = 'Updated by UP_MM copy',
        		 adm_timestamp = sysdate,
        		 adm_userid = p_owner
        	   WHERE image_feature_set_id = v_image_feature_set_id_fk
        	   AND release_pcode_group_id = cRec.release_pcode_group_id;

        	ELSE

        	   BEGIN
                          SELECT DISTINCT pcode_main_price
                                        , pcode_spare_price
                                        , pcode_prefix_main
                                        , pcode_prefix_spare
                                        , pcode_main_orderable_comment
                                        , pcode_spare_orderable_comment
                                        , pcode_main_orderable_instr_id
                                        , pcode_spare_orderable_instr_id
                                        , pcode_main
                                        , pcode_spare
                          INTO v_src_pcode_main_price
                             , v_src_pcode_spare_price
                             , v_src_pcode_prefix_main
                             , v_src_pcode_prefix_spare
                             , v_src_main_orderable_comment
                             , v_src_spare_orderable_comment
                             , v_src_main_orderable_instr_id
                             , v_src_spare_orderable_instr_id
                            , v_src_parent_pcode_main
                            , v_src_parent_pcode_spare
                          FROM shr_pcode
        		  WHERE image_feature_set_id = c2.image_feature_set_id
        		  AND release_pcode_group_id =
        		  	  (SELECT release_pcode_group_id FROM shr_release_pcode_group
        			   WHERE release_number_id = v_src_release_number_id
        			   AND pcode_group_id = cRec.pcode_group_id)
                          AND adm_flag='V';
                	  v_src_pcode_found := TRUE;
        	   EXCEPTION
        	   	  WHEN NO_DATA_FOUND THEN v_src_pcode_found := FALSE;
        		  WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(c2.image_feature_set_id || ',' || cRec.pcode_group_id || ',' || v_src_release_number_id);RAISE others_for_src_shr_pcode;
        	   END;

        	   IF (v_src_pcode_found = TRUE ) THEN

                  	   INSERT INTO shr_pcode
                  	   (pcode_id,
                   	    image_feature_set_id,
                   		release_pcode_group_id,
                   		pcode_prefix_main,
                   		pcode_prefix_spare,
                   		pcode_main,
                   		pcode_spare,
                   		pcode_main_price,
                   		pcode_spare_price,
                   		pcode_main_price_source,
                   		pcode_spare_price_source,
                   		adm_timestamp,
                   		adm_userid,
                   		adm_flag,
                   		adm_comment,
                   		created_by,
                   		created_date,
                                pcode_main_orderable_comment,
                                pcode_spare_orderable_comment,
                                pcode_main_orderable_instr_id,
                                pcode_spare_orderable_instr_id,
                                parent_pcode_main,
                                parent_pcode_spare)
                  	   VALUES
                  	   (shr_pcode_seq.nextval,
                  	    v_image_feature_set_id_fk,
                  		cRec.release_pcode_group_id,
                  		v_src_pcode_prefix_main,
                  		v_src_pcode_prefix_spare,
                  		NULL,
                  		NULL,
                  		v_src_pcode_main_price,
                  		v_src_pcode_spare_price,
                  		'SPRIT',
                  		'SPRIT',
                  		sysdate,
                  		p_owner,
                  		'V',
                  		'Market Matrix record created',
                  		p_owner,
                  		sysdate,
                                v_src_main_orderable_comment,
                                v_src_spare_orderable_comment,
                                v_src_main_orderable_instr_id,
                                v_src_spare_orderable_instr_id,
                                v_src_parent_pcode_main,
                                v_src_parent_pcode_spare
                                );

                  		IF(SQL%ROWCOUNT < 1) THEN
                            RAISE no_shr_pcode_ins_ex	;
                        END IF;

        		END IF;

        	END IF;

          END LOOP; /* Market Matrix */

  END IF; /* Image Type 'I' */

 END;
 END LOOP;

     EXCEPTION

     WHEN null_param_exception THEN
     BEGIN
         p_outmessage := 'Warning: NULL parameters found check parameters value! '
                          ||' Release             =' ||v_RELEASE
                          ||' Maintenance         =' ||v_MAINTENANCE
                          ||' Mrenumber           =' ||v_MRENUMBER
                          ||' Ed_designator       =' ||v_ED_DESIGNATOR
                          ||' Ed_Renumber         =' ||v_ED_RENUMBER
                          ||' Image               =' ||v_IMAGE
                          ||' SRC_Release         =' ||v_src_RELEASE
                          ||' SRC_Maintenance     =' ||v_src_MAINTENANCE
                          ||' SRC_Mrenumber       =' ||v_src_MRENUMBER
                          ||' SRC_Ed_designator   =' ||v_src_ED_DESIGNATOR
                          ||' SRC_Ed_Renumber     =' ||v_src_ED_RENUMBER
                          ||' Owner               =' ||v_OWNER
                          ||' ParentPcodeMain     =' ||v_src_parent_pcode_main
                          ||' ParentPcodeSpare    =' ||v_src_parent_pcode_spare
                         ;
     END;

     WHEN not_insert_exception THEN
     BEGIN
       p_outmessage := 'No Upgrade plannner records have been inserted in shr_image_feature_set';
       null;
     END;

	 WHEN no_data_for_src_rel THEN
	 BEGIN
       p_outmessage := 'The source Release: ' || v_src_RELEASE || ' does not exist';
	 END;

	 WHEN no_data_for_tar_rel THEN
	 BEGIN
       p_outmessage := 'The target Release: ' || v_RELEASE || ' does not exist';
	 END;

	 WHEN no_data_for_image_id THEN
	 BEGIN
       p_outmessage := 'No Image Id found for: ' || v_RELEASE||'('||v_MAINTENANCE||v_MRENUMBER||')'||v_ED_DESIGNATOR||v_ED_RENUMBER || ' Image Name:' || v_image;
	 END;

	 WHEN not_rel_pcode_grp_ins_ex THEN
	 BEGIN
       p_outmessage := 'No Market Matrix records have been inserted into shr_release_pcode_group for target Release: ' || v_RELEASE || ' ' || substr(sqlerrm,1,512);
	 END;

	 WHEN no_data_for_src_shr_pcode THEN
	 BEGIN
	   p_outmessage := 'No data found for the source shr_pcode table: ' || v_src_release_number_id;
	 END;

	 WHEN others_for_src_shr_pcode THEN
	 BEGIN
	   p_outmessage := 'Others error for the source shr_pcode table: ' || v_src_release_number_id || ' ' || substr(sqlerrm,1,512);
	 END;

	 WHEN no_shr_pcode_ins_ex THEN
	 BEGIN
	   p_outmessage := 'Insert error shr_pcode table: ' || v_src_release_number_id || ' ' || substr(sqlerrm,1,512);
	 END;

	 WHEN no_image_type THEN
	 BEGIN
	   p_outmessage := 'Image Type record not found: ' || p_image;
	 END;

     WHEN OTHERS THEN
     BEGIN
         p_outmessage := 'OTHERS BLOCK '||substr(sqlerrm,1,512) || '  '||' image is '||p_image || v_image_feature_set_id_fk || ', ' || v_void_rpg_id ;
         --RAISE_APPLICATION_ERROR(-20001, p_outmessage);
     END;
END;
