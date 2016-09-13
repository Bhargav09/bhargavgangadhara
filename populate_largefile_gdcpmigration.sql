-------------------------------------------------------------------
-- Copyright (c) 2006-2007, 2011 by cisco Systems, Inc. All rights reserved.
--
-- Funciton: populate data for large file publishing and gdcp
--           migration activity
-- Created by :   bhtrived 
-- Created at:    Feb 2011
-------------------------------------------------------------------

/* CSCtl23741 Size Validation for Webservices */
INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '13006',
        'SPRIT',
        'Error',
        'The image size is exceeding 5GB limit.',
        sysdate,
        'spathala',
        sysdate,
        'spathala',
        'Manually inserted',
        'V');   

/* smtp host change : new host: outbound.cisco.com */
update sprit_email_alias
set email_alias = 'outbound.cisco.com'
where email_alias = 'champ.cisco.com';

/* CSCtj32260 file size validation */
insert into sprit_properties values (sprit_properties_seq.nextval, 'IMAGESIZELIMIT', 1,
'Image Size 5GB', '5368709120', '5368709120', '5368709120', sysdate, 'spathala',
'V', 'Manually Populated');

/* CSCtj24006 PCode Description and Designator */
update shr_release_pcode_group
set pcode_group_abbrev = null
where lower(pcode_group_abbrev) = 'null';

update shr_release_pcode_group
set pcode_group_desc = null
where lower(pcode_group_desc) = 'null';
       
/* sprit property change for GDCP migration */
insert into sprit_properties values(sprit_properties_seq.nextval, 'SNAP_MIRROR_COPY_DESTINATION',1, 'SNAP Mirror location where image will be copied'
                                      ,'/auto/swc-sed-xfer-prod/'
                                      ,'/auto/swc-sed-xfer-dev/'
                                      ,'/auto/swc-sed-xfer-stg/'
                                      ,sysdate
                                      ,'bhtrived'
                                      ,'V'
                                      , 'Manually Populated'
                                      );
                                      
 insert into sprit_properties values(sprit_properties_seq.nextval, 'SNAP_MIRROR_COPY_SOURCE',1, 'Linux location where image is stored'
                                      ,'/auto/'
                                      ,'/auto/'
                                      ,'/auto/'
                                      ,sysdate
                                      ,'bhtrived'
                                      ,'V'
                                      , 'Manually Populated'
                                      );                 
                                      
  insert into sprit_properties values(sprit_properties_seq.nextval, 'SNAP_MIRROR_COPY_MAXTIME',1, 'maximum time main thread will wait before killing all copy process (in second)'
                                      ,'1800'
                                      ,'1800'
                                      ,'1800'
                                      ,sysdate
                                      ,'bhtrived'
                                      ,'V'
                                      , 'Manually Populated'
                                      );                                               
                                      
  insert into sprit_properties values(sprit_properties_seq.nextval, 'SNAP_MIRROR_COPY_THREAD_COUNT',1, 'Number of copy thread in thread pool'
                                      ,'10'
                                      ,'10'
                                      ,'10'
                                      ,sysdate
                                      ,'bhtrived'
                                      ,'V'
                                      , 'Manually Populated'
                                      );       
