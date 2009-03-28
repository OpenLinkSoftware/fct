drop table urilbl_complete_lookup;

create table
urilbl_complete_lookup (
  ull_label_lang varchar,
  ull_label_ruined varchar,
  ull_iid iri_id_8,
  ull_label varchar,
  primary key (ull_label, ull_label_lang, ull_iid));

create clustered index urilbl_complete_lookup1 
  on urilbl_complete_lookup (ull_label_ruined, ull_label_lang, ull_iid);

create table 
urilbl_cpl_log (
  ullog_ts timestamp,
  ullog_msg varchar,
  primary key (ullog_ts, ullog_msg));

