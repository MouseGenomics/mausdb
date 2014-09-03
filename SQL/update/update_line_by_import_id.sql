-- ################################################
-- # changing the line for all mice of an import 
-- ################################################

-- n mice have been imported in one batch (they share the same import_id), but the wrong line was chosen at the first step of the import
-- updates of the tables imports and mice are necessary

-- 1) Select the import_ID of the wrong line / check line
select import_id, import_line
from   imports
where  import_id = <integer>;

-- 2) Select the ID of the correct line
select line_id, line_name
from   mouse_lines
where  line_name like 'xyz%';

-- 3) update line_id  in imports table
update imports
set    import_line = <new line_id>
where    import_id = <integer>;

-- 4) update line_id in mice table
update mice
set    mouse_line = <new line_id>
where  mouse_import_id = <integer>;

