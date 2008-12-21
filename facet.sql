



create procedure FCT_LABEL (in x any, in g_id iri_id_8, in ctx varchar, in l iri_id_8)
{
  declare best_str any;
  declare best_l, l int;
  rdf_check_init ();
  best_str := null;
  best_l := 0;
  for select o, p from rdf_quad table option (no cluster) where s = x and p in (rdf_super_sub (ctx, l, 3)) do
    {
      if (is_rdf_box (o) or isstring (o))
	{
	  l := length (o);
	  if (l > best_l)
	    {
	    best_str := o;
	    best_l := l;
	    }
	}
    }
  return best_str;
}

dpipe_define ('DB.DBA.FCT_LABEL', 'DB.DBA.RDF_QUAD', 'RDF_QUAD', 'DB.DBA.FCT_LABEL', 0);


ttlp ('
@prefix foaf: <http://xmlns.com/foaf/0.1/>
@prefix dc: <http://purl.org/dc/elements/1.1/>
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
@prefix virtrdf: <http://www.openlinksw.com/schemas/virtrdf#> 

rdfs:label rdfs:subPropertyOf virtrdf:label .
dc:title rdfs:subPropertyOf virtrdf:label .
foaf:name rdfs:subPropertyOf virtrdf:label .
foaf:nick rdfs:subPropertyOf virtrdf:label .', 'xx', 'facets');



rdfs_rule_set ('facets', 'facets');


create procedure fct_post (in tree any, in post any, in lim int, in offs int)
{
  if (lim is not null)
    http (sprintf (' limit %d ', cast (lim as int)), post);
  if (offs is not null)
    http (sprintf (' offset %d ', cast (offs as int)), post);
}


create procedure fct_xml_wrap (in n int, in txt any)
{
  declare ntxt any;
  ntxt := string_output ();
  if (n = 2)
    http ('select xmlelement ("result", xmlagg (xmlelement ("row", xmlelement ("column", "c1"), xmlelement ("column", "c2")))) from (sparql ', ntxt);
  http (txt, ntxt);
  http (') xx', ntxt);
  return string_output_string (ntxt);
}


create procedure fct_n_cols (in tree any)
{
  declare tp varchar;
  tp := cast (xpath_eval ('//view/@type', tree, 1) as varchar);
  if ('list' = tp)
    return 2;
  return 2;
  signal ('FCT00', 'Unknown facet view type');
}

create procedure fct_view (in tree any, in this_s int, in txt any, in pre any, in post any)
{
  declare lim, offs int;
  declare mode varchar;
  offs := xpath_eval ('./@offset', tree, 1);
  lim := xpath_eval ('./@limit', tree, 1);
  mode := cast (xpath_eval ('./@type', tree, 1) as varchar);
  if ('list' = mode)
    {
      http (sprintf ('select distinct ?s%d as ?c1 (LONG::sql:FCT_LABEL (?s%d, 0, "fct_labels", <label>)) as ?c2 ', this_s, this_s), pre);
      fct_post (tree, post, lim, offs);
    }
  if ('properties' = mode)
    {
      http (sprintf ('select distinct ?s%dp as ?c1 count (*) as ?c2 ', this_s), pre);
      http (sprintf (' ?s%d ?s%dp ?s%do .', this_s, this_s, this_s), txt);
      http (sprintf (' group by ?s%dp order by desc 2', this_s), post);
      fct_post (tree, post, lim, offs);
    }
  if ('classes' = mode)
    {
      http (sprintf ('select ?s%dc as ?c1 count (*) as ?c2 ', this_s), pre);
      http (sprintf (' ?s%d ?a ?s%dc .', this_s, this_s), txt);
      http (sprintf (' group by ?s%dc order by desc 2', this_s), post);
      fct_post (tree, post, lim, offs);
    }
  if ('text' = mode)
    {
      declare exp any;
    exp := cast (xpath_eval ('//text', tree) as varchar);
      http (sprintf ('select distinct ?s%d as ?c1 (bif:search_excerpt (bif:search_terms ("%s"), ?o%d) as ?c2 ', this_s, exp, this_s), pre);
      fct_post (tree, post, lim, offs);
    }
}


create procedure fct_text_1 (in tree any, in this_s int, inout max_s int, in txt any, in pre any, in post any) 
{
  declare c any;
  declare i, len int;
 c := xpath_eval ('./node()', tree, 0);
  for (i := 0; i < length (c); i := i + 1)
    {
      fct_text (c[i], this_s, max_s, txt, pre, post);
    }
}


create procedure fct_text (in tree any, in this_s int, inout max_s int, in txt any, in pre any, in post any) 
{
  declare n varchar;
  n := cast (xpath_eval ('name ()', tree, 1) as varchar);
  if ('class' = n)
    {
      http (sprintf ('?s%d a <%s> .', this_s, cast (xpath_eval ('./@iri', tree) as varchar)), txt);
      return;
    }
  if ('query' = n)
    {
      max_s := 1;
      fct_text_1 (tree, 1, max_s, txt, pre, post);
      return;
    }
  if (n = 'text')
    {
      declare prop varchar;
    prop := cast (xpath_eval ('./@property', tree, 1) as varchar);
      if (prop is not null)
      prop := '<' || prop || '>';
      else 
      prop := sprintf ('?s%dp', this_s);
      http (sprintf (' ?s%d %s ?o%d . filter (bif:contains (?o%d, "%s")) .', this_s, prop, this_s, this_s, cast (tree as varchar)), txt);
    }

  if ('property' = n)
    {
      declare new_s int;
      max_s := max_s + 1;
      new_s := max_s;
      http (sprintf (' ?s%d <%s> ?s%d .', this_s, cast (xpath_eval ('./@iri', tree, 1) as varchar), new_s), txt);
      fct_text_1 (tree, new_s, max_s, txt, pre, post);
    }
  if ('property-of' = n)
    {
      declare new_s int;
      max_s := max_s + 1;
      new_s := max_s;
      http (sprintf (' ?s%d <%s> ?s%d .', new_s, cast (xpath_eval ('./@iri', tree, 1) as varchar), this_s), txt);
      fct_text_1 (tree, new_s, max_s, txt, pre, post);
    }
  if ('value' = n)
    {
      http (sprintf (' filter (?s%d = %s) . ', this_s, cast (tree as varchar)), txt);
    }
  if (n = 'view')
    {
      fct_view (tree, this_s, txt, pre, post);
    }
}


create procedure fct_query (in tree any)
{
  declare s int;
  declare txt, pre, post any;
  txt := string_output ();
  pre := string_output ();
  post := string_output ();
  s := 0;
  fct_text (xpath_eval ('//query', tree), 0, s, txt, pre, post);
  http (' where {', pre);
  http (txt, pre);
  http (' }', pre);
  http (post, pre);
  return string_output_string (pre);
}


create procedure fct_test (in str varchar)
{
  declare sqls, msg varchar;
  declare start_time int;
  declare reply, tree, md, res, qr, qr2 any;
  tree := xtree_doc (str);
  qr := fct_query (xpath_eval ('//query', tree, 1));
 qr2 := fct_xml_wrap (fct_n_cols (tree), qr);
  sqls := '00000';
  start_time := msec_time ();
  exec (qr2, sqls, msg, vector (), 0, md, res);
  if (sqls <> '00000')
    signal (sqls, msg);
  reply := xmlelement ("facets", xmlelement ("sparql", qr), xmlelement ("time", msec_time () - start_time), 
		      xmlelement ("db-activity", db_activity ()), res[0][0]);
  dbg_obj_print (reply);
  return xslt ('file://facet_text.xsl', reply);
}

