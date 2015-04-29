SPARQL
PREFIX oplacl: <http://www.openlinksw.com/ontology/acl#>

DELETE WHERE {
  GRAPH <urn:virtuoso:val:acl:schema> {
    <urn:virtuoso:val:scopes:sponger:describe> ?p ?o .
  }
}

INSERT INTO <urn:virtuoso:val:acl:schema> 
{
      <urn:virtuoso:val:scopes:sponger:describe> a  oplacl:Scope ;
	rdfs:label  "Sponger /describe endpoint scope" ;
        rdfs:comment  """Sponger ACL scope which contains all ACL rules granting access to the /describe service.
The scope includes two access modes: sponge and read. Read access allows use of the /describe service to view 
Linked Data descriptions of resources. Sponge access allows use of the Sponger via the /describe service to
generate the Linked Data descriptions. By default all users have full use of the service.""" ;
	oplacl:hasApplicableAccess  oplacl:Read , oplacl:Sponge ;
        oplacl:hasDefaultAccess  oplacl:Read , oplacl:Sponge .
}
;
