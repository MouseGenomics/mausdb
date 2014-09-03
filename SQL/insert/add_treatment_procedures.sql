-- setting up treatment procedures

insert
into   treatment_procedures (tp_id, tp_treatment_name, tp_treatment_description, tp_treatment_full_protocol, tp_treatment_type,
                             tp_application_type, tp_applied_substance, tp_applied_substance_amount, tp_applied_substance_amount_unit,
                             tp_applied_substance_concentration, tp_applied_substance_concentration_unit, tp_applied_substance_volume,
                             tp_applied_substance_volume_unit, tp_application_medium, tp_application_purpose, tp_treatment_project,
                             tp_treatment_deprecated_since)
values
(1, 'ENU injection',      'ENU injection',      'ENU injection full protocol',      'injection', 'i.p.', 'ENU',                 3.0,  'ug',  10,   'ug/ml',  0.3, 'ml', '0,1 % PBS', 'mutagenesis', 1, NULL),
(2, 'Listeria infection', 'Listeria infection', 'Listeria infection full protocol', 'injection', 'i.p.', 'Listeria suspension', 1000, 'cfu', 1000, 'cfu/ml', 1.0, 'ml', '0,1 % PBS', 'infection',   1, '2008-01-01');

