-- non-weaned litter
select litter_id, litter_mating_id as mating_id, litter_in_mating,
       litter_born_datetime, datediff(curdate(), date(litter_born_datetime)) as litter_age, project_shortname
from   litters
       join matings  on      mating_id = litter_mating_id
       join projects on mating_project = project_id
where  litter_weaning_datetime IS NULL
order  by litter_born_datetime asc;