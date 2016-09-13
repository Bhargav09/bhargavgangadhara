--Copyright (c) 2004 by Cisco Systems, Inc.
CREATE OR REPLACE VIEW DSD_RELID_PFAM_VIEW ( RELEASE, 
MAINTENANCE, MRENUMBER, ED_DESIGNATOR, ED_RENUMBER, 
FAMILY ) AS SELECT  distinct smr.major_release_number    release
	  , to_char(srn.z)                   maintenance
	  , to_char(srn.p)                   mrenumber
	  , srn.a                            ed_designator
	  , srn.o                            ed_renumber
	  , spg.pcode_group_name             family
FROM   shr_platform_image                    spi
      ,shr_image                             si
      ,shr_release_number                    srn
      ,shr_platform_pcode_group              sppg
      ,shr_individual_platform               sip
      ,shr_pcode_group                       spg
      ,shr_major_release                     smr
WHERE smr.major_release_id                   = srn.major_release_id
AND   srn.release_number_id                  = si.release_number_id
AND   si.image_id                            = spi.image_id
AND   spi.individual_platform_id             = sip.individual_platform_id
AND   sip.individual_platform_id             = sppg.individual_platform_id
AND   sppg.pcode_group_id                    = spg.pcode_group_id
AND   spi.adm_flag                           = 'V'
AND   si.adm_flag                            = 'V'
AND   si.is_obsolete                         = 'N'
AND   sppg.adm_flag                          = 'V'
AND   spi.is_in_image_list                   = 'Y'
AND   si.is_in_image_list                    = 'Y';
