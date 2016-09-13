-------------------------------------------------------------------
-- Copyright (c) 2006-2007 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: 
--  1. Create shr_issu_state table for SPRIT-ISSU implementation.
--  2. Populate shr_issu_state table.    
--
-- Created by :   nadialee 
-- Created at:    Aug 2006  
-------------------------------------------------------------------

alter table shr_image drop constraint fk_shr_image_issu_state;

drop table shr_issu_state;

drop sequence shr_issu_state_seq; 

create sequence shr_issu_state_seq increment by 1 start with 1 nocycle nocache;

create table shr_issu_state (
    issu_state_id       number         not null,
    issu_state          varchar2(20)   not null,
    description         varchar2(100),
    adm_created_date    date           not null,
    adm_created_by      varchar2(20)   not null,
    adm_timestamp       date           not null,
    adm_userid          varchar2(20)   not null,
    adm_flag            varchar2(1)    not null,
    adm_comment         varchar2(50) );

alter table shr_issu_state add constraint pk_shr_issu_state primary key (issu_state_id);

create unique index uk_shr_issu_imastatege on shr_issu_state ( issu_state );

insert into shr_issu_state values (
    shr_issu_state_seq.nextval,
    'UNKNOWN',
    'When ISSU image is first created in SPRIT Image List',
    sysdate,
    'nadialee',
    sysdate,
    'nadialee',
    'V',
    'MANUALLY CREATED' ) ;
    
insert into shr_issu_state values (
    shr_issu_state_seq.nextval,
    'ENABLED',
    'ISSU image is found with subsystem during the build',
    sysdate,
    'nadialee',
    sysdate,
    'nadialee',
    'V',
    'MANUALLY CREATED' );

insert into shr_issu_state values (
    shr_issu_state_seq.nextval,
    'INCAPABLE',
    'ISSU image is found without subsystem during the build',
    sysdate,
    'nadialee',
    sysdate,
    'nadialee',
    'V',
    'MANUALLY CREATED' );

insert into shr_issu_state values (
    shr_issu_state_seq.nextval,
    'GEN',
    'Build is complete, full compatibility matrix is generated, and retar is complete',
    sysdate,
    'nadialee',
    sysdate,
    'nadialee',
    'V',
    'MANUALLY CREATED' );
    
insert into shr_issu_state values (
    shr_issu_state_seq.nextval,
    'VER',
    'tar file is verified on HAT test bed',
    sysdate,
    'nadialee',
    sysdate,
    'nadialee',
    'V',
    'MANUALLY CREATED' );
    
insert into shr_issu_state values (
    shr_issu_state_seq.nextval,
    'ISSU_OFF',
    'PM requested to turn off the ISSU capability during the build',
    sysdate,
    'nadialee',
    sysdate,
    'nadialee',
    'V',
    'MANUALLY CREATED' );

insert into shr_issu_state values (
    shr_issu_state_seq.nextval,
    'N/A',
    'Not applicable',
    sysdate,
    'nadialee',
    sysdate,
    'nadialee',
    'V',
    'MANUALLY CREATED' ) ;
    
commit;
