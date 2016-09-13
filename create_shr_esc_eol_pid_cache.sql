drop table shr_esc_eol_pid_cache;
create table shr_esc_eol_pid_cache( 
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
  UPDATE_USER                   VARCHAR2(40)       );
      
  ALTER TABLE shr_esc_eol_pid_cache
  add CONSTRAINT shr_esc_eol_pid_cache_uk UNIQUE (REQUEST_ID, PID);  
  
  drop table shr_esc_eol_pid_cache_temp; 
 
  create table shr_esc_eol_pid_cache_temp(
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
  UPDATE_USER                   VARCHAR2(40)       );
  
  ALTER TABLE shr_esc_eol_pid_cache_temp
  add CONSTRAINT shr_esc_eol_pid_cache_temp_uk UNIQUE (REQUEST_ID, PID);
 