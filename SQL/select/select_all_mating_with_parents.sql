-- all matings with some attributes
select mating_id, transfer_id, mating_matingstart_datetime as mating_start,
       pm1.p2m_parent_id as father, m1.mouse_sex as sex, l1.line_name,
       pm2.p2m_parent_id as mother, m2.mouse_sex as sex, l2.line_name
from   matings
       left join embryo_transfers    on transfer_mating_id= mating_id
       left join parents2matings pm1 on pm1.p2m_mating_id = mating_id
       left join parents2matings pm2 on pm2.p2m_mating_id = mating_id
       left join mice m1             on pm1.p2m_parent_id = m1.mouse_id
       left join mice m2             on pm2.p2m_parent_id = m2.mouse_id
       left join mouse_lines l1      on        l1.line_id = m1.mouse_line
       left join mouse_lines l2      on        l2.line_id = m2.mouse_line
where  m1.mouse_sex = 'm'
and    m2.mouse_sex = 'f'
order  by mating_id asc;
