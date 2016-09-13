CREATE OR REPLACE FORCE VIEW SHR_RDA.VW_IMAGE_FEATURE_PRODUCT_IOX
AS
select distinct smr.major_release_number                               release 
       -- CASE HD4637074
       -- Requested by Sathish Duraisamy
       -- Risk Analysis Tool (STS) / QDDTS (CBMS) Teams
       , srn.z                                                         maintenance 
       , srn.p                                                         mrenumber 
       , srn.a                                                         ed_designator 
       , srn.o                                                         ed_renumber 
       --, smr.major_release_number||'('||srn.z||srn.p||')'||srn.a||srn.o  RELEASE_NUMBER 
       , io.release_number                                             RELEASE_NUMBER 
       , stt.train_type                                                train_type 
       , srt.release_type_name                                         release_type_name 
       , sds.deployment_status_name                                    status 
       , ic.FILE_NAME                                                  image 
       , ic.PLATFORM                                                   platform 
       , ic.dram                                                       mindram 
       , ic.flash                                                      minflash 
       , ic.DESCRIPTION                                                featuredesc 
       , ic.CCO_POST_TIME                                              ccotime 
       , spg.pcode_group_name                                          platform_family 
       , ic.MD5CHKSUM                                                  md5chksum 
       , replace(replace(replace(smr.major_release_number,'.','') 
         ||'-'||srn.z||srn.p||decode(srn.a,'','','.' 
         ||srn.a||srn.o),'(','.'),')','')                              buildnum --???
       , io.PRODUCT_NAME                                               pcode_sys 
       , greatest( 
	       ic.adm_timestamp, 
	       io.adm_timestamp
         ) 												   	  		   adm_timestamp 
      , os_type_name 
from  iox_opus                                         io 
     ,iox_cco                                          ic
     ,shr_major_release                                smr
     ,shr_release_number                               srn
     ,shr_train_type                                   stt
     ,shr_release_type                                 srt
     ,shr_deployment_status                            sds 
     ,shr_platform_pcode_group                         sppg 
     ,shr_individual_platform                          sip 
     ,shr_pcode_group                                  spg 
     ,shr_os_type 				       os
where io.RELEASE_NUMBER_ID (+) = ic.RELEASE_NUMBER_ID
AND   io.FILE_NAME (+) = ic.FILE_NAME
AND   ic.RELEASE_NUMBER_ID = srn.RELEASE_NUMBER_ID
AND   srn.MAJOR_RELEASE_ID = smr.MAJOR_RELEASE_ID
AND   smr.train_type_id = stt.train_type_id(+)
AND   srn.release_type_id = srt.release_type_id
AND   srn.deployment_status_id = sds.deployment_status_id
AND   ic.PLATFORM = sip.INDIVIDUAL_PLATFORM_NAME
AND   sip.INDIVIDUAL_PLATFORM_ID = sppg.INDIVIDUAL_PLATFORM_ID
AND   sppg.PCODE_GROUP_ID = spg.PCODE_GROUP_ID
AND   smr.os_type_id = os.os_type_id;

GRANT SELECT ON  VW_IMAGE_FEATURE_PRODUCT_IOX TO SIIS_VIEW_USER;

