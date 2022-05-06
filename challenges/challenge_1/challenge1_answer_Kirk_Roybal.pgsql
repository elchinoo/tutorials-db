\set QUIET 1
-- created this index to discover if the data in meta_obj.obj_data had anything to do with num_data
--  spoiler alert:  it doesn't
-- CREATE INDEX IF NOT EXISTS yada_yada ON meta_obj USING GIN (obj_data jsonb_path_ops);
--  Here's the real sauce (i think)
CREATE INDEX IF NOT EXISTS idx_fk_meta_id ON meta_obj (meta_id);

-- SET statement_timeout TO '2s';
-- EXPLAIN VERBOSE
WITH RECURSIVE a AS (
    SELECT m.meta_id, m.meta_id::text hierarchy_id, m.meta_name::text hierarchy_name,
            m.meta_name, 0::bigint num_data, m.meta_id::text ass_backwards
    FROM meta m
    WHERE m.meta_id IN (1,2,3)  --<-- I'm too lazy to do the anti join here.
    UNION ALL
    SELECT m1.meta_id,                               -- index
        a.ass_backwards || ' -> ' || m1.meta_id,     -- id flipped in front
        a.hierarchy_name || ' -> ' || m1.meta_name,  -- etymology
        m1.meta_name,                                -- reference
        -- not sure which of these two answers is rational given the problem
        --  the first one fits the pathology a bit better
        (SELECT count(o.meta_id)::bigint FROM meta_obj o WHERE o.meta_id = m1.meta_id)::bigint,
        -- a.num_data + (SELECT count(o.meta_id)::bigint FROM meta_obj o WHERE o.meta_id = m1.meta_id)::bigint,
        m1.meta_id || ' -> ' || a.hierarchy_id       -- cadence
    FROM meta m1
    INNER JOIN a
    ON (m1.meta_parent = a.meta_id)
)
SELECT meta_id, hierarchy_id, hierarchy_name, meta_name, num_data FROM a;
