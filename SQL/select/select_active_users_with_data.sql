-- projects, users with contacts
select contact_last_name as last_name, contact_first_name as first_name, user_name, user_id, user_status, project_name, user_id, project_id
from   users
       left join users2projects on    u2p_user_id = user_id
       left join projects       on u2p_project_id = project_id
       left join contacts       on     contact_id = user_contact
where  user_status = 'active'
order  by last_name;