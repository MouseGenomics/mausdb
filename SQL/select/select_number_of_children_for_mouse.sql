-- number of direct offspring for a mouse
select count(mouse_id)
from   mice
where  mouse_litter_id in (select l2p_litter_id
                           from   litters2parents
                           where  l2p_parent_id = 30063928
                          )
;
