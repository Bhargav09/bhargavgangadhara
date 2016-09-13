insert into webservice_request_type
values ( WEBSERVICE_REQUEST_TYPE_SEQ.nextval, 'ISSU STATE UPDATE', sysdate, 'nadialee', sysdate, 'nadialee', 'CREATED FOR SPRIT_ISSU', 'V');

insert into webservice_request_type
values ( WEBSERVICE_REQUEST_TYPE_SEQ.nextval, 'ISSU STATE REPORT', sysdate, 'nadialee', sysdate, 'nadialee', 'CREATED FOR SPRIT_ISSU', 'V');
*********/
INSERT INTO webservice_request_type 
VALUES (webservice_request_type_seq.nextval,
        'IPCENTRALPROJECTRELEASE',
        sysdate,
        'aselvara',
        sysdate,
        'aselvara',
        'Created for IP Central Project Release record',
        'V');


INSERT INTO webservice_request_type 
VALUES (webservice_request_type_seq.nextval,
        'IPCENTRALPROJECTIMAGE',
        sysdate,
        'aselvara',
        sysdate,
        'aselvara',
        'Created for IP Central Project Image record',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '13001',
        'SPRIT',
        'Error',
        'No such IP central project Id exists in SPRIT.',
        sysdate,
        'aselvara',
        sysdate,
        'aselvara',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '13002',
        'SPRIT',
        'Error',
        'Start date and End date have more than 6 months of difference.',
        sysdate,
        'bhtrived',
        sysdate,
        'bhtrived',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '13003',
        'SPRIT',
        'Error',
        'Start value is more than total recourd found',
        sysdate,
        'bhtrived',
        sysdate,
        'bhtrived',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '13004',
        'SPRIT',
        'Error',
        'Error while executing the request',
        sysdate,
        'bhtrived',
        sysdate,
        'bhtrived',
        '',
        'V');

INSERT INTO response_metadata
VALUES (response_metadata_seq.nextval,
        '13005',
        'SPRIT',
        'Info',
        'No records found.',
        sysdate,
        'bhtrived',
        sysdate,
        'bhtrived',
        '',
        'V');
commit;
