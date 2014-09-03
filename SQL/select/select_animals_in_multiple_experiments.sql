-- mice with more than one experimental assignment

select m2e_mouse_id, count(m2e_experiment_id) as number
from   mice2experiments
group  by m2e_mouse_id
having number > 1;