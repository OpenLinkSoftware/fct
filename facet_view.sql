
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


create procedure fct_view_info (in tree any, in ctx int, in txt any)
{
  declare pos, lim, offs int;
  declare mode varchar;
  pos := 1 + fct_view_pos (tree);
  tree := xpath_eval ('//view', tree);
  mode := cast (xpath_eval ('./@type', tree, 1) as varchar);
 lim := atoi (cast (xpath_eval ('./@limit', tree, 1) as varchar));
 offs := atoi (cast (xpath_eval ('./@offset', tree, 1) as varchar));
  if ('list' = mode)
    {
      http (sprintf ('showing list of s%d\n', pos), txt);
    }
  if ('properties' = mode)
    {
      http (sprintf ('showing properties of s%d\n', pos), txt);
    }
  if ('properties-in' = mode)
    {
      http (sprintf ('showing properties where s%d is the value\n', pos), txt);
    }

  if ('text-properties' = mode)
    {
      http (sprintf ('showing properties of s%d where the value contains %s\n', pos, cast (xpath_evall ('//text', tree) as varchar)), txt);
    }
  if ('classes' = mode)
    {
      http (sprintf ('showing classes of s%d\n', pos), txt);
    }
  if ('text' = mode)
    {
      http (sprintf ('showing objects and text summaries of s%d\n', pos), txt);
    }
  if (offs)
    http (sprintf ('  values %d - %d', 1 + offs, 1 + lim), txt);
  http ('<br>\n', txt);
}


create procedure fct_var_tag (in this_s int, in ctx int)
{
  if (ctx)
    return sprintf ('<a href="/fct/facet.vsp?cmd=set_focus&sid=%d&n=%d">s%d</a>', connection_get ('sid'), this_s, this_s);
  else 
    return sprintf ('s%d', this_s);
}


create procedure fct_query_info_1 (in tree any, in this_s int, inout max_s int, in level int, in ctx any, in txt any)
{
  declare c any;
  declare i, len int;
 c := xpath_eval ('./node()', tree, 0);
  for (i := 0; i < length (c); i := i + 1)
    {
      fct_query_info (c[i], this_s, max_s, level + 1, ctx, txt);
    }
}

create procedure fct_query_info (in tree any, in this_s int, inout max_s int, in level int, in ctx any, in txt any)
{
  declare n varchar;
  n := cast (xpath_eval ('name ()', tree, 1) as varchar);
  http (space (2 * level), txt);
  if ('class' = n)
    {
      http (sprintf ('%s a %s .', fct_var_tag (this_s, ctx), cast (xpath_eval ('./@iri', tree) as varchar)), txt);
    }
  else if ('query' = n)
    {
      max_s := 1;
      fct_view_info (tree, ctx, txt);
      fct_query_info_1 (tree, 1, max_s, 1, ctx, txt);
    }
  else if (n = 'text')
    {
      declare prop varchar;
    prop := cast (xpath_eval ('./@property', tree, 1) as varchar);
      if (prop is null)
        prop := 'any property';
      http (sprintf (' %s contains %s in %s.', fct_var_tag (this_s, ctx), cast (tree as varchar), prop), txt);
    }
  else if ('property' = n)
    {
      declare new_s int;
      max_s := max_s + 1;
      new_s := max_s;
      http (sprintf (' %s %s %s .', fct_var_tag (this_s, ctx), cast (xpath_eval ('./@iri', tree, 1) as varchar), fct_var_tag (new_s, ctx)), txt);
      if (ctx)
	http (sprintf ('<a href="/fct/facet.vsp?sid=%d&cmd=drop&n=%d">drop s%d</a> ', connection_get ('sid'), new_s, new_s), txt);
      fct_query_info_1 (tree, new_s, max_s, level, ctx, txt);
    }
  else if ('property-of' = n)
    {
      declare new_s int;
      max_s := max_s + 1;
      new_s := max_s;
      http (sprintf (' %s  %s %s .', fct_var_tag (new_s, ctx), cast (xpath_eval ('./@iri', tree, 1) as varchar), fct_var_tag (this_s, ctx)), txt);
      if (ctx)
	http (sprintf ('<a href="/fct/facet.vsp?sid=%d&cmd=drop&n=%d">drop s%d</a> ', connection_get ('sid'), new_s, new_s), txt);
      fct_query_info_1 (tree, new_s, max_s, ctx, level, txt);
    }
  if ('value' = n)
    {
      http (sprintf (' %s = %s .', fct_var_tag (this_s, ctx), cast (tree as varchar)), txt);
    }
  if (ctx)
    http (' <br>\n', txt);
  else 
    http ('\n', txt);
}



vhost_define (lpath=>'/fct',ppath=>'/fct/',vsp_user=>'dba', def_page=>'index.vsp;index.vspx;');

create table fct_state (fct_sid int primary key, fct_state xmltype);
alter index fct_state on fct_state partition (fct_sid int);

sequence_next ('fct_seq');


create procedure fct_top (in tree any, in txt any)
{
  declare max_s int;
  max_s := 0;
  fct_query_info (xpath_eval ('/query', tree), 1, max_s, 1, 1, txt);
  http ('<br>Results:<br><br>', txt);
}


create procedure fct_view_link (in tp varchar, in msg varchar, in txt any)
{
  http (sprintf ('<a href="/fct/facet.vsp?cmd=set_view&sid=%d&type=%s&limit=20&offset=0">%s</a><br>\n', connection_get ('sid'), tp, msg), txt);
}


create procedure fct_nav (in tree any, in reply any, in txt any)
{
  declare pos int;
  declare tp varchar;
  tp := cast (xpath_eval ('//view/@type', tree) as varchar);
  pos := fct_view_pos (tree);
  if ('text-properties' = tp)
    {
      fct_view_link ('text', 'Return to text match list', txt);
      return;
    }
  if ('text' = tp and pos = 1)
    fct_view_link ('text-properties', 'Show properties where the text occurs', txt);
  if ('classes' <> tp)
    fct_view_link ('classes', 'Show classes', txt);
  if ('properties' <> tp)
    fct_view_link ('properties', 'Show properties', txt);
  if ('properties-in' <> tp)
    fct_view_link ('properties-in', 'Show properties where these are the values', txt);
} 


create procedure fct_view_type (in vt varchar)
{
  if (vt in ('properties', 'classes', 'properties-in', 'text-properties'))
    return 'properties';
  return 'default';
}

create procedure fct_view_cmd (in tp varchar)
{
  if ('text_properties' = tp)
    return 'set_text_property';
  if ('properties' = tp)
    return 'open_property';
  if ('properties-in' = tp)
    return 'open_property_of';
  if ('classes' = tp)
    return 'set_class';
  return 'select_value';
}


create procedure fct_web (in tree any, in timeout int := 0)
{
  declare sqls, msg, tp varchar;
  declare start_time int;
  declare reply, md, res, qr, qr2, txt any;
  qr := fct_query (xpath_eval ('//query', tree, 1));
 qr2 := fct_xml_wrap (fct_n_cols (tree), qr);
  set result_timeout = timeout;
  sqls := '00000';
  start_time := msec_time ();
  exec (qr2, sqls, msg, vector (), 0, md, res);
  if (sqls <> '00000' and sqls <> 'S1TAT')
    signal (sqls, msg);
  reply := xmlelement ("facets", xmlelement ("sparql", qr), xmlelement ("time", msec_time () - start_time),
		       xmlelement ("complete", case when sqls = 'S1TAT' then 'no' else 'yes' end),
		       xmlelement ("db-activity", db_activity ()), res[0][0]);
  --dbg_obj_print (reply);
 txt := string_output ();
  fct_top (tree, txt);
 tp := cast (xpath_eval ('//view/@type', tree) as varchar);
  http_value (xslt ('file://fct/fct_vsp.xsl', reply, vector ('sid', connection_get ('sid'), 'cmd', fct_view_cmd (tp), 'type', fct_view_type (tp))),
	      null, txt);
  fct_nav (tree, reply, txt);
  http (txt);
}



create procedure fct_set_text (in tree any, in sid int, in txt varchar)
{
  declare new_tree any;
 new_tree := xslt ('file://fct/fct_set_text.xsl', tree, vector ('text', txt, 'prop', 'none'));
  if (xpath_eval ('//view', new_tree) is null)
    {
    new_tree := xslt ('file://fct/fct_set_view.xsl', new_tree, vector ('pos', 0, 'type', 'text', 'limit', 20, 'op', 'view'));
      dbg_obj_print (new_tree);
    }
  update fct_state set fct_state = new_tree where fct_sid = sid; 
  commit work;
  fct_web (new_tree);
}


create procedure fct_set_focus (in tree any, in sid int, in pos int)
{
  tree := xslt ('file://fct/fct_set_view.xsl', tree, vector ('pos', pos - 1, 'op', 'view', 'type', 'list', 'limit', 20, 'offset', 0));
  update fct_state set fct_state = tree where fct_sid = sid;
  commit work;
  fct_web (tree);
}


create procedure fct_drop (in tree any, in sid int, in pos int)
{
 tree := xslt ('file://fct/fct_set_view.xsl', tree, vector ('pos', pos - 1, 'op', 'close'));
  if (xpath_eval ('//view', tree) is null)
    tree := xslt ('file://fct/fct_set_view.xsl', tree, vector ('pos', 0, 'op', 'view', 'type', 'list', 'limit', 20, 'offset', 0));
  update fct_state set fct_state = tree where fct_sid = sid;
  commit work;
  fct_web (tree);
}


create procedure fct_set_view (in tree any, in sid int, in tp varchar, in lim int, in offs int)
{
  declare pos int;
  pos := fct_view_pos (tree);
  tree := xslt ('file://fct/fct_set_view.xsl', tree, vector ('pos', pos, 'op', 'view', 'type', tp, 'limit', lim, 'offset', offs));
  update fct_state set fct_state = tree where fct_sid = sid;
  commit work;
  fct_web (tree);
}

create procedure fct_next (in tree any, in sid int)
{
  declare tp varchar;
  declare lim, offs int;
  tp := cast (xpath_eval ('//view/@type', tree) as varchar);
  lim := atoi (cast (xpath_eval ('//view/@limit', tree) as varchar));
  offs := atoi (cast (xpath_eval ('//view/@offset', tree) as varchar));
  fct_set_view  (tree, sid, tp, lim + 20, offs + 20);
}


create procedure fct_open_property  (in tree any, in sid int, in iri varchar, in name varchar)
{
  declare pos int;
  pos := fct_view_pos (tree);
 tree := xslt ('file://fct/fct_set_view.xsl', tree, vector ('pos', pos, 'op', 'prop', 'name', name, 'iri', iri, 'type', 'list', 'limit', 20, 'offset', 0));
  update fct_state set fct_state = tree where fct_sid = sid;
  commit work;
  fct_web (tree);
}


create procedure fct_set_class  (in tree any, in sid int, in iri varchar)
{
  declare pos int;
  pos := fct_view_pos (tree);
 tree := xslt ('file://fct/fct_set_view.xsl', tree, vector ('pos', pos, 'op', 'class', 'iri', iri, 'type', 'list', 'limit', 20, 'offset', 0));
  update fct_state set fct_state = tree where fct_sid = sid;
  commit work;
  fct_web (tree);
}


create procedure fct_new ()
{
  declare sid int;
  sid := sequence_next ('fct_seq');
  insert into fct_state (fct_sid, fct_state) values (sid, '<query />');
  ?> 
<form method="post" action="/fct/facet.vsp?cmd=text&sid=<?= sid ?>" >
Search for: <input type=text name=search_for> 
<input type=submit  value="Go">
</form>
<?vsp 
}


create procedure fct_vsp ()
{
  declare cmd varchar;
  declare tree any;
  declare sid int;
  cmd := http_param ('cmd');
  if (0 = cmd)
    {
      fct_new ();
      return;
    }
  sid := atoi (http_param ('sid'));
  whenever not found goto no_ses;
  select fct_state into tree from fct_state where fct_sid = sid;
  connection_set ('sid', sid);
  if ('text' = cmd)
    fct_set_text (tree, sid, http_param ('search_for'));
  else if ('set_focus' = cmd)
    fct_set_focus (tree, sid, atoi (http_param ('n')));
  else if ('set_view' = cmd)
    fct_set_view (tree, sid, http_param ('type'), atoi (http_param ('limit')), atoi (http_param ('offset')));
  else if ('next' = cmd)
    fct_next (tree, sid);
  else if ('open_property' = cmd)
    fct_open_property (tree, sid, http_param ('iri'), 'property');
  else if ('open_property_of' = cmd)
    fct_open_property (tree, sid, http_param ('iri'), 'property-of');
  else if ('drop' = cmd)
    fct_drop (tree, sid, atoi (http_param ('n')));
  else if ('set_class' = cmd)
    fct_set_class (tree, sid, http_param ('iri'));
  else 
    {
      http ('Unrecognized command');
      return;
    }
  return;
 no_ses:
  http ('bad session number.  New search started');
  fct_new ();
}



