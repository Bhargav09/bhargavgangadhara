-------------------------------------------------------------------
-- Copyright (c) 2007 by cisco Systems, Inc. All rights reserved.
--
-------------------------------------------------------------------

drop table SHR_IMAGE_ACL;

CREATE TABLE SHR_IMAGE_ACL
(
  IMAGE_ID       NUMBER                         NOT NULL,
  USER_ID        VARCHAR2(20 BYTE)              NOT NULL,
  CREATED_BY     VARCHAR2(20 BYTE)              NOT NULL,
  CREATED_DATE   DATE                           NOT NULL,
  ADM_USERID     VARCHAR2(20 BYTE)              NOT NULL,
  ADM_TIMESTAMP  DATE                           NOT NULL,
  ADM_FLAG       VARCHAR2(1 BYTE)               NOT NULL,
  ADM_COMMENT    VARCHAR2(50 BYTE)
);

alter table SHR_IMAGE_ACL add constraint PK_SHR_IMAGE_ACL primary key (IMAGE_ID, USER_ID);

create or replace SYNONYM IMAGE_ACL_POST_HISTORY for sprit.IMAGE_ACL_POST_HISTORY;

create or replace SYNONYM IMAGE_ACL_POST_HISTORY_SEQ for sprit.IMAGE_ACL_POST_HISTORY_SEQ;
