-- all living mice
select mouse_id, mouse_sex as sex, mouse_litter_id as litter, litter_mating_id as mating,
       line_name as line, c2l_location_id as rack , m2c_cage_id as cage, mouse_comment as comment
from   mice
       join mice2cages      on        mouse_id = m2c_mouse_id
       join cages2locations on     c2l_cage_id = m2c_cage_id
       join mouse_lines     on      mouse_line = line_id
       left join litters    on mouse_litter_id = litter_id
where  mouse_deathorexport_datetime IS NULL
       and          m2c_datetime_to IS NULL
       and          c2l_datetime_to IS NULL
order  by mouse_line asc, mouse_comment asc, mouse_id asc, mouse_sex desc;

