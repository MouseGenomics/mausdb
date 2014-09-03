-- ################################################
-- # changing the strain for all mice of an import 
-- ################################################

-- n mice have been imported in one batch (they share the same import_id), but the wrong strain was chosen at the first step of the import
-- updates of the tables imports and mice are necessary

-- 1) Select the import_ID of the wrong strain
select import_id, import_strain
from   imports
where  import_id = <integer>;

-- 2) Select the ID of the correct strain
select strain_id, strain_name
from   mouse_strains
where  strain_name like 'xyz%';

-- 3) update strain_id  in imports table
update imports
set    import_strain = <new strain_id>
where  import_id = <integer>;

-- 4) update strain_id in mice table
update mice
set    mouse_strain = <new strain_id>
where  mouse_import_id = <integer>;
