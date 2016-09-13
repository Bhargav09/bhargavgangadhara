--Copyright (c) 2006 by Cisco Systems, Inc.
CREATE OR REPLACE VIEW VW_IMAGE_FEATURE_PRODUCT
AS SELECT 
   smr.major_release_number                                        release 
 , srn.z                                                           maintenance 
 , srn.p                                                           mrenumber 
 , srn.a                                                           ed_designator 
 , srn.o                                                           ed_renumber 
 --, smr.major_release_number||'('||srn.z||srn.p||')'||srn.a||srn.o  RELEASE_NUMBER 
 , release_number RELEASE_NUMBER 
 , stt.train_type                                                  train_type 
 , srt.release_type_name                                           release_type_name 
 , sds.deployment_status_name                                      status 
 , si.image_name                                                   image 
 , sip.individual_platform_name                                    platform 
 , spi.dram                                                        mindram 
 , spi.min_flash                                                   minflash 
 , sfsd.feature_set_desc                                           featuredesc 
 , sfsdr.feature_set_designator                                    feature_designator 
 , si.is_going_to_cco                                              cco 
 , si.CCO_POSTED_TIME                                              ccotime 
 , spg.pcode_group_name                                            platform_family 
 , si.IMAGE_SIZE_COMPRESSED                                        imagesize 
 , si.md5chksum                                                    md5chksum 
 , null                                                            build 
 , si.image_build_time                                             buildtime 
 , null                                                            mfgtime 
 , replace(replace(replace(smr.major_release_number,'.','') 
   ||'-'||srn.z||srn.p||decode(srn.a,'','','.' 
   ||srn.a||srn.o),'(','.'),')','')                                buildnum 
 , null                                                            netboot 
 , si.is_software_advisory                                         swadvise 
 , si.software_advisory_id                                         software_advisory_id 
 , si.is_deferred                                                  deferral 
 , si.deferral_id                                                  deferral_request_id 
 , sp.pcode_main                                                   pcode_sys 
 , sp.pcode_spare                                                  pcode_spr 
 , greatest( 
	spi.adm_timestamp, 
	si.adm_timestamp, 
	sp.adm_timestamp, 
	sfs.adm_timestamp, 
	sfsd.adm_timestamp, 
	sds.adm_timestamp, 
	srt.adm_timestamp, 
	stt.adm_timestamp 
   ) 												   	  		   adm_timestamp 
 ,os_type_name                                                    os_type
 ,cco_transaction_status                                           cco_transaction_status 
 ,cco_transaction_type                                               cco_transaction_type
 ,is_posted_to_cco                                                   is_posted_to_cco 
FROM	 shr_image                                        si 
     	,shr_platform_image                               spi 
      	,shr_image_feature_set                            sifs 
      	,shr_pcode                                        sp 
      	,shr_feature_set                                  sfs 
      	,shr_feature_set_desc                             sfsd 
      	,shr_feature_set_designator                       sfsdr 
      	,shr_release_pcode_group                          srpg 
      	,shr_release_number                               srn 
      	,shr_platform_pcode_group                         sppg 
      	,shr_individual_platform                          sip 
      	,shr_pcode_group                                  spg 
      	,shr_major_release                                smr 
      	,shr_deployment_status                            sds 
	    ,shr_release_type                                 srt 
	    ,shr_train_type                                   stt 
	    ,shr_os_type                                       os
		,cspr_image_posting_status                        cips
WHERE 
         si.release_number_id                           = srn.release_number_id 
AND      srn.major_release_id                           = smr.major_release_id 
AND      srn.deployment_status_id                       = sds.deployment_status_id 
AND      srn.release_type_id                            = srt.release_type_id 
AND      smr.train_type_id                              = stt.train_type_id 
AND      si.image_id                                    = spi.image_id
AND      si.image_id                                    = cips.image_id(+) 
AND      spi.individual_platform_id                     = sip.individual_platform_id 
AND      sip.individual_platform_id                     = sppg.individual_platform_id 
AND      sppg.pcode_group_id                            = spg.pcode_group_id 
AND      si.image_id                                    = sifs.image_id 
AND      sifs.feature_set_id                            = sfs.feature_set_id 
AND      sfs.feature_set_desc_id                        = sfsd.feature_set_desc_id 
AND      sfs.feature_set_designator_id                  = sfsdr.feature_set_designator_id(+) 
AND      sifs.image_feature_set_id                      = sp.image_feature_set_id 
AND      srpg.release_number_id                         = srn.release_number_id 
AND      srpg.pcode_group_id                            = spg.pcode_group_id 
AND      srpg.release_pcode_group_id                    = sp.release_pcode_group_id(+) 
AND      sifs.adm_flag                                  = 'V' 
AND      si.adm_flag                                    = 'V' 
AND      sfs.adm_flag                                   = 'V' 
AND      spi.adm_flag                                   = 'V' 
AND      si.is_in_image_list                            = 'Y' 
AND      spi.is_in_image_list                           = 'Y' 
AND      os.os_type_id = smr.os_type_id
