# Challenge 3

Hey there, I hope you are doing great! We keep investigating our database and we found something really interesting on our Queue. We have the below table:

```SQL
CREATE TABLE t_queue_item (
   q_item_id int8,
   item_type int2,
   q_id int8 not null,
   is_active boolean,
   q_item_parent int8,
   q_item_value numeric(10,2)
);

-- Populate it with 1M random rows
INSERT INTO t_queue_item
   SELECT
       i,                               -- q_item_id
       (random() * 125)::int,           -- item_type
       (random() * 99999)::int,         -- q_id
       ((random() * 999)::int % 2 = 0), -- is_active
       (random() * 999)::int,           -- q_item_parent
       (random() * 999)::float         -- q_item_value
   FROM generate_series(1, 1000000) AS i;
CHECKPOINT;
```

Checking in our Postgres 14 it occupies 74MB on disk. It's a small table, I know, but it's growing fast! One of our colleagues was playing with this table and he found that if we change the order of some of the columns we can save disk space. I was a bit skeptical but gave it a try and create the below table based on the `t_queue_item` table:

```SQL
CREATE TABLE t_queue_item_good AS  
   SELECT q_id, 
      q_item_id, 
      q_item_parent, 
      item_type, 
      is_active, 
      q_item_value 
   FROM t_queue_item;
```

I then checked both tables:

```SQL
test=# SELECT relname, pg_size_pretty(pg_relation_size(relname::TEXT)) as size
FROM pg_class 
WHERE relname like 't_queue_item%';
      relname      | size  
-------------------+-------
 t_queue_item      | 74 MB
 t_queue_item_good | 65 MB
(2 rows)
```

Doing a simple math here I get a 12% disk size difference. This is really interesting and intriguing! Can you help me understand it? 

Why the second table is smaller than the first one? 

Does this have any impact on database performance?

I look forward to hearing from you!