-- Set the default of column analysis_id in analysis_params as currval
CREATE OR REPLACE FUNCTION take_last1() RETURNS bigint LANGUAGE SQL AS
$$ SELECT last_value FROM analysis_sets_set_id_seq; $$;
-- add last_value function for default definition

ALTER TABLE ONLY analysis_params ALTER COLUMN analysis_id SET DEFAULT take_last1();
--currval('analysis_record_analysis_id_seq');