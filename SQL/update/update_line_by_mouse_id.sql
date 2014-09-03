-- ################################################
-- # changing the line for selected mice
-- ################################################

-- n mice have been imported in one batch (they share the same import_id), but the wrong line was chosen at the first step of the import
-- updates of the tables imports and mice are necessary

-- 1) Select the ID of the correct line
select line_id, line_name
from   mouse_lines
where  line_name like 'xyz%';

-- 2) update line_id in imports table
update imports
set    import_line = <new line_id>
where    import_id = <import_id>;

-- 3) now update mice themselves
update mice
set    mouse_line = <new line_id>
where  mouse_line = <old line_id>
       and mouse_id between 30059293 and 30059297;

-- 4) update line_id in mice table
update mice
set         mouse_line = <new line_id>
where  mouse_import_id = <import_id>;
