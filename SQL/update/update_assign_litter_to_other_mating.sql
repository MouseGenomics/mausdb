-- #################################################
-- # assign an existing litter to another mating
-- #################################################

-- 1) litter_mating_id aendern
update litters
set    litter_mating_id = <new_mating_id>
where  litter_id = ?

-- 2) update litter order within mating if necessary
update litters
set    litter_in_mating = ?
where  litter_id = ?

-- 3) update parentships of litter
-- for all parents!!!
update litters2parents
set    l2p_parent_id = <new parent>
where  l2p_litter_id = ?
       and l2p_parent_id = <old_parent>

-- 4) update of line and strain of litter
update mice
set    mouse_line = ?
where  mouse_litter_id = ?

update mice
set    mouse_strain = ?
where  mouse_litter_id = ?