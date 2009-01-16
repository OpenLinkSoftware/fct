set ignore_params=on;
-- Facets web page

create procedure
fct_view_pos (in tree any)
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


create procedure
fct_view_info (in tree any, in ctx int, in txt any)
{
  declare pos, lim, offs int;
  declare mode varchar;

  pos := 1 + fct_view_pos (tree);
  tree := xpath_eval ('//view', tree);
  mode := cast (xpath_eval ('./@type', tree, 1) as varchar);
  lim := atoi (cast (xpath_eval ('./@limit', tree, 1) as varchar));
  offs := atoi (cast (xpath_eval ('./@offset', tree, 1) as varchar));

  http ('<h3 id="view_info">', txt);
  if ('list' = mode)
    {
      http (sprintf ('showing list of %s%d\n', connection_get ('s_term'), pos), txt);
    }
  if ('list-count' = mode)
    {
      http (sprintf ('showing list of distinct %s%d with counts\n', connection_get ('s_term'), pos), txt);
    }
  if ('properties' = mode)
    {
      http (sprintf ('showing properties of %s%d\n', connection_get ('s_term'), pos), txt);
    }
  if ('properties-in' = mode)
    {
      http (sprintf ('showing %s where %s%d is the value\n',
      	   	     connection_get ('c_term'),
                     connection_get ('s_term'),
		     pos), txt);
    }

  if ('text-properties' = mode)
    {
      http (sprintf ('showing %s of %s%d where the value contains "%s"\n',
                     connection_get ('c_term'),
		     connection_get ('s_term'),
		     pos,
	    	     cast (xpath_eval ('//text', tree) as varchar)),
            txt);
    }
  if ('classes' = mode)
    {
      http (sprintf ('Displaying types of %s%d\n', connection_get ('s_term'), pos), txt);
    }
  if ('text' = mode)
    {
      http (sprintf ('Displaying values and text summaries associated with pattern: %s%d\n', connection_get ('s_term'), pos), txt);
    }
  if (offs)
    http (sprintf ('  values %d - %d', 1 + offs, lim), txt);
  http ('</h3>\n', txt);
}


create procedure
fct_var_tag (in this_s int, in ctx int)
{
  if (ctx)
    return sprintf ('<a href="/fct/facet.vsp?cmd=set_focus&sid=%d&n=%d" title="Focus on %s%d">%s%d</a>',
                    connection_get ('sid'),
		    this_s,
		    connection_get ('s_term'),
		    this_s,
		    connection_get ('s_term'),
		    this_s);
  else
    return sprintf ('%s%d', connection_get ('s_term'), this_s);
}


create procedure
fct_query_info_1 (in tree any,
		  in this_s int,
		  inout max_s int,
		  in level int,
		  in ctx any,
		  in txt any,
		  inout cno int)
{
  declare c any;
  declare i, len int;
  c := xpath_eval ('./node()', tree, 0);
  for (i := 0; i < length (c); i := i + 1)
    {
      fct_query_info (c[i], this_s, max_s, level + 1, ctx, txt, cno);
    }
}

create procedure
fct_space (in n int)
{
  declare i int;
  declare t varchar;

  t := '';

  for (i := 0; i < n; i := i + 1) {
    concat (t, '&nbsp;');
  }

  return t;
}
;

create procedure
fct_query_info (in tree any,
	        in this_s int,
		inout max_s int,
		in level int,
		in ctx any,
		in txt any,
		inout cno int)
{
  declare n varchar;

  n := cast (xpath_eval ('name ()', tree, 1) as varchar);

  http (fct_space (2 * level), txt);

  if ('class' = n)
    {
      http (sprintf ('%s is a <span class="iri">%s</span> . <a href="/fct/facet.vsp?sid=%d&cmd=drop_cond&cno=%d">Drop</a>',
                     fct_var_tag (this_s, ctx),
		     fct_short_form (cast (xpath_eval ('./@iri', tree) as varchar)),
		     connection_get ('sid'),
		     cno),
            txt);
      cno := cno + 1;
    }
  else if ('query' = n)
    {
      max_s := 1;
      fct_view_info (tree, ctx, txt);
      fct_query_info_1 (tree, 1, max_s, 1, ctx, txt, cno);
    }
  else if (n = 'text')
    {
      declare prop varchar;
      prop := cast (xpath_eval ('./@property', tree, 1) as varchar);

      http (sprintf (' %s has %s whose value contains <span class="value">"%s"</span>. ',
                     fct_var_tag (this_s, ctx),
		     case 
		       when prop is not null 
		       then 'property <span class="iri">' || fct_short_form (prop) || '</span>' 
		       else 'any property' 
                     end, 
		     cast (tree as varchar)),
	    txt);

--      if (prop is not null)
--        {
--	  http (sprintf (' <a href="/fct/facet.vsp?sid=%d&cmd=drop_cond&cno=%d">Drop</a>',
--		     connection_get ('sid'),
--		     cno)
--               ,txt);
--        }	         	   
    }
  else if ('property' = n)
    {
      declare new_s int;
      max_s := max_s + 1;
      new_s := max_s;
      http (sprintf (' %s <span class="iri">%s</span> %s . ',
                     fct_var_tag (this_s, ctx),
		     fct_short_form (cast (xpath_eval ('./@iri', tree, 1) as varchar)), fct_var_tag (new_s, ctx)), txt);
      if (ctx)
	http (sprintf ('<a href="/fct/facet.vsp?sid=%d&cmd=drop&n=%d">Drop %s%d</a> ',
	               connection_get ('sid'), new_s, connection_get('s_term'), new_s), txt);
      fct_query_info_1 (tree, new_s, max_s, level, ctx, txt, cno);
    }
  else if ('property-of' = n)
    {
      declare new_s int;
      max_s := max_s + 1;
      new_s := max_s;
      http (sprintf (' %s <span class="iri">%s</span> %s . ',
                     fct_var_tag (new_s, ctx),
		     fct_short_form (cast (xpath_eval ('./@iri', tree, 1) as varchar), 1),
		     fct_var_tag (this_s, ctx)),
            txt);

      if (ctx)
	http (sprintf ('<a href="/fct/facet.vsp?sid=%d&cmd=drop&n=%d">Drop %s%d</a> ',
	connection_get ('sid'),
	new_s, connection_get ('s_term'), new_s), txt);
      fct_query_info_1 (tree, new_s, max_s, ctx, level, txt, cno);
    }
  if ('value' = n)
    {
      http (sprintf (' %s %s %V . <a href="/fct/facet.vsp?sid=%d&cmd=drop_cond&cno=%d">Drop</a>',
                     fct_var_tag (this_s, ctx),
		     cast (xpath_eval ('./@op', tree) as varchar),
		     fct_literal (tree),
		     connection_get ('sid'),
		     cno),
            txt);
    }
  if (ctx)
    http ('<br/>\n', txt);
  else
    http ('\n', txt);
}

vhost_define (lpath=>'/fct',ppath=>'/fct/',vsp_user=>'dba', def_page=>'index.vsp;index.vspx;');

create table fct_state (fct_sid int primary key, fct_state xmltype);
alter index fct_state on fct_state partition (fct_sid int);

create table fct_log (
  fl_sid int, 
  fl_ts timestamp, 
  fl_cli_ip varchar,
  fl_where varchar, 
  fl_state xmltype, 
  fl_cmd varchar,
  fl_sqlstate varchar,
  fl_sqlmsg varchar,
  fl_parms varchar,
  primary key (fl_sid, fl_ts));

sequence_next ('fct_seq');

create procedure
fct_top (in tree any, in txt any)
{
  declare max_s int;
  max_s := 0;

  declare cno int;
  cno := 0;

  fct_query_info (xpath_eval ('/query', tree), 1, max_s, 1, 1, txt, cno);

}


create procedure
fct_view_link (in tp varchar, in msg varchar, in txt any)
{
  http (sprintf ('<li><a href="/fct/facet.vsp?cmd=set_view&sid=%d&type=%s&limit=20&offset=0">%s</a></li>\n',
                 connection_get ('sid'), tp, msg),
        txt);
}

create procedure
fct_set_conn_tlogy (in tree any)
{
  declare c_term, s_term varchar;
  c_term := cast (xpath_eval ('/query/@c-term', tree) as varchar);
  s_term := cast (xpath_eval ('/query/@s-term', tree) as varchar);
  connection_set ('c_term', c_term);
  connection_set ('s_term', s_term);
}

create procedure
fct_nav (in tree any,
         in reply any,
         in txt any)
{
  declare pos int;
  declare tp varchar;
  tp := cast (xpath_eval ('//view/@type', tree) as varchar);
  pos := fct_view_pos (tree);

  fct_set_conn_tlogy (tree);

  http ('<div id="fct_nav">', txt);
  http ('<h3>Navigation</h3>', txt);
  http ('<ul class="n1">', txt);

  if ('text-properties' = tp)
    {
      fct_view_link ('text', 'Return to text match list', txt);
      return;
    }

  if ('properties' <> tp)
    fct_view_link ('properties', 'Properties', txt);

  if ('text' = tp and pos = 0)
    fct_view_link ('text-properties', 'Properties containing the text', txt);

  if ('properties-in' <> tp)
    fct_view_link ('properties-in', 'Referencing properties', txt);

  if ('text' <> tp)
    {
      if (tp <> 'list-count')
	fct_view_link ('list-count', 'Distinct values with counts', txt);
      if (tp <> 'list')
	fct_view_link ('list', 'Show values', txt);
    }
  if ('classes' <> tp)
    if (connection_get('c_term') = 'class') fct_view_link ('classes', 'Classes', txt);
    else fct_view_link ('classes', 'Types', txt);

  http ('</ul>\n<ul class="n2">', txt);
  http (sprintf ('<li><a href="/fct/facet.vsp?cmd=set_inf&sid=%d">Options</a></li>', connection_get ('sid')), txt);
  http ('<li><a href=/fct/facet.vsp?qq=ww">New Search</a></li>', txt);
  http ('</ul>', txt);
  http ('</div> <!-- #fct_nav -->', txt);
}


create procedure
fct_view_type (in vt varchar)
{
  if (vt in ('properties', 'classes', 'properties-in', 'text-properties', 'list', 'list-count'))
    return 'properties';
  return 'default';
}

create procedure
fct_view_cmd (in tp varchar)
{
  if ('text-properties' = tp)
    return 'set_text_property';
  if ('properties' = tp)
    return 'open_property';
  if ('properties-in' = tp)
    return 'open_property_of';
  if ('classes' = tp)
    return 'set_class';
  return 'select_value';
}


cl_exec ('registry_set (''fct_timeout'', ''0'')');

create procedure
fct_web (in tree any, in timeout int := 0)
{
  declare sqls, msg, tp varchar;
  declare start_time int;
  declare reply, md, res, qr, qr2, txt, time_txt any;

  time_txt := http_param ('timeout');

  if (isstring (time_txt))
    timeout := atoi (time_txt);
  else
    timeout := atoi (registry_get ('fct_timeout'));

  reply := fct_exec (tree, timeout);

  --dbg_obj_print (reply);

  txt := string_output ();

  http ('<div id="top_ctr">', txt);
  fct_top (tree, txt);
  http ('</div>', txt);

  tp := cast (xpath_eval ('//view/@type', tree) as varchar);

  http_value (xslt ('file://fct/fct_vsp.xsl',
                    reply,
		    vector ('sid',
		            connection_get ('sid'),
     			    'cmd',
			    fct_view_cmd (tp),
			    'type',
			    fct_view_type (tp),
			    'timeout',
			    timeout)),
	      null, txt);


  -- dbg_obj_print (reply);
  -- dbg_printf ('%s', string_output_string (txt));

  fct_nav (tree, reply, txt);

  http (txt);
}

create procedure
fct_set_text (in tree any, in sid int, in txt varchar)
{
  declare new_tree any;

  new_tree := xslt ('file://fct/fct_set_text.xsl', tree, vector ('text', txt, 'prop', 'none'));

  if (xpath_eval ('//view', new_tree) is null)
    {
      new_tree := xslt ('file://fct/fct_set_view.xsl',
                        new_tree,
		        vector ('pos', 0, 'type', 'text', 'limit', 20, 'op', 'view'));
    }

  update fct_state set fct_state = new_tree where fct_sid = sid;

  commit work;

  fct_web (new_tree);
}


create procedure
fct_set_text_property (in tree any, in sid int, in iri varchar)
{
  declare new_tree, txt any;
  txt := cast (xpath_eval ('//text', tree) as varchar);
  new_tree := xslt ('file://fct/fct_set_text.xsl', tree, vector ('text', txt, 'prop', iri));
  new_tree := xslt ('file://fct/fct_set_view.xsl', new_tree, vector ('pos', 0, 'type', 'text', 'limit', 20, 'op', 'view'));
  update fct_state set fct_state = new_tree where fct_sid = sid;
  commit work;
  fct_web (new_tree);
}

create procedure
fct_set_focus (in tree any, in sid int, in pos int)
{
  tree := xslt ('file://fct/fct_set_view.xsl',
                tree,
		vector ('pos', pos - 1, 'op', 'view', 'type', 'list', 'limit', 20, 'offset', 0));
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

create procedure
fct_drop_cond (in tree any, in sid int, in cno int)
{
  tree := xslt ('file://fct/fct_drop_cond.xsl', tree, vector ('cno', cno));

  update fct_state set fct_state = tree where fct_sid = sid;
  commit work;
  fct_web (tree);
}

create procedure
fct_set_view (in tree any, in sid int, in tp varchar, in lim int, in offs int)
{
  declare pos int;
  pos := fct_view_pos (tree);

  if ('text-properties' = tp)
    {
      declare txt varchar;

      txt := cast (xpath_eval ('//text', tree) as varchar);
      tree := xslt ('file://fct/fct_set_text.xsl',
                    tree,
		    vector ('text', txt, 'prop', 'none'));
    }

  tree := xslt ('file://fct/fct_set_view.xsl',
                tree,
		vector ('pos', pos, 'op', 'view', 'type', tp, 'limit', lim, 'offset', offs));

  update fct_state set fct_state = tree where fct_sid = sid;
  commit work;

  fct_web (tree);
}

create procedure
fct_next (in tree any, in sid int)
{
  declare tp varchar;
  declare lim, offs int;
  tp := cast (xpath_eval ('//view/@type', tree) as varchar);
  lim := atoi (cast (xpath_eval ('//view/@limit', tree) as varchar));
  offs := atoi (cast (xpath_eval ('//view/@offset', tree) as varchar));
  fct_set_view  (tree, sid, tp, lim + 20, offs + 20);
}


create procedure
fct_open_property  (in tree any, in sid int, in iri varchar, in name varchar)
{
  declare pos int;
  pos := fct_view_pos (tree);
  tree := xslt ('file://fct/fct_set_view.xsl',
                tree,
		vector ('pos', pos, 'op', 'prop', 'name', name, 'iri', iri, 'type', 'list', 'limit', 20, 'offset', 0));
  update fct_state set fct_state = tree where fct_sid = sid;

  commit work;
  fct_web (tree);
}


create procedure fct_set_class (in tree any, in sid int, in iri varchar)
{
  declare pos int;

  pos := fct_view_pos (tree);
  tree := xslt ('file://fct/fct_set_view.xsl',
                tree,
                vector ('pos', pos, 'op', 'class', 'iri', iri, 'type', 'list', 'limit', 20, 'offset', 0));

  update fct_state set fct_state = tree where fct_sid = sid;

  commit work;
  fct_web (tree);
}


create procedure fct_new ()
{
  declare sid int;
  sid := sequence_next ('fct_seq');
  insert into fct_state (fct_sid, fct_state) values (sid, '<query inference="" same-as="" s-term="" c-term=""/>');
  ?>
  <form method="post"
        action="/fct/facet.vsp?cmd=text&sid=<?= sid ?>" >
  <div id="new_srch">
    <label class="left_txt"
           for="new_search_txt">Search for</label><input id="new_search_txt" size="60" type=text name=search_for>
  <input type=submit  value="Go">
  </div>
  </form>
  <?vsp
}


--	 <!-- <label class="left_txt" for="inf_type">Inference context name</label>
--         <input id="inf_type"
--                type="text"
--                name="inference"
--                value="<?= selected_inf ?>"><br/>
--         <input id="inf_sas"
--                type="checkbox"
--                name="same-as" <?= case when selected_sas = 'yes' then 'selected="true"' else '' end ?>">
--         <label class="cbox" for="inf_sas">Follow owl:sameAs</label><br/>
         -->

create procedure
fct_set_inf (in tree any, in sid int)
{
  declare inf, sas, tlogy, s_term, c_term varchar;
  inf := http_param ('inference');
  sas := http_param ('same-as');
  tlogy := http_param ('tlogy');


  if (0 = sas or 0 = inf or
  	0 = tlogy)
    {
      declare selected_inf, selected_sas, sel_c_term, sel_s_term  varchar;

     again:

      selected_inf := cast (xpath_eval ('/query/@inference', tree) as varchar);
      selected_sas := cast (xpath_eval ('/query/@same-as',   tree) as varchar);
      sel_c_term   := cast (xpath_eval ('/query/@c-term',    tree) as varchar);
      sel_s_term   := cast (xpath_eval ('/query/@s-term',    tree) as varchar);

      ?> <div id="opts_ctr">
           <div id="opts">
             <h2>Options</h2>
             <form action="/fct/facet.vsp?cmd=set_inf&sid=<?= sid ?>" method=post>
	       <div class="opt_sect">
<h3>Inference</h3>
Inference: <input type=text name="inference" value="<?=selected_inf ?>"> <br> 
Same As: <input type=text name="same-as" value="<?=selected_sas ?>"> <br> 
	         <h3>User Interface</h3>
	         <label class="left_txt" for="tlogy">Terminology</label>
                 <select name="tlogy">
	           <option value="eav" <?= case when sel_s_term = 'e' then 'selected="true"' else '' end ?>>Entity-Attribute-Value</option>
	           <option value="spo" <?= case when sel_s_term = 's' then 'selected="true"' else '' end ?>>Subject-Predicate-Object</option>
	       	 </select>
               </div>
               <br/><input type=submit value="Apply">
             </form>
	   </div>
         </div>
       <?vsp
     return;
    }

  if (isstring (sas) and isstring (inf) and
  isstring (tlogy))
    {
--      dbg_printf ('tlogy: %s', tlogy);

      if (inf <> '' and not exists (select 1 from sys_rdf_schema where rs_name = inf))
	{
	  http ('<div class="err">Incorrect inference context name</div>');
	  inf := 0;
	  goto again;
	}

      c_term := case when 'eav' = tlogy then 'type' else 'class' end;
      s_term := case when 'eav' = tlogy then 'e' else 's' end;

      tree := xmlupdate (tree,
      	         '/query/@inference', inf,
		         '/query/@same-as',   sas,
			 '/query/@s-term',    s_term,
			 '/query/@c-term',    c_term);

      connection_set ('c_term', c_term);
      connection_set ('s_term', s_term);

      update fct_state set fct_state = tree where fct_sid = sid;

      commit work;

      fct_refresh (tree);
    }
}

create procedure
fct_open_iri (in tree any, in sid int, in iri varchar)
{
  declare txt, sqls, msg, md, res, res_tree any;

  http (sprintf ('Showing iri %s', iri));
  txt := string_output ();

  http ('select xmlelement ("result", xmlagg (xmlelement ("row", xmlelement ("column", __ro2sq ("c1")), xmlelement ("column", fct_label ("c1", 0, ''facets'')), xmlelement ("column", xmlattributes (fct_lang ("c2") as "xml:lang", fct_dtp ("c2") as "datatype"), __ro2sq ("c2"))))) from (sparql define output:valmode "LONG" ', txt);

  http (sprintf (' %s %s %s select ?c1 ?c2 where { <%s> ?c1 ?c2 } limit 10000) xx',
    	fct_graph_clause (tree),
	fct_inf_clause (tree),
	fct_sas_clause (tree),
	iri), txt);

  sqls:= '00000';

  exec (string_output_string (txt), sqls, msg, vector (), 0, md, res);

  if ('00000' <> sqls)
    signal (sqls, msg);

  txt := string_output ();
  res_tree := xslt ('file://fct/open.xsl', res[0][0], vector ('sid', sid));

  http_value (res_tree, null);
}

create procedure
fct_refresh (in tree any)
{
  fct_web (tree);
}

create procedure
fct_bold_tags (in s varchar)
{
  declare ret any;

  declare exit handler for sqlstate '*'
    {
      return s;
    };

  ret := xtree_doc (sprintf ('<span class="srch_xerpt">%s</span>', s));
  -- dbg_obj_print (ret);
  return ret;
}

create procedure
fct_select_value (in tree any,
		  in sid int,
		  in val varchar,
		  in lang varchar,
		  in dtp varchar,
		  in op varchar)
{
  declare pos int;

--  dbg_printf ('in fct_select_value()');

  if (op is null or op = '' or op = 0)
    op := '=';

  pos := fct_view_pos (tree);

  tree := xslt ('file://fct/fct_set_view.xsl',
                tree,
		vector ('pos', pos, 'op', 'value', 'iri', val, 'lang', lang, 'datatype', dtp, 'cmp', op));

--  dbg_obj_print (tree);

  if (op = '=')
    tree := xslt ('file://fct/fct_set_view.xsl',
                  tree,
		  vector ('pos', 0, 'op', 'view', 'type', 'list', 'limit', 20, 'offset', 0));

--  dbg_obj_print (tree);

  update fct_state set fct_state = tree where fct_sid = sid;

  commit work;
  fct_web (tree);
}

create procedure
fct_vsp ()
{
  declare cmd varchar;
  declare tree any;
  declare sid int;
  declare _to int;
  declare _to_max int;
  declare _to_def int;

  cmd := http_param ('cmd');

  if (0 = cmd)
    {
      fct_new ();
      return;
    }

  sid := atoi (http_param ('sid'));

  _to := http_param ('timeout'); -- XXX add timeout
  if (_to <> 0) _to := atoi (_to);

  _to_max := registry_get ('fct_max_to');
  _to_def := registry_get ('fct_def_to');

  if (_to_def = 0) _to_def := 8000;
  if (_to = 0) _to := _to_def;
  if (_to*2 > _to_max)
    {
      _to := _to_max;
    }

  connection_set ('timeout', _to);

  whenever not found goto no_ses;

  select fct_state into tree from fct_state where fct_sid = sid;
  connection_set ('sid', sid);

  declare s_term varchar;
  s_term := cast (xpath_eval ('/query/@s-term', tree) as varchar);
  if ('' = s_term) s_term := 'e';
  connection_set ('s_term', s_term);

  declare c_term varchar;
  c_term := cast (xpath_eval ('/query/@c-term', tree) as varchar);
  if ('' = c_term) c_term := 'class';
  connection_set ('c_term', c_term);

  insert into fct_log (fl_sid, fl_cli_ip, fl_where, fl_state, fl_cmd)
         values (sid, http_client_ip(), 'DISPATCH', tree, cmd);
  commit work;

  if ('text' = cmd)
    fct_set_text (tree, sid, http_param ('search_for'));
  else if ('set_focus' = cmd)
    fct_set_focus (tree, sid, atoi (http_param ('n')));
  else if ('set_view' = cmd)
    fct_set_view (tree,
    		  sid,
		  http_param ('type'),
                  atoi (http_param ('limit')),
		  atoi (http_param ('offset')));
  else if ('next' = cmd)
    fct_next (tree, sid);
	else if ('set_text_property' = cmd)
	fct_set_text_property (tree, sid, http_param ('iri'));
  else if ('open_property' = cmd)
    fct_open_property (tree, sid, http_param ('iri'), 'property');
  else if ('open_property_of' = cmd)
    fct_open_property (tree, sid, http_param ('iri'), 'property-of');
  else if ('drop' = cmd)
    fct_drop (tree, sid, atoi (http_param ('n')));
  else if ('drop_cond' = cmd)
    fct_drop_cond (tree, sid, atoi (http_param ('cno')));
  else if ('set_class' = cmd)
    fct_set_class (tree, sid, http_param ('iri'));
  else if ('open' = cmd)
    fct_open_iri (tree, sid, http_param ('iri'));
  else if ('refresh' = cmd)
    fct_refresh (tree);
  else if ('set_inf' = cmd)
    fct_set_inf (tree, sid);
  else if ('select_value' = cmd)
    fct_select_value (tree,
    		      sid,
		      http_param ('iri'),
		      http_param ('lang'),
		      http_param ('datatype'),
		      http_param ('op'));
  else
    {
      http ('Unrecognized command');
      return;
    }

  declare _state any;

  select fct_state into _state from fct_state where fct_sid = http_param ('sid');

  insert into fct_log (fl_sid, fl_cli_ip, fl_where, fl_state, fl_cmd)
         values (sid, http_client_ip(), 'RETURN', _state, cmd);
  commit work;
  
  return;

 no_ses:
  http ('<div class="ses_info">Session lost. New search started</div>');
  fct_new ();
}
;
