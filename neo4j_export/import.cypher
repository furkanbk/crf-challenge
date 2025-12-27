// Neo4j Import Script for Medical Knowledge Graph
// Generated automatically from triplet data

-- Create constraints for unique IDs
CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalReport) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalFeature) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalEntity) REQUIRE n.id IS UNIQUE;

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS FOR (n:MedicalEntity) ON (n.name);
CREATE INDEX IF NOT EXISTS FOR (n:MedicalFeature) ON (n.name);
CREATE INDEX IF NOT EXISTS FOR ()-[r:RELATED_TO]-() ON (r.feature_context);

-- Import nodes
-- Import MedicalReport nodes
CREATE (:MedicalReport {id: 'report_0', });
CREATE (:MedicalReport {id: 'report_7', report_index: '7'});
CREATE (:MedicalReport {id: 'report_8', report_index: '8'});
CREATE (:MedicalReport {id: 'report_1', report_index: '1'});
CREATE (:MedicalReport {id: 'report_2', report_index: '2'});
-- ... and 5 more MedicalReport nodes

-- Import MedicalFeature nodes
CREATE (:MedicalFeature {id: 'feature_spo2', name: 'spo2', category: 'General'});
CREATE (:MedicalFeature {id: 'feature_presence_of_dyspnea', name: 'presence of dyspnea', category: 'General'});
CREATE (:MedicalFeature {id: 'feature_active_neoplasia', name: 'active neoplasia', category: 'General'});
CREATE (:MedicalFeature {id: 'feature_respiratory_rate', name: 'respiratory rate', category: 'Vital Sign'});
CREATE (:MedicalFeature {id: 'feature_blood_pressure', name: 'blood pressure', category: 'Vital Sign'});
-- ... and 19 more MedicalFeature nodes

-- Import MedicalEntity nodes
CREATE (:MedicalEntity {id: 'entity_36_8_95', name: '36.8', entity_type: 'Entity'});
CREATE (:MedicalEntity {id: 'entity_conscious_11', name: 'conscious', entity_type: 'Entity'});
CREATE (:MedicalEntity {id: 'entity_18_apm_93', name: '18 apm', entity_type: 'Vital Sign'});
CREATE (:MedicalEntity {id: 'entity_cad_62', name: 'CAD', entity_type: 'Disease'});
CREATE (:MedicalEntity {id: 'entity_none_known_3', name: 'none known', entity_type: 'Entity'});
-- ... and 107 more MedicalEntity nodes

-- Import relationships
-- Import ADMITTED_FOR relationships
-- 1 relationships of type ADMITTED_FOR
MATCH (a), (b) WHERE a.id = 'entity_patient_36' AND b.id = 'entity_left_knee_injury_37' CREATE (a)-[:ADMITTED_FOR {relation_text: 'admitted for', feature_context: 'history of recent trauma', report_id: '2', evidence: 'Patient admitted to the CTO ER for left knee injury, X-ray evidence of supracondylar fracture of the left femur.', reasoning: 'The admission to the emergency room due to a left knee injury and subsequent diagnosis of a fracture indicates recent trauma.'}]->(b);

-- Import IS_A_FORM_OF relationships
-- 1 relationships of type IS_A_FORM_OF
MATCH (a), (b) WHERE a.id = 'entity_arterial_hypertension_48' AND b.id = 'entity_vascular_disease_49' CREATE (a)-[:IS_A_FORM_OF {relation_text: 'is a form of', feature_context: 'diffuse vascular disease', report_id: '3', evidence: '-[DETAILED_DESCRIPTION] Arterial[/DETAILED_DESCRIPTION][DISEASE_DISORDER] hypertension[/DISEASE_DISORDER]', reasoning: 'Hypertension is a type of vascular disease, and its presence in the medical history supports this feature.'}]->(b);

-- Import IS_A_TYPE_OF relationships
-- 1 relationships of type IS_A_TYPE_OF
MATCH (a), (b) WHERE a.id = 'entity_diabetes_mellitus_type_2_0' AND b.id = 'entity_metabolic_disorder_1' CREATE (a)-[:IS_A_TYPE_OF {relation_text: 'is a type of', feature_context: 'chronic metabolic failure', evidence: '-[DISEASE_DISORDER] Diabetes mellitus type 2[/DISEASE_DISORDER]', reasoning: 'The presence of diabetes mellitus type 2 in the past medical history indicates chronic metabolic failure.'}]->(b);

-- Import INCLUDES_MULTIPLE_MEDICATIONS relationships
-- 1 relationships of type INCLUDES_MULTIPLE_MEDICATIONS
MATCH (a), (b) WHERE a.id = 'entity_therapy_46' AND b.id = 'entity_warfarin__asa__aldactone__bisoprolol__lansoprazole_47' CREATE (a)-[:INCLUDES_MULTIPLE_MEDICATIONS {relation_text: 'includes multiple medications', feature_context: 'poly-pharmacological therapy', report_id: '3', evidence: '[MEDICATION] warfarin[/MEDICATION][DOSAGE] 5 mg[/DOSAGE][DOSAGE] 1+1/4 tablet[/DOSAGE],[MEDICATION] ASA[/MEDICATION][DOSAGE] 100 mg 1 tablet[/DOSAGE],[MEDICATION] aldactone[/MEDICATION][DOSAGE] 25 mg 1 tablet[/DOSAGE],[MEDICATION] bisoprolol[/MEDICATION][DOSAGE] 2.5 mg 1 tablet[/DOSAGE],[MEDICATION] lansoprazole[/MEDICATION][DOSAGE] 30 mg 1 tablet[/DOSAGE],[MEDICATION] pregabalin[/MEDICATION][DOSAGE] 75 mg 1 tablet[/DOSAGE],[MEDICATION] Micardis plus[/MEDICATION][DOSAGE] 80/12.5 mg 1 tablet[/DOSAGE]', reasoning: 'The presence of multiple medications in the therapy list indicates poly-pharmacological therapy.'}]->(b);

-- Import RESULT relationships
-- 1 relationships of type RESULT
MATCH (a), (b) WHERE a.id = 'entity_ct_34' AND b.id = 'entity_not_significant_35' CREATE (a)-[:RESULT {relation_text: 'result', feature_context: 'brain ct scan, any abnormality', report_id: '1', evidence: '[DIAGNOSTIC_PROCEDURE] CT[/DIAGNOSTIC_PROCEDURE][BIOLOGICAL_STRUCTURE] brain[/BIOLOGICAL_STRUCTURE] +[BIOLOGICAL_STRUCTURE] eye sockets[/BIOLOGICAL_STRUCTURE][LAB_VALUE] not significant[/LAB_VALUE]', reasoning: 'The CT scan of the brain and eye sockets shows no significant abnormalities, confirming the ground truth annotation.'}]->(b);

-- Import IS relationships
-- 14 relationships of type IS
MATCH (a), (b) WHERE a.id = 'entity_patient_10' AND b.id = 'entity_conscious_11' CREATE (a)-[:IS {relation_text: 'is', feature_context: 'level of consciousness', evidence: '[SIGN_SYMPTOM] Conscious[/SIGN_SYMPTOM],[SIGN_SYMPTOM] lucid[/SIGN_SYMPTOM],[SIGN_SYMPTOM] oriented[/SIGN_SYMPTOM], not[SIGN_SYMPTOM] agitated[/SIGN_SYMPTOM].', reasoning: 'The note states the patient is conscious, lucid, and oriented.'}]->(b);
MATCH (a), (b) WHERE a.id = 'entity_rf_12' AND b.id = 'entity_14_apm_13' CREATE (a)-[:IS {relation_text: 'is', feature_context: 'respiratory rate', evidence: '[DIAGNOSTIC_PROCEDURE] RF[/DIAGNOSTIC_PROCEDURE][LAB_VALUE] 14 apm[/LAB_VALUE]', reasoning: 'The respiratory rate is recorded as 14 breaths per minute, indicating a normal rate.'}]->(b);
MATCH (a), (b) WHERE a.id = 'entity_hr_14' AND b.id = 'entity_80_bpm_15' CREATE (a)-[:IS {relation_text: 'is', feature_context: 'heart rate', evidence: '[DIAGNOSTIC_PROCEDURE] HR[/DIAGNOSTIC_PROCEDURE][LAB_VALUE] 80 bpm[/LAB_VALUE]', reasoning: 'The heart rate is recorded as 80 beats per minute, indicating a normal rate.'}]->(b);
-- ... and 11 more IS relationships

-- Import INCLUDES relationships
-- 3 relationships of type INCLUDES
MATCH (a), (b) WHERE a.id = 'entity_therapy_4' AND b.id = 'entity_multiple_medications_5' CREATE (a)-[:INCLUDES {relation_text: 'includes', feature_context: 'poly-pharmacological therapy', evidence: '[MEDICATION] metformin[/MEDICATION][DOSAGE] 500 mg[/DOSAGE],[MEDICATION] iperten[/MEDICATION][DOSAGE] 1/2 tablet[/DOSAGE],[MEDICATION] enalapril[/MEDICATION][DOSAGE] 5 mg[/DOSAGE],[MEDICATION] omnic[/MEDICATION][DOSAGE] 0.4 mg[/DOSAGE],[MEDICATION] seloken[/MEDICATION][DOSAGE] 100 mg 1/2 tablet x 2[/DOSAGE],[MEDICATION] cardioASA[/MEDICATION],[MEDICATION] torvast[/MEDICATION][DOSAGE] 20 mg[/DOSAGE],[MEDICATION] contramala[/MEDICATION][DOSAGE] 15 drops[/DOSAGE],[MEDICATION] tachipirina AD[/MEDICATION],[MEDICATION] omnepraozlo[/MEDICATION][DOSAGE] 20 mg[/DOSAGE]', reasoning: 'The note lists multiple medications being taken, indicating poly-pharmacological therapy.'}]->(b);
MATCH (a), (b) WHERE a.id = 'entity_therapy_6' AND b.id = 'entity_iperten_7' CREATE (a)-[:INCLUDES {relation_text: 'includes', feature_context: 'antihypertensive therapy', evidence: '[MEDICATION] iperten[/MEDICATION][DOSAGE] 1/2 tablet[/DOSAGE]', reasoning: 'The presence of \'iperten\' in the therapy list indicates antihypertensive treatment.'}]->(b);
MATCH (a), (b) WHERE a.id = 'entity_past_medical_history_8' AND b.id = 'entity_cad_9' CREATE (a)-[:INCLUDES {relation_text: 'includes', feature_context: 'cardiovascular diseases', evidence: '-[DISEASE_DISORDER] CAD[/DISEASE_DISORDER] (reports quadruple[DISEASE_DISORDER] B[/DISEASE_DISORDER][SIGN_SYMPTOM]PAC[/SIGN_SYMPTOM])', reasoning: 'The note mentions \'CAD\' in the past medical history, indicating cardiovascular disease.'}]->(b);

-- Import TO relationships
-- 1 relationships of type TO
MATCH (a), (b) WHERE a.id = 'entity_allergy_26' AND b.id = 'entity_insect_venom_27' CREATE (a)-[:TO {relation_text: 'to', feature_context: 'history of allergy', report_id: '1', evidence: '[DISEASE_DISORDER] allergy[/DISEASE_DISORDER][DETAILED_DESCRIPTION] to[/DETAILED_DESCRIPTION][DETAILED_DESCRIPTION] insect venom[/DETAILED_DESCRIPTION]', reasoning: 'The text explicitly states the patient has an allergy to insect venom, confirming a history of allergy.'}]->(b);

-- Import RELATED_TO_FEATURE relationships
-- 112 relationships of type RELATED_TO_FEATURE
MATCH (a), (b) WHERE a.id = 'entity_diabetes_mellitus_type_2_0' AND b.id = 'feature_chronic_metabolic_failure' CREATE (a)-[:RELATED_TO_FEATURE {feature: 'chronic metabolic failure', role: 'subject'}]->(b);
MATCH (a), (b) WHERE a.id = 'entity_metabolic_disorder_1' AND b.id = 'feature_chronic_metabolic_failure' CREATE (a)-[:RELATED_TO_FEATURE {feature: 'chronic metabolic failure', role: 'object'}]->(b);
MATCH (a), (b) WHERE a.id = 'entity_allergies_2' AND b.id = 'feature_history_of_allergy' CREATE (a)-[:RELATED_TO_FEATURE {feature: 'history of allergy', role: 'subject'}]->(b);
-- ... and 109 more RELATED_TO_FEATURE relationships

-- Import IS_ORIENTED_TO relationships
-- 1 relationships of type IS_ORIENTED_TO
MATCH (a), (b) WHERE a.id = 'entity_patient_102' AND b.id = 'entity_time_place_103' CREATE (a)-[:IS_ORIENTED_TO {relation_text: 'is oriented to', feature_context: 'level of consciousness', report_id: '9', evidence: 'oriented to time/place', reasoning: 'The patient is described as alert and oriented to time and place, indicating a normal level of consciousness.'}]->(b);

