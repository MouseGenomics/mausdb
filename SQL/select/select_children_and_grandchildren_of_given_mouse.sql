-- 2 generation offspring for a mouse (children + grandchildren)
set @parent = 30063928;

select mouse_id, mouse_litter_id
from   mice
where  
--     mice from 1. generation (children)
       mouse_id in (select m1.mouse_id
                    from   mice m0
                           join litters2parents lp0 on  lp0.l2p_parent_id = m0.mouse_id
                           join mice m1             on m1.mouse_litter_id = lp0.l2p_litter_id
                    where  m0.mouse_id in (@parent)
                   )
--     mice from 2. generation (grandchildren)
       or mouse_litter_id in (select distinct l2p_litter_id as litter2
                           from   litters2parents
                           where  l2p_parent_id in (select m2.mouse_id
                                                    from   mice m3
                                                           join litters2parents lp3 on  lp3.l2p_parent_id = m3.mouse_id
                                                           join mice m2             on m2.mouse_litter_id = lp3.l2p_litter_id
                                                    where  m3.mouse_id in (@parent)
                                                   )
                          )
;
