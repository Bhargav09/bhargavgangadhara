CREATE OR REPLACE PROCEDURE SHR_RDA.PROC_UPDATE_IMAGE_POSTING_TYPE(
            p_release_number_id    IN  NUMBER ) 
IS

/* Copyright (c) 2011 by cisco Systems, Inc. All rights reserved. 

    When the posting_type_id is modified in CISROMM for the given release,
    check whether SPRIT app has any images mapped for that release with
    corresponding image_posting_type_id. If so, CISROMM can make a call to this
    procedure whenever the posting_type_id is modified in CISROMM app to update
    image_posting_type_id in SPRIT app.
    
    There are different posting_type_id (s) and has mapping image_posting_type_id(s).
    After the update in SPRIT, it has to map like "public to public", "hidden to hidden"
    
    For example, if the posting_type_id is 5, it can have 5, 6, 9 image_posting_type_id
    in shr_image. If the posting_type_id is changed in CISROMM to 6, then shr_image
    records with image_posting_type_id with 5 should change to 7, 6 to 8, 9 to 10
    
    For example, if the posting_type_id is 5, it can have 5, 6, 9 image_posting_type_id
    in shr_image. If the posting_type_id is changed in CISROMM to 1, then shr_image
    records with image_posting_type_id with 5, or 6 or 9 to 1.
    
    For example, if the posting_type_id is 2, it can have 2 as image_posting_type_id
    in shr_image. If the posting_type_id is changed in CISROMM to 5, then shr_image
    records with image_posting_type_id with 2 should change to 6. Since 2 is hidden and 
    matching is image_posting_type_id 6 is also hidden.

*/

CURSOR cImgPostTypeId IS
select old_image_posting_type_id, new_image_posting_type_id
  from 
(SELECT distinct release_number_id,sipt.posting_type_id old_posting_type_id, sipt.image_posting_type_id old_image_posting_type_id,  IMAGE_POSTING_TYPE_NAME
  FROM shr_image si,
       shr_image_posting_type sipt 
 WHERE si.image_posting_type_id = sipt.image_posting_type_id
   AND si.release_number_id = p_release_number_id
   --AND si.adm_flag = 'V'
 ) a1,
  ( select release_number_id,rn.posting_type_id new_posting_type_id, sipt.image_posting_type_id new_image_posting_type_id,image_posting_type_name
     from shr_release_number rn,
          shr_image_posting_type sipt      
   where release_number_id = p_release_number_id
     and rn.posting_type_id = sipt.posting_type_id
     and rn.adm_flag = 'V'
 ) a2
 where  case when a2.new_posting_type_id < 5 then 
     a2.image_posting_type_name 
     else
      a1.image_posting_type_name
     end = a2.image_posting_type_name
   and a1.release_number_id = a2.release_number_id 
   and a1.old_posting_type_id <> a2.new_posting_type_id;
   
BEGIN

   FOR cImgPostTypeIdRow in cImgPostTypeId LOOP

    BEGIN
                 UPDATE SHR_IMAGE
                   SET image_posting_type_id = cImgPostTypeIdRow.new_image_posting_type_id
                 WHERE release_number_id = p_release_number_id
                   AND image_posting_type_id = cImgPostTypeIdRow.old_image_posting_type_id;
                   --AND adm_flag = 'V';
                   
                   COMMIT;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
             DBMS_OUTPUT.PUT_LINE(' no data found' );

         WHEN OTHERS THEN
             DBMS_OUTPUT.PUT_LINE(' others' );
    END; 
   END LOOP;
END PROC_UPDATE_IMAGE_POSTING_TYPE;
/
