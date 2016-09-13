CREATE OR REPLACE FORCE VIEW SHR_RDA.VW_RELEASE_INFO
(
   OS_TYPE,
   RELEASE_NUMBER,
   ED_DESIGNATOR,
   STATUS,
   ADM_TIMESTAMP
)
AS
   SELECT                                                    /*+ FIRST_ROWS */
         os_type_name os_type,
            release_number release_number,
            srn.a ed_designator,
            sds.deployment_status_name status,
            GREATEST (srn.adm_timestamp,
                      sds.adm_timestamp,
                      srt.adm_timestamp)
               adm_timestamp
     FROM   shr_release_number srn,
            shr_major_release smr,
            shr_deployment_status sds,
            shr_release_type srt,
            shr_train_type stt,
            shr_os_type os
    WHERE       srn.major_release_id = smr.major_release_id
            AND srn.deployment_status_id = sds.deployment_status_id
            AND srn.release_type_id = srt.release_type_id
            AND smr.train_type_id = stt.train_type_id
            AND os.os_type_id = smr.os_type_id
            AND EXISTS
                  (SELECT   'X'
                     FROM   shr_image si
                    WHERE       si.release_number_id = srn.release_number_id
                            AND si.adm_flag = 'V'
                            AND si.is_in_image_list = 'Y');


DROP SYNONYM SRDA_STS.VW_RELEASE_INFO;

CREATE SYNONYM SRDA_STS.VW_RELEASE_INFO FOR SHR_RDA.VW_RELEASE_INFO;


GRANT SELECT ON SHR_RDA.VW_RELEASE_INFO TO SRDA_STS;



