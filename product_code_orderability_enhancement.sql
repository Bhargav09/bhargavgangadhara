/**************************************************
Copyright (c) 2005-2006 by Cisco Systems, Inc.

Created for product code orderability enhancement project

Author: Selvaraj Aran (aselvara)
Date  : 10/16/2006
**************************************************/
drop table shr_pcode_orderable_instr cascade constraints;

drop sequence pcode_orderable_instr_id_seq;

CREATE SEQUENCE pcode_orderable_instr_id_seq START WITH 1 INCREMENT BY 1 NOCACHE;

create table shr_pcode_orderable_instr(
 pcode_orderable_instr_id            number         NOT NULL
,pcode_orderable_instr_name          varchar2(50)   NOT NULL
,pcode_orderable_instr_desc          varchar2(100)     NULL
,ADM_TIMESTAMP                       DATE           NOT NULL
,ADM_USERID                          VARCHAR2 (8)   NOT NULL 
,ADM_FLAG                            CHAR (1)       NOT NULL 
,ADM_COMMENT                         VARCHAR2 (50)      NULL
,created_by                          varchar2(8)    NOT NULL
,created_date                        Date           NOT NULL
); 

ALTER TABLE shr_pcode_orderable_instr
ADD ( CONSTRAINT pk_shr_pcode_orderable_instr
      PRIMARY KEY(  pcode_orderable_instr_id ) ) ;


drop table shr_role cascade constraints;

drop sequence shr_role_seq;

create sequence shr_role_seq START WITH 1 INCREMENT BY 1 NOCACHE;
 
create table shr_role  (
 role_id                       number           Not Null   --this is sequence  shr_role_seq      
,role_name                     varchar2(50)     Not null
,role_name_description         varchar2(100)    Not null
,adm_timestamp                 Date             Not NULL
,adm_userid                    varchar2(8)      Not NULL
,adm_flag                      varchar2(1)      Not NULL
,adm_comment                   varchar2(50)         NULL
,created_by                    varchar2(8)      Not NULL
,created_date                  Date             Not NULL
);

ALTER TABLE shr_role
ADD ( CONSTRAINT pk_shr_role
      PRIMARY KEY(  role_id ) ) ;

ALTER TABLE shr_role
ADD ( CONSTRAINT uk_shr_role
      UNIQUE (  role_name) ) ;

drop table  shr_platform_role cascade constraints;

drop sequence shr_platform_role_seq;

create sequence shr_platform_role_seq START WITH 1 INCREMENT BY 1 NOCACHE;

create table shr_platform_role(
 platform_role_id             number           Not Null     --this is sequence  shr_platform_role_seq      
,individual_platform_id       number           Not NULL     --foreign key from shr_individual_platform
,platform_role_userid         varchar2(8)      Not NULL     --cisco user id
,role_id                      number           Not null     --fk from shr_role table.
,adm_timestamp                Date             Not NULL
,adm_userid                   varchar2(8)      Not NULL
,adm_flag                     varchar2(1)      Not NULL
,adm_comment                  varchar2(50)         NULL
,created_by                   varchar2(8)      Not NULL
,created_date                 Date             Not NULL
);

ALTER TABLE shr_platform_role
ADD ( CONSTRAINT pk_shr_platform_role
      PRIMARY KEY(  platform_role_id ) ) ;

ALTER TABLE shr_platform_role
ADD ( CONSTRAINT uk_shr_platform_role
      UNIQUE (  individual_platform_id
	            ,platform_role_userid
				,role_id) ) ;

Alter table shr_pcode
drop column pcode_main_orderable_comment;
            
Alter table shr_pcode
drop column pcode_spare_orderable_comment;

Alter table shr_pcode
drop column pcode_main_orderable_instr_id;

Alter table shr_pcode
drop column pcode_spare_orderable_instr_id;
            
	  
Alter table shr_pcode
Add (pcode_main_orderable_comment     varchar2(1000)   Null
,pcode_spare_orderable_comment        varchar2(1000)   Null
,pcode_main_orderable_instr_id        Number           Null
,pcode_spare_orderable_instr_id       Number           Null
);

ALTER TABLE shr_pcode
ADD  ( CONSTRAINT FK_pcode_main_orderable_instr
       FOREIGN KEY (pcode_main_orderable_instr_id )
       REFERENCES shr_pcode_orderable_instr(pcode_orderable_instr_id  ) );
	   
ALTER TABLE shr_pcode
ADD  ( CONSTRAINT FK_pcode_spare_orderable_instr
       FOREIGN KEY (pcode_spare_orderable_instr_id )
       REFERENCES shr_pcode_orderable_instr(pcode_orderable_instr_id  ) );
	   
insert into shr_pcode_orderable_instr
(PCODE_ORDERABLE_INSTR_ID
, PCODE_ORDERABLE_INSTR_NAME
, PCODE_ORDERABLE_INSTR_DESC
, ADM_TIMESTAMP, ADM_USERID
, ADM_FLAG, ADM_COMMENT
, CREATED_BY
, CREATED_DATE)
values(PCODE_ORDERABLE_INSTR_ID_SEQ.nextval
, 'Orderable'
, 'SKU orderable upon CCO post, visible in price list, visible in configurator tool.'
, sysdate
, 'aselvara'
, 'V'
, 'Inital creation'
, 'aselvara'
, sysdate);

insert into shr_pcode_orderable_instr
(PCODE_ORDERABLE_INSTR_ID
, PCODE_ORDERABLE_INSTR_NAME
, PCODE_ORDERABLE_INSTR_DESC
, ADM_TIMESTAMP
, ADM_USERID
, ADM_FLAG
, ADM_COMMENT
, CREATED_BY
, CREATED_DATE)
values(PCODE_ORDERABLE_INSTR_ID_SEQ.nextval
, 'Orderable not on Price List', 'SKU orderable upon CCO post, not visible in price list.'
, sysdate
, 'aselvara'
, 'V'
, 'Inital creation'
, 'aselvara'
, sysdate);

insert into shr_pcode_orderable_instr
(PCODE_ORDERABLE_INSTR_ID
, PCODE_ORDERABLE_INSTR_NAME
, PCODE_ORDERABLE_INSTR_DESC
, ADM_TIMESTAMP, ADM_USERID
, ADM_FLAG
, ADM_COMMENT
, CREATED_BY
, CREATED_DATE)
values(PCODE_ORDERABLE_INSTR_ID_SEQ.nextval
, 'Hold'
, 'SKU not initally orderable upon CCO post, PM to contact PDT to make orderable.'
, sysdate
, 'aselvara'
, 'V'
, 'Inital creation'
, 'aselvara'
, sysdate);


insert into shr_pcode_orderable_instr
(PCODE_ORDERABLE_INSTR_ID
, PCODE_ORDERABLE_INSTR_NAME
, PCODE_ORDERABLE_INSTR_DESC
, ADM_TIMESTAMP
, ADM_USERID
, ADM_FLAG
, ADM_COMMENT
, CREATED_BY
, CREATED_DATE)
values(PCODE_ORDERABLE_INSTR_ID_SEQ.nextval
, 'Remove', 'SKU is never orderable and should be removed in next maintenance build of release.'
, sysdate
, 'aselvara'
, 'V'
, 'Inital creation'
, 'aselvara'
, sysdate);

insert into shr_role ( role_id
, role_name
, role_name_description
, adm_timestamp
, adm_userid
, adm_flag
, adm_comment
, created_by
, created_date)
values ( shr_role_seq.nextval
, 'platformManager'
, 'platfrom manager role'
, sysdate
, 'sraju'
, 'V'
, 'populated manually as part of orderability project'
, 'sraju'
, sysdate);

insert into shr_role ( role_id
, role_name
, role_name_description
, adm_timestamp
, adm_userid
, adm_flag
, adm_comment
, created_by
, created_date)
values ( shr_role_seq.nextval
, 'platformPdtContact'
, 'platfrom pdt contact role'
, sysdate
, 'sraju'
, 'V'
, 'populated manually as part of orderability project'
, 'sraju'
, sysdate);

commit;
