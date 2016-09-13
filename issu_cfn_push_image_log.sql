-------------------------------------------------------------------
-- Copyright (c) 2007 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: create issu_cfn_push_image_log table.
--
-- Created by :   nadialee 
-- Created at:    January 2007 
-------------------------------------------------------------------

drop table issu_cfn_push_image_log;

drop sequence issu_cfn_push_image_log_seq; 

create sequence issu_cfn_push_image_log_seq increment by 1 start with 1 nocycle nocache;

create table issu_cfn_push_image_log (
    trans_image_id      number       not null,
    trans_id            number       not null,
    image_id            number       not null,
    image_name          varchar2(20) not null,
    adm_created_date    date         not null,
    adm_created_by      varchar2(20) not null,
    adm_timestamp       date         not null,
    adm_userid          varchar2(20) not null,
    adm_flag            varchar2(1)  not null,
    adm_comment         varchar2(50) );

alter table issu_cfn_push_image_log add constraint pk_issu_cfn_push_image_log primary key (trans_image_id);

create index uk_issu_cfnpush_imagelog on issu_cfn_push_image_log (trans_id, image_id );


