-- snapshot_datetime = '2006-02-13 00:00:00'

set @snapshot_datetime = '2007-12-31 00:00:00';


-- breeding GVO
            select count(mouse_id) as mouse_number, line_name
            from   mice
                   left join imports         on mouse_import_id = import_id
                   left join litters         on mouse_litter_id = litter_id
                   left join mice2cages      on        mouse_id = m2c_mouse_id
                   left join cages2locations on     m2c_cage_id = c2l_cage_id
                   left join locations       on c2l_location_id = location_id
                   left join mouse_lines     on      mouse_line = line_id
            where  ( ( mouse_origin_type = 'import'
                       and import_datetime <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                       and mouse_is_gvo = 'y'
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                           )
                     )
                     or
                     ( mouse_origin_type = 'weaning'
                       and litter_weaning_datetime <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                       and mouse_is_gvo = 'y'
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                           )
                     )
                   )
                   and mouse_origin_type in ('import', 'weaning')
                   and m2c_datetime_from <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                   and (m2c_datetime_to  >  DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                        or
                        m2c_datetime_to IS NULL
                       )
                   and c2l_datetime_from <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                   and (c2l_datetime_to  >  DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                        or
                        c2l_datetime_to IS NULL
                       )
            group  by line_name;

-- breeding non-GVO
            select count(mouse_id) as mouse_number, line_name
            from   mice
                   left join imports         on mouse_import_id = import_id
                   left join litters         on mouse_litter_id = litter_id
                   left join mice2cages      on        mouse_id = m2c_mouse_id
                   left join cages2locations on     m2c_cage_id = c2l_cage_id
                   left join locations       on c2l_location_id = location_id
                   left join mouse_lines     on      mouse_line = line_id
            where  ( ( mouse_origin_type = 'import'
                       and import_datetime <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                       and mouse_is_gvo = 'n'
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                           )
                     )
                     or
                     ( mouse_origin_type = 'weaning'
                       and litter_weaning_datetime <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                       and mouse_is_gvo = 'n'
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                           )
                     )
                   )
                   and mouse_origin_type in ('import', 'weaning')
                   and m2c_datetime_from <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                   and (m2c_datetime_to  >  DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                        or
                        m2c_datetime_to IS NULL
                       )
                   and c2l_datetime_from <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                   and (c2l_datetime_to  >  DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                        or
                        c2l_datetime_to IS NULL
                       )
            group  by line_name;


-- experiment GVO
            select count(m2e_mouse_id) as mouse_number, line_name, experiment_name
            from   mice
                   left join imports         on   mouse_import_id = import_id
                   left join litters         on   mouse_litter_id = litter_id
                   left join mice2cages      on          mouse_id = m2c_mouse_id
                   left join cages2locations on       m2c_cage_id = c2l_cage_id
                   left join locations       on   c2l_location_id = location_id
                   join mice2experiments     on      m2e_mouse_id = mouse_id
                   join experiments          on m2e_experiment_id = experiment_id
                   left join mouse_lines     on      mouse_line = line_id
            where  ( ( mouse_origin_type = 'import'
                       and import_datetime <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                       and mouse_is_gvo = 'y'
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                           )
                     )
                     or
                     ( mouse_origin_type = 'weaning'
                       and litter_weaning_datetime <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                       and mouse_is_gvo = 'y'
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                           )
                     )
                   )
                   and
                   (m2e_datetime_from <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                   and
                   ( (m2e_datetime_to > DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                     or
                     (m2e_datetime_to is null)
                   )
                   and mouse_origin_type in ('import', 'weaning')
                   and m2c_datetime_from <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                   and (m2c_datetime_to  >  DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                        or
                        m2c_datetime_to IS NULL
                       )
                   and c2l_datetime_from <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                   and (c2l_datetime_to  >  DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                        or
                        c2l_datetime_to IS NULL
                       )
            group by line_name, m2e_experiment_id;


-- experiment non-GVO
            select count(m2e_mouse_id) as mouse_number, line_name, experiment_name
            from   mice
                   left join imports         on   mouse_import_id = import_id
                   left join litters         on   mouse_litter_id = litter_id
                   left join mice2cages      on          mouse_id = m2c_mouse_id
                   left join cages2locations on       m2c_cage_id = c2l_cage_id
                   left join locations       on   c2l_location_id = location_id
                   join mice2experiments     on      m2e_mouse_id = mouse_id
                   join experiments          on m2e_experiment_id = experiment_id
                   left join mouse_lines     on      mouse_line = line_id
            where  ( ( mouse_origin_type = 'import'
                       and import_datetime <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                       and mouse_is_gvo = 'n'
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                           )
                     )
                     or
                     ( mouse_origin_type = 'weaning'
                       and litter_weaning_datetime <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                       and mouse_is_gvo = 'n'
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                           )
                     )
                   )
                   and
                   (m2e_datetime_from <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                   and
                   ( (m2e_datetime_to > DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND))
                     or
                     (m2e_datetime_to is null)
                   )
                   and mouse_origin_type in ('import', 'weaning')
                   and m2c_datetime_from <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                   and (m2c_datetime_to  >  DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                        or
                        m2c_datetime_to IS NULL
                       )
                   and c2l_datetime_from <= DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                   and (c2l_datetime_to  >  DATE_SUB(@snapshot_datetime, INTERVAL 1 SECOND)
                        or
                        c2l_datetime_to IS NULL
                       )
            group by line_name, m2e_experiment_id;
