
cl_exec ('registry_set (''fct_max_timeout'',''10000'')');

DB.DBA.VHOST_REMOVE (lpath=>'/fct/service');
DB.DBA.VHOST_DEFINE (lpath=>'/fct/service', ppath=>'/SOAP/Http/FCT_SVC', soap_user=>'dba');

create procedure fct_svc_exec (in tree any, in timeout int, in accept varchar)
{
  declare start_time int;
  declare sqls, msg, qr, qr2, act varchar;
  declare ret, md, res, xmlout any;

  xmlout := 1;
  if (accept like '%/sparql-results+%' or accept = 'application/json')
    xmlout := 0;
  set result_timeout = timeout;
  sqls := '00000';
  ret := '';
  qr := fct_query (xpath_eval ('//query', tree, 1));
  if (xmlout)
    qr2 := fct_xml_wrap (tree, qr);
  else
    qr2 := 'sparql define output:valmode "LONG" ' || qr;
  start_time := msec_time ();
  --http (qr2);
  exec (qr2, sqls, msg, vector (), 0, md, res);
  act := db_activity ();
  if (sqls <> '00000' and sqls <> 'S1TAT')
    signal (sqls, msg);

  set result_timeout = 0;

  if (xmlout)
    {
      if (not isarray (res) or 0 = length (res) or not isarray (res[0]) or 0 = length (res[0]))
	res := vector (vector (xtree_doc ('<result/>')));

      ret := xmlelement ("facets", xmlelement ("sparql", qr), xmlelement ("time", msec_time () - start_time),
			   xmlelement ("complete", case when sqls = 'S1TAT' then 'no' else 'yes' end),
			   xmlelement ("timeout", timeout),
			   xmlelement ("db-activity", act), res[0][0]);
      ret := xslt ('file:///fct/fct_resp.xsl', ret);
    }
  else
    {
      declare ses, tmp any;
      ses := string_output ();
      DB.DBA.SPARQL_RESULTS_WRITE (ses, md, res, accept, 1);
      ret := ses;
    }
  return ret;
}
;

create procedure fct_svc () __soap_http 'text/xml'
{
  declare cnt, tp, ret, timeout, xt, xslt, maxt, tmp, lines, accept any;

  lines := http_request_header ();
  tp := http_request_header (lines, 'Content-Type');
  accept := http_request_header_full (lines, 'Accept', '*/*');
  accept := DB.DBA.HTTP_RDF_GET_ACCEPT_BY_Q (accept);
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
  ret := fct_svc_exec (xslt, timeout, accept);
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