use mausdb;
drop function if exists get_number_of_cagemates;
delimiter //

/**
CREATED: Holger Maier 2008-02-22
The function returns the total number of cage mates for a given mouse and timepoint (given in datetime format)
It will return 1-5 as valid number of cagemates for a given point in time (including given mouse)
It will return NULL if the given point in time is outside cage history of mouse (i.e. mouse did not live at given point in time)
*/

create function get_number_of_cagemates(
  mouseID   int
, timepoint datetime
)
returns int
READS SQL DATA
COMMENT 'returns the number of total cage mates (1-5) for a given mouse and timepoint (given in datetime format), returns NULL if timepoint outside cage history of mouse'

BEGIN

declare cageID    int;
declare cagemates int;

-- first step: identify the cage, in which the mouse was placed at the given point in time
select m2c_cage_id into cageID
from   mice2cages
where  m2c_mouse_id = mouseID
       and m2c_cage_id > 0
       and     m2c_datetime_from <= timepoint
       and (   m2c_datetime_to   >= timepoint
            or m2c_datetime_to   is NULL)
;

-- return NULL if timepoint is outside cage history of given mouse (mouse did not live at given point in time)
if (cageID is NULL) then
   return NULL;
end if;

-- second step: now we have identified the cage in which given mouse was placed at given point in time.
-- Now let's find all mice placed in this cage at same given point in time
select count(m2c_mouse_id) into cagemates
from   mice2cages
where  m2c_cage_id = cageID
       and     m2c_datetime_from <= timepoint
       and (   m2c_datetime_to   >= timepoint
            or m2c_datetime_to   is NULL)
;

-- optional: return -1 if number of cagemates is outside valid range (0-4)
-- if (cagemates < 0) then
--    return -1;
-- end if;
-- 
-- if (cagemates > 4) then
--    return -1;
-- end if;

return cagemates;

END;
//

delimiter ;





