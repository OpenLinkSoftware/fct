
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
      return '<error>Invalid content type</error>';
    }
  cnt := http_body_read ();

  dbg_obj_print ('fct_svc');
  dbg_obj_print (string_output_string (cnt));

  declare exit handler for sqlstate '*'
    {
      return sprintf ('<error>Error while executing query</error>');
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
