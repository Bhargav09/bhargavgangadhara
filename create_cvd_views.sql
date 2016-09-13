/* The following database views are created for CVD systems.
 CVD access software type, image name, product mdf concepts from these view
 and certifies the images with CVD I,CVD II or Safe Harbor certifications.
 
 CVD systems pushes certification data through API(Stored procedures) into
 SPRIT, cspr_certification table. If the images being certified has been posted already
 SPRIT auto repost kicks off metadata repost in SPRIT and pushes certification data to 
 SDS through yPublish.

--Copyright (c) 2007 by Cisco Systems, Inc.

*/
--IOS views

create view VW_CVD_IMAGE_PLATFORM
as select distinct 
si.release_number_id
,full_image_name
,si.image_id
,si.MDF_SWT_CONCEPT_ID
,spi.individual_platform_id
,si.is_posted_to_cco
from
shr_image si
,shr_platform_image spi
,shr_individual_platform sip
--,SHR_OSTYPE_MDFSWTYPE som
where  si.image_id                = spi.image_id
and spi.INDIVIDUAL_PLATFORM_ID = sip.INDIVIDUAL_PLATFORM_ID
--and som.MDF_SWT_CONCEPT_ID=si.MDF_SWT_CONCEPT_ID
and si.adm_flag='V'
and spi.adm_flag='V'
and sip.adm_flag='V' 
;

create view VW_CVD_MDF_PLATFORM_PRODUCT
as select distinct 
sipm.individual_platform_id
,individual_platform_name
,smpa.mdf_concept_id 
,smpa.mdf_concept_name
from
shr_individual_platform sip
,shr_individual_platform_mdf sipm
,SHR_MDF_PRODUCTS_ATTR smpa
where sip.individual_platform_id=sipm.individual_platform_id
and  sipm.mdf_concept_id=smpa.MDF_CONCEPT_ID
and sipm.MDF_CONCEPT_ID        = smpa.mdf_concept_id 
;

create view VW_CVD_SWT_MDF_CONCEPT_RELEASE
as select distinct som.mdf_swt_concept_id
,smsa.mdf_swt_concept_name
,release_number
,srn.release_number_id
from
shr_os_type sot
,shr_release_number srn
,shr_major_release smr 
,SHR_MDF_SWTYPE_ATTR smsa
,SHR_OSTYPE_MDFSWTYPE som
where sot.os_type_id           = som.os_type_id
and som.MDF_SWT_CONCEPT_ID= smsa.MDF_SWT_CONCEPT_ID
and sot.OS_TYPE_ID = smr.OS_TYPE_ID
and smr.MAJOR_RELEASE_ID=srn.MAJOR_RELEASE_ID 
;

--Non-IOS view

create view VW_NIOS_CVD_IMAGE_MDF_PRODUCTS
as select smsa.mdf_swt_concept_id
      ,mdf_swt_concept_name 
      ,crn.release_number_id
      ,release_name
      ,ci.image_id
      ,image_name
      ,smpa.mdf_concept_id
      ,mdf_concept_name
      ,decode(cco_first_posted_time,NULL,'N','Y') is_posted_to_cco
from cspr_release_number      crn
    ,cspr_image                ci
    ,shr_mdf_swtype_attr     smsa
    ,shr_mdf_products_attr   smpa
    ,shr_ostype_mdfswtype     som
    ,shr_os_type              sot
    ,cspr_image_mdf           cim
    ,cspr_image_posting_status cips
where
       sot.os_type_id  = crn.os_type_id
   and crn.os_type_id=som.os_type_id
   and som.mdf_swt_concept_id=smsa.mdf_swt_concept_id
   and crn.release_number_id=ci.release_number_id
   and ci.image_id=cim.image_id
   and cim.mdf_concept_id = smpa.mdf_concept_id
   and ci.IMAGE_ID = cips.IMAGE_ID(+)
   and ci.adm_flag='V'
   and cim.adm_flag='V' 
;
