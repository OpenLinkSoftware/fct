create procedure label_get(in smode varchar)
{
  declare label varchar;
  if (smode='1') label := 'Text Search';
  else if (smode='2') label := 'Graphs With Text';
  else if (smode='3') label := 'Types of Things With Text';
  else if (smode='4') label := 'Interests Around';
  --else if (smode='5') label := 'The Most One-Sidedly Known People';
  else if (smode='5') label := 'Top 100 Authors by Text';
  else if (smode='6') label := 'Social Connections a la LinkedIn';
  else if (smode='7') label := 'Connection Between';
  else if (smode='100') label := 'Concept Cloud';
  else if (smode='101') label := 'Social Net';
  else if (smode='102') label := 'Graphs in Social Net';
  else if (smode='103') label := 'Interest Mattches';
  else label := 'No such query';
  return label;
}
;

create procedure validate_input(inout val varchar)
{
  val := trim(val, ' ');
  val := replace(val, '*', '');
  val := replace(val, '>', '');
  val := replace(val, '<', '');
  --val := replace(val, '&', '');
  val := replace(val, '"', '');
  val := replace(val, '''', '');
}
;

create procedure element_split(in val any)
{
  declare srch_split, el varchar;
  declare k integer;
  declare sall any;


  --srch_split := '';
  --k := 0;
  --sall := split_and_decode(val, 0, '\0\0 ');
  --for(k:=0;k<length(sall);k:=k+1)
  --{
  -- el := sall[k];
  -- if (el is not null and length(el) > 0) srch_split := concat (srch_split, ', ', '''',el,'''');
  --};
  --srch_split := trim(srch_split,',');
  --srch_split := trim(srch_split,' ');
  --return srch_split;

  declare words any;
  srch_split := '';
  FTI_MAKE_SEARCH_STRING_INNER (val,words);
  k := 0;
  for(k:=0;k<length(words);k:=k+1)
  {
    el := words[k];
    if (el is not null and length(el) > 0)
      srch_split := concat (srch_split, ', ', '''',el,'''');
  };
  srch_split := trim(srch_split,',');
  srch_split := trim(srch_split,' ');
  return srch_split;
}
;

create procedure words_to_string(in val any)
{
  declare srch_split, el varchar;
  declare k integer;
  declare words any;
  srch_split := '';
  FTI_MAKE_SEARCH_STRING_INNER (val,words);
  k := 0;
  for(k:=0;k<length(words);k:=k+1)
  {
    el := words[k];
    if (el is not null and length(el) > 0)
      srch_split := concat (srch_split, ' ',el);
  };
  srch_split := trim(srch_split,' ');
  return srch_split;
}
;

create procedure pick_query(in smode varchar, inout val any, inout query varchar, inout val2 any := null)
{
  declare s1, s2, s3, s4, s5 varchar;

  s1:='';
  s2:='';
  s3:='';
  s4:='';
  s5:='';

  if (smode='1')
  {
--* Text Search - default is semantic web.
--sparql
--select ?s ?p (bif:search_excerpt (bif:vector ('semantic', 'web'), ?o))
--where
--  {
--    ?s ?p ?o .
--    filter (bif:contains (?o, "'semantic web'"))
--  }
--limit 10
--;

    if (isnull(val) or val = '') val := 'semantic web';
    s1 := 'sparql select ?s ?p (bif:search_excerpt (bif:vector (';
    s3 := '), ?o))  where { ?s ?p ?o . filter (bif:contains (?o, "''';
    s5 := '''")) } limit 10';

    validate_input(val);
    s2 := element_split(val);
    s4 := words_to_string(val);
    query := concat('',s1, s2, s3, s4, s5, '');
  }
  else if (smode='2')
  {
--* Graphs With Text  -- paris and dakar is the sample
--sparql
--select ?g count (*)
--where {
--  graph ?g
--  {
--    ?s ?p ?o .
--    filter (bif:contains (?o, "paris and dakar"))
--  } } group by ?g order by desc 2 limit 50
--;
    if (isnull(val) or val = '') val := 'paris and dakar';
    s1 := 'sparql select ?g count (*) where { graph ?g { ?s ?p ?o . filter (bif:contains (?o, "';
    validate_input(val);
    s2 := FTI_MAKE_SEARCH_STRING(val);
    s3 := '")) } } group by ?g order by desc 2 limit 50';
    query := concat('',s1, s2, s3,'');
  }
  else if (smode='3')
  {
----* Types of Things With Text -- sample is Paris Hiltton
--sparql
--select ?tp count (*)
--where
--  {
--    graph ?g
--      {
--        ?s ?p ?o .
--        ?s a ?tp
--        filter (bif:contains (?o, "'paris hilton'"))
--      }
--  }
--group by ?tp
--order by desc 2;
    if (isnull(val)  or val = '') val := 'Paris Hilton';
    s1 := 'sparql select ?tp count(*) where { graph ?g  { ?s ?p ?o . ?s a ?tp  filter (bif:contains (?o, "''';
    validate_input(val);
    s2 := words_to_string(val);
    s3 := '''") ) } } group by ?tp order by desc 2';
    query := concat('',s1, s2, s3,'');
  }
  else if (smode='4')
  {
--* Interests Around  -- sample is  <http://www.livejournal.com/interests.bml?int=harry+potter>
--sparql
--select ?i2 count (*)
--where
--  {
--    ?p foaf:interest <http://www.livejournal.com/interests.bml?int=harry+potter> .
--    ?p foaf:interest ?i2
--  }
--group by ?i2
--order by desc 2
--limit 20
--;
  if (isnull(val)  or val = '') val := 'http://www.livejournal.com/interests.bml?int=harry+potter';
  s1 := 'sparql select ?i2 count (*) where   { ?p foaf:interest <';
  validate_input(val);
  s2 := val;
  s3 := '> . ?p foaf:interest ?i2  } group by ?i2 order by desc 2 limit 20';
  query := concat('',s1, s2, s3,'');
  }
  else if (smode='5')
  {
-- this query crashes the server:
----* The Most One-Sidedly Known People
--sparql
--select ?celeb, count (*)
--where
--  {
--    ?claimant foaf:knows ?celeb .
--    filter (!bif:exists ((select (1) where { ?celeb foaf:knows ?claimant })))
--  }
--group by ?celeb
--order by desc 2
--limit 10
--;
--

  --s1 := 'sparql select ?celeb, count (*) where { ?claimant foaf:knows ?celeb . filter ( !bif:exists ( ( select (1) where { ?celeb foaf:knows ?claimant } ) ) ) } group by ?celeb order by desc 2 limit 10 ' ;
  --query := concat('',s1, '');

-- the new query is Top 100 Authors by Text: default is semantic and web

--sparql
--select ?auth ?cnt ((select count (distinct ?xx) where { ?xx dc:creator ?auth})) where
--{{ select ?auth count (distinct ?d) as ?cnt
--where
--  {
--    ?d dc:creator ?auth .
--    ?d ?p ?o
--    filter (bif:contains (?o, "semantic and web"))
--  }
--group by ?auth
--order by desc 2 limit 100 }}
--;

    if (isnull(val) or val = '') val := 'semantic and web';
    s1 := 'sparql select ?auth ?cnt ((select count (distinct ?xx) where { ?xx dc:creator ?auth})) where {{ select ?auth count (distinct ?d) as ?cnt where { ?d dc:creator ?auth .  ?d ?p ?o   filter (bif:contains (?o, "' ;
    validate_input(val);
    s2 := FTI_MAKE_SEARCH_STRING(val);
    s3 := '") && isIRI (?auth)) } group by ?auth order by desc 2 limit 100 }} ' ;
    query := concat('',s1, s2, s3, '');


  }
  else if (smode='6')
  {
----* Social Connections a la LinkedIn   sample is http://myopenlink.net/dataspace/person/kidehen#this
--sparql select ?o ?dist ((select count (*) where {?o foaf:knows ?xx}))
--where
--  {
--    {
--      select ?s ?o
--      where
--        {
--          ?s foaf:knows ?o
--        }
--    }
--    option (transitive, t_distinct, t_in(?s), t_out(?o), t_min (1), t_max (4), t_step ('step_no') as ?dist) .
--    filter (?s= <http://myopenlink.net/dataspace/person/kidehen#this>)
--  } order by ?dist desc 3 limit 50;
    if (isnull(val)  or val = '') val := 'http://myopenlink.net/dataspace/person/kidehen#this';
    s1 := 'sparql select ?o ?dist ( ( select count (*) where {?o foaf:knows ?xx } ) ) where  { { select ?s ?o  where { ?s foaf:knows ?o } } option (transitive, t_distinct, t_in(?s), t_out(?o), t_min (1), t_max (4), t_step (''step_no'') as ?dist ) . filter (?s= <';
    validate_input(val);
    s2 := val;
    s3 := '> ) } order by ?dist desc 3 limit 50 ';
    query := concat('',s1, s2, s3,'');
  }
  else if (smode='7')
  {
----* Connection Between  samples are http://myopenlink.net/dataspace/person/kidehen#this and http://www.advogato.org/person/mparaz/foaf.rdf#me
--
--sparql  select ?link ?g ?step ?path
--where
--  {
--    {
--      select ?s ?o ?g
--      where
--        {
--          graph ?g {?s foaf:knows ?o }
--        }
--    }
--    option (transitive, t_distinct, t_in(?s), t_out(?o), t_no_cycles, T_shortest_only,
--       t_step (?s) as ?link, t_step ('path_id') as ?path, t_step ('step_no') as ?step, t_direction 3) .
--    filter (?s= <http://myopenlink.net/dataspace/person/kidehen#this>
--	&& ?o = <http://www.advogato.org/person/mparaz/foaf.rdf#me>)
--  } limit 20;
    if (isnull(val)  or val = '') val := 'http://myopenlink.net/dataspace/person/kidehen#this';
    if (isnull(val2)  or val2 = '') val2 := 'http://www.advogato.org/person/mparaz/foaf.rdf#me';
    s1 := 'sparql select ?link ?g ?step ?path where { { select ?s ?o ?g where { graph ?g {?s foaf:knows ?o } } } option (transitive, t_distinct, t_in(?s), t_out(?o), t_no_cycles, T_shortest_only, t_step (?s) as ?link, t_step (''path_id'') as ?path, t_step (''step_no'') as ?step, t_direction 3) . filter (?s= <';
    validate_input(val);
    s2 := val;
    s3 := '>  && ?o = <';
    validate_input(val2);
    s4 := val2;
    s5 := '>)  } limit 20';
    query := concat('',s1, s2, s3, s4, s5, '');
  }
  --smode > 99 is reserved for drill-down queries
  else if (smode='100')
  {
-- 1  Cloud Around foaf Person, placeholder for http://myopenlink.net/dataspace/person/kidehen#this
--sparql define input:inference 'b3s'
--select count(*)
--where
--  {
--    <http://myopenlink.net/dataspace/person/kidehen#this>  ?p2 ?o2 .
--    ?o2 <http://b3s-demo.openlinksw.com/label> ?lbl .
--  }
--;
    if (isnull(val)  or val = '') val := 'http://myopenlink.net/dataspace/person/kidehen#this';
    s1 := 'sparql define input:inference ''b3s'' select count(*) where { <';
    validate_input(val);
    s2 := val;
    s3 := '>  ?p2 ?o2 . ?o2 <http://b3s-demo.openlinksw.com/label> ?lbl .  }';
    query := concat('',s1, s2, s3, '');
  }
  else if (smode='101')
  {
-- -- 2 Social Connections a la LinkedIn, placeholder is sample is http://myopenlink.net/dataspace/person/kidehen#this
--sparql
--select ?o ?dist ((select count (*) where {?o foaf:knows ?xx}))
--where
--  {
--    {
--      select ?s ?o
--      where
--        {
--          ?s foaf:knows ?o
--        }
--    }
--    option (transitive, t_distinct, t_in(?s), t_out(?o), t_min (1), t_max (4), t_step ('step_no') as ?dist) .
--    filter (?s= <http://myopenlink.net/dataspace/person/kidehen#this>)
--  } order by ?dist desc 3 limit 50
--;
    if (isnull(val)  or val = '') val := 'http://myopenlink.net/dataspace/person/kidehen#this';
    s1 := 'sparql select ?o ?dist ((select count (*) where {?o foaf:knows ?xx})) where { { select ?s ?o where { ?s foaf:knows ?o } } option (transitive, t_distinct, t_in(?s), t_out(?o), t_min (1), t_max (4), t_step (''step_no'') as ?dist) . filter (?s= <';
    validate_input(val);
    s2 := val;
    s3 := '> ) } order by ?dist desc 3 limit 50';
    query := concat('',s1, s2, s3, '');
  }
  else if (smode='102')
  {
---- 3 Connection Between, placeholder is http://myopenlink.net/dataspace/person/kidehen#this and text entry for the other IRI: http://www.advogato.org/person/mparaz/foaf.rdf#me
--sparql
--select ?link ?g ?step ?path
--where
--  {
--    {
--      select ?s ?o ?g
--      where
--        {
--          graph ?g {?s foaf:knows ?o }
--        }
--    }
--    option (transitive, t_distinct, t_in(?s), t_out(?o), t_no_cycles, T_shortest_only,
--       t_step (?s) as ?link, t_step ('path_id') as ?path, t_step ('step_no') as ?step, t_direction 3) .
--    filter (?s= <http://myopenlink.net/dataspace/person/kidehen#this>
--	&& ?o = <http://www.advogato.org/person/mparaz/foaf.rdf#me>)
--  } limit 20
--;

    if (isnull(val)  or val = '') val := 'http://myopenlink.net/dataspace/person/kidehen#this';
    if (isnull(val2)  or val2 = '') val2 := 'http://www.advogato.org/person/mparaz/foaf.rdf#me';
    s1 := 'sparql select ?link ?g ?step ?path where  { { select ?s ?o ?g where { graph ?g {?s foaf:knows ?o } } } option (transitive, t_distinct, t_in(?s), t_out(?o), t_no_cycles, T_shortest_only, t_step (?s) as ?link, t_step (''path_id'') as ?path, t_step (''step_no'') as ?step, t_direction 3) . filter (?s= <';
    validate_input(val);
    s2 := val;
    s3 := '> && ?o = <';
    validate_input(val2);
    s4 := val2;
    s5 := '> )  } limit 20';
    query := concat('',s1, s2, s3, s4, s5, '');
  }
  else if (smode='103')
  {
---- 4 placehoder is : http://myopenlink.net/dataspace/person/kidehen#this
--sparql
--select distinct ?n ((select count (*) where {?p foaf:interest ?i . ?ps foaf:interest ?i}))
--   ((select count (*) where { ?p foaf:interest ?i}))
--where {
--{select distinct ?p ?psi where {?p foaf:interest ?i . ?psi foaf:interest ?i }} .
--  filter (?psi = <http://myopenlink.net/dataspace/person/kidehen#this> && ?ps = <http://myopenlink.net/dataspace/person/kidehen#this> )
--  ?p foaf:nick ?n
--} order by desc 2 limit 50
--;
    if (isnull(val)  or val = '') val := 'http://myopenlink.net/dataspace/person/kidehen#this';
    s1 := 'sparql select distinct ?n ((select count (*) where {?p foaf:interest ?i . ?ps foaf:interest ?i})) ((select count (*) where { ?p foaf:interest ?i})) where { {select distinct ?p ?psi where {?p foaf:interest ?i . ?psi foaf:interest ?i }} . filter (?psi = <';
    validate_input(val);
    s2 := val;
    s3 := '> && ?ps = <';
    s4 := val;
    s5 := '> ) ?p foaf:nick ?n } order by desc 2 limit 50';
    query := concat('',s1, s2, s3, s4, s5, '');
  }
  else
  {
    query := '';
  };
}
;
