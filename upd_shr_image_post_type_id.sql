/*
	Copyright (c) 2007 by Cisco Systems, Inc.
	This file is a data migration script to populate the SHR_IMAGE.IMAGE_POSTING_TYPE column based
	on the SHR_RELEASE_NUMBER.POSTING_TYPE_ID column. It is a part of Split Posting enhancement for SPRIT 
	6.9	
*/
DECLARE
    n_count NUMBER := 0;
BEGIN
    
    FOR releaseObj IN (
        SELECT release_number_id FROM shr_release_number
    )
    LOOP
        UPDATE shr_image img
        SET img.image_posting_type_id = 
            (SELECT DECODE(release.posting_type_id,1,1,2,2,3,3,4,4,5,5,6,7,NULL)
                FROM shr_release_number release
                WHERE release.release_number_id = img.release_number_id)
        WHERE img.release_number_id = releaseObj.release_number_id;
        
        n_count := n_count + 1;
        
        -- Commit after every 300 releases.
        IF n_count = 300 THEN
            COMMIT;
            n_count := 0;     
        END IF;
        
    END LOOP;
    
    -- Commit remaining rows
    COMMIT;
    
    EXCEPTION
     WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occured while running script');
        ROLLBACK;
END;
/
