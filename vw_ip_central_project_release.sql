/**********************************************************************
 File: vw_ip_central_project_release.sql
 Description: This DB view is created to simply the data extraction from database
              and provide that to IP Central through WebServices.
 Auther:Selvaraj Aran(aselvara)
 Date  :08/24/2010
 Copyright (c) 2010 by Cisco Systems, Inc.
 All rights reserved.A
*********************************************************************/
create or replace view vw_ip_central_project_release
as Select distinct srn.release_number_id
       ,srn.release_number
       ,decode(sricp.adm_flag , 'D',NULL,project_id )ipcentral_project_id -- will be optional if the project id is not associated 
      ,sot.os_type_id  
      ,smsa.MDF_SWT_CONCEPT_NAME
      ,smsa.MDF_SWT_CONCEPT_ID
      ,srn.adm_flag
      ,srn.created_by
      ,greatest(srn.adm_timestamp
                ,sricp.adm_timestamp
               )adm_timestamp
      ,sysdate cco_fcs_date -- optional
from  shr_os_type         sot
     ,shr_ostype_mdfswtype som
     ,shr_mdf_swtype_attr  smsa
     ,shr_major_release  smr
     ,shr_release_number srn
     ,shr_rel_ip_central_project sricp
where
      SOT.OS_TYPE_ID=SOM.OS_TYPE_ID
and   som.MDF_SWT_CONCEPT_ID=smsa.MDF_SWT_CONCEPT_ID
and   sot.os_type_id=smr.os_type_id
and   smr.major_release_id=srn.major_release_id
and   smsa.mdf_swt_concept_id=280805680 --this is for IOS
and   srn.release_number_id=sricp.release_number_id(+)
union
Select distinct crn.release_number_id
      ,crn.release_name
      ,decode(sricp.adm_flag , 'D',NULL,project_id )ipcentral_project_id -- will be optional if the project id is not associated 
      ,sot.os_type_id  
      ,smsa.MDF_SWT_CONCEPT_NAME
      ,smsa.MDF_SWT_CONCEPT_ID
      ,crn.adm_flag
      ,crn.created_by
      ,crn.adm_timestamp
      ,sysdate cco_fcs_date -- optional
from  shr_os_type         sot
     ,shr_ostype_mdfswtype som
     ,shr_mdf_swtype_attr  smsa
     ,cspr_release_number crn
     ,shr_rel_ip_central_project sricp
where
      SOT.OS_TYPE_ID=SOM.OS_TYPE_ID
and   som.MDF_SWT_CONCEPT_ID=smsa.MDF_SWT_CONCEPT_ID
and   sot.os_type_id=crn.os_type_id
and   crn.release_number_id=sricp.release_number_id(+)
;
