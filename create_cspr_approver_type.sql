CREATE TABLE cspr_approver_type(
  approver_type_id	       integer              not null,
  property_id	           integer              not null,  
  approval_required        char(1 byte)         not null,  
  approver_admin_controller char(1 byte)         not null,
  adm_timestamp            date                 not null,
  adm_userid               varchar2(8 byte)     not null,
  adm_flag                 char(1 byte)         not null,
  adm_comment              varchar2(32 byte),
  created_by               varchar2(8 byte)     not null,
  created_date             date                 not null
);

ALTER table cspr_approver_type ADD (
CONSTRAINT pk_cspr_approver_type 
PRIMARY KEY (approver_type_id));

ALTER table cspr_approver_type ADD (
CONSTRAINT fk_cspr_approver_type_PROP_ID 
FOREIGN KEY (property_id) 
REFERENCES SPRIT_PROPERTIES (property_id));
  
ALTER table cspr_approver_type ADD (
CONSTRAINT uk_cspr_approver_type  
UNIQUE (property_id));  

DROP SEQUENCE cspr_approver_type_seq;
CREATE SEQUENCE cspr_approver_type_seq  START WITH 1 INCREMENT BY 1 NOCACHE;

GRANT ALL ON cspr_approver_type TO SHR_RDA;
GRANT ALL ON cspr_approver_type_seq TO SHR_RDA;