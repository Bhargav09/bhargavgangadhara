

CREATE OR REPLACE FUNCTION get_pcode(p_image_feature_set_id IN NUMBER
                         ,p_pcode_group_id IN NUMBER
                         ,p_code_type IN VARCHAR2)
RETURN VARCHAR2
IS
    l_pcode          varchar2(200);
BEGIN
      SELECT decode(p_code_type,'main',pcode_main,
                                       pcode_spare) INTO l_pcode
      FROM shr_pcode sp
           ,shr_release_pcode_group srpg
      WHERE sp.release_pcode_group_id=srpg.release_pcode_group_id
          AND sp.image_feature_set_id=p_image_feature_set_id
          AND sp.image_feature_set_id =p_image_feature_set_id
          AND srpg.pcode_group_id     =p_pcode_group_id
          AND sp.adm_flag='V'
          AND srpg.adm_flag='V'
          AND rownum < 2
     ;
    RETURN l_pcode;
END get_pcode;
/
