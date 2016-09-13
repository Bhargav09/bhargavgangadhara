-------------------------------------------------------------------
-- Copyright (c) 2007 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: create issu_cfn_push_trans_log table.
--
-- Created by :   nadialee 
-- Created at:    January 2007 
-------------------------------------------------------------------

-- drop table issu_cfn_push_trans_log;

-- drop sequence issu_cfn_push_trans_log_seq; 

create sequence issu_cfn_push_trans_log_seq increment by 1 start with 1 nocycle nocache;

create table issu_cfn_push_trans_log (
    trans_id            number       not null,
    release_number      varchar2(40) not null,
    cco_trans_type      varchar2(10) not null,
    os_type_id          number       not null,
    no_of_attempt       number,
    is_accepted_by_hat  varchar2(1)  not null,
    hat_url             varchar2(500),
    status_code         number,
    status_msg          varchar2(4000),
    adm_created_date    date         not null,
    adm_created_by      varchar2(20) not null,
    adm_timestamp       date         not null,
    adm_userid          varchar2(20) not null,
    adm_flag            varchar2(1)  not null,
    adm_comment         varchar2(50) );

alter table issu_cfn_push_trans_log add constraint pk_issu_cfn_push_trans_log primary key (trans_id);

create index ix_issu_cfnpush_translog_relos on issu_cfn_push_trans_log (release_number, os_type_id );



