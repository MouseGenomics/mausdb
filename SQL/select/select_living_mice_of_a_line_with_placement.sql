-- all living mice for a mouse line (id)
select line_name, mouse_id, mouse_sex as sex, c2l_location_id as rack_id, location_name as rack, m2c_cage_id as cage, mouse_comment
from   mice
       join mice2cages      on    mouse_id = m2c_mouse_id
       join cages2locations on c2l_cage_id = m2c_cage_id
       join locations       on location_id = c2l_location_id
       join mouse_lines     on  mouse_line = line_id
where  mouse_line = 4
       and mouse_deathorexport_datetime IS NULL
       and m2c_datetime_to IS NULL
       and c2l_datetime_to IS NULL
order  by mouse_comment asc;

