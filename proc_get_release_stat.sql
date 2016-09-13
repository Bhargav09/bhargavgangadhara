--Copyright (c) 2003 by Cisco Systems, Inc.

CREATE OR REPLACE PROCEDURE PROC_GET_RELEASE_STAT
    (  p_RELEASE                  IN    VARCHAR2
    ,p_MAINTENANCE                IN    VARCHAR2
    ,p_MRENUMBER                  IN    VARCHAR2
    ,p_ED_DESIGNATOR              IN    VARCHAR2
    ,p_ED_RENUMBER                IN    VARCHAR2
    ,p_Out_release_state          OUT   NUMBER
    ,p_Out_message                OUT   VARCHAR2 )     IS

--Varibales declarations

    v_RELEASE                        IMAGE.RELEASE%TYPE;
    v_MAINTENANCE                    IMAGE.MAINTENANCE%TYPE;
    --v_MRENUMBER                      IMAGE.MRENUMBER%TYPE;
    v_MRENUMBER                      varchar2(10);
    v_ED_DESIGNATOR                  IMAGE.ED_DESIGNATOR%TYPE;
    v_ED_RENUMBER                    IMAGE.ED_RENUMBER%TYPE;


    null_param_exception            EXCEPTION;

    v_Out_release_state               NUMBER;
    l_v_Is_in_imagebuild              NUMBER;
    l_v_Is_in_product                 NUMBER;
    l_v_Is_in_mfg_cache_opus          NUMBER;
    l_v_Is_in_image                   NUMBER;
    l_v_Is_in_release_stat            NUMBER;
    l_v_Is_in_feature                 NUMBER;



BEGIN

-- get rid of spaces in the parameters

    v_RELEASE           :=trim(p_RELEASE);
    v_MAINTENANCE       :=trim(p_MAINTENANCE);
    v_MRENUMBER         :=trim(p_MRENUMBER);
    v_ED_DESIGNATOR     :=trim(p_ED_DESIGNATOR);
    v_ED_RENUMBER       :=trim(p_ED_RENUMBER);

      p_Out_message := 'Success'; --Initialize to success

      IF (   v_RELEASE       IS NULL OR v_MAINTENANCE  IS NULL )  THEN
        RAISE null_param_exception;
      END IF;

        BEGIN
           SELECT count(1) INTO l_v_Is_in_imagebuild
           FROM imagebuild
           WHERE buildnum=replace(replace(replace(v_RELEASE,'.','')||'-'||v_MAINTENANCE||v_MRENUMBER||
                             decode(v_ED_DESIGNATOR,'','','.'||v_ED_DESIGNATOR||v_ED_RENUMBER),'(','.'),')','')
           ;

           SELECT distinct count(distinct pcode_sys) INTO l_v_Is_in_product
           FROM product
           WHERE key in( SELECT seq FROM feature
                         WHERE release                  = v_RELEASE
                         AND   maintenance              = v_MAINTENANCE
                         AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
                         AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
                         AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
                         AND   pcode_sys                IS NOT NULL)
                        ;
            SELECT count(product_name) INTO l_v_Is_in_mfg_cache_opus
            FROM mfg_cache_opus
            WHERE rel             = v_RELEASE
            AND   maint           = v_MAINTENANCE
            AND   nvl(mren,'N')   = nvl(v_MRENUMBER     ,'N')
            AND   nvl(ed ,'N')    = nvl(v_ED_DESIGNATOR ,'N')
            AND   nvl(edr,'N')    = nvl(v_ED_RENUMBER   ,'N')
            ;

           SELECT distinct count(1) INTO l_v_Is_in_image
           FROM image
           WHERE release                  = v_RELEASE
           AND   maintenance              = v_MAINTENANCE
           AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
           AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
           AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
           ;
           SELECT distinct count(1) INTO l_v_Is_in_release_stat
           FROM image
           WHERE release                  = v_RELEASE
           AND   maintenance              = v_MAINTENANCE
           AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
           AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
           AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
           ;

           SELECT distinct count(1) INTO l_v_Is_in_feature
           FROM feature
           WHERE release                  = v_RELEASE
           AND   maintenance              = v_MAINTENANCE
           AND   nvl(mrenumber     ,'N')  = nvl(v_MRENUMBER     ,'N')
           AND   nvl(ed_designator ,'N')  = nvl(v_ED_DESIGNATOR ,'N')
           AND   nvl(ed_renumber   ,'N')  = nvl(v_ED_RENUMBER   ,'N')
           ;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             BEGIN
               p_Out_message := substr(sqlerrm,1,512);
             END;
        END;


       v_Out_release_state :=0;

      IF( (l_v_Is_in_imagebuild >=1 OR l_v_Is_in_feature >=1) AND l_v_Is_in_product < 1  AND l_v_Is_in_mfg_cache_opus < 1)   THEN
            v_Out_release_state :=10;
        ELSIF(l_v_Is_in_imagebuild < 1  AND l_v_Is_in_product >= 1 AND l_v_Is_in_mfg_cache_opus < 1)   THEN
            v_Out_release_state :=20;
        ELSIF(l_v_Is_in_imagebuild < 1  AND l_v_Is_in_product < 1  AND l_v_Is_in_mfg_cache_opus >= 1)  THEN
            v_Out_release_state :=30;
        ELSIF(l_v_Is_in_imagebuild >= 1 AND l_v_Is_in_product >= 1 AND l_v_Is_in_mfg_cache_opus < 1)   THEN
            v_Out_release_state :=1020;
        ELSIF(l_v_Is_in_imagebuild >= 1 AND l_v_Is_in_product < 1  AND l_v_Is_in_mfg_cache_opus >= 1)  THEN
            v_Out_release_state :=1030;
        ELSIF(l_v_Is_in_imagebuild < 1  AND l_v_Is_in_product >= 1 AND l_v_Is_in_mfg_cache_opus >= 1)  THEN
            v_Out_release_state :=2030;
        ELSIF(l_v_Is_in_imagebuild >= 1 AND l_v_Is_in_product >= 1 AND l_v_Is_in_mfg_cache_opus >= 1)  THEN
            v_Out_release_state :=102030;
        ELSIF(l_v_Is_in_imagebuild < 1  AND l_v_Is_in_product < 1  AND l_v_Is_in_mfg_cache_opus < 1)   THEN
            v_Out_release_state :=-5;
           --DBMS_OUTPUT.PUT_LINE('Release_state is inside get_release_stet else part-delte '|| v_Out_release_state);

      END IF;

      IF(l_v_Is_in_image < 1 OR l_v_Is_in_release_stat < 1) THEN
         v_Out_release_state:=-1;
      END IF;

       p_Out_release_state := v_Out_release_state;

     EXCEPTION

     WHEN null_param_exception THEN
     BEGIN
         p_Out_message := 'Warning: NULL parameters found check parameters value! '
                          ||' Release         = ' ||v_RELEASE
                          ||' Maintenance     = ' ||v_MAINTENANCE
                          ||' Mrenumber       = ' ||v_MRENUMBER
                          ||' Ed_designator   = ' ||v_ED_DESIGNATOR
                          ||' Ed_Renumber     = ' ||v_ED_RENUMBER
                         ;
     END;

     WHEN NO_DATA_FOUND THEN
     BEGIN
         p_Out_message := substr(sqlerrm,1,512);
     END;

     WHEN OTHERS THEN
     BEGIN
         p_Out_message := 'OTHERS BLOCK '||substr(sqlerrm,1,512);
         --RAISE_APPLICATION_ERROR(-20001, p_Out_message);
     END;
END;
