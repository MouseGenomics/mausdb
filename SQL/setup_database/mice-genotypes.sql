drop function if exists mice_genotypes;
delimiter //

create function mice_genotypes (mouse_ID int)
returns varchar(255)
READS SQL DATA
COMMENT 'Returns all genotypes for a mouse'
BEGIN

declare genotype_string   varchar(255);

set genotype_string = "unset";

select group_concat(concat(m2g_genotype, " (", gene_name, ")") ORDER BY m2g_gene_order SEPARATOR "; ") as genotypes
into   genotype_string
from   mice2genes
       join genes on m2g_gene_id = gene_id
where  m2g_mouse_id = mouse_ID
;

return genotype_string;

END;
//

delimiter ;






