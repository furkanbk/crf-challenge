# Neo4j Knowledge Graph Import Guide

## Overview

This guide shows how to import your medical triplet data into Neo4j as a knowledge graph. The export process has generated several files that make the import process straightforward.

## Generated Files

Your triplet data has been converted into the following files in the `neo4j_export/` directory:

### 1. **nodes.csv** (9.2 KB)
- Contains all nodes (MedicalReports, MedicalFeatures, MedicalEntities)
- Format: `id:ID,type:LABEL,name,entity_type,report_index,document_id,annotated_items_count,total_triplets,category`
- 146 nodes total

### 2. **relationships.csv** (33.3 KB)
- Contains all relationships between nodes
- Format: `id:ID,type:TYPE,:START_ID,:END_ID,relation_text,feature_context,report_id,evidence,reasoning,role`
- 223 relationships total

### 3. **import.cypher** (10 KB)
- Cypher queries for direct execution
- Includes constraints, indexes, and sample import queries

### 4. **visualization.json** (115 KB)
- JSON format suitable for visualization tools like Neo4j Bloom or external tools

### 5. **statistics.json** (2.6 KB)
- Graph statistics and analysis

## Knowledge Graph Structure

### Node Types
- **MedicalReport** (10 nodes): Clinical reports/documents
- **MedicalFeature** (24 nodes): Medical features from the CFR dataset
- **MedicalEntity** (112 nodes): Extracted medical entities (diseases, medications, vital signs, etc.)

### Relationship Types
- **HAS_FEATURE** (55): Links reports to their medical features
- **RELATED_TO_FEATURE** (112): Links entities to the features they belong to
- **IS** (14): General "is" relationships
- **MEASURED_AT** (4): Vital sign measurements
- **INCLUDES** (3): Inclusion relationships
- And 35+ other specific relationship types

## Import Methods

### Method 1: Neo4j Desktop (Recommended)

1. **Install Neo4j Desktop** from https://neo4j.com/download/

2. **Create a new project**:
   - Open Neo4j Desktop
   - Click "Create Project" → Name it "Medical Knowledge Graph"

3. **Create a database**:
   - Click "Add Database" → Name it "medical-kg"
   - Set password (default: "neo4j")
   - Wait for the database to start

4. **Copy files to import directory**:
   - Find your database folder in Neo4j Desktop
   - Navigate to `import/` subfolder
   - Copy `nodes.csv` and `relationships.csv` to this folder

5. **Run import queries**:
   Open Neo4j Browser and run the corrected import queries:

   **Option A: Simple Import (Recommended - No APOC required)**
   ```cypher
   // Use the simple_import.cypher file
   // Copy and paste its contents, or run: :source simple_import.cypher
   ```

   **Option B: APOC Import (More flexible)**
   ```cypher
   // Create constraints for unique IDs
   CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalReport) REQUIRE n.id IS UNIQUE;
   CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalFeature) REQUIRE n.id IS UNIQUE;
   CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalEntity) REQUIRE n.id IS UNIQUE;

   // Import nodes - MedicalReport
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

   // Import nodes - MedicalFeature
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

   // Import nodes - MedicalEntity
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

   // Import relationships (requires APOC)
   LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
   MATCH (start), (end)
   WHERE start.id = row.`:START_ID` AND end.id = row.`:END_ID`
   CALL apoc.create.relationship(start, row.type, {
       id: row.id,
       relation_text: row.relation_text,
       feature_context: row.feature_context,
       report_id: row.report_id,
       evidence: row.evidence,
       reasoning: row.reasoning,
       role: row.role
   }, end) YIELD rel
   RETURN rel;
   ```

### Method 2: Command Line Import

For large datasets, use Neo4j-admin import:

```bash
# Stop the database first
neo4j-admin database import full \
  --nodes=import/nodes.csv \
  --relationships=import/relationships.csv \
  --overwrite-destination=true \
  --database=neo4j
```

### Method 3: Direct Cypher Execution

Run the generated `import.cypher` file in Neo4j Browser:

```cypher
// Copy and paste the contents of import.cypher
// Or run: :source import.cypher
```

## Post-Import Queries

### 1. Verify Import
```cypher
// Check node counts
MATCH (n) RETURN n.type as NodeType, count(*) as Count ORDER BY Count DESC;

// Check relationship counts
MATCH ()-[r]->() RETURN type(r) as RelationType, count(*) as Count ORDER BY Count DESC;
```

### 2. Sample Queries

**Find all diseases mentioned in reports:**
```cypher
MATCH (r:MedicalReport)-[:HAS_FEATURE]->(f:MedicalFeature)-[:RELATED_TO_FEATURE]->(e:MedicalEntity)
WHERE e.entity_type = 'Disease'
RETURN r.report_index, f.name, e.name;
```

**Find medications and their relationships:**
```cypher
MATCH (e:MedicalEntity {entity_type: 'Medication'})-[r]->(target)
RETURN e.name as Medication, type(r) as Relationship, target.name as Target;
```

**Explore vital signs across reports:**
```cypher
MATCH (r:MedicalReport)-[:HAS_FEATURE]->(f:MedicalFeature)-[:RELATED_TO_FEATURE]->(e:MedicalEntity)
WHERE e.entity_type = 'Vital Sign'
RETURN r.report_index, e.name, r.relation_text;
```

**Find evidence-backed relationships:**
```cypher
MATCH (e1:MedicalEntity)-[r]->(e2:MedicalEntity)
WHERE r.evidence IS NOT NULL
RETURN e1.name, type(r) as Relation, e2.name, r.evidence as Evidence
LIMIT 10;
```

### 3. Graph Visualization Queries

**Medical entity network:**
```cypher
MATCH (e1:MedicalEntity)-[r]->(e2:MedicalEntity)
RETURN e1, r, e2
LIMIT 25;
```

**Report-feature-entity network:**
```cypher
MATCH (r:MedicalReport)-[:HAS_FEATURE]->(f:MedicalFeature)-[:RELATED_TO_FEATURE]->(e:MedicalEntity)
WHERE r.report_index = 0
RETURN r, f, e;
```

## Index Creation for Performance

Create additional indexes for better query performance:

```cypher
// Indexes for common queries
CREATE INDEX IF NOT EXISTS FOR (n:MedicalEntity) ON (n.name);
CREATE INDEX IF NOT EXISTS FOR (n:MedicalFeature) ON (n.name);
CREATE INDEX IF NOT EXISTS FOR (n:MedicalEntity) ON (n.entity_type);
CREATE INDEX IF NOT EXISTS FOR ()-[r:RELATED_TO_FEATURE]-() ON (r.feature_context);
CREATE INDEX IF NOT EXISTS FOR ()-[r:HAS_FEATURE]-() ON (r.report_id);
```

## Data Quality Checks

```cypher
// Find orphaned nodes (nodes without relationships)
MATCH (n) WHERE NOT (n)--() RETURN n;

// Check for duplicate entities
MATCH (e:MedicalEntity) 
WITH e.name as name, collect(e) as entities
WHERE size(entities) > 1
RETURN name, entities;

// Verify evidence coverage
MATCH ()-[r]->() 
WHERE r.evidence IS NOT NULL 
RETURN count(*) as relationships_with_evidence;
```

## Export and Backup

### Export the graph:
```cypher
// Export nodes
CALL apoc.export.csv.query("MATCH (n) RETURN n.id, n.type, n.name", "nodes_backup.csv", {});

// Export relationships
CALL apoc.export.csv.query("MATCH ()-[r]->() RETURN startNode(r).id, type(r), endNode(r).id", "relationships_backup.csv", {});
```

### Create backup:
```cypher
// Using neo4j-admin dump
neo4j-admin database dump neo4j --to-path=/path/to/backup/
```

## Integration with Visualization Tools

### Neo4j Bloom
1. Open Bloom from Neo4j Desktop
2. Create a new perspective
3. Use the phrase-based exploration:
   - "Show me diseases and their treatments"
   - "Display vital signs from report 0"

### External Tools
Use the `visualization.json` file with:
- **Neo4j Browser**: Import JSON data
- **D3.js**: Custom web visualizations
- **Gephi**: Network analysis
- **Cytoscape**: Biological network visualization

## Performance Optimization

For larger datasets:

1. **Use APOC procedures** for bulk operations
2. **Implement periodic commits** for large imports
3. **Configure memory settings** in neo4j.conf
4. **Use proper indexing** strategy
5. **Consider graph projections** for complex analytics

## Troubleshooting

### Common Issues:
1. **File not found**: Ensure CSV files are in the import directory
2. **Memory issues**: Increase heap size in neo4j.conf
3. **Constraint violations**: Check for duplicate IDs
4. **Slow queries**: Create appropriate indexes

### Debug Queries:
```cypher
// Check import progress
MATCH (n) RETURN count(*) as total_nodes;

// Find relationship issues
MATCH ()-[r]->() WHERE r.id IS NULL RETURN r;

// Validate data types
MATCH (n:MedicalReport) WHERE n.report_index IS NULL RETURN n;
```

## Next Steps

1. **Explore the graph** using the sample queries
2. **Create custom visualizations** in Bloom
3. **Add more data** by extending the export script
4. **Implement graph algorithms** (path finding, centrality, community detection)
5. **Build applications** using the Neo4j driver for your preferred programming language

## Support

- **Neo4j Documentation**: https://neo4j.com/docs/
- **Cypher Manual**: https://neo4j.com/docs/cypher-manual/
- **Neo4j Community**: https://community.neo4j.com/

Your medical knowledge graph is now ready for exploration and analysis!
