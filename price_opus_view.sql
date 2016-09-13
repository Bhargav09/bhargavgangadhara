--Copyright (c) 2004 by Cisco Systems, Inc.
CREATE OR REPLACE VIEW PRICE_OPUS_VIEW ( ITEM_ID, 
PRODUCT_CODE, PRICE, LAST_UPDATE_DATE, DESCRIPTION
 ) AS SELECT
    op_items.item_id            ITEM_ID,
    op_items.item_name          PRODUCT_CODE,
    op_items.list_price         PRICE,
    op_items.last_update_date   LAST_UPDATE_DATE,
    op_items.description        DESCRIPTION
FROM
    CMF_PT_ITEMS@sj        op_items,
    CMF_PT_GROUP_TYPES@sj  op_group
WHERE
    op_items.GROUP_ID    = op_group.GROUP_ID AND
    op_items.LIST_PRICE  IS NOT NULL         AND
    op_group.STATUS_CODE IN ('A','P');
