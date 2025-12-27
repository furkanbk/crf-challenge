#!/usr/bin/env python3
"""
Neo4j Knowledge Graph Export Script for Medical Triplets

This script converts the medical triplet data into Neo4j-compatible formats:
1. CSV files for nodes and relationships (for bulk import)
2. Cypher queries for direct execution
3. JSON format for visualization tools

Author: Medical Knowledge Graph Pipeline
"""

import json
import csv
import os
from typing import Dict, List, Any, Tuple
from collections import defaultdict, Counter
import re

class Neo4jExporter:
    def __init__(self, input_file: str, output_dir: str = "neo4j_export"):
        """
        Initialize the Neo4j exporter.
        
        Args:
            input_file: Path to the JSON file containing triplet data
            output_dir: Directory to save exported files
        """
        self.input_file = input_file
        self.output_dir = output_dir
        self.data = None
        self.nodes = {}
        self.relationships = []
        self.node_types = defaultdict(set)
        self.relationship_types = set()
        
        # Create output directory
        os.makedirs(output_dir, exist_ok=True)
        
    def load_data(self):
        """Load the triplet data from JSON file."""
        with open(self.input_file, 'r', encoding='utf-8') as f:
            self.data = json.load(f)
        print(f"Loaded data for {len(self.data)} reports")
        
    def extract_nodes_and_relationships(self):
        """Extract nodes and relationships from triplet data."""
        node_id_counter = 0
        
        for report_key, report_data in self.data.items():
            report_id = report_data.get('report_index', report_key)
            
            # Create report node
            report_node_id = f"report_{report_id}"
            self.nodes[report_node_id] = {
                'id': report_node_id,
                'type': 'MedicalReport',
                'properties': {
                    'report_index': report_id,
                    'document_id': report_data.get('document_id', ''),
                    'annotated_items_count': report_data.get('annotated_items_count', 0),
                    'total_triplets': report_data.get('total_triplets', 0)
                }
            }
            self.node_types['MedicalReport'].add(report_node_id)
            
            # Process triplets
            if 'relation_triplets_by_feature' in report_data:
                triplets = report_data['relation_triplets_by_feature']
                
                for feature, triplet_list in triplets.items():
                    # Create feature node
                    feature_node_id = f"feature_{self._sanitize_id(feature)}"
                    self.nodes[feature_node_id] = {
                        'id': feature_node_id,
                        'type': 'MedicalFeature',
                        'properties': {
                            'name': feature,
                            'category': self._categorize_feature(feature)
                        }
                    }
                    self.node_types['MedicalFeature'].add(feature_node_id)
                    
                    # Link report to feature
                    self.relationships.append({
                        'id': f"rel_has_feature_{report_id}_{self._sanitize_id(feature)}",
                        'type': 'HAS_FEATURE',
                        'source': report_node_id,
                        'target': feature_node_id,
                        'properties': {
                            'source_report': report_id
                        }
                    })
                    self.relationship_types.add('HAS_FEATURE')
                    
                    # Process each triplet for this feature
                    for i, triplet_data in enumerate(triplet_list):
                        if 'triplet' in triplet_data and len(triplet_data['triplet']) == 3:
                            subject, relation, obj = triplet_data['triplet']
                            
                            # Create subject node
                            subject_node_id = f"entity_{self._sanitize_id(subject)}_{node_id_counter}"
                            self.nodes[subject_node_id] = {
                                'id': subject_node_id,
                                'type': 'MedicalEntity',
                                'properties': {
                                    'name': subject,
                                    'entity_type': self._detect_entity_type(subject)
                                }
                            }
                            self.node_types['MedicalEntity'].add(subject_node_id)
                            
                            # Create object node
                            obj_node_id = f"entity_{self._sanitize_id(obj)}_{node_id_counter + 1}"
                            self.nodes[obj_node_id] = {
                                'id': obj_node_id,
                                'type': 'MedicalEntity',
                                'properties': {
                                    'name': obj,
                                    'entity_type': self._detect_entity_type(obj)
                                }
                            }
                            self.node_types['MedicalEntity'].add(obj_node_id)
                            
                            # Create relationship
                            rel_type = self._sanitize_relationship_type(relation)
                            self.relationships.append({
                                'id': f"rel_{node_id_counter}",
                                'type': rel_type,
                                'source': subject_node_id,
                                'target': obj_node_id,
                                'properties': {
                                    'relation_text': relation,
                                    'feature_context': feature,
                                    'report_id': report_id,
                                    'evidence': triplet_data.get('evidence', ''),
                                    'reasoning': triplet_data.get('reasoning', '')
                                }
                            })
                            self.relationship_types.add(rel_type)
                            
                            # Link entities to feature
                            self.relationships.append({
                                'id': f"rel_entity_feature_{node_id_counter}",
                                'type': 'RELATED_TO_FEATURE',
                                'source': subject_node_id,
                                'target': feature_node_id,
                                'properties': {
                                    'feature': feature,
                                    'role': 'subject'
                                }
                            })
                            
                            self.relationships.append({
                                'id': f"rel_entity_feature_{node_id_counter + 1}",
                                'type': 'RELATED_TO_FEATURE',
                                'source': obj_node_id,
                                'target': feature_node_id,
                                'properties': {
                                    'feature': feature,
                                    'role': 'object'
                                }
                            })
                            self.relationship_types.add('RELATED_TO_FEATURE')
                            
                            node_id_counter += 2
        
        print(f"Extracted {len(self.nodes)} nodes and {len(self.relationships)} relationships")
        
    def export_csv_files(self):
        """Export nodes and relationships as CSV files for Neo4j bulk import."""
        
        # Export nodes
        nodes_file = os.path.join(self.output_dir, 'nodes.csv')
        with open(nodes_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['id:ID', 'type:LABEL', 'name', 'entity_type', 'report_index', 'document_id', 'annotated_items_count', 'total_triplets', 'category'])
            
            for node_id, node_data in self.nodes.items():
                row = [
                    node_id,
                    node_data['type'],
                    node_data['properties'].get('name', ''),
                    node_data['properties'].get('entity_type', ''),
                    node_data['properties'].get('report_index', ''),
                    node_data['properties'].get('document_id', ''),
                    node_data['properties'].get('annotated_items_count', ''),
                    node_data['properties'].get('total_triplets', ''),
                    node_data['properties'].get('category', '')
                ]
                writer.writerow(row)
        
        # Export relationships
        relationships_file = os.path.join(self.output_dir, 'relationships.csv')
        with open(relationships_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(['id:ID', 'type:TYPE', ':START_ID', ':END_ID', 'relation_text', 'feature_context', 'report_id', 'evidence', 'reasoning', 'role'])
            
            for rel_data in self.relationships:
                row = [
                    rel_data['id'],
                    rel_data['type'],
                    rel_data['source'],
                    rel_data['target'],
                    rel_data['properties'].get('relation_text', ''),
                    rel_data['properties'].get('feature_context', ''),
                    rel_data['properties'].get('report_id', ''),
                    rel_data['properties'].get('evidence', ''),
                    rel_data['properties'].get('reasoning', ''),
                    rel_data['properties'].get('role', '')
                ]
                writer.writerow(row)
        
        print(f"CSV files exported to {self.output_dir}")
        print(f"  - nodes.csv: {len(self.nodes)} nodes")
        print(f"  - relationships.csv: {len(self.relationships)} relationships")
        
    def export_cypher_queries(self):
        """Export Cypher queries for direct Neo4j execution."""
        
        cypher_file = os.path.join(self.output_dir, 'import.cypher')
        with open(cypher_file, 'w', encoding='utf-8') as f:
            f.write("// Neo4j Import Script for Medical Knowledge Graph\n")
            f.write("// Generated automatically from triplet data\n\n")
            
            # Create constraints
            f.write("-- Create constraints for unique IDs\n")
            f.write("CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalReport) REQUIRE n.id IS UNIQUE;\n")
            f.write("CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalFeature) REQUIRE n.id IS UNIQUE;\n")
            f.write("CREATE CONSTRAINT IF NOT EXISTS FOR (n:MedicalEntity) REQUIRE n.id IS UNIQUE;\n\n")
            
            # Create indexes
            f.write("-- Create indexes for common queries\n")
            f.write("CREATE INDEX IF NOT EXISTS FOR (n:MedicalEntity) ON (n.name);\n")
            f.write("CREATE INDEX IF NOT EXISTS FOR (n:MedicalFeature) ON (n.name);\n")
            f.write("CREATE INDEX IF NOT EXISTS FOR ()-[r:RELATED_TO]-() ON (r.feature_context);\n\n")
            
            # Node creation queries
            f.write("-- Import nodes\n")
            for node_type, node_ids in self.node_types.items():
                f.write(f"-- Import {node_type} nodes\n")
                for node_id in list(node_ids)[:5]:  # Sample first 5 to avoid huge file
                    node_data = self.nodes[node_id]
                    props_str = self._format_properties(node_data['properties'])
                    f.write(f"CREATE (:{node_type} {{id: '{node_id}', {props_str}}});\n")
                if len(node_ids) > 5:
                    f.write(f"-- ... and {len(node_ids) - 5} more {node_type} nodes\n")
                f.write("\n")
            
            # Relationship creation queries
            f.write("-- Import relationships\n")
            for rel_type in list(self.relationship_types)[:10]:  # Sample first 10 relationship types
                f.write(f"-- Import {rel_type} relationships\n")
                rel_count = len([r for r in self.relationships if r['type'] == rel_type])
                f.write(f"-- {rel_count} relationships of type {rel_type}\n")
                sample_rels = [r for r in self.relationships if r['type'] == rel_type][:3]
                for rel in sample_rels:
                    props_str = self._format_properties(rel['properties'])
                    f.write(f"MATCH (a), (b) WHERE a.id = '{rel['source']}' AND b.id = '{rel['target']}' CREATE (a)-[:{rel_type} {{{props_str}}}]->(b);\n")
                if rel_count > 3:
                    f.write(f"-- ... and {rel_count - 3} more {rel_type} relationships\n")
                f.write("\n")
        
        print(f"Cypher queries exported to {cypher_file}")
        
    def export_visualization_json(self):
        """Export data in JSON format suitable for visualization tools."""
        
        viz_data = {
            'metadata': {
                'total_nodes': len(self.nodes),
                'total_relationships': len(self.relationships),
                'node_types': {k: len(v) for k, v in self.node_types.items()},
                'relationship_types': list(self.relationship_types)
            },
            'nodes': [],
            'relationships': []
        }
        
        # Convert nodes for visualization
        for node_data in self.nodes.values():
            viz_node = {
                'id': node_data['id'],
                'label': node_data['properties'].get('name', node_data['id']),
                'type': node_data['type'],
                'properties': node_data['properties']
            }
            viz_data['nodes'].append(viz_node)
        
        # Convert relationships for visualization
        for rel_data in self.relationships:
            viz_rel = {
                'id': rel_data['id'],
                'source': rel_data['source'],
                'target': rel_data['target'],
                'type': rel_data['type'],
                'label': rel_data['properties'].get('relation_text', rel_data['type']),
                'properties': rel_data['properties']
            }
            viz_data['relationships'].append(viz_rel)
        
        viz_file = os.path.join(self.output_dir, 'visualization.json')
        with open(viz_file, 'w', encoding='utf-8') as f:
            json.dump(viz_data, f, indent=2, ensure_ascii=False)
        
        print(f"Visualization JSON exported to {viz_file}")
        
    def generate_statistics(self):
        """Generate statistics about the knowledge graph."""
        
        stats = {
            'graph_statistics': {
                'total_nodes': len(self.nodes),
                'total_relationships': len(self.relationships),
                'node_types': {k: len(v) for k, v in self.node_types.items()},
                'relationship_types': {rel_type: len([r for r in self.relationships if r['type'] == rel_type]) 
                                   for rel_type in self.relationship_types}
            },
            'top_entities': self._get_top_entities(),
            'top_features': self._get_top_features(),
            'top_relationships': self._get_top_relationship_types()
        }
        
        stats_file = os.path.join(self.output_dir, 'statistics.json')
        with open(stats_file, 'w', encoding='utf-8') as f:
            json.dump(stats, f, indent=2, ensure_ascii=False)
        
        print(f"Statistics exported to {stats_file}")
        
        # Print summary
        print("\n=== Knowledge Graph Statistics ===")
        print(f"Total Nodes: {stats['graph_statistics']['total_nodes']}")
        print(f"Total Relationships: {stats['graph_statistics']['total_relationships']}")
        print("\nNode Types:")
        for node_type, count in stats['graph_statistics']['node_types'].items():
            print(f"  {node_type}: {count}")
        print("\nTop 5 Relationship Types:")
        for rel_type, count in sorted(stats['graph_statistics']['relationship_types'].items(), 
                                     key=lambda x: x[1], reverse=True)[:5]:
            print(f"  {rel_type}: {count}")
        
    def _sanitize_id(self, text: str) -> str:
        """Sanitize text for use in IDs."""
        return re.sub(r'[^a-zA-Z0-9_]', '_', text.lower())[:50]
        
    def _sanitize_relationship_type(self, relation: str) -> str:
        """Sanitize relation text for use as relationship type."""
        # Convert to uppercase and replace spaces/invalid chars with underscores
        sanitized = re.sub(r'[^a-zA-Z0-9_]', '_', relation.upper())
        # Ensure it starts with a letter
        if sanitized and sanitized[0].isdigit():
            sanitized = 'REL_' + sanitized
        return sanitized[:30] or 'RELATED_TO'
        
    def _categorize_feature(self, feature: str) -> str:
        """Categorize medical features."""
        categories = {
            'chronic': 'Chronic Condition',
            'therapy': 'Treatment',
            'history': 'Medical History',
            'trauma': 'Injury',
            'disease': 'Disease',
            'rate': 'Vital Sign',
            'pressure': 'Vital Sign',
            'test': 'Diagnostic Test',
            'scan': 'Imaging',
            'medication': 'Medication'
        }
        
        feature_lower = feature.lower()
        for keyword, category in categories.items():
            if keyword in feature_lower:
                return category
        return 'General'
        
    def _detect_entity_type(self, entity: str) -> str:
        """Detect entity type based on name patterns."""
        entity_lower = entity.lower()
        
        if any(word in entity_lower for word in ['mg', 'tablet', 'drops', 'dose']):
            return 'Dosage'
        elif any(word in entity_lower for word in ['bp', 'hr', 'rf', 'spo2', '%', 'bpm', 'apm']):
            return 'Vital Sign'
        elif any(word in entity_lower for word in ['ct', 'mri', 'ultrasound', 'scan', 'ecg', 'eeg']):
            return 'Diagnostic Procedure'
        elif any(word in entity_lower for word in ['diabetes', 'hypertension', 'cad', 'cancer']):
            return 'Disease'
        elif any(word in entity_lower for word in ['metformin', 'enalapril', 'asa', 'torvast']):
            return 'Medication'
        elif entity_lower in ['patient', 'therapy', 'history']:
            return 'Medical Concept'
        else:
            return 'Entity'
            
    def _format_properties(self, props: Dict[str, Any]) -> str:
        """Format properties for Cypher queries."""
        formatted = []
        for key, value in props.items():
            if value:
                escaped_value = str(value).replace("'", "\\'")
                formatted.append(f"{key}: '{escaped_value}'")
        return ', '.join(formatted)
        
    def _get_top_entities(self) -> List[Dict]:
        """Get top entities by frequency."""
        entity_counts = Counter()
        for node_data in self.nodes.values():
            if node_data['type'] == 'MedicalEntity':
                name = node_data['properties'].get('name', '')
                if name:
                    entity_counts[name] += 1
        
        return [{'entity': entity, 'count': count} 
                for entity, count in entity_counts.most_common(10)]
                
    def _get_top_features(self) -> List[Dict]:
        """Get top features by number of related entities."""
        feature_counts = Counter()
        for rel_data in self.relationships:
            if rel_data['type'] == 'HAS_FEATURE':
                feature = rel_data['properties'].get('feature_context', '')
                if feature:
                    feature_counts[feature] += 1
        
        return [{'feature': feature, 'count': count} 
                for feature, count in feature_counts.most_common(10)]
                
    def _get_top_relationship_types(self) -> List[Dict]:
        """Get top relationship types."""
        rel_counts = Counter()
        for rel_data in self.relationships:
            rel_counts[rel_data['type']] += 1
        
        return [{'relationship_type': rel_type, 'count': count} 
                for rel_type, count in rel_counts.most_common(10)]
        
    def export_all(self):
        """Export all formats."""
        print("Starting Neo4j export process...")
        
        # Load and process data
        self.load_data()
        self.extract_nodes_and_relationships()
        
        # Export in all formats
        self.export_csv_files()
        self.export_cypher_queries()
        self.export_visualization_json()
        self.generate_statistics()
        
        print(f"\nExport completed! All files saved to: {self.output_dir}")
        print("\nFiles generated:")
        print("  - nodes.csv: Node data for bulk import")
        print("  - relationships.csv: Relationship data for bulk import")
        print("  - import.cypher: Cypher queries for direct execution")
        print("  - visualization.json: JSON format for visualization")
        print("  - statistics.json: Graph statistics and analysis")


def main():
    """Main function to run the export process."""
    input_file = "full_dataset_results.json"
    
    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found!")
        print("Please ensure the file exists in the current directory.")
        return
    
    exporter = Neo4jExporter(input_file)
    exporter.export_all()


if __name__ == "__main__":
    main()
