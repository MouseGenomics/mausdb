-- all mouse lines with number of currently living mice
select mouse_line, line_name as line, count(mouse_id) as mice_from_this_line
from   mice
       join mouse_lines on mouse_line = line_id
where  mouse_deathorexport_datetime is null
group  by mouse_line
order  by line_name;

