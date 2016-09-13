CREATE OR REPLACE FORCE VIEW VW_SPRIT_IMAGE_PIDS
(
   OS_TYPE_ID,
   OS_TYPE_NAME,
   RELEASE_NUMBER,
   MAJOR_RELEASE,
   MAINTENANCE_RELEASE,
   MAINTENANCE_RENUMBER,
   ED_DESIGNATOR,
   ED_RENUMBER,
   IMAGE_NAME,
   PRODUCT_CODE,
   MDF_CONCEPT_ID,
   MDF_CONCEPT_NAME,
   PRODUCT_DESCRIPTION,
   PRODUCT_MANAGER,
   RELEASE_OWNER,
   ERP_PRODUCT_FAMILY,
   IS_POSTED_TO_CCO,
   SOFTWARE_ADVISORY,
   SOFTWARE_ADVISORY_DOC_URL,
   DEFERRAL_ADVISORY,
   DEFERRAL_ADIVISORY_DOC_URL,
   ADM_FLAG,
   CREATED_DATE,
   LAST_UPDATED_DATE,
   CCO_FCS_DATE,
   IS_ORDERABLE      
)
AS

Select 
sot.OS_TYPE_ID                                               OS_TYPE_ID
,sot.OS_TYPE_NAME                                            OS_TYPE_NAME
,srn.RELEASE_NUMBER                                          RELEASE_NUMBER 
,smr.major_release_number                                    MAJOR_RELEASE
,srn.z                                                       MAINTENANCE_RELEASE
,srn.p                                                       MAINTENANCE_RENUMBER
,srn.a                                                       ED_DESIGNATOR
,srn.o                                                       ED_RENUMBER
,si.IMAGE_NAME                                               IMAGE_NAME
,sp.pcode_main                                               PRODUCT_CODE
,smpa.MDF_CONCEPT_ID                                         MDF_CONCEPT_ID
,smpa.MDF_CONCEPT_NAME                                       MDF_CONCEPT_NAME
,srpg.pcode_group_desc                                       PRODUCT_DESCRIPTION
,GET_PLATFORM_MANAGER_LIST(si.image_id)                      PRODUCT_MANAGER  
,GET_RELEASE_OWNERS(srn.release_number_id)                   RELEASE_OWNER
,sip.platform_product_family                                 ERP_PRODUCT_FAMILY  
--,si.IMAGE_TYPE    
,si.IS_POSTED_TO_CCO                                         IS_POSTED_TO_CCO
,si.is_SOFTWARE_ADVISORY                                     SOFTWARE_ADVISORY
,si.SOFTWARE_ADVISORY_URL                                    SOFTWARE_ADVISORY_DOC_URL
,si.is_deferred                                              DEFERRAL_ADVISORY
,si.deferral_advisory_url                                    DEFERRAL_ADIVISORY_DOC_URL
,sp.ADM_FLAG                                                 ADM_FLAG
,sp.CREATED_DATE                                             CREATED_DATE
,GREATEST (srn.adm_timestamp,
                      cips.adm_timestamp,
                      spi.adm_timestamp,
                      sipm.adm_timestamp,
                      sp.adm_timestamp
                      )                                     LAST_UPDATED_DATE          
,cips.CCO_POSTED_TIME                                       CCO_FCS_DATE        
,sp.pcode_main_orderable                                    IS_ORDERABLE    
FROM
shr_os_type                sot
,shr_major_release          smr
,shr_release_number         srn
,shr_image                   si
,cspr_image_posting_status  cips
,shr_platform_image           spi
,shr_individual_platform     sip
,SHR_INDIVIDUAL_PLATFORM_MDF  sipm 
,shr_mdf_products_attr      smpa
,shr_image_feature_set        sifs
,shr_release_pcode_group      srpg
,shr_pcode                   sp
WHERE
    sot.os_type_id=smr.os_type_id
and smr.major_release_id=srn.major_release_id
and srn.release_number_id=si.release_number_id
and si.image_id=cips.image_id
and si.image_id=spi.image_id
and SPI.INDIVIDUAL_PLATFORM_ID=SIP.INDIVIDUAL_PLATFORM_ID
and sip.individual_platform_id=SIPM.INDIVIDUAL_PLATFORM_ID
and SIPM.MDF_CONCEPT_ID=SMPA.MDF_CONCEPT_ID
and si.image_id=sifs.image_id
and si.release_number_id=srpg.release_number_id
and sifs.image_feature_set_id=SP.IMAGE_FEATURE_SET_ID
and SRPG.RELEASE_PCODE_GROUP_ID=SP.RELEASE_PCODE_GROUP_ID
and sot.adm_flag='V'
and smr.adm_flag='V'
and srn.adm_flag='V'
and si.adm_flag='V'
and cips.adm_flag='V'
and spi.adm_flag='V'
and sip.adm_flag='V'
and sipm.adm_flag='V'
and smpa.adm_flag='V'
and sifs.adm_flag='V'
and srpg.adm_flag='V'
and sp.adm_flag='V'
