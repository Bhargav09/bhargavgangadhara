--Copyright (c) 2006 by Cisco Systems, Inc. -kdharmal

CREATE OR REPLACE TRIGGER iox_cco_trig
BEFORE INSERT ON iox_cco
FOR EACH ROW
DECLARE
v_image_id_seq iox_cco.image_id%TYPE;
BEGIN
    IF (INSERTING) THEN
     SELECT SHR_IMAGE_SEQ.NEXTVAL
       INTO v_image_id_seq
       FROM DUAL;
    :new.image_id := v_image_id_seq;
    END IF;       
END;