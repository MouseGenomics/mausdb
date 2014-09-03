-- snapshot_datetime = '2006-02-13 00:00:00'

set @snapshot_datetime = '2007-12-31 00:00:00';

-- total living GVO animals at snapshot_datetime
select count(*) as number_total_living_gvo
from   mice
       left join imports on mouse_import_id = import_id
       left join litters on mouse_litter_id = litter_id
where  ( ( mouse_origin_type = 'import'
           and import_datetime <= @snapshot_datetime
           and mouse_is_gvo = 'y'
           and ( (mouse_deathorexport_datetime is null)
                 or
                 (mouse_deathorexport_datetime > @snapshot_datetime)
               )
         )
         or
         ( mouse_origin_type = 'weaning'
           and litter_weaning_datetime <= @snapshot_datetime
           and mouse_is_gvo = 'y'
           and ( (mouse_deathorexport_datetime is null)
                 or
                 (mouse_deathorexport_datetime > @snapshot_datetime)
               )
         )
       );


-- total living non-GVO animals at snapshot_datetime
select count(*) as number_total_living_non_gvo
from   mice
       left join imports on mouse_import_id = import_id
       left join litters on mouse_litter_id = litter_id
where  ( ( mouse_origin_type = 'import'
           and import_datetime <= @snapshot_datetime
           and mouse_is_gvo = 'n'
           and ( (mouse_deathorexport_datetime is null)
                 or
                 (mouse_deathorexport_datetime > @snapshot_datetime)
               )
         )
         or
         ( mouse_origin_type = 'weaning'
           and litter_weaning_datetime <= @snapshot_datetime
           and mouse_is_gvo = 'n'
           and ( (mouse_deathorexport_datetime is null)
                 or
                 (mouse_deathorexport_datetime > @snapshot_datetime)
               )
         )
       );


-- total living GVO animals in experiment at snapshot_datetime
select count(m2e_mouse_id), experiment_name
from   mice
       left join imports     on   mouse_import_id = import_id
       left join litters     on   mouse_litter_id = litter_id
       join mice2experiments on      m2e_mouse_id = mouse_id
       join experiments      on m2e_experiment_id = experiment_id
where  ( ( mouse_origin_type = 'import'
           and import_datetime <= @snapshot_datetime
           and mouse_is_gvo = 'y'
           and ( (mouse_deathorexport_datetime is null)
                 or
                 (mouse_deathorexport_datetime > @snapshot_datetime)
               )
         )
         or
         ( mouse_origin_type = 'weaning'
           and litter_weaning_datetime <= @snapshot_datetime
           and mouse_is_gvo = 'y'
           and ( (mouse_deathorexport_datetime is null)
                 or
                 (mouse_deathorexport_datetime > @snapshot_datetime)
               )
         )
       )
       and
       (m2e_datetime_from <= @snapshot_datetime)
       and
       ( (m2e_datetime_to > @snapshot_datetime)
         or
         (m2e_datetime_to is null)
       )
group by m2e_experiment_id;


-- total living non-GVO animals in experiment at snapshot_datetime
select count(m2e_mouse_id), experiment_name
from   mice
       left join imports     on   mouse_import_id = import_id
       left join litters     on   mouse_litter_id = litter_id
       join mice2experiments on      m2e_mouse_id = mouse_id
       join experiments      on m2e_experiment_id = experiment_id
where  ( ( mouse_origin_type = 'import'
           and import_datetime <= @snapshot_datetime
           and mouse_is_gvo = 'n'
           and ( (mouse_deathorexport_datetime is null)
                 or
                 (mouse_deathorexport_datetime > @snapshot_datetime)
               )
         )
         or
         ( mouse_origin_type = 'weaning'
           and litter_weaning_datetime <= @snapshot_datetime
           and mouse_is_gvo = 'n'
           and ( (mouse_deathorexport_datetime is null)
                 or
                 (mouse_deathorexport_datetime > @snapshot_datetime)
               )
         )
       )
       and
       (m2e_datetime_from <= @snapshot_datetime)
       and
       ( (m2e_datetime_to > @snapshot_datetime)
         or
         (m2e_datetime_to is null)
       )
group by m2e_experiment_id;

