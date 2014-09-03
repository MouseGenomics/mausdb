-- number of matings in which current mouse was parent
select count(p2m_mating_id)
from   parents2matings
where  p2m_parent_id = 30063928;