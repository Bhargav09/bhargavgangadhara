CREATE OR REPLACE PACKAGE SHR_RDA.IRE_BUILD AS

/* Copyright (c) 2005-2008 by cisco Systems, Inc. All rights reserved. */

    PROCEDURE upd_platform_crypto_approval (
            in_image_prefix               in  varchar2,
            in_is_crypto_approved      in  varchar2,
            out_status_msg          out varchar2 );

END IRE_BUILD;
/


CREATE OR REPLACE PACKAGE BODY SHR_RDA.IRE_BUILD AS

    PROCEDURE upd_platform_crypto_approval (
            in_image_prefix               in  varchar2,
            in_is_crypto_approved      in  varchar2,
            out_status_msg          out varchar2 )
    IS
        v_exist             number := 0;
    BEGIN

    if( in_image_prefix is null ) then
        out_status_msg  := 'Image Prefix can not be null.';
        return;
    end if;

    if( in_is_crypto_approved != 'Y'  and  in_is_crypto_approved != 'N' ) then
        out_status_msg  :=  'crypto_approved value can be Y or N';
        return;
    end if;


    select
        count(*)
    into v_exist
    from
        shr_image_prefix
    where
        image_prefix_name = in_image_prefix;

    if( v_exist = 0 ) then
        INSERT INTO SHR_RDA.SHR_IMAGE_PREFIX (IMAGE_PREFIX_ID, IMAGE_PREFIX_NAME, ADM_TIMESTAMP, 
                    ADM_FLAG, ADM_USERID, ADM_COMMENT, IS_CRYPTO_APPROVED) 
        VALUES ( SHR_IMAGE_PREFIX_SEQ.nextval, in_image_prefix, sysdate, 'V', 'cms', 'Created by IRE Build Team', in_is_crypto_approved);
    else
        update shr_image_prefix
            set is_crypto_approved = in_is_crypto_approved
        where
            image_prefix_name = in_image_prefix;
    end if;

    out_status_msg  := 'Success';
    return;

    EXCEPTION
              when OTHERS then
                     out_status_msg  := 'Error: ' || substr(sqlerrm,1,500);

              return;

     END upd_platform_crypto_approval;
END IRE_BUILD;
/