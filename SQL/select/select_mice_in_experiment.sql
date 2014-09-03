-- mice by experimental license

select mouse_id, strain_name, line_name, experiment_name, m2e_datetime_from
from  mice
      join mouse_lines      on    mouse_line = line_id
      join mouse_strains    on  mouse_strain = strain_id
      join mice2experiments on      mouse_id = m2e_mouse_id
      join experiments      on experiment_id = m2e_experiment_id
where mouse_id in (select m2e_mouse_id
                   from   mice2experiments
                   where  m2e_experiment_id in (1, 2, 3, 6, 8)
                          and m2e_datetime_to is null
                  );

select mouse_id, strain_name, line_name, experiment_name, m2e_datetime_from
from  mice
      join mouse_lines      on    mouse_line = line_id
      join mouse_strains    on  mouse_strain = strain_id
      join mice2experiments on      mouse_id = m2e_mouse_id
      join experiments      on experiment_id = m2e_experiment_id
where mouse_id in (select m2e_mouse_id
                   from   mice2experiments
                   where  m2e_experiment_id in (3, 6, 8)
                          and m2e_datetime_to is null
                  );

