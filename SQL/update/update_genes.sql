-- first look genes assigned for lines selection
select line_id, line_name, gene_id, gene_name, gene_valid_qualifiers
from   mouse_lines
       join mouse_lines2genes on ml2g_mouse_line_id = line_id
       join genes             on       ml2g_gene_id = gene_id
where  line_name like 'EPD%';


-- update gene_info for lines selection
update mouse_lines
       join mouse_lines2genes on ml2g_mouse_line_id = line_id
       join genes             on       ml2g_gene_id = gene_id
set    gene_valid_qualifiers = concat(gene_valid_qualifiers, 'complete;high;medium;low;very low;')
where  line_name like 'EPD%';