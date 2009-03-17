create procedure 
isvector (in x any)
{
  if (x is null) return null;
  if (__TAG (x) = 193) return 1;
  return 0;
}

create procedure 
json_out_vec (in v any, inout ses any)
{
  declare s varchar;
  http ('[', ses);

  dbg_obj_print (v[0]);

  for (declare i, l int, l := length (v); i < l; i := i + 1)
    {
      if (isvector(v[i]))
	{
      	  json_out_vec (v[i], ses);
        }
      else
        {
          http (sprintf ('"%s",', v[i]), ses);
        }
    }

  s := rtrim (string_output_string (ses), ',');
  s := s || '],';

  ses := string_output ();
  http (s, ses);
}

DB.DBA.VHOST_REMOVE (lpath=>'/services/rdf/iriautocomplete.get');
DB.DBA.VHOST_DEFINE (lpath=>'/services/rdf/iriautocomplete.get', 
                     ppath=>'/SOAP/Http/IRI_AUTOCOMPLETE', soap_user=>'PROXY');

create procedure 
DB.DBA.IRI_AUTOCOMPLETE () __SOAP_HTTP 'text/json'
{
  declare params any;
  declare res,ses any;
  declare accept varchar;
  declare len int;
  declare iri_str varchar;

  ses := string_output();

  params := http_param ();

  for (declare i, l int,l := length (params); i < l; i := i + 2)
    {
	if (params[i] = 'uri')
          {
            iri_str := params[i+1];
          }
    }

  if (iri_str = '' or iri_str = null)
    goto empty;

  set result_timeout = 1500;

  res := DB.DBA.cmp_uri (params[1]);
  

  if (length (res))
    {
      http ('{', ses);

      if (isvector (res[0]))
          http ('"restype":"multiple",', ses);
      else 
          http ('"restype":"single",', ses);

      http ('"results":', ses);
      json_out_vec (res, ses);
    }
  else goto empty;

  ses := rtrim (string_output_string (ses), ',');
  ses := ses || '}';

  return ses;
 empty:
  return '{results: []}';
}

grant execute on DB.DBA.IRI_AUTOCOMPLETE to PROXY;