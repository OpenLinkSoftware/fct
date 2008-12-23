
-- Facets web page 

create procedure fct_view_pos (in tree any)
{
  declare c any;
  declare i int;
  c := xpath_eval ('//*[name() = "query" or name () = "property" or name () = "property-of"]', tree, 0);
  for (i := 0; i < length (c); i := i + 1)
    {
      if (xpath_eval ('./view', c[i]) is not null)
	return i;
    }
  return null;
}


create procedure fct_set_view (in tree any, in pos int, in tp varchar, in offset int := 0, in limit int := 20)
{
  return xslt ('file://fct_set_view.xsl', tree, vector ('pos', pos, 'type', tp, 'offset', offset, 'limit', limit, 'op', 'view'));
}

create procedure fct_open_property (in tree any, in pos int, in name varchar, in iri varchar, in view_type varchar := 'list', in limit int := 20, in offset int := 0)
{
  return xslt ('file://fct_set_view.xsl', tree, vector ('pos', pos, 'type', view_type, 'offset', offset, 'limit', limit, 'name', name, 'iri', iri, 'op', 'prop'));
}

create procedure fct_close_property (in tree any, in pos int)
{
  return xslt ('file://fct_set_view.xsl', tree, vector ('pos', pos, 'op', 'close'));
}




