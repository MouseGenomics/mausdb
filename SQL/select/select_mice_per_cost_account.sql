-- number of mice grouped by cost acccounts

select count(m2ca_mouse_id), cost_account_id, cost_account_name
from   mice2cost_accounts
       join cost_accounts on cost_account_id = m2ca_cost_account_id
group  by cost_account_id;
