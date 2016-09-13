CREATE OR REPLACE PROCEDURE SHR_MDF_REFRESH_JOB_SUBMIT IS

    jobno NUMBER;
	
BEGIN


  	EXECUTE IMMEDIATE 'ALTER SESSION SET GLOBAL_NAMES=FALSE';

    -- Run once a day, everyday at 5:00 AM.
	-- Note: 1) two single quote, not double quote around the weekday.
	--       2) 4th line all on one line. 200 chars limit.
    DBMS_JOB.SUBMIT(jobno,
                   'SHR_MDF_REFRESH_PKG.main;',
                   sysdate ,
                   'trunc(sysdate+1) + 5/24',
                   FALSE );
	COMMIT;	
	DBMS_OUTPUT.PUT_LINE('JOBNO = '||TO_CHAR(jobno));	
		   
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        
END SHR_MDF_REFRESH_JOB_SUBMIT;
/
