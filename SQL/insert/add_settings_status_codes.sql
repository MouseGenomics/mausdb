-- add status code settings
-- IMPORTANT: status code has to be flanked by '_', e.g. "_DIED_" in order to be recognized as status code on data upload
insert
into   settings
values (null, 'menu', 'mr_status_codes', '', 'text', NULL, '_REJECTED_', NULL, NULL, '');