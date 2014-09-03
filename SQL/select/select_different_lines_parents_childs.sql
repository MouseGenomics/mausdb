-- mice with mouse line different from parents'
select distinct m1.mouse_litter_id,
--       m1.mouse_id as child_id,
       ml1.line_name as child_line,
       m2.mouse_id as father_id, ml2.line_name as father_line,
       m3.mouse_id as mother_id, ml3.line_name as mother_line
from   mice m1
       join litters2parents lp2 on m1.mouse_litter_id = lp2.l2p_litter_id
       join litters2parents lp3 on m1.mouse_litter_id = lp3.l2p_litter_id
       join mice m2         on            m2.mouse_id = lp2.l2p_parent_id
       join mice m3         on            m3.mouse_id = lp3.l2p_parent_id
       join mouse_lines ml1 on          m1.mouse_line = ml1.line_id
       join mouse_lines ml2 on          m2.mouse_line = ml2.line_id
       join mouse_lines ml3 on          m3.mouse_line = ml3.line_id
where  m1.mouse_origin_type in ('weaning', 'weaning_external')
       and m2.mouse_sex = 'm'
       and m3.mouse_sex = 'f'
       and m1.mouse_line <> m2.mouse_line
       and m1.mouse_line <> m3.mouse_line
limit 20
;



