-- ######################################################################################

-- check if cage occupation information is consistent (more than one current rack location)
select c2l_cage_id as cage, count(c2l_location_id) as current_locations
from   cages2locations
where  c2l_datetime_to is null
group  by c2l_cage_id
having current_locations > 1;

-- => must be empty set!

-- ######################################################################################

-- count free cages using two independent methods (must result in same number, of course)
select count(*)
from   cages
where            cage_id > 0
       and cage_occupied = 'y';

select count(*)
from   cages2locations
where  c2l_datetime_to is null
       and c2l_cage_id > 0;

-- => must be identical!

-- ######################################################################################

-- checking for living mice in wrong cage
select mouse_id, dr1.death_reason_name as how, dr2.death_reason_name as why, m2c_cage_id
from   mice
       join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
       join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
       join mice2cages        on             m2c_mouse_id = mouse_id
where  mouse_deathorexport_datetime IS NULL
       and m2c_datetime_to IS NULL
       and m2c_cage_id < 0;

-- => must be empty set!

-- ######################################################################################

-- Checking for living mice with wrong status
select mouse_id, dr1.death_reason_name as how, dr2.death_reason_name as why
from   mice
       join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
       join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
where  mouse_deathorexport_datetime IS NULL
       and (mouse_deathorexport_how <> 1
            or
            mouse_deathorexport_why <> 2
           );

-- => must be empty set!

-- ######################################################################################

-- checking for dead mice in wrong cage
select mouse_id, mouse_deathorexport_datetime, dr1.death_reason_name as how, dr2.death_reason_name as why, m2c_cage_id
from   mice
       join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
       join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
       join mice2cages        on             m2c_mouse_id = mouse_id
where  not (mouse_deathorexport_datetime IS NULL)
       and m2c_datetime_to IS NULL
       and m2c_cage_id > 0;

-- => must be empty set!

-- ######################################################################################

-- Checking for dead mice with wrong status
select mouse_id, mouse_deathorexport_datetime, dr1.death_reason_name as how, dr2.death_reason_name as why
from   mice
       join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
       join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
where  not (mouse_deathorexport_datetime IS NULL)
       and (mouse_deathorexport_how = 1
            OR
            mouse_deathorexport_why = 2
           );

-- => must be empty set!

-- ######################################################################################

-- checking for errors in mouse cage/location tables
select m2c_mouse_id as mouse_id, count(m2c_cage_id) as number_of_cages
from   mice2cages
where  m2c_datetime_to IS NULL
group  by mouse_id
having number_of_cages <> 1;

-- => must be empty set!

-- ######################################################################################

-- find mice where alive/dead status does not match experiment_end status
select mouse_id, mouse_deathorexport_datetime, m2e_datetime_to
from   mice
       join mice2experiments on mouse_id = m2e_mouse_id
where  ( (mouse_deathorexport_datetime is null and m2e_datetime_to is not null)
         or
         (mouse_deathorexport_datetime is not null and m2e_datetime_to is null)
       );

-- => must be empty set!

-- ######################################################################################

-- count alive mice using two independent methods (must result in same number, of course)
select count(*)
from   mice
where  mouse_deathorexport_datetime is null;

select count(*)
from   mice2cages
where  m2c_datetime_to is null 
       and m2c_cage_id > 0;

-- => must be identical!

-- if not identical, identify those which differ:
select m2c_mouse_id
from   mice2cages
where  m2c_datetime_to is null
       and m2c_cage_id > 0
       and m2c_mouse_id not in (select mouse_id
                                from   mice
                                where  mouse_deathorexport_datetime is null
                               )
;

-- the problem occurs when dating back a mating with mice that are already dead. This is explicitely enabled in
-- order to build up a stock long after the real events happened. When setting up such matings, the "dont move"
-- option must be checked in order to prevent moving dead mice to a real cage.

-- how to repair:
-- 1) show cages of mouse that causes the problem
select *
from   mice2cages
where  m2c_mouse_id = 30056089
order  by m2c_cage_of_this_mouse;

-- Result:
-- +--------------+-------------+------------------------+---------------------+---------------------+------------------+---------------------+
-- | m2c_mouse_id | m2c_cage_id | m2c_cage_of_this_mouse | m2c_datetime_from   | m2c_datetime_to     | m2c_move_user_id | m2c_move_datetime   |
-- +--------------+-------------+------------------------+---------------------+---------------------+------------------+---------------------+
-- |     30056089 |        1613 |                      1 | 2006-11-21 10:55:08 | 2006-11-28 13:25:53 |               62 | 2006-12-28 11:20:45 |
-- |     30056089 |        1655 |                      2 | 2006-11-28 13:25:53 | 2007-03-21 13:59:08 |               62 | 2006-12-28 13:26:01 |
-- |     30056089 |          -1 |                      3 | 2007-03-21 13:59:08 | 2007-03-16 14:39:00 |              132 | 2007-03-21 13:59:11 |
-- |     30056089 |         950 |                      4 | 2007-03-16 14:39:00 | NULL                |              132 | 2007-03-21 14:39:29 |
-- +--------------+-------------+------------------------+---------------------+---------------------+------------------+---------------------+

-- 2) delete last move to real cage:
-- delete
-- from   mice2cages
-- where                m2c_mouse_id = 30006114
--        and            m2c_cage_id = 1843
--        and m2c_cage_of_this_mouse = 11;
-- 
-- -- 3) re-null m2c_datetime_to from last but one cage (-1)
-- update mice2cages
-- set    m2c_datetime_to = NULL
-- where                m2c_mouse_id = 30006114
--        and            m2c_cage_id = -1
--        and m2c_cage_of_this_mouse = 10;



