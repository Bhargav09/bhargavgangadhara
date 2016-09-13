/*******************************************************************
-- Copyright (c) 2006-2007 by cisco Systems, Inc. All rights reserved.
-- This sql script is created for CSCsi25260 sprit Enhance Product code orderable report performance 
-- Created by :   Selvaraj Aran(aselvara@cisco.com)
-- Created on:    April 5 2007
*******************************************************************/

create index indx_mfg_cache_opus_version
on mfg_cache_opus(version);

CREATE INDEX IX_CSPR_PRODUCTS_ATTR_PID
ON CSPR_PRODUCTS_ATTR(MDF_PARENT_CONCEPT_ID);

DROP TABLE RELEASE_ORDERABLE_REPORT CASCADE CONSTRAINTS ; 

CREATE TABLE RELEASE_ORDERABLE_REPORT ( 
  RELEASE_NUMBER_ID                 NUMBER        NOT NULL, 
  RELEASE_NUMBER                    VARCHAR2 (50) NOT NULL, 
  RELEASE_PM                        VARCHAR2 (8)  NOT NULL, 
  OPUS_SUBMISSION_DATE              DATE              NULL, 
  OPUS_APPROVAL_DATE                DATE              NULL, 
  CCO_DATE                          DATE              NULL, 
  ECO_WRITEBACK                     DATE              NULL, 
  FINANCE_APPROVAL_DATE             DATE              NULL, 
  READY_FOR_ORDERABILITY_DATE       DATE              NULL, 
  ORDERABLE_PERCENTAGE              NUMBER            NULL, 
  DATE_100PERCENT_PDT_ORDERABLE     DATE              NULL, 
  PERCENTAGE_PRICE_TOOL_VISIBLE     NUMBER            NULL, 
  DATE_100PERCENT_PRICE_TOOL_VIS    DATE              NULL,
  CREATED_BY                        VARCHAR2 (8)  NOT NULL, 
  CREATED_DATE                      DATE          NOT NULL, 
  ADM_USERID                        VARCHAR2 (8)  NOT NULL, 
  ADM_TIMESTAMP                     DATE          NOT NULL, 
  ADM_FLAG                          CHAR (1)      NOT NULL, 
  ADM_COMMENT                       VARCHAR2 (50) 
) ; 


grant all on RELEASE_ORDERABLE_REPORT to shr_rda;


--create in shr_rda
create synonym RELEASE_ORDERABLE_REPORT for sprit.RELEASE_ORDERABLE_REPORT

--This is for ImageOrderableReport begins
drop table pcode_orderable

create table pcode_orderable (
-- pcode_id                    Number       Not null
pcode_name                     Varchar2(18) Not null
,in_orderable_tool             Varchar2(2)  Null
,pricing_tool_visible_date     Date         Null
)

alter table pcode_orderable
add constraint UK_PCODE_ORDERABLE unique  (pcode_name);

grant all on pcode_orderable to shr_rda;


create synonym pcode_orderable for sprit.pcode_orderable;


--This is for ImageOrderableReport ends

