-- death_reasons for selection of mice

select mouse_id, mouse_earmark, mouse_sex, line_name, date(mouse_birth_datetime) as birth, mouse_deathorexport_datetime as death,
       dr1.death_reason_name as how, dr2.death_reason_name as why, import_owner_name as origin, mouse_import_id
from   mice
       join mouse_lines       on              mouse_line = line_id
       join death_reasons dr1 on mouse_deathorexport_how = dr1.death_reason_id
       join death_reasons dr2 on mouse_deathorexport_why = dr2.death_reason_id
       left join imports      on         mouse_import_id = import_id
where  mouse_line = 316
       and date(mouse_birth_datetime) between '2005-12-01' and '2006-02-01'
;
