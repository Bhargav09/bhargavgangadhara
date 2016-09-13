/*******************************************************************
-- Copyright (c) 2010-2011 by cisco Systems, Inc. All rights reserved.
-- This sql script is created for capturing messaging about the status of CCO Post transaction on yPublish and
   snap mirror copy on SPRIT side. yPUblish keeps updating the message in SPRIT by calling the PKG
-- Created by :   Selvaraj Aran(aselvara)
-- Created on:    February 2 2011
*******************************************************************/

/********************************************
 CSPR_YPUBLISH_MESSAGE_LOG
********************************************/
DROP SEQUENCE CSPR_YPUBLISH_MESSAGE_LOG_SEQ;

CREATE SEQUENCE CSPR_YPUBLISH_MESSAGE_LOG_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;

DROP TABLE CSPR_YPUBLISH_MESSAGE_LOG CASCADE CONSTRAINTS;

CREATE TABLE CSPR_YPUBLISH_MESSAGE_LOG
(MESSAGE_ID           NUMBER         NOT NULL,    
TRANSACTION_ID        NUMBER         NOT NULL,
IMAGE_ID              NUMBER             NULL,
MESSAGE               VARCHAR2(500)  NOT NULL,
CREATED_BY            VARCHAR2(8)    NOT NULL,
CREATED_DATE          DATE           NOT NULL,
ADM_USERID            VARCHAR2(8)    NOT NULL,
ADM_TIMESTAMP         DATE           NOT NULL,
ADM_FLAG              CHAR(1)        NOT NULL,
ADM_COMMENT           VARCHAR2(50)       NULL
);

ALTER TABLE CSPR_YPUBLISH_MESSAGE_LOG
ADD CONSTRAINT FK_YPUBLISH_TRANSACTION_ID
FOREIGN KEY ( TRANSACTION_ID )
REFERENCES CSPR_YPUBLISH_TRANS_LOG( TRANSACTION_ID );

--alter table CSPR_YPUBLISH_MESSAGE_LOG
--add CONSTRAINT FK_YPUBLISH_IMAGE_ID
--FOREIGN KEY ( IMAGE_ID )
--REFERENCES CSPR_YPUBLISH_IMAGE_LOG( IMAGE_ID );

ALTER TABLE CSPR_YPUBLISH_MESSAGE_LOG
ADD CONSTRAINT PK_CSPR_YPUBLISH_MESSAGE_LOG
PRIMARY KEY ( MESSAGE_ID );

ALTER TABLE cspr_ypublish_image_log
ADD (snap_mirror_copy_begin_time date null
            ,snap_mirror_copy_end_time date null
            );

--adding new column in cspr_ypublish_trans_log for adding priority value in metadata_xml
alter table cspr_ypublish_trans_log
add   (priority_value   number);

--CSCtj32260 file size validation - as a part of this cdets, store ios image source location
alter table cspr_image_posting_status
add   IMAGE_SOURCE_LOCATION  varchar2(1000);

            
            
grant all on CSPR_YPUBLISH_MESSAGE_LOG to shr_rda;

grant all on CSPR_YPUBLISH_MESSAGE_LOG_SEQ to shr_rda;
            

