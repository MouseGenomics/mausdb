-- job:    delete a mouse line
-- needed: line_id

-- 1) find out line_id of mouse line to be deleted
select line_id
from   mouse_lines
where  line_name like '%abc%'
;
-- choose one <line_id> from the above

-- 2) check if there are mice assigned to this line
select count(*)
from   mice
where  mouse_line = <line_id>
;
-- must be 0!

-- 3) check if there are matings assigned to this line
select count(*)
from   matings
where  mating_line = <line_id>
;
-- must be 0!

-- 4) check if there are imports assigned to this line
select count(*)
from   imports
where  import_line = <line_id>
;
-- must be 0!

-- 5) delete entry from mouse_lines
delete
from   mouse_lines
where  line_id = <line_id>
;

-- 6) delete related entry from GTAS_line_info
delete
from   GTAS_line_info
where  gli_mouse_line_id = <line_id>
;

-- 7) delete related entries from mouse_lines2genes
delete
from   mouse_lines2genes
where  ml2g_mouse_line_id = <line_id>
;

-- 8) delete related entries from line2blob_data
delete
from   line2blob_data
where  l2b_line_id = <line_id>
;

-- to be sure that neither mice nor matings or imports have been assigned to the mouse line
-- during steps 5)-8): repeat steps 2)-4)