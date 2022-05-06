# 挑战 3

嘿，大家好！ 我们一直在研究数据库，并在我们的队列中发现了一些非常有趣的东西。 我们有下表：

```SQL
CREATE TABLE t_queue_item (
   q_item_id int8,
   item_type int2,
   q_id int8 not null,
   is_active boolean,
   q_item_parent int8,
   q_item_value numeric(10,2)
);

-- 创建 100 百万随机条记录
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

检查我们的 Postgres 14，它占用了 74MB 的磁盘空间。 这是一张小表，但它正在快速增长！ 我们的一位同事正在捣鼓这张表，他发现如果我们更改某些列的顺序，我们可以节省磁盘空间。 我有点怀疑，但试了一下，并根据 `t_queue_item` 表创建了下表：

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

然后我查看了下两张表:

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


在这里做一个简单的数学运算，两张表在占据磁盘大小的差异有 12% 。 这真是有趣并耐人寻味！ 你能帮我理解吗？

为什么第二张表比第一张小？

这对数据库性能有影响吗？

我期待着您的回复！
