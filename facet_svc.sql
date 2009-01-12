
cl_exec ('registry_set (''fct_max_timeout'',''10000'')');

DB.DBA.VHOST_REMOVE (lpath=>'/fct/service');
DB.DBA.VHOST_DEFINE (lpath=>'/fct/service', ppath=>'/SOAP/Http/FCT_SVC', soap_user=>'dba');

create procedure fct_svc () __soap_http 'text/xml'
{
  declare cnt, tp, ret, timeout, xt, xslt, maxt, tmp any;
  tp := http_request_header (http_request_header (), 'Content-Type');
  if (tp <> 'text/xml')
    {
      http_status_set (500);
      return '<error><code>22023</code><message>Invalid content type</message><diagnostics/></error>';
    }
  cnt := http_body_read ();

--  dbg_obj_print ('fct_svc');
--  dbg_obj_print (string_output_string (cnt));

  declare exit handler for sqlstate '*'
    {
      http_status_set (500);
      return sprintf ('<error><code>%V</code><message>Error while executing query</message><diagnostics>%V</diagnostics></error>',
	  __SQL_STATE, __SQL_MESSAGE);
    };
  xt := xtree_doc (cnt);
  xslt := xslt ('file:///fct/fct_req.xsl', xt);

  tmp := cast (xpath_eval ('//query/@timeout', xslt) as varchar);
  if (tmp is null)
    timeout := atoi (registry_get ('fct_timeout'));
  else
    timeout := atoi (tmp);

  maxt := atoi (registry_get ('fct_max_timeout'));
  if (timeout > maxt)
    timeout := maxt;
  ret := fct_exec (xslt, timeout);
  ret := xslt ('file:///fct/fct_resp.xsl', ret);
  return ret;
}
;

grant execute on fct_svc to dba;

DB.DBA.VHOST_REMOVE (lpath=>'/fct/soap');
DB.DBA.VHOST_DEFINE (lpath=>'/fct/soap', ppath=>'/SOAP/', soap_user=>'dba');

select DB.DBA.soap_dt_define ('',
'<element xmlns="http://www.w3.org/2001/XMLSchema" name="facets" targetNamespace="http://openlinksw.com/services/facets/1.0/">
    <complexType>
	<sequence>
	    <any/>
	</sequence>
    </complexType>
</element>');

select DB.DBA.soap_dt_define ('',
'<complexType xmlns="http://www.w3.org/2001/XMLSchema" name="query" targetNamespace="http://openlinksw.com/services/facets/1.0/">
	<sequence>
	    <any/>
	</sequence>
    </complexType>
');

create procedure fct.fct.query (
	in query XMLType __soap_type 'http://openlinksw.com/services/facets/1.0/:query',
	in ws_soap_request any
	)
__SOAP_DOC 'http://openlinksw.com/services/facets/1.0/:facets'
{
  declare cnt, tp, ret, timeout, xt, xslt, maxt, tmp any;
  xt := xml_cut (xpath_eval ('/Envelope/Body/query', xml_tree_doc (ws_soap_request)));
  xslt := xslt ('file:///fct/fct_req.xsl', xt);

  tmp := cast (xpath_eval ('//query/@timeout', xslt) as varchar);
  if (tmp is null)
    timeout := atoi (registry_get ('fct_timeout'));
  else
    timeout := atoi (tmp);

  maxt := atoi (registry_get ('fct_max_timeout'));
  if (timeout > maxt)
    timeout := maxt;
  ret := fct_exec (xslt, timeout);
  ret := xslt ('file:///fct/fct_resp.xsl', ret);
  return ret;
}
;

grant execute on fct.fct.query to dba;
