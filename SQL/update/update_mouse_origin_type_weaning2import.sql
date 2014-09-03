-- Change the mouse origin type from import to weaning for a mouse that was forgotten at weaning and entered later as an import:


-- 1. Check mouse birthdate and time of the litter

select litter_born_datetime
from litters
where litter_id = 12950;

-- 2. Change the number of pups in the litter

update litters
set  litter_alive_male = 3
where litter_id = 12950;

-- 3. Change values in the mice table

update mice
set mouse_origin_type = 'weaning', mouse_litter_id = 12950, mouse_import_id = NULL, mouse_birth_datetime = '2008-08-26 10:53:00', mouse_comment = NULL
where mouse_origin_type = 'import' and
      mouse_id = 30098294;


-- 4. Delete the import

delete from imports where import_id = 1378;