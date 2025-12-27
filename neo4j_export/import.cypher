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
CREATE (:MedicalReport {id: 'report_1', report_index: '1'});
CREATE (:MedicalReport {id: 'report_5', report_index: '5'});
CREATE (:MedicalReport {id: 'report_6', report_index: '6'});
CREATE (:MedicalReport {id: 'report_8', report_index: '8'});
CREATE (:MedicalReport {id: 'report_9', report_index: '9'});
-- ... and 5 more MedicalReport nodes

-- Import MedicalFeature nodes
CREATE (:MedicalFeature {id: 'feature_brain_ct_scan__any_abnormality', name: 'brain ct scan, any abnormality', category: 'Imaging'});
CREATE (:MedicalFeature {id: 'feature_head_or_other_districts_trauma', name: 'head or other districts trauma', category: 'Injury'});
CREATE (:MedicalFeature {id: 'feature_body_temperature', name: 'body temperature', category: 'General'});
CREATE (:MedicalFeature {id: 'feature_creatinine', name: 'creatinine', category: 'General'});
CREATE (:MedicalFeature {id: 'feature_ecg__any_abnormality', name: 'ecg, any abnormality', category: 'General'});
-- ... and 19 more MedicalFeature nodes

-- Import MedicalEntity nodes
CREATE (:MedicalEntity {id: 'entity_80_bpm_15', name: '80 bpm', entity_type: 'Vital Sign'});
CREATE (:MedicalEntity {id: 'entity_36_8_95', name: '36.8', entity_type: 'Entity'});
CREATE (:MedicalEntity {id: 'entity_occipital_region_19', name: 'occipital region', entity_type: 'Entity'});
CREATE (:MedicalEntity {id: 'entity_bp_98', name: 'BP', entity_type: 'Vital Sign'});
CREATE (:MedicalEntity {id: 'entity_adenocarcinoma_of_the_rectum_54', name: 'adenocarcinoma of the rectum', entity_type: 'Diagnostic Procedure'});
-- ... and 107 more MedicalEntity nodes

-- Import relationships
-- Import IS_AN_ANTICOAGULANT relationships
-- 1 relationships of type IS_AN_ANTICOAGULANT
MATCH (a), (b) WHERE a.id = 'entity_warfarin_44' AND b.id = 'entity_therapy_45' CREATE (a)-[:IS_AN_ANTICOAGULANT {relation_text: 'is an anticoagulant', feature_context: 'anticoagulants or antiplatelet drug therapy', report_id: '3', evidence: '[MEDICATION] warfarin[/MEDICATION][DOSAGE] 5 mg[/DOSAGE][DOSAGE] 1+1/4 tablet[/DOSAGE]', reasoning: 'Warfarin is a well-known anticoagulant medication, and its presence in the therapy list confirms this feature.'}]->(b);

-- Import CAUSES relationships
-- 1 relationships of type CAUSES
MATCH (a), (b) WHERE a.id = 'entity_hyperthyroidism_40' AND b.id = 'entity_metabolic_failure_41' CREATE (a)-[:CAUSES {relation_text: 'causes', feature_context: 'chronic metabolic failure', report_id: '3', evidence: '-[DISEASE_DISORDER] Hyperthyroidism[/DISEASE_DISORDER]', reasoning: 'Hyperthyroidism is a condition that can lead to chronic metabolic failure due to its impact on metabolism.'}]->(b);

-- Import IS_A_RESPIRATORY_RATE_OF relationships
-- 1 relationships of type IS_A_RESPIRATORY_RATE_OF
MATCH (a), (b) WHERE a.id = 'entity_rf_92' AND b.id = 'entity_18_apm_93' CREATE (a)-[:IS_A_RESPIRATORY_RATE_OF {relation_text: 'is a respiratory rate of', feature_context: 'respiratory rate', report_id: '8', evidence: 'RF 18 apm', reasoning: 'The patient\'s respiratory rate is recorded as \'18 apm,\' which falls within the normal range, indicating eupnea.'}]->(b);

-- Import IS_NOT relationships
-- 1 relationships of type IS_NOT
MATCH (a), (b) WHERE a.id = 'entity_patient_22' AND b.id = 'entity_agitated_23' CREATE (a)-[:IS_NOT {relation_text: 'is not', feature_context: 'agitation', evidence: '[SIGN_SYMPTOM] Conscious[/SIGN_SYMPTOM],[SIGN_SYMPTOM] lucid[/SIGN_SYMPTOM],[SIGN_SYMPTOM] oriented[/SIGN_SYMPTOM], not[SIGN_SYMPTOM] agitated[/SIGN_SYMPTOM].', reasoning: 'The note states the patient is not agitated.'}]->(b);

-- Import IS_A_CARDIOVASCULAR_DISEASE relationships
-- 1 relationships of type IS_A_CARDIOVASCULAR_DISEASE
MATCH (a), (b) WHERE a.id = 'entity_arterial_hypertension_52' AND b.id = 'entity_condition_53' CREATE (a)-[:IS_A_CARDIOVASCULAR_DISEASE {relation_text: 'is a cardiovascular disease', feature_context: 'cardiovascular diseases', report_id: '3', evidence: '-[DETAILED_DESCRIPTION] Arterial[/DETAILED_DESCRIPTION][DISEASE_DISORDER] hypertension[/DISEASE_DISORDER]', reasoning: 'Hypertension is classified as a cardiovascular disease, and its presence in the medical history supports this feature.'}]->(b);

-- Import ADMITTED_FOR relationships
-- 1 relationships of type ADMITTED_FOR
MATCH (a), (b) WHERE a.id = 'entity_patient_36' AND b.id = 'entity_left_knee_injury_37' CREATE (a)-[:ADMITTED_FOR {relation_text: 'admitted for', feature_context: 'history of recent trauma', report_id: '2', evidence: 'Patient admitted to the CTO ER for left knee injury, X-ray evidence of supracondylar fracture of the left femur.', reasoning: 'The admission to the emergency room due to a left knee injury and subsequent diagnosis of a fracture indicates recent trauma.'}]->(b);

-- Import TREATED_WITH relationships
-- 2 relationships of type TREATED_WITH
MATCH (a), (b) WHERE a.id = 'entity_prostate_cancer_excision_24' AND b.id = 'entity_therapy_25' CREATE (a)-[:TREATED_WITH {relation_text: 'treated_with', feature_context: 'active neoplasia', report_id: '1', evidence: 'previous[THERAPEUTIC_PROCEDURE] prostate cancer excision[/THERAPEUTIC_PROCEDURE] (2012) with[LAB_VALUE] normal[/LAB_VALUE][CLINICAL_EVENT] follow[/CLINICAL_EVENT]-[CLINICAL_EVENT]up[/CLINICAL_EVENT]', reasoning: 'The mention of \'prostate cancer excision\' in 2012 followed by a normal follow-up indicates that the neoplasm was treated and is not currently active.'}]->(b);
MATCH (a), (b) WHERE a.id = 'entity_adenocarcinoma_of_the_rectum_54' AND b.id = 'entity_folfox_chemotherapy_55' CREATE (a)-[:TREATED_WITH {relation_text: 'treated with', feature_context: 'active neoplasia', report_id: '4', evidence: 'in past medical history: [HISTORY] arterial [DISEASE_DISORDER] hypertension [DISEASE_DISORDER], in 2018[DETAILED_DESCRIPTION] subtotal [DETAILED_DESCRIPTION][THERAPEUTIC_PROCEDURE] colectomy [THERAPEUTIC_PROCEDURE] for[DISEASE_DISORDER] adenocarcinoma [DISEASE_DISORDER] of the[BIOLOGICAL_STRUCTURE] rectum [BIOLOGICAL_STRUCTURE] followed by a cycle of[MEDICATION] FOLFOX chemotherapy [MEDICATION]', reasoning: 'The patient has a history of adenocarcinoma of the rectum, which was treated with FOLFOX chemotherapy in 2018. This indicates that the neoplasia is no longer active.'}]->(b);

-- Import IS_AN_OXYGEN_SATURATION_OF relationships
-- 1 relationships of type IS_AN_OXYGEN_SATURATION_OF
MATCH (a), (b) WHERE a.id = 'entity_spo2_100' AND b.id = 'entity_96__101' CREATE (a)-[:IS_AN_OXYGEN_SATURATION_OF {relation_text: 'is an oxygen saturation of', feature_context: 'spo2', report_id: '8', evidence: 'SpO2 96% on room air', reasoning: 'The patient\'s SpO2 is recorded as \'96%\' on room air, which aligns with the annotation.'}]->(b);

-- Import MEASURED_AT relationships
-- 4 relationships of type MEASURED_AT
MATCH (a), (b) WHERE a.id = 'entity_hr_64' AND b.id = 'entity_89_65' CREATE (a)-[:MEASURED_AT {relation_text: 'measured at', feature_context: 'heart rate', report_id: '4', evidence: '[DIAGNOSTIC_PROCEDURE] HR [DIAGNOSTIC_PROCEDURE][LAB_VALUE] 89 [LAB_VALUE]', reasoning: 'The patient\'s heart rate is measured at 89, which falls within the normal range of 60-100 beats per minute.'}]->(b);
MATCH (a), (b) WHERE a.id = 'entity_bp_66' AND b.id = 'entity_160_90_mmhg_67' CREATE (a)-[:MEASURED_AT {relation_text: 'measured at', feature_context: 'blood pressure', report_id: '4', evidence: '[DIAGNOSTIC_PROCEDURE] BP [DIAGNOSTIC_PROCEDURE][LAB_VALUE] 160/90 mmHg [LAB_VALUE]', reasoning: 'The patient\'s blood pressure is measured at 160/90 mmHg, which indicates hypertension.'}]->(b);
MATCH (a), (b) WHERE a.id = 'entity_so2_68' AND b.id = 'entity_96__69' CREATE (a)-[:MEASURED_AT {relation_text: 'measured at', feature_context: 'spo2', report_id: '4', evidence: '[DIAGNOSTIC_PROCEDURE] SO2 [DIAGNOSTIC_PROCEDURE]:[LAB_VALUE] 96% [LAB_VALUE]', reasoning: 'The patient\'s oxygen saturation is measured at 96%, which falls within the normal range of 95-100%.'}]->(b);
-- ... and 1 more MEASURED_AT relationships

-- Import TRAUMA relationships
-- 1 relationships of type TRAUMA
MATCH (a), (b) WHERE a.id = 'entity_head_18' AND b.id = 'entity_occipital_region_19' CREATE (a)-[:TRAUMA {relation_text: 'trauma', feature_context: 'head or other districts trauma', evidence: '-[BIOLOGICAL_STRUCTURE] occipital region[/BIOLOGICAL_STRUCTURE] with no[SIGN_SYMPTOM] loss of consciousness[/SIGN_SYMPTOM] or[DISEASE_DISORDER] concussion[/DISEASE_DISORDER]', reasoning: 'The note mentions trauma to the occipital region.'}]->(b);

