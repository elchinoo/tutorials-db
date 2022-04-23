WITH RECURSIVE cte_rel AS (
    SELECT meta_id,meta_id::VARCHAR AS hierarchy_id, meta_name AS hierarchy_name, meta_name
    FROM meta
    WHERE meta_parent IS NULL
    UNION ALL
    SELECT
        m2.meta_id,c.hierarchy_id ||' -> '||m2.meta_id AS hierarchy_id,c.hierarchy_name ||' -> '||m2.meta_name AS hierarchy_name,
        m2.meta_name
    FROM meta m2 JOIN cte_rel c ON m2.meta_parent=c.meta_id
),
cte_obj AS (
    SELECT meta_id, count(*) tot FROM meta_obj GROUP BY meta_id
)
SELECT c1.meta_id, c1.hierarchy_id, c1.hierarchy_name, c1.meta_name, coalesce(o.tot,0) AS total
FROM cte_rel c1 left 
    OUTER JOIN cte_obj o ON c1.meta_id=o.meta_id
ORDER BY c1.meta_id;