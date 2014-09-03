drop function if exists mr2string;
delimiter //

create function mr2string (medical_record_ID int)
returns varchar(255)
READS SQL DATA
COMMENT 'Returns the value of a medical record as string'
BEGIN

/** DESCRIPTION:
--------------------
converts medical record values of different types to a string
*/
/** HISTORY:
created:  2007-12-13 wapar
modified: 2008-06-16 Holger Maier
*/

declare valtyp   char(1);
declare intval   int;
declare floatval float;
declare boolval  bit;
declare textval  longtext;
declare retval   varchar(255);

set retval = 'unset';

select  parameter_type, mr_integer, mr_float, mr_bool, mr_text
into    valtyp,         intval,     floatval, boolval, textval
from    parameters
        join medical_records on parameter_id = mr_parameter
where   mr_id = medical_record_ID
;

if (valtyp = 'f') then
   select convert(floatval, CHAR) into retVal;
end if;
if (valtyp = 'i') then
   select convert(intval, CHAR)   into retVal;
end if;
if (valtyp = 'b') then
   select convert(boolval, CHAR)  into retVal;
end if;
if (valtyp = 'c') then
   select convert(textval, CHAR)  into retVal;
end if;

return retVal;

END;
//

delimiter ;
