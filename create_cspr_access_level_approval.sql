CREATE TABLE cspr_access_level_approval(
  access_level_id	  	  integer               not null,
  cdc_access_level_id     integer               not null,
  os_type_id              integer               not null,
  approver_type           varchar2(32 byte)     not null,
  approver_id             varchar2(15 byte)     not null,
  status                  varchar2(15 byte),
  approval_date           date,
  approval_comment        varchar2(255 byte),
  adm_timestamp           date                  not null,
  adm_userid              varchar2(8 byte)      not null,
  adm_flag                char(1 byte)          not null,
  adm_comment             varchar2(32 byte),
  created_by              varchar2(8 byte)      not null,
  created_date            date                  not null
);

ALTER TABLE cspr_access_level_approval ADD (
CONSTRAINT pk_access_level_id 
PRIMARY KEY (access_level_id));

ALTER TABLE cspr_access_level_approval ADD (
CONSTRAINT fk_cdc_access_lvl_appr_id 
FOREIGN KEY (cdc_access_level_id) 
REFERENCES CSPR_CDC_ACCESS_LEVEL (cdc_access_level_id));

ALTER TABLE cspr_access_level_approval ADD (
CONSTRAINT fk_cdc_access_lvl_appr_os_type 
FOREIGN KEY (os_type_id) 
REFERENCES SHR_RDA.SHR_OS_TYPE (os_type_id));

ALTER TABLE cspr_access_level_approval ADD (
CONSTRAINT uk_cdc_access_level_approval 
UNIQUE (cdc_access_level_id,os_type_id, approver_id));

DROP SEQUENCE cspr_access_level_approval_seq;
CREATE SEQUENCE cspr_access_level_approval_seq START WITH 1 INCREMENT BY 1 NOCACHE;
  
GRANT ALL ON cspr_access_level_approval TO SHR_RDA;
  
GRANT ALL ON cspr_access_level_approval_seq TO SHR_RDA;