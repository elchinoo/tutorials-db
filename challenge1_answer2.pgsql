\set QUIET 1
--  Challenge 2: Don't use this index and get < 2s anyway
-- CREATE INDEX IF NOT EXISTS idx_fk_meta_id ON meta_obj (meta_id);
CREATE MATERIALIZED VIEW IF NOT EXISTS cheat_like_hell AS (
    SELECT m.meta_id, count(o.meta_id) how_many
    FROM meta m
    LEFT JOIN meta_obj o
    ON (m.meta_id = o.meta_id)
    GROUP BY 1
    ORDER BY 1
    );

REFRESH MATERIALIZED VIEW cheat_like_hell;

SET statement_timeout TO '15s';
-- EXPLAIN VERBOSE
WITH RECURSIVE a AS (
    SELECT m.meta_id, m.meta_id::text hierarchy_id, m.meta_name::text hierarchy_name,
            m.meta_name,
            0::bigint num_data,
            m.meta_id::text ass_backwards
    FROM meta m
    WHERE m.meta_parent IS NULL
    UNION ALL
    SELECT m1.meta_id,                               -- index
        a.ass_backwards || ' -> ' || m1.meta_id,     -- id flipped in front
        a.hierarchy_name || ' -> ' || m1.meta_name,  -- etymology
        m1.meta_name,                                -- reference
        --  fix this line, since it's 95% of the problem...
        -- (SELECT count(o.meta_id)::bigint FROM meta_obj o WHERE o.meta_id = m1.meta_id)::bigint,
        c.how_many num_data,
        m1.meta_id || ' -> ' || a.hierarchy_id       -- cadence
    FROM meta m1
    INNER JOIN a
    ON (m1.meta_parent = a.meta_id)
    INNER JOIN cheat_like_hell c
    ON (m1.meta_id = c.meta_id)
)
SELECT  a.meta_id,
        a.hierarchy_id,
        a.hierarchy_name,
        a.meta_name,
        a.num_data
    FROM a;
