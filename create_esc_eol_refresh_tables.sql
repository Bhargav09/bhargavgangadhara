drop table esc_eol_pid_cache;
create table esc_eol_pid_cache( 
  REQUEST_ID                    VARCHAR2 (12)      NOT NULL,
  PID                           VARCHAR2 (48)      NOT NULL,
  PID_DESCRIPTION               VARCHAR2 (500)     ,
  ACTIVE_FLAG                   CHAR (1)           ,
  PB_FINAL_URL                  VARCHAR2 (500)     ,
  PB_NUMBER                     VARCHAR2(24)       ,
  EO_SALES_DATE                 DATE               , 
  EO_SW_AVAL_DATE               DATE               ,  
  EO_SW_LICENSE_AVAL_DATE       DATE               , 
  EO_SW_MAINTENANCE_DATE        DATE               ,  
  EO_SECURITY_VUL_SUPPORT_DATE  DATE               , 
  EO_LAST_SUPPORT_DATE          DATE               , 
  CREATE_TIMESTAMP              DATE               , 
  CREATE_USER                   VARCHAR2(40)       ,
  UPDATE_TIMESTAMP              DATE               , 
  UPDATE_USER                   VARCHAR2(40),
  ADM_USERID      VARCHAR2(8 BYTE)   NOT NULL,
  ADM_TIMESTAMP   DATE               NOT NULL,
  ADM_FLAG        CHAR(1 BYTE)       NOT NULL,
  ADM_COMMENT     VARCHAR2(50 BYTE)  
        );
      
  ALTER TABLE esc_eol_pid_cache
  add CONSTRAINT esc_eol_pid_cache_uk UNIQUE (REQUEST_ID, PID);  
 ---------------------------------------
 
  drop table esc_eol_refresh_log; 
  create table esc_eol_refresh_log(
  REFRESH_ID      NUMBER    NOT NULL,
  MSG             VARCHAR2(500 BYTE)   NOT NULL,
  CREATED_BY      VARCHAR2(8 BYTE)   NOT NULL,
  CREATED_DATE    DATE               NOT NULL
  );
  
  ALTER TABLE esc_eol_refresh_log
  ADD CONSTRAINT pk_esc_eol_refresh_log
  PRIMARY KEY (REFRESH_ID);

  CREATE SEQUENCE REFRESH_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE;
 ----------------------------------------
 
 drop table auto_refrsh_detail;  
 create table auto_refrsh_detail(
  LAST_UPDATED_TIME   DATE               NOT NULL,
  LAST_UPDATED_FOR    VARCHAR2(20 BYTE)   NOT NULL,
  REFRESH_ID    NUMBER    ,
  CREATED_BY      VARCHAR2(8 BYTE)   NOT NULL,
  CREATED_DATE    DATE               NOT NULL,
  ADM_USERID      VARCHAR2(8 BYTE)   NOT NULL,
  ADM_TIMESTAMP   DATE               NOT NULL,
  ADM_FLAG        CHAR(1 BYTE)       NOT NULL,
  ADM_COMMENT     VARCHAR2(50 BYTE) );
  
  ALTER TABLE auto_refrsh_detail
ADD CONSTRAINT pk_auto_refrsh_detail
PRIMARY KEY (LAST_UPDATED_FOR);

ALTER TABLE           auto_refrsh_detail
ADD CONSTRAINT        fk_auto_refrsh_detail
FOREIGN KEY           (REFRESH_ID)
REFERENCES            esc_eol_refresh_log(REFRESH_ID);
