-------------------------------------------------------------------
-- Copyright (c) 2006-2007 by cisco Systems, Inc. All rights reserved.
--
-- Funciton:
--  1. Create shr_image_issu_state table.
--
-- Created by :   nadialee
-- Created at:    Aug 2006
-------------------------------------------------------------------

drop table shr_image_issu_state;

create table shr_image_issu_state (
    image_id            number       not null,
    os_type_id          number       not null,
    issu_state_id       number       not null,
    adm_created_date    date         not null,
    adm_created_by      varchar2(20) not null,
    adm_timestamp       date         not null,
    adm_userid          varchar2(20) not null,
    adm_flag            varchar2(1)  not null,
    adm_comment         varchar2(50) );

alter table shr_image_issu_state add constraint pk_shr_image_issu_state primary key (image_id);

alter table shr_image_issu_state add constraint fk1_shr_issu_image_os_type_id foreign key( os_type_id ) references shr_os_type( os_type_id );

alter table shr_image_issu_state add constraint fk2_shr_issu_image_os_type_id foreign key( issu_state_id ) references shr_issu_state( issu_state_id );


