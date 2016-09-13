/**************************************************
Copyright (c) 2005-2006 by Cisco Systems, Inc.

Created for product code orderability enhancement project

Author: Selvaraj Aran (aselvara)
Date  : 10/16/2006
**************************************************/
/*This procedure returns whether pcode eixist in orderable tool or not(Y or N) and
the data when the pcode made visible in pricing tool
*/
CREATE  procedure get_pcode_orderable_state(
           p_product_code               in  varchar2,
           p_exist_in_orderable_tool    out varchar2,
           p_pricing_tool_visible_date  out date
          ) is
v_sample varchar2(10);
Begin
    SELECT decode(count(*),0,'N','Y')
    into p_exist_in_orderable_tool
    FROM xxcpd_orderable_products
    WHERE segment1 = p_product_code
    ;
    SELECT cre_date
    into  p_pricing_tool_visible_date
    FROM xxcpd_web_prod_maps
    WHERE product_id = p_product_code
    and rownum <2
    ;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       BEGIN
        NULL;
        --no need to take any action if the sqls don't return any value
       END;
END;
/
