-- Set the default value of column analysis_id in evses_now as currval
CREATE OR REPLACE FUNCTION take_last13() RETURNS bigint LANGUAGE SQL AS
$$ SELECT last_value FROM analysis_record_analysis_id_seq $$;
-- add last_value function for default definition

ALTER TABLE ONLY evses_now ALTER COLUMN analysis_id SET DEFAULT take_last13();

--currval('analysis_record_analysis_id_seq');