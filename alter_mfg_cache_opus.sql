alter table mfg_cache_opus
add (PARENT_PRODUCT_NAME     VARCHAR2(18 BYTE) );

alter table mfg_cache_opus
add (PLATFORM_MANAGER_LIST     VARCHAR2(100 BYTE) );


alter table mfg_cache_opus
add release_manager_id varchar2(8) null;

