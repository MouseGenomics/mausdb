-- #################################################
-- # insert a new gene/locus 'xyz'
-- #################################################

-- 1) get next gene_id
select max(gene_id) + 1
from   genes;

-- 2) check if gene/locus already exists
select *
from   genes
where  gene_name like '%xyz%';

-- 3) insert with gene_id from 1)
insert
into   genes (gene_id, gene_name, gene_shortname, gene_description, gene_valid_qualifiers)
values (<gene_id>, 'TX', 'TX', 'TX', '+/-;+/+;-/-;');

-- 4) add linkage between line_id and gene_id in table mouse_lines2genes:
insert into mouse_lines2genes (ml2g_mouse_line_id,  ml2g_gene_id,  ml2g_gene_order) values (<line_id>, <gene_id>, 1);
