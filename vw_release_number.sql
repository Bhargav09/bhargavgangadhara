-- Copyright (c) 2004-2008 by Cisco Systems, Inc.
CREATE OR REPLACE VIEW VW_RELEASE_NUMBER
AS
SELECT 
    srn.release_number_id AS RELEASE_NUMBER_ID,
    null AS RELEASE_NUMBER,
    smr.major_release_number AS RELEASE_COMPONENT_1,
    TO_CHAR(srn.z) AS RELEASE_COMPONENT_2,
    srn.zabp AS RELEASE_COMPONENT_3,
    srn.p AS RELEASE_COMPONENT_4,
    srn.a AS RELEASE_COMPONENT_5,
    srn.o AS RELEASE_COMPONENT_6,
    null AS RELEASE_COMPONENT_7,
    null AS RELEASE_COMPONENT_8,
    sot.productization AS PRODUCTIZATION,
    sot.os_type_name AS SOFTWARE_TYPE_NAME,
    sot.os_type_name AS MASTER_OS_TYPE_NAME
FROM shr_release_number srn,
     shr_major_release smr,
     shr_os_type sot
WHERE 
    srn.major_release_id = smr.major_release_id
    AND smr.os_type_id = sot.os_type_id
    AND	sot.os_type_name IN ('IOS','IOX','CatOS') 
    AND srn.adm_flag = 'V'
    AND smr.adm_flag = 'V'
    AND sot.adm_flag = 'V'
UNION    
SELECT crn.release_number_id AS RELEASE_NUMBER_ID,
	crn.release_name AS RELEASE_NUMBER,
    crn.release_component_1 AS RELEASE_COMPONENT_1,
    crn.release_component_2 AS RELEASE_COMPONENT_2,
    crn.release_component_3 AS RELEASE_COMPONENT_3,
    crn.release_component_4 AS RELEASE_COMPONENT_4,
    crn.release_component_5 AS RELEASE_COMPONENT_5,
    crn.release_component_6 AS RELEASE_COMPONENT_6,
    crn.release_component_7 AS RELEASE_COMPONENT_7,
    crn.release_component_8 AS RELEASE_COMPONENT_8,
    sot.productization AS PRODUCTIZATION,
    sot.os_type_name AS SOFTWARE_TYPE_NAME,
    sot.os_type_name AS MASTER_OS_TYPE_NAME
FROM cspr_release_number crn,
    shr_os_type sot
WHERE crn.os_type_id = sot.os_type_id
	AND	crn.adm_flag = 'V'
	AND sot.adm_flag = 'V';
	
-- GRANT SELECT ON VW_RELEASE_NUMBER TO SHR_RDA;	
