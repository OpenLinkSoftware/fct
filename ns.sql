



DB.DBA.XML_SET_NS_DECL ('foaf', 'http://xmlns.com/foaf/0.1/', 2);
DB.DBA.XML_SET_NS_DECL ('rev', 'http://purl.org/stuff/rev#', 2);
DB.DBA.XML_SET_NS_DECL ('sioc', 'http://rdfs.org/sioc/ns#', 2);
DB.DBA.XML_SET_NS_DECL ('geonames', 'http://www.geonames.org/ontology#', 2);
DB.DBA.XML_SET_NS_DECL ('geo', 'http://www.w3.org/2003/01/geo/wgs84_pos#', 2);
DB.DBA.XML_SET_NS_DECL ('usc',  'http://www.rdfabout.com/rdf/schema/uscensus/details/100pct/', 2);
DB.DBA.XML_SET_NS_DECL ('b3s', 'http://b3s-demo.openlinksw.com/', 2);


delete from rdf_quad where g = iri_to_id ('b3sonto');

ttlp ('
@prefix foaf: <http://xmlns.com/foaf/0.1/>
@prefix dc: <http://purl.org/dc/elements/1.1/>
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
@prefix b3s: <http://b3s-demo.openlinksw.com/>

rdfs:label rdfs:subPropertyOf b3s:label .
dc:title rdfs:subPropertyOf b3s:label .
foaf:name rdfs:subPropertyOf b3s:label .
foaf:nick rdfs:subPropertyOf b3s:label .', 'xx', 'b3sonto');



rdfs_rule_set ('b3s', 'b3sonto');


ttlp ('
@prefix foaf: <http://xmlns.com/foaf/0.1/>
@prefix owl: <http://www.w3.org/2002/07/owl#>
foaf:mbox_sha1sum a owl:InverseFunctionalProperty .
foaf:name a owl:InverseFunctionalProperty .
', 'xx', 'b3sifp');

rdfs_rule_set ('b3sifp', 'b3sifp');

