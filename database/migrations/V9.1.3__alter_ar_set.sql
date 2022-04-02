CREATE OR REPLACE FUNCTION take_last3() RETURNS bigint LANGUAGE SQL AS
$$ SELECT last_value FROM analysis_sets_set_id_seq $$;
-- add last_value function for default definition

ALTER TABLE ONLY analysis_record ALTER COLUMN set_id SET DEFAULT take_last3();


--currval('analysis_sets_set_id_seq');

-- CREATE TABLE analysis_sets_record_xref (
--     set_id integer NOT NULL, 
--     analysis_id integer NOT NULL, 
--     CONSTRAINT fk_set
--       FOREIGN KEY(set_id) 
-- 	  REFERENCES analysis_sets(set_id), 
--     CONSTRAINT fk_record
--       FOREIGN KEY(analysis_id) 
-- 	  REFERENCES analysis_record(analysis_id)
-- );