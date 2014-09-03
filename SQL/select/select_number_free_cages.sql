-- number of free cages
select count(*)
from   cages
where  cage_occupied = 'n';

