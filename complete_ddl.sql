drop table urilbl_complete_lookup;

create table
urilbl_complete_lookup (
  ull_label_lang varchar,
  ull_label_ruined varchar,
  ull_iid iri_id,
  ull_label varchar,
  primary key (ull_label, ull_label_lang, ull_iid));

create clustered index urilbl_complete_lookup1 
  on urilbl_complete_lookup (ull_label_ruined, ull_label_lang, ull_iid);

