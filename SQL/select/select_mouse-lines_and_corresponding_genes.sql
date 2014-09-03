-- List all mouse_lines and their corresponding genes:

select ml.line_name, g.gene_name
from mouse_lines ml
     left join mouse_lines2genes ml2g on ml2g.ml2g_mouse_line_id = ml.line_id
     left join genes g on g.gene_id = ml2g.ml2g_gene_id
order by ml.line_name, g.gene_name
;

