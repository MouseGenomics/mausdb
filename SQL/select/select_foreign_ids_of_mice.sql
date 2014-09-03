-- get foreign ids for selected mice

select mouse_id, mouse_import_id, mouse_litter_id, property_value_text as foreign_ID
from   mice
       left join mice2properties on    m2pr_mouse_id = mouse_id
       left join properties      on m2pr_property_id = property_id
where        mouse_line = 171
       and (   property_key = 'foreignID'
            or property_key IS NULL)
;