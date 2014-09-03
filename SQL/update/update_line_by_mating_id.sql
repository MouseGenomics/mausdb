-- change line of mating and mice

-- example: update to line_id 211

-- update mating
select mating_line
from   matings
where  mating_id in (11611);


update matings
set    mating_line = 211
where  mating_id in (11611);


-- update mice already weaned from these matings
select mouse_id
from   mice
where  mouse_litter_id in (select litter_id
                           from   litters
                           where  litter_mating_id in (11611)
                          );

update mice
set    mouse_line = 211
where  mouse_litter_id in (select litter_id
                           from   litters
                           where  litter_mating_id in (11611)
                          );

