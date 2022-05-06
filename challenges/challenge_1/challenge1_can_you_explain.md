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


## No index EXPLAIN
I messed up this challenge, it wasn't supposed to have the index at this stage but it's there in the EXPLAIN. But I should say that for this exercise the index isn't the major contributor for the performance. Please find the EXPLAINs of the queries without the index below and you'll find easier a feature that is the major contributor for the performance difference in this case here:

#### Query 1 EXPLAIN without index

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
 Sort  (cost=677841.13..677842.04 rows=361 width=112) (actual time=6042.870..6042.907 rows=20 loops=1)
   Output: mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name, (count(mo.obj_id)), mh.depth
   Sort Key: mh.depth, mh.meta_id
   Sort Method: quicksort  Memory: 27kB
   Buffers: shared hit=164 read=10149, temp read=2707 written=2724
   CTE meta_hierarchy
     ->  Recursive Union  (cost=0.00..477.65 rows=3606 width=108) (actual time=0.016..0.258 rows=20 loops=1)
           Buffers: shared hit=4
           ->  Seq Scan on public.meta  (cost=0.00..22.03 rows=6 width=108) (actual time=0.013..0.019 rows=3 loops=1)
                 Output: meta.meta_id, 1, (meta.meta_id)::text, meta.meta_name, meta.meta_parent, meta.meta_name
                 Filter: (meta.meta_parent IS NULL)
                 Rows Removed by Filter: 17
                 Buffers: shared hit=1
           ->  Subquery Scan on "*SELECT* 2"  (cost=1.95..41.95 rows=360 width=108) (actual time=0.037..0.067 rows=6 loops=3)
                 Output: "*SELECT* 2".meta_id, "*SELECT* 2".depth, "*SELECT* 2".hierarchy_id, "*SELECT* 2".hierarchy_name, "*SELECT* 2".meta_parent, "*SELECT* 2".meta_name
                 Buffers: shared hit=3
                 ->  Hash Join  (cost=1.95..38.35 rows=360 width=108) (actual time=0.034..0.056 rows=6 loops=3)
                       Output: m.meta_id, (ms.depth + 1), ((ms.hierarchy_id || ' -> '::text) || (m.meta_id)::text), (((ms.hierarchy_name)::text || ' -> '::text) || (m.meta_name)::t
ext), m.meta_parent, m.meta_name
                       Hash Cond: (m.meta_parent = ms.meta_id)
                       Buffers: shared hit=3
                       ->  Seq Scan on public.meta m  (cost=0.00..22.00 rows=1200 width=40) (actual time=0.002..0.015 rows=20 loops=3)
                             Output: m.meta_id, m.meta_parent, m.meta_name
                             Buffers: shared hit=3
                       ->  Hash  (cost=1.20..1.20 rows=60 width=72) (actual time=0.013..0.014 rows=7 loops=3)
                             Output: ms.depth, ms.hierarchy_id, ms.hierarchy_name, ms.meta_id
                             Buckets: 1024  Batches: 1  Memory Usage: 9kB
                             ->  WorkTable Scan on meta_hierarchy ms  (cost=0.00..1.20 rows=60 width=72) (actual time=0.001..0.006 rows=7 loops=3)
                                   Output: ms.depth, ms.hierarchy_id, ms.hierarchy_name, ms.meta_id
   ->  HashAggregate  (cost=677344.54..677348.15 rows=361 width=112) (actual time=6042.817..6042.846 rows=20 loops=1)
         Output: mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name, count(mo.obj_id), mh.depth
         Group Key: mh.depth, mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name
         Batches: 1  Memory Usage: 45kB
         Buffers: shared hit=164 read=10149, temp read=2707 written=2724
         ->  Merge Left Join  (cost=133926.51..406894.54 rows=18030000 width=108) (actual time=1572.846..5049.066 rows=1000003 loops=1)
               Output: mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name, mh.depth, mo.obj_id
               Merge Cond: (mh.meta_id = mo.meta_id)
               Buffers: shared hit=164 read=10149, temp read=2707 written=2724
               ->  Sort  (cost=285.17..294.18 rows=3606 width=104) (actual time=0.307..0.339 rows=20 loops=1)
                     Output: mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name, mh.depth
                     Sort Key: mh.meta_id
                     Sort Method: quicksort  Memory: 27kB
                     Buffers: shared hit=4
                     ->  CTE Scan on meta_hierarchy mh  (cost=0.00..72.12 rows=3606 width=104) (actual time=0.020..0.285 rows=20 loops=1)
                           Output: mh.meta_id, mh.hierarchy_id, mh.hierarchy_name, mh.meta_name, mh.depth
                           Buffers: shared hit=4
               ->  Materialize  (cost=133641.34..138641.34 rows=1000000 width=8) (actual time=1572.531..3664.729 rows=1000000 loops=1)
                     Output: mo.obj_id, mo.meta_id
                     Buffers: shared hit=160 read=10149, temp read=2707 written=2724
                     ->  Sort  (cost=133641.34..136141.34 rows=1000000 width=8) (actual time=1572.526..2316.399 rows=1000000 loops=1)
                           Output: mo.obj_id, mo.meta_id
                           Sort Key: mo.meta_id
                           Sort Method: external merge  Disk: 17696kB
                           Buffers: shared hit=160 read=10149, temp read=2707 written=2724
                           ->  Seq Scan on public.meta_obj mo  (cost=0.00..20309.00 rows=1000000 width=8) (actual time=0.039..738.156 rows=1000000 loops=1)
                                 Output: mo.obj_id, mo.meta_id
                                 Buffers: shared hit=160 read=10149
 Planning Time: 0.320 ms
 Execution Time: 6045.349 ms
(58 rows)
```

#### Query 2 EXPLAIN without index

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
 Sort  (cost=18336.71..18345.73 rows=3606 width=112) (actual time=1511.733..1514.789 rows=20 loops=1)
   Output: c1.meta_id, c1.hierarchy_id, c1.hierarchy_name, c1.meta_name, (COALESCE(o.tot, '0'::bigint)), c1.depth
   Sort Key: c1.depth, c1.meta_id
   Sort Method: quicksort  Memory: 27kB
   Buffers: shared hit=210 read=10117
   CTE cte_rel
     ->  Recursive Union  (cost=0.00..477.65 rows=3606 width=104) (actual time=0.016..0.275 rows=20 loops=1)
           Buffers: shared hit=4
           ->  Seq Scan on public.meta  (cost=0.00..22.03 rows=6 width=104) (actual time=0.013..0.021 rows=3 loops=1)
                 Output: meta.meta_id, 1, (meta.meta_id)::character varying, meta.meta_name, meta.meta_name
                 Filter: (meta.meta_parent IS NULL)
                 Rows Removed by Filter: 17
                 Buffers: shared hit=1
           ->  Subquery Scan on "*SELECT* 2"  (cost=1.95..41.95 rows=360 width=104) (actual time=0.042..0.071 rows=6 loops=3)
                 Output: "*SELECT* 2".meta_id, "*SELECT* 2".depth, "*SELECT* 2".hierarchy_id, "*SELECT* 2".hierarchy_name, "*SELECT* 2".meta_name
                 Buffers: shared hit=3
                 ->  Hash Join  (cost=1.95..38.35 rows=360 width=104) (actual time=0.039..0.060 rows=6 loops=3)
                       Output: m2.meta_id, (c.depth + 1), (((c.hierarchy_id)::text || ' -> '::text) || (m2.meta_id)::text), (((c.hierarchy_name)::text || ' -> '::text) || (m2.meta_
name)::text), m2.meta_name
                       Hash Cond: (m2.meta_parent = c.meta_id)
                       Buffers: shared hit=3
                       ->  Seq Scan on public.meta m2  (cost=0.00..22.00 rows=1200 width=40) (actual time=0.003..0.017 rows=20 loops=3)
                             Output: m2.meta_id, m2.meta_parent, m2.meta_name
                             Buffers: shared hit=3
                       ->  Hash  (cost=1.20..1.20 rows=60 width=72) (actual time=0.014..0.015 rows=7 loops=3)
                             Output: c.depth, c.hierarchy_id, c.hierarchy_name, c.meta_id
                             Buckets: 1024  Batches: 1  Memory Usage: 9kB
                             ->  WorkTable Scan on cte_rel c  (cost=0.00..1.20 rows=60 width=72) (actual time=0.002..0.007 rows=7 loops=3)
                                   Output: c.depth, c.hierarchy_id, c.hierarchy_name, c.meta_id
   ->  Hash Left Join  (cost=17564.23..17646.02 rows=3606 width=112) (actual time=1511.394..1514.740 rows=20 loops=1)
         Output: c1.meta_id, c1.hierarchy_id, c1.hierarchy_name, c1.meta_name, COALESCE(o.tot, '0'::bigint), c1.depth
         Inner Unique: true
         Hash Cond: (c1.meta_id = o.meta_id)
         Buffers: shared hit=210 read=10117
         ->  CTE Scan on cte_rel c1  (cost=0.00..72.12 rows=3606 width=104) (actual time=0.019..0.302 rows=20 loops=1)
               Output: c1.meta_id, c1.depth, c1.hierarchy_id, c1.hierarchy_name, c1.meta_name
               Buffers: shared hit=4
         ->  Hash  (cost=17564.02..17564.02 rows=17 width=12) (actual time=1511.366..1514.394 rows=17 loops=1)
               Output: o.tot, o.meta_id
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               Buffers: shared hit=206 read=10117
               ->  Subquery Scan on o  (cost=17559.54..17564.02 rows=17 width=12) (actual time=1511.213..1514.372 rows=17 loops=1)
                     Output: o.tot, o.meta_id
                     Buffers: shared hit=206 read=10117
                     ->  Finalize GroupAggregate  (cost=17559.54..17563.85 rows=17 width=12) (actual time=1511.211..1514.345 rows=17 loops=1)
                           Output: meta_obj.meta_id, count(*)
                           Group Key: meta_obj.meta_id
                           Buffers: shared hit=206 read=10117
                           ->  Gather Merge  (cost=17559.54..17563.51 rows=34 width=12) (actual time=1511.196..1514.280 rows=51 loops=1)
                                 Output: meta_obj.meta_id, (PARTIAL count(*))
                                 Workers Planned: 2
                                 Workers Launched: 2
                                 Buffers: shared hit=206 read=10117
                                 ->  Sort  (cost=16559.52..16559.56 rows=17 width=12) (actual time=1504.754..1504.769 rows=17 loops=3)
                                       Output: meta_obj.meta_id, (PARTIAL count(*))
                                       Sort Key: meta_obj.meta_id
                                       Sort Method: quicksort  Memory: 25kB
                                       Buffers: shared hit=206 read=10117
                                       Worker 0:  actual time=1503.068..1503.083 rows=17 loops=1
                                         Sort Method: quicksort  Memory: 25kB
                                         Buffers: shared hit=71 read=3351
                                       Worker 1:  actual time=1500.389..1500.404 rows=17 loops=1
                                         Sort Method: quicksort  Memory: 25kB
                                         Buffers: shared hit=77 read=3352
                                       ->  Partial HashAggregate  (cost=16559.00..16559.17 rows=17 width=12) (actual time=1504.697..1504.712 rows=17 loops=3)
                                             Output: meta_obj.meta_id, PARTIAL count(*)
                                             Group Key: meta_obj.meta_id
                                             Batches: 1  Memory Usage: 24kB
                                             Buffers: shared hit=192 read=10117
                                             Worker 0:  actual time=1503.007..1503.022 rows=17 loops=1
                                               Batches: 1  Memory Usage: 24kB
                                               Buffers: shared hit=64 read=3351
                                             Worker 1:  actual time=1500.312..1500.327 rows=17 loops=1
                                               Batches: 1  Memory Usage: 24kB
                                               Buffers: shared hit=70 read=3352
                                             ->  Parallel Seq Scan on public.meta_obj  (cost=0.00..14475.67 rows=416667 width=4) (actual time=0.036..718.234 rows=333333 loops=3)
                                                   Output: meta_obj.obj_id, meta_obj.meta_id, meta_obj.obj_name, meta_obj.obj_json
                                                   Buffers: shared hit=192 read=10117
                                                   Worker 0:  actual time=0.035..712.864 rows=331255 loops=1
                                                     Buffers: shared hit=64 read=3351
                                                   Worker 1:  actual time=0.029..694.257 rows=331868 loops=1
                                                     Buffers: shared hit=70 read=3352
 Planning Time: 0.309 ms
 Execution Time: 1514.885 ms
(83 rows)

```
