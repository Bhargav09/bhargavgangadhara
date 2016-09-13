--Copyright (c) 2004 by Cisco Systems, Inc.
CREATE OR REPLACE VIEW PRICE_ERP_VIEW ( INVENTORY_ITEM_ID, 
PRODUCT_CODE, PRICE, LAST_UPDATE_DATE, ENABLED_FLAG, 
START_DATE_ACTIVE, END_DATE_ACTIVE, DESCRIPTION ) AS SELECT
        msi.inventory_item_id    INVENTORY_ITEM_ID,
        msi.segment1             PRODUCT_CODE,
        qpll.list_price          PRICE,
        msi.last_update_date     LAST_UPDATE_DATE,
        msi.enabled_flag         ENABLED_FLAG,
        msi.start_date_active    START_DATE_ACTIVE,
        msi.end_date_active      END_DATE_ACTIVE,
        msi.description          DESCRIPTION
FROM
        QP_PRICE_LIST_LINES_V@sj  qpll,
        QP_LIST_HEADERS_B@sj      qplh,
        MTL_SYSTEM_ITEMS_B@sj     msi,
        QP_LIST_HEADERS_TL@sj     qplht
WHERE
        qpll.list_price       IS NOT NULL                  AND
        msi.inventory_item_id = qpll.inventory_item_id     AND
        msi.organization_id   = 1                          AND
        qpll.price_list_id    = qplh.list_header_id        AND
        qplht.list_header_id = qpll.price_list_id          AND
		qplht.list_header_id  = qplh.list_header_id        AND
		qplht.name            = 'Global Price List - US';

