-------------------------------------------------------------------
-- Copyright (c) 2007 by cisco Systems, Inc. All rights reserved.
--
-------------------------------------------------------------------

drop table IMAGE_ACL_POST_HISTORY;

CREATE TABLE IMAGE_ACL_POST_HISTORY
(
  ACL_POST_HISTORY_ID  NUMBER                   NOT NULL,
  IMAGE_ID             NUMBER                   NOT NULL,
  USER_ID              VARCHAR2(20 BYTE)        NOT NULL,
  TRANSACTION_ID       NUMBER                   NOT NULL,
  TRANSACTION_STATUS   VARCHAR2(20 BYTE),
  ACL_URL              VARCHAR2(1000 BYTE),
  POSTED_TIME          DATE,
  CREATED_DATE         DATE                     NOT NULL,
  CREATED_BY           VARCHAR2(20 BYTE)        NOT NULL,
  ADM_TIMESTAMP        DATE                     NOT NULL,
  ADM_USERID           VARCHAR2(20 BYTE)        NOT NULL,
  ADM_FLAG             VARCHAR2(1 BYTE)         NOT NULL,
  ADM_COMMENT          VARCHAR2(50 BYTE)
);

alter table IMAGE_ACL_POST_HISTORY add constraint PK_IMAGE_ACL_POST_HISTORY primary key (ACL_POST_HISTORY_ID);

DROP SEQUENCE IMAGE_ACL_POST_HISTORY_SEQ;

CREATE SEQUENCE IMAGE_ACL_POST_HISTORY_SEQ; 

GRANT ALL ON IMAGE_ACL_POST_HISTORY TO SHR_RDA;

GRANT ALL ON IMAGE_ACL_POST_HISTORY_SEQ TO SHR_RDA;




