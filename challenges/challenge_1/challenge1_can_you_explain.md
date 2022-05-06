# Can you explain?

Can you explain me why the first query here runs in avg of 760ms but the second one takes less than 180ms to run in avg?

## Query 1 and its EXPLAIN plan:

```SQL
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
WITH RECURSIVE meta_hierarchy AS (
    SELECT meta_id, 
        1::INT AS depth, 
        meta_id::TEXT AS hierarchy_id, 
        meta_name AS hierarchy_name,
        meta_parent, meta_name 
    FROM meta WHERE meta_parent IS NULL

    UNION ALL

    SELECT m.meta_id, 
        ms.depth + 1 AS depth,
        ms.hierarchy_id   ||' -> '|| m.meta_id AS hierarchy_id,
        ms.hierarchy_name ||' -> '|| m.meta_name AS hierarchy_name,
        m.meta_parent, m.meta_name 
    FROM meta m 
        JOIN meta_hierarchy ms ON ms.meta_id = m.meta_parent
) 
    SELECT mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name, count(mo.obj_id) AS total 
    FROM meta_hierarchy mh
        LEFT JOIN meta_obj mo ON mo.meta_id = mh.meta_id
    GROUP BY mh.meta_id, mh.depth, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name
    ORDER BY mh.depth, mh.meta_id;


                                                                                                     QUERY PLAN                                                                     
                                 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------
 Sort  (cost=603699.86..603700.76 rows=361 width=112) (actual time=4749.613..4749.648 rows=20 loops=1)
   Output: mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name, (count(mo.obj_id)), mh.depth
   Sort Key: mh.depth, mh.meta_id
   Sort Method: quicksort  Memory: 27kB
   Buffers: shared hit=174804
   CTE meta_hierarchy
     ->  Recursive Union  (cost=0.00..477.65 rows=3606 width=108) (actual time=0.012..0.287 rows=20 loops=1)
           Buffers: shared hit=4
           ->  Seq Scan on public.meta  (cost=0.00..22.03 rows=6 width=108) (actual time=0.010..0.015 rows=3 loops=1)
                 Output: meta.meta_id, 1, (meta.meta_id)::text, meta.meta_name, meta.meta_parent, meta.meta_name
                 Filter: (meta.meta_parent IS NULL)
                 Rows Removed by Filter: 17
                 Buffers: shared hit=1
           ->  Subquery Scan on "*SELECT* 2"  (cost=1.95..41.95 rows=360 width=108) (actual time=0.046..0.076 rows=6 loops=3)
                 Output: "*SELECT* 2".meta_id, "*SELECT* 2".depth, "*SELECT* 2".hierarchy_id, "*SELECT* 2".hierarchy_name, "*SELECT* 2".meta_parent, "*SELECT* 2".meta_name
                 Buffers: shared hit=3
                 ->  Hash Join  (cost=1.95..38.35 rows=360 width=108) (actual time=0.043..0.065 rows=6 loops=3)
                       Output: m.meta_id, (ms.depth + 1), ((ms.hierarchy_id || ' -> '::text) || (m.meta_id)::text), (((ms.hierarchy_name)::text || ' -> '::text) || (m.meta_name)::t
ext), m.meta_parent, m.meta_name
                       Hash Cond: (m.meta_parent = ms.meta_id)
                       Buffers: shared hit=3
                       ->  Seq Scan on public.meta m  (cost=0.00..22.00 rows=1200 width=40) (actual time=0.002..0.016 rows=20 loops=3)
                             Output: m.meta_id, m.meta_parent, m.meta_name
                             Buffers: shared hit=3
                       ->  Hash  (cost=1.20..1.20 rows=60 width=72) (actual time=0.018..0.019 rows=7 loops=3)
                             Output: ms.depth, ms.hierarchy_id, ms.hierarchy_name, ms.meta_id
                             Buckets: 1024  Batches: 1  Memory Usage: 9kB
                             ->  WorkTable Scan on meta_hierarchy ms  (cost=0.00..1.20 rows=60 width=72) (actual time=0.002..0.007 rows=7 loops=3)
                                   Output: ms.depth, ms.hierarchy_id, ms.hierarchy_name, ms.meta_id
   ->  HashAggregate  (cost=603203.27..603206.88 rows=361 width=112) (actual time=4749.561..4749.587 rows=20 loops=1)
         Output: mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name, count(mo.obj_id), mh.depth
         Group Key: mh.depth, mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name
         Batches: 1  Memory Usage: 45kB
         Buffers: shared hit=174804
         ->  Merge Right Join  (cost=285.59..332753.27 rows=18030000 width=108) (actual time=0.375..3746.863 rows=1000003 loops=1)
               Output: mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name, mh.depth, mo.obj_id
               Merge Cond: (mo.meta_id = mh.meta_id)
               Buffers: shared hit=174804
               ->  Index Scan using idx_fk_meta_id on public.meta_obj mo  (cost=0.42..59518.10 rows=1000000 width=8) (actual time=0.027..969.319 rows=1000000 loops=1)
                     Output: mo.obj_id, mo.meta_id, mo.obj_name, mo.obj_json
                     Buffers: shared hit=174800
               ->  Sort  (cost=285.17..294.18 rows=3606 width=104) (actual time=0.342..679.113 rows=968696 loops=1)
                     Output: mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name, mh.depth
                     Sort Key: mh.meta_id
                     Sort Method: quicksort  Memory: 27kB
                     Buffers: shared hit=4
                     ->  CTE Scan on meta_hierarchy mh  (cost=0.00..72.12 rows=3606 width=104) (actual time=0.016..0.313 rows=20 loops=1)
                           Output: mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name, mh.depth
                           Buffers: shared hit=4
 Planning Time: 0.327 ms
 Execution Time: 4749.768 ms
(50 rows)

```


## Query 2 and its EXPLAIN plan:

```SQL
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
WITH RECURSIVE cte_rel AS (
    SELECT meta_id, 
        1::INT AS depth, 
        meta_id::VARCHAR AS hierarchy_id, 
        meta_name AS hierarchy_name, 
        meta_name
    FROM meta
    WHERE meta_parent IS NULL

    UNION ALL

    SELECT m2.meta_id,
        c.depth + 1 AS depth,
        c.hierarchy_id ||' -> '||m2.meta_id AS hierarchy_id,
        c.hierarchy_name ||' -> '||m2.meta_name AS hierarchy_name,
        m2.meta_name
    FROM meta m2 
        JOIN cte_rel c ON m2.meta_parent=c.meta_id
),
cte_obj AS (
    SELECT meta_id, count(*) tot FROM meta_obj GROUP BY meta_id
)
SELECT c1.meta_id, c1.hierarchy_id, c1.hierarchy_name, c1.meta_name, coalesce(o.tot,0) AS total
FROM cte_rel c1 left 
    OUTER JOIN cte_obj o ON c1.meta_id=o.meta_id
ORDER BY c1.depth, c1.meta_id;

                                                                                                  QUERY PLAN                                                                        
                           
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------
 Sort  (cost=16473.73..16482.74 rows=3606 width=112) (actual time=1389.616..1391.415 rows=20 loops=1)
   Output: c1.meta_id, c1.hierarchy_id, c1.hierarchy_name, c1.meta_name, (COALESCE((count(*)), '0'::bigint)), c1.depth
   Sort Key: c1.depth, c1.meta_id
   Sort Method: quicksort  Memory: 27kB
   Buffers: shared hit=851 read=1
   CTE cte_rel
     ->  Recursive Union  (cost=0.00..477.65 rows=3606 width=104) (actual time=0.013..0.266 rows=20 loops=1)
           Buffers: shared hit=4
           ->  Seq Scan on public.meta  (cost=0.00..22.03 rows=6 width=104) (actual time=0.010..0.015 rows=3 loops=1)
                 Output: meta.meta_id, 1, (meta.meta_id)::character varying, meta.meta_name, meta.meta_name
                 Filter: (meta.meta_parent IS NULL)
                 Rows Removed by Filter: 17
                 Buffers: shared hit=1
           ->  Subquery Scan on "*SELECT* 2"  (cost=1.95..41.95 rows=360 width=104) (actual time=0.041..0.071 rows=6 loops=3)
                 Output: "*SELECT* 2".meta_id, "*SELECT* 2".depth, "*SELECT* 2".hierarchy_id, "*SELECT* 2".hierarchy_name, "*SELECT* 2".meta_name
                 Buffers: shared hit=3
                 ->  Hash Join  (cost=1.95..38.35 rows=360 width=104) (actual time=0.039..0.060 rows=6 loops=3)
                       Output: m2.meta_id, (c.depth + 1), (((c.hierarchy_id)::text || ' -> '::text) || (m2.meta_id)::text), (((c.hierarchy_name)::text || ' -> '::text) || (m2.meta_
name)::text), m2.meta_name
                       Hash Cond: (m2.meta_parent = c.meta_id)
                       Buffers: shared hit=3
                       ->  Seq Scan on public.meta m2  (cost=0.00..22.00 rows=1200 width=40) (actual time=0.002..0.015 rows=20 loops=3)
                             Output: m2.meta_id, m2.meta_parent, m2.meta_name
                             Buffers: shared hit=3
                       ->  Hash  (cost=1.20..1.20 rows=60 width=72) (actual time=0.017..0.018 rows=7 loops=3)
                             Output: c.depth, c.hierarchy_id, c.hierarchy_name, c.meta_id
                             Buckets: 1024  Batches: 1  Memory Usage: 9kB
                             ->  WorkTable Scan on cte_rel c  (cost=0.00..1.20 rows=60 width=72) (actual time=0.001..0.006 rows=7 loops=3)
                                   Output: c.depth, c.hierarchy_id, c.hierarchy_name, c.meta_id
   ->  Hash Right Join  (cost=1117.64..15783.03 rows=3606 width=112) (actual time=142.141..1391.326 rows=20 loops=1)
         Output: c1.meta_id, c1.hierarchy_id, c1.hierarchy_name, c1.meta_name, COALESCE((count(*)), '0'::bigint), c1.depth
         Hash Cond: (meta_obj.meta_id = c1.meta_id)
         Buffers: shared hit=851 read=1
         ->  Finalize GroupAggregate  (cost=1000.45..15654.88 rows=17 width=12) (actual time=141.802..1390.898 rows=17 loops=1)
               Output: meta_obj.meta_id, count(*)
               Group Key: meta_obj.meta_id
               Buffers: shared hit=847 read=1
               ->  Gather Merge  (cost=1000.45..15654.54 rows=34 width=12) (actual time=53.815..1390.783 rows=51 loops=1)
                     Output: meta_obj.meta_id, (PARTIAL count(*))
                     Workers Planned: 2
                     Workers Launched: 2
                     Buffers: shared hit=847 read=1
                     ->  Partial GroupAggregate  (cost=0.42..14650.60 rows=17 width=12) (actual time=42.985..1076.228 rows=17 loops=3)
                           Output: meta_obj.meta_id, PARTIAL count(*)
                           Group Key: meta_obj.meta_id
                           Buffers: shared hit=847 read=1
                           Worker 0:  actual time=42.628..1342.372 rows=17 loops=1
                             Buffers: shared hit=361
                           Worker 1:  actual time=35.944..1342.466 rows=17 loops=1
                             Buffers: shared hit=363
                           ->  Parallel Index Only Scan using idx_fk_meta_id on public.meta_obj  (cost=0.42..12567.09 rows=416667 width=4) (actual time=0.032..515.889 rows=333333 l
oops=3)
                                 Output: meta_obj.meta_id
                                 Heap Fetches: 0
                                 Buffers: shared hit=847 read=1
                                 Worker 0:  actual time=0.027..657.609 rows=427342 loops=1
                                   Buffers: shared hit=361
                                 Worker 1:  actual time=0.028..620.657 rows=429172 loops=1
                                   Buffers: shared hit=363
         ->  Hash  (cost=72.12..72.12 rows=3606 width=104) (actual time=0.316..0.319 rows=20 loops=1)
               Output: c1.meta_id, c1.hierarchy_id, c1.hierarchy_name, c1.meta_name, c1.depth
               Buckets: 4096  Batches: 1  Memory Usage: 34kB
               Buffers: shared hit=4
               ->  CTE Scan on cte_rel c1  (cost=0.00..72.12 rows=3606 width=104) (actual time=0.017..0.293 rows=20 loops=1)
                     Output: c1.meta_id, c1.hierarchy_id, c1.hierarchy_name, c1.meta_name, c1.depth
                     Buffers: shared hit=4
 Planning:
   Buffers: shared hit=8 read=1
 Planning Time: 0.333 ms
 Execution Time: 1391.523 ms
(68 rows)

```
