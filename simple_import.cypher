// Simple Neo4j Import Script (No APOC Required)
// This version uses explicit relationship creation instead of APOC

// Step 1: Create constraints for unique IDs
CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalReport) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalFeature) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalEntity) REQUIRE n.id IS UNIQUE;

// Step 2: Import nodes by type
// Import MedicalReport nodes
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
WITH row WHERE row.type = 'MedicalReport'
CREATE (n:MedicalReport {
    id: row.id,
    name: row.name,
    entity_type: row.entity_type,
    report_index: toInteger(row.report_index),
    document_id: row.document_id,
    annotated_items_count: toInteger(row.annotated_items_count),
    total_triplets: toInteger(row.total_triplets),
    category: row.category
});

// Import MedicalFeature nodes
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
WITH row WHERE row.type = 'MedicalFeature'
CREATE (n:MedicalFeature {
    id: row.id,
    name: row.name,
    entity_type: row.entity_type,
    report_index: toInteger(row.report_index),
    document_id: row.document_id,
    annotated_items_count: toInteger(row.annotated_items_count),
    total_triplets: toInteger(row.total_triplets),
    category: row.category
});

// Import MedicalEntity nodes
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
WITH row WHERE row.type = 'MedicalEntity'
CREATE (n:MedicalEntity {
    id: row.id,
    name: row.name,
    entity_type: row.entity_type,
    report_index: toInteger(row.report_index),
    document_id: row.document_id,
    annotated_items_count: toInteger(row.annotated_items_count),
    total_triplets: toInteger(row.total_triplets),
    category: row.category
});

// Step 3: Import relationships by type
// HAS_FEATURE relationships
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
WITH row WHERE row.type = 'HAS_FEATURE'
MATCH (start), (end)
WHERE start.id = row.`:START_ID` AND end.id = row.`:END_ID`
CREATE (start)-[r:HAS_FEATURE {
    id: row.id,
    relation_text: row.relation_text,
    feature_context: row.feature_context,
    report_id: row.report_id,
    evidence: row.evidence,
    reasoning: row.reasoning,
    role: row.role
}]->(end);

// RELATED_TO_FEATURE relationships
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
WITH row WHERE row.type = 'RELATED_TO_FEATURE'
MATCH (start), (end)
WHERE start.id = row.`:START_ID` AND end.id = row.`:END_ID`
CREATE (start)-[r:RELATED_TO_FEATURE {
    id: row.id,
    relation_text: row.relation_text,
    feature_context: row.feature_context,
    report_id: row.report_id,
    evidence: row.evidence,
    reasoning: row.reasoning,
    role: row.role
}]->(end);

// IS relationships
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
WITH row WHERE row.type = 'IS'
MATCH (start), (end)
WHERE start.id = row.`:START_ID` AND end.id = row.`:END_ID`
CREATE (start)-[r:IS {
    id: row.id,
    relation_text: row.relation_text,
    feature_context: row.feature_context,
    report_id: row.report_id,
    evidence: row.evidence,
    reasoning: row.reasoning,
    role: row.role
}]->(end);

// MEASURED_AT relationships
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
WITH row WHERE row.type = 'MEASURED_AT'
MATCH (start), (end)
WHERE start.id = row.`:START_ID` AND end.id = row.`:END_ID`
CREATE (start)-[r:MEASURED_AT {
    id: row.id,
    relation_text: row.relation_text,
    feature_context: row.feature_context,
    report_id: row.report_id,
    evidence: row.evidence,
    reasoning: row.reasoning,
    role: row.role
}]->(end);

// INCLUDES relationships
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
WITH row WHERE row.type = 'INCLUDES'
MATCH (start), (end)
WHERE start.id = row.`:START_ID` AND end.id = row.`:END_ID`
CREATE (start)-[r:INCLUDES {
    id: row.id,
    relation_text: row.relation_text,
    feature_context: row.feature_context,
    report_id: row.report_id,
    evidence: row.evidence,
    reasoning: row.reasoning,
    role: row.role
}]->(end);

// USED_TO_TREAT relationships
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
WITH row WHERE row.type = 'USED_TO_TREAT'
MATCH (start), (end)
WHERE start.id = row.`:START_ID` AND end.id = row.`:END_ID`
CREATE (start)-[r:USED_TO_TREAT {
    id: row.id,
    relation_text: row.relation_text,
    feature_context: row.feature_context,
    report_id: row.report_id,
    evidence: row.evidence,
    reasoning: row.reasoning,
    role: row.role
}]->(end);

// DIAGNOSED_WITH relationships
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
WITH row WHERE row.type = 'DIAGNOSED_WITH'
MATCH (start), (end)
WHERE start.id = row.`:START_ID` AND end.id = row.`:END_ID`
CREATE (start)-[r:DIAGNOSED_WITH {
    id: row.id,
    relation_text: row.relation_text,
    feature_context: row.feature_context,
    report_id: row.report_id,
    evidence: row.evidence,
    reasoning: row.reasoning,
    role: row.role
}]->(end);

// TREATED_WITH relationships
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
WITH row WHERE row.type = 'TREATED_WITH'
MATCH (start), (end)
WHERE start.id = row.`:START_ID` AND end.id = row.`:END_ID`
CREATE (start)-[r:TREATED_WITH {
    id: row.id,
    relation_text: row.relation_text,
    feature_context: row.feature_context,
    report_id: row.report_id,
    evidence: row.evidence,
    reasoning: row.reasoning,
    role: row.role
}]->(end);

// VALUE relationships
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
WITH row WHERE row.type = 'VALUE'
MATCH (start), (end)
WHERE start.id = row.`:START_ID` AND end.id = row.`:END_ID`
CREATE (start)-[r:VALUE {
    id: row.id,
    relation_text: row.relation_text,
    feature_context: row.feature_context,
    report_id: row.report_id,
    evidence: row.evidence,
    reasoning: row.reasoning,
    role: row.role
}]->(end);

// Catch-all for any other relationship types
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
WITH row WHERE row.type NOT IN ['HAS_FEATURE', 'RELATED_TO_FEATURE', 'IS', 'MEASURED_AT', 'INCLUDES', 'USED_TO_TREAT', 'DIAGNOSED_WITH', 'TREATED_WITH', 'VALUE']
MATCH (start), (end)
WHERE start.id = row.`:START_ID` AND end.id = row.`:END_ID`
CREATE (start)-[r:RELATED_TO {
    id: row.id,
    relation_text: row.relation_text,
    feature_context: row.feature_context,
    report_id: row.report_id,
    evidence: row.evidence,
    reasoning: row.reasoning,
    role: row.role,
    original_type: row.type
}]->(end);

// Step 4: Verify import
MATCH (n) RETURN labels(n) as NodeType, count(*) as Count ORDER BY Count DESC;
MATCH ()-[r]->() RETURN type(r) as RelationType, count(*) as Count ORDER BY Count DESC;
