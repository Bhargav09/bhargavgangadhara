/*******************************************************************
   Copyright (c) 2010-2011 by Cisco Systems, Inc. All rights reserved.
   This sql script is modified to include all source location and md5checksum information for all the images
   that are being Posted to CCO from SPRIT. This view is consumed by Manufacturing Autotest team
   With data center migration from SJC to RCDN auto test team will no logber be able to read files from CCO Beyond.
   So they will start reading files from SJ Beyond using this View
   
   SPRIT SFS EDCS :EDCS-915422
   CDETS id: CSCtj32271
   View Name: vw_image_source_location
   
   Created by       :   Selvaraj Aran(aselvara)
   Last Updated on  :   February 2 2011
*******************************************************************/

DROP VIEW SHR_RDA.VW_IMAGE_SOURCE_LOCATION;

/* Formatted on 4/22/2011 1:59:01 PM (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW SHR_RDA.VW_IMAGE_SOURCE_LOCATION
(
   OS_TYPE_NAME,
   RELEASE_NAME,
   IMAGE_NAME,
   CCO_IMAGE_NAME,
   SOURCE_LOCATION,
   MD5_CHECKSUM,
   IMAGE_SIZE
)
AS
   SELECT   sot.os_type_name os_type_name,
            crn.release_name release_name,
            ci.image_name image_name,
            ci.image_name cco_image_name,
            ci.source_location source_location,
            ips.md5_checksum md5_checksum,
            ips.image_size image_size
     FROM   cspr_image ci,
            cspr_release_number crn,
            shr_os_type sot,
            cspr_image_posting_status ips
    WHERE       ci.adm_flag = 'V'
            AND crn.adm_flag = 'V'
            AND sot.adm_flag = 'V'
            AND sot.os_type_id = crn.os_type_id
            AND crn.release_number_id = ci.release_number_id
            AND ci.image_id = ips.image_id(+)
   UNION
   SELECT   sot.os_type_name os_type_name,
            srn.release_number release_name,
            si.image_name || '.'
            || REPLACE (
                  REPLACE (
                        REPLACE (smr.major_release_number, '.', '')
                     || '-'
                     || srn.z
                     || srn.p
                     || DECODE (srn.a, '', '', '.' || srn.a || srn.o),
                     '(',
                     '.'
                  ),
                  ')',
                  ''
               )
               image_name,
            full_image_name cco_image_name,
            ips.image_source_location source_location,
            ips.md5_checksum md5_checksum,
            ips.image_size image_size
     FROM   shr_image si,
            shr_release_number srn,
            shr_major_release smr,
            shr_os_type sot,
            cspr_image_posting_status ips
    WHERE       sot.os_type_id = smr.os_type_id
            AND smr.major_release_id = srn.major_release_id
            AND srn.release_number_id = si.release_number_id
            AND si.image_id = ips.image_id
            AND si.adm_flag = 'V'
--AND srn.adm_flag = 'V'
--AND sot.adm_flag = 'V';

GRANT SELECT ON SHR_RDA.VW_IMAGE_SOURCE_LOCATION TO MFG_IT;

