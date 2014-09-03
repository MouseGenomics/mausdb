use mausdb;
drop function if exists get_simple_value_for_mouse_p_ps;
delimiter //

/**
CREATED: Holger Maier 2009-02-27
The function returns the value of a simple parameter for a given mouse, parameter, parameterset
*/

create function get_simple_value_for_mouse_p_ps(
  mouseID       int
, parameter     int
, parameter_set int
)
returns varchar(20)
READS SQL DATA
COMMENT 'returns the value of a simple parameter for a given mouse, parameter, parameterset'

BEGIN

declare valtyp   char(1);
declare intval   int;
declare floatval float;
declare retval   varchar(255);

set retval = 'unset';

select  parameter_type, mr_integer, mr_float
into    valtyp,         intval,     floatval
from    mice2medical_records
        join medical_records on m2mr_mr_id = mr_id
        join      parameters on parameter_id = mr_parameter
where            m2mr_mouse_id = mouseID
        and       mr_parameter = parameter
        and mr_parameterset_id = parameter_set
limit   1
;

if (valtyp = 'f') then
   select convert(floatval, CHAR) into retVal;
end if;
if (valtyp = 'i') then
   select convert(intval, CHAR)   into retVal;
end if;

return retVal;

END;
//

delimiter ;
