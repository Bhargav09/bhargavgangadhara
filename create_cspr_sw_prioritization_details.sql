CREATE TABLE SPRIT.CSPR_SW_PRIORITIZATION_DETAILS
(
  PRIORITY_DETAIL_ID  NUMBER                    NOT NULL,
  MDF_CONCEPT_ID      NUMBER                    NOT NULL,
  MDF_CONCEPT_NAME    VARCHAR2(640 BYTE)        NOT NULL,
  CREATED_BY          VARCHAR2(8 BYTE),
  CREATED_DATE        DATE                      NOT NULL,
  ADM_USERID          VARCHAR2(8 BYTE),
  ADM_TIMESTAMP       DATE,
  ADM_FLAG            CHAR(1 BYTE),
  ADM_COMMENT         VARCHAR2(50 BYTE),
  PRIORITY_ID         NUMBER
)
TABLESPACE DATA
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE UNIQUE INDEX SPRIT.CSPR_SW_PRIORITIZATION_DETA_PK ON SPRIT.CSPR_SW_PRIORITIZATION_DETAILS
(PRIORITY_DETAIL_ID)
LOGGING
TABLESPACE DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


ALTER TABLE SPRIT.CSPR_SW_PRIORITIZATION_DETAILS ADD (
  CONSTRAINT CSPR_SW_PRIORITIZATION_DETA_PK
 PRIMARY KEY
 (PRIORITY_DETAIL_ID)
    USING INDEX 
    TABLESPACE DATA
    PCTFREE    10
    INITRANS   2
    MAXTRANS   255
    STORAGE    (
                INITIAL          1M
                NEXT             1M
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                PCTINCREASE      0
               ));

ALTER TABLE SPRIT.CSPR_SW_PRIORITIZATION_DETAILS ADD (
  CONSTRAINT CSPR_SW_PRIORITIZATION_DET_R01 
 FOREIGN KEY (PRIORITY_ID) 
 REFERENCES SPRIT.CSPR_SW_PRIORITIZATION (PRIORITY_ID));

 
CREATE SEQUENCE SPRIT.CSPR_SW_PRIORITIZATION_D_SEQ
  START WITH 1
  MAXVALUE 999999999999999999999999999
  MINVALUE 0
  NOCYCLE
  NOCACHE
  NOORDER;
  
  
 

