-- Set the default of column analysis_id in new evses as currval
CREATE OR REPLACE FUNCTION take_last4() RETURNS bigint LANGUAGE SQL AS
$$ SELECT last_value FROM analysis_record_analysis_id_seq $$;
-- add last_value function for default definition

ALTER TABLE ONLY new_evses ALTER COLUMN analysis_id SET DEFAULT take_last4();

--currval('analysis_record_analysis_id_seq');