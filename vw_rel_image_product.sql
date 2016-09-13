--Copyright (c) 2004-2005 by Cisco Systems, Inc.
CREATE OR REPLACE VIEW VW_REL_IMAGE_PRODUCT ( RELEASE, 
RELEASE_NUMBER, IMAGE, PCODE_SYS, PCODE_SPR, 
PCODE_MAIN_PRICE, PCODE_SPARE_PRICE ) AS SELECT /*+ RULE */
   smr.major_release_number                                        release 
 , smr.major_release_number||'('||srn.z||srn.p||')'||srn.a||srn.o  RELEASE_NUMBER 
 , si.image_name                                                   image 
 , sp.pcode_main                                                   pcode_sys 
 , sp.pcode_spare                                                  pcode_spr 
 , sp.PCODE_MAIN_PRICE
 , sp.PCODE_SPARE_PRICE
FROM	  shr_image                                        si 
      	, shr_image_feature_set                            sifs 
      	, shr_pcode                                        sp 
      	, shr_release_number                               srn 
      	, shr_major_release                                smr 
	--
	-- Project: SPRIT 
	-- This view is built for Evans Fernandes evfernan@cisco.com
	--
WHERE 
         si.release_number_id                           = srn.release_number_id 
AND      srn.major_release_id                           = smr.major_release_id 
AND      si.image_id                                    = sifs.image_id 
AND      sifs.image_feature_set_id                      = sp.image_feature_set_id 
AND      sifs.adm_flag                                  = 'V' 
AND      si.adm_flag                                    = 'V' 
AND      si.is_in_image_list                            = 'Y' 
AND	 smr.ADM_FLAG					= 'V'
AND	 srn.ADM_FLAG		 	                = 'V'
AND	 sp.ADM_FLAG			                = 'V'
AND	 sifs.ADM_FLAG			                = 'V'

grant select on VW_REL_IMAGE_PRODUCT to siis_view_user

