

- Which graphs have text pattern x?

sparql 
select count (*) 
where 
  { 
    ?s ?p ?o . 
    filter (bif:contains (?o, "paris")) 
  }
; 

sparql 
select distinct ?g 
where 
  graph (?g) 
  { 
    ?s ?p ?o . 
    filter (bif:contains (?o, "paris and moonlight")) 
  }
;

-- what kinds of things have conspiracy?

sparql 
select ?tp count (*) 
where 
  {
    graph ?g 
      { 
        ?s ?p ?o . 
        ?s a ?tp 
        filter (bif:contains (?o, "conspiracy")) 
      }
  } 
group by ?tp
order by desc 2;

-- most popular interests

sparql
select * 
where 
  {
    {
      select ?o count (*) as cnt 
      where 
        {
          ?s foaf:interest ?o
        } 
      group by ?o
    } 
    filter (?cnt > 100) 
  } 
order by 2 desc;

-- interests of harry potter fans 
sparql 
select ?i2 count (*) 
where 
  { 
    ?p foaf:interest <http://www.livejournal.com/interests.bml?int=harry+potter> .
    ?p foaf:interest ?i2 
  } 
group by ?i2 
order by desc 2 
limit 20;



-- common distinctive interests 

sparql  
select ?i ?cnt ?n1 ?n2 ?p1 ?p2 
  where 
    {
      {
        select ?i count (*) as ?cnt 
          where 
            { 
              ?p foaf:interest ?i 
            } 
          group by ?i
      }
      filter ( ?cnt > 1 && ?cnt < 10) .
      ?p1 foaf:interest ?i .
      ?p2 foaf:interest ?i .
      filter  (?p1 != ?p2 && 
               !bif:exists ((select (1) where {?p1 foaf:knows ?p2 })) && 
               !bif:exists ((select (1) where {?p2 foaf:knows ?p1 }))) .
      ?p1 foaf:nick ?n1 .
      ?p2 foaf:nick ?n2 .
    } 
  order by ?cnt 
  limit 10;

-- cliques 

sparql 
select ?i ?cnt ?n1 ?n2 ?p1 ?p2 
  where 
    {
      {
        select ?i count (*) as ?cnt 
        where 
          { 
            ?p foaf:interest ?i
          } 
        group by ?i
      }
      filter ( ?cnt > 1 && ?cnt < 10) .
      ?p1 foaf:interest ?i .
      ?p2 foaf:interest ?i .
      filter  (?p1 != ?p2 && 
               (bif:exists ((select (1) where {?p1 foaf:knows ?p2 })) || 
                bif:exists ((select (1) where {?p2 foaf:knows ?p1 })))) .
      ?p1 foaf:nick ?n1 .
      ?p2 foaf:nick ?n2 .
    } 
order by ?cnt 
limit 10
;



-- Most asymetrically known

sparql 
select count (*) 
  where 
    { 
      ?p1 foaf:knows ?p2 
    }
;


sparql 
select count (*) 
  where 
    { 
      ?p1 foaf:knows ?p2 . 
      ?p2 foaf:knows ?p1 
    };

-- celeb with value subquery 

sparql 
select ?celeb 
  (select count (*)  
   where 
     { 
       ?xx foaf:knows ?celeb . 
       filter (!bif:exists ((select (1) where { ?celeb foaf:knows ?xx1 })) ) 
     })
where 
  {
    { 
      select distinct ?celeb 
      where 
        { 
          ?xx foaf:knows ?celeb
        } 
    }
  } 
limit 10
;

-- celeb with group by

sparql 
select ?celeb, count (*) 
where 
  { 
    ?claimant foaf:knows ?celeb . 
    filter (!bif:exists ((select (1) where { ?celeb foaf:knows ?claimant }))) 
  } 
group by ?celeb 
order by desc 2 
limit 10
;

sparql 
select count (*) 
where 
  { 
    ?claimant foaf:knows ?celeb . 
    filter (!bif:exists ((select (1) where {?celeb foaf:knows ?claimant }))) 
  }
;

-- Interest profile matches of plaid_skirt who are male and want sex


-- how many interests do people have?
sparql 
select avg ((select count (*) { ?p foaf:interest ?i })) 
where 
  {
    { 
      select distinct ?p 
      where 
        { 
          ?p foaf:interest ?i2 
        }
    }
  }
;

-- does openid connect between graphs?

sparql 
select count (*) 
where 
  { 
    graph ?g1 
      { 
        ?p1 foaf:openid  ?id 
      } . 
    graph ?g2 
      { 
        ?p2 foaf:openid ?id 
      } .
    filter (?g1 != ?g2) 
  }
;

-- most mentioned openids 

sparql select ?id count (distinct ?g) 
where 
  { 
    graph ?g 
      { 
        ?xx foaf:openid ?id
      }
  } 
group by ?id
order by desc 2
limit 100;

-- what kind of stuff is around Gutman?

sparql
select ?tp count (*) 
where 
  {
    ?s ?p ?o .
    filter (bif:contains (?o, "gutman")) .
	?s ?p2 ?rel . 
	?rel a ?tp
  }
;

sparql 
select ?tp ?lbl ?s 
where 
  {
    ?s ?p ?o .
    filter (bif:contains (?o, "gutman")) .
	?s a ?tp 
	optional 
	  {
	    ?s rdfs:label ?lbl 
	  } 
  } 
order by ?tp
;

-- type of parties  that claim to know each other 

sparql 
select distinct ?st ?ot 
where 
  { 
    ?s foaf:knows ?o .
    ?s a ?st .
    ?o a ?ot
  }
;


-- tag cloud of bombing 
-- who starts threads about bombing 


-- sameAs for identical email sha 

insert into rdf_quad (g, s, p, o) 
  select iri_to_id ('b3si'), first.s, rdf_sas_iri (), rest.s from 
     (select distinct o from rdf_quad where p = iri_to_id ('http://xmlns.com/foaf/0.1/mbox_sha1sum') ) sha,
       (select top 1 s, o from rdf_quad where p = iri_to_id ('http://xmlns.com/foaf/0.1/mbox_sha1sum')) first,
       rdf_quad rest 
where   first.o = sha.o 
and rest.o = sha.o
and rest.p = iri_to_id ('http://xmlns.com/foaf/0.1/mbox_sha1sum') 
and first.s <> rest.s;


-- related tag analysis 

create table tag_count (tcn_tag iri_id_8, tcn_count int, primary key (tcn_tag))
alter index tag_count on tag_count partition (tcn_tag int (0hexffff00));

create table tag_coincidence (tc_t1 iri_id_8, tc_t2 iri_id_8, tc_count  int, tc_t1_count int, tc_t2_count int, primary key  (tc_t1, tc_t2))
alter index tag_coincidence on tag_coincidence partition (tc_t1 int (0hexffff00));


insert into tag_count select * from (sparql define output:valmode "LONG" select ?t count (*) as ?cnt where {?s sioc:topic ?t} group by ?t) xx option (quietcast);


update tag_coincidence set tc_t1_count = (select tcn_count from tag_count where tcn_tag = tc_t1),
       tc_t2_count = (select tcn_count from tag_count where tcn_tag = tc_t2);

insert into tag_coincidence  (tc_t1, tc_t2, tc_count)
select "t1", "t2", cnt from 
(select  "t1", "t2", count (*) as cnt from 
(sparql define output:valmode "LONG"
select ?t1 ?t2 where {?s sioc:topic ?t1 . ?s sioc:topic ?t2 } ) tags
where  "t1" < "t2" group by "t1", "t2") xx
where isiri_id ("t1") and isiri_id ("t2") option (quietcast); 



 group by ?t1 ?t2);

insert into rdf_quad (g, s, p, o) 
  select iri_to_id ('tag_summary'), tc_t1, iri_to_id ('related_tag'), tc_t2
  from tag_coincidence 
  where tc_count > )


-- what is the link between person 1 and person 2?
-- what is the latest mention of x and y?
-- On what sources does the link between x and y depend?

-- Who is my nearest match of xx?

-- what properties are available for discerning identity of blanks in knows relation?

sparql 
select ?s ?n 
where 
  { 
    ?s foaf:knows ?x .
    ?s foaf:name ?n 
  } 
limit 10
;

-- what graph contains the most knows relations?

sparql 
select count (*) ?g 
where 
  {
    graph ?g 
      {
        ?s foaf:knows ?o
      }
  } 
group by ?g
order by desc 1
limit 10
;

-- What properties do posts have?

sparql 
select ?p count (*) 
where 
  {
    ?s a sioc:Post . 
    ?s ?p ?o
  } 
group by ?p 
order by desc 2
limit 40
;

-- tag cloud of computer 

sparql 
select ?lbl count (*) 
where 
  {  
    ?s ?p ?o . 
    filter (bif:contains (?o, "computer")) .
    ?s sioc:topic ?tg .
    optional 
      {
        ?tg rdfs:label ?lbl
      }
  }  
group by ?lbl
order by desc 2
limit 40
;


sparql 
select count (*) 
where 
  { 
    ?claimant foaf:knows ?celeb .
    filter (!bif:exists ((select (1) where {?celeb foaf:knows ?claimant }))) 
  }
;

-- does something refer to geography outside geonames?

sparql select count (*) 
where 
  { 
    graph <http://sws.geonames.org> 
      { 
        ?f a geo:Feature 
      } . 
    graph ?g 
      {
        ?s ?p ?f 
      } .
    filter (?g != <http://sws.geonames.org>) 
  }
;

sparql select ?g count (*) 
where 
  { 
    graph <http://sws.geonames.org> 
      { 
        ?f a geo:Feature 
      } . 
    graph ?g 
      {
        ?s ?p ?f 
      } 
  } 
group by ?g 
order by desc 2 
limit 40
;

-- what properties do documents have?
sparql 
select ?p count (*) 
where 
  {
    ?s a foaf:Document . 
    ?s ?p ?o
  } 
group by ?p 
order by desc 2;

-- what properties do persons have?

sparql 
select ?p count (*) 
  where 
    {
      ?s a foaf:Person . 
      ?s ?p ?o
    } 
group by ?p 
order by desc 2 
limit 50
;

-- authors on folksonomy 

sparql 
select ?auth count (*) 
where 
  { 
    ?d dc:creator ?auth . 
    ?d ?p ?o 
    filter (bif:contains (?o, "folksonomy")) 
  } 
group by ?auth 
order by desc 2
;


-- who talks most about sex?


sparql 
select ?auth count (*) 
where 
  { 
    ?d dc:creator ?auth .
    ?d ?p ?o 
    filter (bif:contains (?o, "sex")) 
  } 
group by ?auth 
order by desc 2
;

-- Who talks only about sex?

--- traditional text search 

sparql 
select ?s ?p (bif:search_excerpt (bif:vector ('semantic', 'web'), ?o))  
where 
  {
    ?s ?p ?o .
    filter (bif:contains (?o, "'semantic web'")) 
  } 
limit 10
;

-- graph vicinity of text hits 

-- what types of things surround foaf plaid_skirt?

sparql 
select ?tp count(*) 
where 
  { 
    ?s ?p2 ?o2 . 
    ?o2 a ?tp . 
    ?s foaf:nick ?o . 
    filter (bif:contains (?o, "plaid_skirt")) 
  } 
group by ?tp 
order by desc 2 
limit 40;

-- what are they called?

sparql 
select ?lbl count(*) 
where 
  { 
    ?s ?p2 ?o2 . 
    ?o2 rdfs:label ?lbl . 
    ?s foaf:nick ?o . 
    filter (bif:contains (?o, "plaid_skirt")) 
  } 
group by ?lbl 
order by desc 2
;

-- more generally called?

sparql define input:inference 'b3s'
select ?lbl count(*) 
where 
  { 
    ?s  ?p2 ?o2 . 
    ?o2 <http://b3s-demo.openlinksw.com/label> ?lbl . 
    ?s  foaf:nick ?o . 
    filter (bif:contains (?o, "plaid_skirt")) 
  } 
group by ?lbl 
order by desc 2
;

sparql 
select ?lbl count(*) 
where 
  { 
    ?s ?p2 ?o2 . 
    ?o2 b3s:label ?lbl . 
    ?s foaf:nick ?o . 
    filter ( bif:contains (?o, "plaid_skirt")) 
  } 
group by ?lbl 
order by desc 2;


-- who knows about terrorist bombings?
sparql 
select ?g count(*) 
where 
  { 
    graph ?g 
      {
        ?s ?p ?o . 
        filter (bif:contains (?o, "'terrorist bombing'")) 
      }
  } 
group by ?g 
order by desc 2;

-- extended friends of plaid skirt 

sparql 
select ?xx 
where 
  { 
    ?skirt rdfs:label ?lbl . 
    filter (bif:contains (?lbl, "plaid_skirt")) .
    ?skirt foaf:knows ?xx
  }
;


sparql 
select count (*) ?place ?lat ?long ?lbl 
where 
  {
    ?s foaf:based_near ?place .
    ?place pos:lat ?lat .
    ?place pos:long ?long . 
    ?place rdfs:label ?lbl 
  } 
group by ?place ?long ?lat ?lbl 
order by desc 2 
limit 50
;

-- Stefan Decker 
sparql
select ?lbl ?p ?o ?sd  
where 
  { 
    ?sd a foaf:Person .
    ?sd ?namep ?ns .
    filter (bif:contains (?ns, "stefan and decker")) ?sd ?p ?o . 
    optional 
      {
        ?o rdfs:label ?lbl
      }
  } 
limit 50
;

-- Social Stefan Decker 

sparql select ?sd count (distinct ?xx) 
where 
  { 
    ?sd a foaf:Person . 
    ?sd ?name ?ns . 
    filter (bif:contains (?ns, "'Stefan Decker'")) . 
    ?sd foaf:knows ?xx
  } 
group by ?sd
order by desc 2;

-- connections of Kingsley Idehen 

sparql select count (*) 
where 
  { 
    {
      select ?s ?o  
      where 
        { 
          ?s foaf:knows ?o 
        }
    }
    option (transitive, t_distinct, t_in(?s), t_out(?o), t_min (1)) . 
    filter (?s= <http://myopenlink.net/dataspace/person/kidehen#this>)
  };

-- Connections of Kingsley Idehen with same as aliases 
sparql define input:same-as "YES" select count (*) 
where 
  { 
    {
      select ?s ?o  
      where 
        { 
          ?s foaf:knows ?o 
        }
    }
    option (transitive, t_distinct, t_in(?s), t_out(?o), t_min (1)) . 
    filter (?s= <http://myopenlink.net/dataspace/person/kidehen#this>)
  };



-- Closest connections of Kingsley Idehen 
sparql select ?o ?dist 
where 
  { 
    {
      select ?s ?o  
      where 
        { 
          ?s foaf:knows ?o 
        }
    }
    option (transitive, t_distinct, t_in(?s), t_out(?o), t_min (1), t_step ('step_no') as ?dist) . 
    filter (?s= <http://myopenlink.net/dataspace/person/kidehen#this>)
  } limit 50;


-- LinkedIn style 
sparql select ?o ?dist ((select count (*) where {?o foaf:knows ?xx}))
where 
  { 
    {
      select ?s ?o  
      where 
        { 
          ?s foaf:knows ?o 
        }
    }
    option (transitive, t_distinct, t_in(?s), t_out(?o), t_min (1), t_max (4), t_step ('step_no') as ?dist) . 
    filter (?s= <http://myopenlink.net/dataspace/person/kidehen#this>)
  } order by ?dist desc 3 limit 50;


-- What graphs are the principal constituents of Kingsley's network, counting all sameAs aliases?
sparql define input:same-as "YES" select ?g count (*) 
where 
  { 
    {
      select ?s ?o ?g 
      where 
        { 
          graph ?g {?s foaf:knows ?o }
        }
    }
    option (transitive, t_distinct, t_in(?s), t_out(?o), t_min (1)) . 
    filter (?s= <http://myopenlink.net/dataspace/person/kidehen#this>)
  } group by ?g order by desc 2 limit 100;



-- What connects?
sparql  select ?link ?g ?step ?path 
where 
  { 
    {
      select ?s ?o ?g 
      where 
        { 
          graph ?g {?s foaf:knows ?o }
        }
    }
    option (transitive, t_in(?s), t_out(?o), t_no_cycles, T_shortest_only, t_step (?s) as ?link, t_step ('path_id') as ?path, t_step ('step_no') as ?step, t_direction 3) . 
    filter (?s= <http://myopenlink.net/dataspace/person/kidehen#this>
	&& ?o = <http://www.advogato.org/person/mparaz/foaf.rdf#me>)
  } limit 20;





-- what is being claimed about the location of something called San Francisco?

sparql 
select distinct ?sfo ?lat ?long 
where 
  { 
    ?sfo ?sname ?name .
    filter (bif:contains (?name, "'san francisco'")) .
    ?sfo pos:lat ?lat .
    ?sfo pos:long ?long
  }
;


-- types of things which have same as assertions 

sparql select ?tp count (*) 
where 
  {
    ?s owl:sameAs ?o .
    ?s a ?tp  
  } 
group by ?tp
order by desc 2 
limit 100;

