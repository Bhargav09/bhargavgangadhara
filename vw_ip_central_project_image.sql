/******************************************************************************
 File: vw_ip_central_project_image.sql
 Description: This DB view is created to simply the data extraction from database
              and provide that to IP Central through WebServices.
 Auther:Selvaraj Aran(aselvara)
 Date  :08/24/2010
 Copyright (c) 2010 by Cisco Systems, Inc.
 All rights reserved.A
********************************************************************/

create or replace view vw_ip_central_project_image
as select distinct srn.release_number_id
       ,srn.release_number
       ,decode(sricp.adm_flag,'D', NULL,sricp.project_id)  ipcentral_project_id -- will be optional if the project id is not associated 
      ,sot.os_type_id  
      ,smsa.MDF_SWT_CONCEPT_NAME
      ,smsa.MDF_SWT_CONCEPT_ID
      ,si.image_id
      ,si.image_name
      ,feature_set_desc image_description
      ,cips.MD5_CHECKSUM
      ,CCO_TRANSACTION_TYPE||CCO_TRANSACTION_STATUS ccopostedstatus
      ,cips.CCO_POSTED_TIME 
      ,si.adm_flag
      ,si.created_by
      ,si.created_date
      ,greatest( si.adm_timestamp
                ,srn.adm_timestamp
                ,sifs.adm_timestamp
                ,sfs.adm_timestamp
                ,nvl(sfsd.adm_timestamp,sysdate-3000)
                ,nvl(sricp.adm_timestamp,sysdate-3000)
               )adm_timestamp
from  shr_os_type         sot
     ,shr_ostype_mdfswtype som
     ,shr_mdf_swtype_attr  smsa
     ,shr_major_release  smr
     ,shr_release_number srn
     ,shr_image           si
     ,cspr_image_posting_status cips
     ,shr_image_feature_set sifs
     ,shr_feature_set       sfs
     ,SHR_FEATURE_SET_DESC      sfsd
     ,SHR_FEATURE_SET_DESIGNATOR sfsdi
     ,shr_rel_ip_central_project sricp
where
      SOT.OS_TYPE_ID=SOM.OS_TYPE_ID
and   som.MDF_SWT_CONCEPT_ID=smsa.MDF_SWT_CONCEPT_ID
and   sot.os_type_id=smr.os_type_id
and   smr.major_release_id=srn.major_release_id
and   srn.release_number_id=si.release_number_id
and   srn.release_number_id=sricp.release_number_id(+)
and   si.image_id=cips.image_id
and   si.image_id=sifs.image_id
and   SIFS.FEATURE_SET_ID=SFS.FEATURE_SET_ID
and   SFS.FEATURE_SET_DESC_ID=SFSD.FEATURE_SET_DESC_ID
and   SFS.FEATURE_SET_DESIGNATOR_ID=SFSDI.FEATURE_SET_DESIGNATOR_ID(+)
union
Select distinct crn.release_number_id
       ,crn.release_name
       ,decode(sricp.adm_flag,'D', NULL,sricp.project_id)  ipcentral_project_id -- will be optional if the project id is not associated 
      ,sot.os_type_id  
      ,smsa.MDF_SWT_CONCEPT_NAME
      ,smsa.MDF_SWT_CONCEPT_ID
      ,ci.image_id
      ,ci.image_name
      ,ci.image_description
      ,cips.MD5_CHECKSUM
      ,cips.CCO_TRANSACTION_TYPE||cips.CCO_TRANSACTION_STATUS ccopostedstatus
      ,cips.CCO_POSTED_TIME 
      ,ci.adm_flag
      ,ci.created_by
      ,ci.created_date
      ,greatest(ci.adm_timestamp
                ,crn.adm_timestamp
                ,nvl(sricp.adm_timestamp,sysdate-3000)
                )adm_timestamp
from  shr_os_type         sot
     ,shr_ostype_mdfswtype som
     ,shr_mdf_swtype_attr  smsa
     ,cspr_release_number crn
     ,cspr_image           ci
     ,cspr_image_posting_status cips
     ,shr_rel_ip_central_project sricp
where
      SOT.OS_TYPE_ID=SOM.OS_TYPE_ID
and   som.MDF_SWT_CONCEPT_ID=smsa.MDF_SWT_CONCEPT_ID
and   sot.os_type_id=crn.os_type_id
and   crn.release_number_id=ci.release_number_id
and   crn.release_number_id=sricp.release_number_id(+)
and   ci.image_id=cips.image_id(+)
;
