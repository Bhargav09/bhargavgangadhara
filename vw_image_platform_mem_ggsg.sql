CREATE OR REPLACE FORCE VIEW VW_IMAGE_PLATFORM_MEM_GGSG
AS
SELECT 
   -- Global Government Solution Group
   -- reuqested by Craig D. Williams 
   -- CASE HD4637074
   smr.major_release_number                                        release 
 , srn.z                                                           maintenance 
 , srn.p                                                           mrenumber 
 , srn.a                                                           ed_designator 
 , srn.o                                                           ed_renumber 
 --, smr.major_release_number||'('||srn.z||srn.p||')'||srn.a||srn.o  RELEASE_NUMBER 
 , release_number RELEASE_NUMBER 
 , si.image_name                                                   image 
 , sip.individual_platform_name                                    platform 
 , spi.dram                                                        mindram 
 , spi.min_flash                                                   minflash 
FROM	shr_image                                         si 
	,shr_platform_image                               spi 
      	,shr_release_number                               srn 
      	,shr_individual_platform                          sip 
      	,shr_major_release                                smr 
WHERE    si.release_number_id                           = srn.release_number_id 
AND      srn.major_release_id                           = smr.major_release_id 
AND      si.image_id                                    = spi.image_id 
AND      spi.individual_platform_id                     = sip.individual_platform_id 
AND      si.adm_flag                                    = 'V' 
AND      spi.adm_flag                                   = 'V' 
AND      si.is_in_image_list                            = 'Y' 
AND      spi.is_in_image_list                           = 'Y';

GRANT SELECT ON  VW_IMAGE_PLATFORM_MEM_GGSG TO SIIS_VIEW_USER;
