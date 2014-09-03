-- ################################################
-- # add a mouse to another litter (caused by missing a mouse during weaning)
-- ################################################

-- assume we have 9 pups and weaned only 8 (forgot to wean one)
-- what to do?

-- 0) find out the litter_id to which the 8 belong (assume it is 3456)

-- 1) report and wean the 9th pup as a litter on its own using the web interface
--    assume it gets mouse_id 30060789 and litter_id 3457

-- 2) update the field "mouse_litter_id" for this mouse and set it to the litter
--    where the other 8 brothers and sisters are
update mice
set    mouse_litter_id = 3456
where  mouse_id = 30060789;

-- 3) delete the empty litter
delete
from   litters
where  litter_id = 3457;

-- 4) delete the lines in litters2parents that refer to the deleted litter
delete
from   litters2parents
where  l2p_litter_id = 3457;

-- Done!
--
-- (Best practice would be to block user interaction to the database by setting a global lock in the web interface)
