/*******************************************************************
-- Copyright (c) 2006-2007 by cisco Systems, Inc. All rights reserved.
-- This sql script is created for SDS release component sorting
-- Created by :   aselvara
-- Created at:    March 25 2007
*******************************************************************/

/********************************************
1. CSPR_SWTYPE_RELEASE_COMPONENT
********************************************/

DROP SEQUENCE CSPR_SWTYPE_RELEASE_COMPON_SEQ;

DROP TABLE CSPR_SWTYPE_RELEASE_COMPONENT CASCADE CONSTRAINTS;

CREATE SEQUENCE CSPR_SWTYPE_RELEASE_COMPON_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE CSPR_SWTYPE_RELEASE_COMPONENT(
SWTYPE_RELEASE_COMPONENT_ID   NUMBER       NOT NULL,
OS_TYPE_ID                    NUMBER       NOT NULL, --FK from shr_os_type
RELEASE_COMPONENT_COLUMN      VARCHAR2(25) NOT NULL,
RELEASE_COMPONENT_NAME        VARCHAR2(25) NOT NULL,
RELEASE_COMPONENT_LABEL       VARCHAR2(35) NOT NULL,
RELEASE_COMPONENT_SEQ         NUMBER       NOT NULL,
RELEASE_COMPONENT_GROUP       VARCHAR2(10) NOT NULL,
IS_REQUIRED                   VARCHAR2(1) NOT NULL,
DATA_TYPE                     VARCHAR2(35) NOT NULL,
CREATED_BY                    VARCHAR2 (8)  NOT NULL,
CREATED_DATE                  DATE          NOT NULL,
ADM_USERID                    VARCHAR2 (8)  NOT NULL,
ADM_TIMESTAMP                 DATE          NOT NULL,
ADM_FLAG                      CHAR (1)      NOT NULL,
ADM_COMMENT                   VARCHAR2 (50)     NULL
);

ALTER TABLE CSPR_SWTYPE_RELEASE_COMPONENT
ADD CONSTRAINT PK_SWTYPE_RELEASE_COMPONENT_ID
PRIMARY KEY( SWTYPE_RELEASE_COMPONENT_ID ) ;


ALTER TABLE CSPR_SWTYPE_RELEASE_COMPONENT
ADD  ( CONSTRAINT FK_SHR_OS_TYPE_ID
       FOREIGN KEY (OS_TYPE_ID)
       REFERENCES SHR_OS_TYPE) ;

GRANT ALL ON CSPR_SWTYPE_RELEASE_COMPONENT TO shr_rda;

GRANT ALL ON CSPR_SWTYPE_RELEASE_COMPON_SEQ TO shr_rda;

********************************************
2. alter table cspr_release_number to include release_components
********************************************/

ALTER TABLE CSPR_RELEASE_NUMBER
ADD (RELEASE_COMPONENT_1       VARCHAR2(20)      NULL,
RELEASE_COMPONENT_2            VARCHAR2(20)      NULL,
RELEASE_COMPONENT_3            VARCHAR2(20)      NULL,
RELEASE_COMPONENT_4            VARCHAR2(20)      NULL,
RELEASE_COMPONENT_5            VARCHAR2(20)      NULL,
RELEASE_COMPONENT_6            VARCHAR2(20)      NULL,
RELEASE_COMPONENT_7            VARCHAR2(20)      NULL,
RELEASE_COMPONENT_8            VARCHAR2(20)      NULL )
;

create synonym CSPR_SWTYPE_RELEASE_COMPONENT for sprit.CSPR_SWTYPE_RELEASE_COMPONENT;

create synonym CSPR_SWTYPE_RELEASE_COMPON_SEQ for sprit.CSPR_SWTYPE_RELEASE_COMPON_SEQ;


/*************************************************
This view is created and granted select previlege to software center
***************************************************/
create view vw_CSPR_SWTYPE_RELEASE_Sort
as select som.os_type_id
,smsa.MDF_SWT_CONCEPT_ID
,MDF_SWT_CONCEPT_NAME,
RELEASE_COMPONENT_COLUMN     
,RELEASE_COMPONENT_NAME       
,RELEASE_COMPONENT_LABEL      
,RELEASE_COMPONENT_SEQ        
,RELEASE_COMPONENT_GROUP      
,IS_REQUIRED                  
,DATA_TYPE
from  SHR_MDF_SWTYPE_ATTR   smsa
     ,shr_ostype_mdfswtype   som
 --  ,shr_software_type_mdf  sstm
 ,CSPR_SWTYPE_RELEASE_COMPONENT csrc
where smsa.MDF_SWT_CONCEPT_ID=som.MDF_SWT_CONCEPT_ID
--and som.MDF_SWT_CONCEPT_ID=sstm.mdf_concept_id
and som.os_type_id=csrc.os_type_id
union
select som.os_type_id
,smsa.MDF_SWT_CONCEPT_ID
,MDF_SWT_CONCEPT_NAME
,'FCS_DATE' RELEASE_COMPONENT_COLUMN     
,'ReleasePublishDate' RELEASE_COMPONENT_NAME       
,'FCS_DATE' RELEASE_COMPONENT_LABEL      
,1          RELEASE_COMPONENT_SEQ        
,'FALSE'     RELEASE_COMPONENT_GROUP      
,'Y'        IS_REQUIRED                  
,'Date'     DATA_TYPE
from  SHR_MDF_SWTYPE_ATTR   smsa
     ,shr_ostype_mdfswtype   som
where smsa.MDF_SWT_CONCEPT_ID=som.MDF_SWT_CONCEPT_ID
and os_type_id not in(select os_type_id from CSPR_SWTYPE_RELEASE_COMPONENT)
;


alter table cspr_image
add CCO_FCS_DATE date null;

alter table cspr_image_posting_status
add CCO_FIRST_POSTED_TIME date null;


grant select on vw_CSPR_SWTYPE_RELEASE_Sort to SHR_RDA_READONLY;


