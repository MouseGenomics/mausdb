-- setting up workflows

-- in this example, two tasks are assigned to a workflow "Ship_mice"

insert into parametersets (parameterset_id, parameterset_name, parameterset_description, parameterset_project_id, parameterset_class, parameterset_display_order, parameterset_version, parameterset_version_datetime, parameterset_is_active) 
values
(1, 'QC_Genotype',        'QC_Genotype',       22, 4, 1, '', '2009-12-07 09:00:00', 'y');
(2, 'Pack_for_Shipping',  'Pack_for_Shipping', 22, 4, 1, '', '2009-12-07 09:00:00', 'y');


insert into workflows (workflow_id, workflow_name, workflow_description, workflow_is_active)
values
(10, 'Ship_mice', 'Ship_mice', 'y');


-- when mice are put to workflow "Ship_mice", that means:
-- orderlists for task 1 (QC_Genotype) are generated and are due 7 days after worklist reference date
-- orderlists for task 2 (Pack_for_Shipping) are generated and are due 14 days after worklist reference date
insert into workflows2parametersets (w2p_workflow_id, w2p_parameterset_id, w2p_days_from_ref_date)
values
(10, 1, 7),
(10, 2, 14);
