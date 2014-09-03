select m2mr_mouse_id                                               as mouse_id,
       line_name                                                   as line,
       mouse_sex                                                   as sex,
       round(sum(IF(mr_parameter=1, mr_float,     NULL)), 2)       as mass,
             sum(IF(mr_parameter=2, mr_integer,   NULL))           as length
from   mice2medical_records
       join medical_records       on      m2mr_mr_id = mr_id
       join mice                  on        mouse_id = m2mr_mouse_id
       join mouse_lines           on      mouse_line = line_id
       join parameters            on    mr_parameter = parameter_id
where  m2mr_mouse_id          in (MYMOUSESELECTION)
       and mr_parameterset_id  =  1
       and mr_parameter    in (1, 2)
       and mr_orderlist_id    = MYORDERLIST_ID
group  by m2mr_mouse_id, mouse_sex
order  by mouse_sex
;


