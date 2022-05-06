# Challenge 1
Do you know how to write SQL? Then I have a challenge for you to warm up for our Database Tutorial.

Let's say I have 2 tables, table "Meta" and table "Data" according to the below SQL:

``` SQL
create table meta
(
    meta_id integer primary key,
    meta_parent integer,
    meta_name varchar not null,
    constraint fk_meta_parent foreign key (meta_id) references meta
);

create table meta_obj
(
    obj_id integer primary key,
    meta_id integer not null,
    obj_name varchar not null,
    obj_data jsonb not null,
    constraint fk_obj_meta_id foreign key (meta_id) references meta
);
```

How can I get the below result using only one SQL command?
```
  meta_id | hierarchy_id  |        hierarchy_name         | meta_name | total 
---------+----------------+-------------------------------+-----------+-------
       1 | 1              | Meta 1                        | Meta 1    |     0
       2 | 2              | Meta 2                        | Meta 2    |     0
       3 | 3              | Meta 3                        | Meta 3    |     0
       4 | 2 -> 4         | Meta 2 -> Meta 4              | Meta 4    | 31166
       5 | 3 -> 5         | Meta 3 -> Meta 5              | Meta 5    | 62526
       6 | 1 -> 6         | Meta 1 -> Meta 6              | Meta 6    | 62661
       7 | 1 -> 7         | Meta 1 -> Meta 7              | Meta 7    | 62976
      10 | 2 -> 10        | Meta 2 -> Meta 10             | Meta 10   | 62280
      11 | 3 -> 11        | Meta 3 -> Meta 11             | Meta 11   | 62868
      12 | 1 -> 12        | Meta 1 -> Meta 12             | Meta 12   | 62319
      15 | 1 -> 15        | Meta 1 -> Meta 15             | Meta 15   | 62753
       8 | 2 -> 4  -> 8   | Meta 2 -> Meta 4  -> Meta 8   | Meta 8    | 62838
       9 | 1 -> 7  -> 9   | Meta 1 -> Meta 7  -> Meta 9   | Meta 9    | 62200
      13 | 2 -> 10 -> 13  | Meta 2 -> Meta 10 -> Meta 13  | Meta 13   | 62571
      14 | 2 -> 4  -> 14  | Meta 2 -> Meta 4  -> Meta 14  | Meta 14   | 62271
      16 | 3 -> 5  -> 16  | Meta 3 -> Meta 5  -> Meta 16  | Meta 16   | 62030
      17 | 1 -> 12 -> 17  | Meta 1 -> Meta 12 -> Meta 17  | Meta 17   | 62333
      18 | 2 -> 4  -> 18  | Meta 2 -> Meta 4  -> Meta 18  | Meta 18   | 62873
      19 | 2 -> 10 -> 19  | Meta 2 -> Meta 10 -> Meta 19  | Meta 19   | 62027
      20 | 1 -> 7  -> 20  | Meta 1 -> Meta 7  -> Meta 20  | Meta 20   | 31308
Time: 980.642 ms
```

Also, can you make your SQL run in less than 2s on a "t2.micro" free AWS instance with the below dataset?

``` SQL
INSERT INTO meta VALUES (1, NULL, 'Meta 1');
INSERT INTO meta VALUES (2, NULL, 'Meta 2');
INSERT INTO meta VALUES (3, NULL, 'Meta 3');
INSERT INTO meta VALUES (4, 2, 'Meta 4');
INSERT INTO meta VALUES (5, 3, 'Meta 5');
INSERT INTO meta VALUES (6, 1, 'Meta 6');
INSERT INTO meta VALUES (7, 1, 'Meta 7');
INSERT INTO meta VALUES (8, 4, 'Meta 8');
INSERT INTO meta VALUES (9, 7, 'Meta 9');
INSERT INTO meta VALUES (10, 2, 'Meta 10');
INSERT INTO meta VALUES (11, 3, 'Meta 11');
INSERT INTO meta VALUES (12, 1, 'Meta 12');
INSERT INTO meta VALUES (13, 10, 'Meta 13');
INSERT INTO meta VALUES (14, 4, 'Meta 14');
INSERT INTO meta VALUES (15, 1, 'Meta 15');
INSERT INTO meta VALUES (16, 5, 'Meta 16');
INSERT INTO meta VALUES (17, 12, 'Meta 17');
INSERT INTO meta VALUES (18, 4, 'Meta 18');
INSERT INTO meta VALUES (19, 10, 'Meta 19');
INSERT INTO meta VALUES (20, 7, 'Meta 20');

INSERT INTO meta_obj SELECT x, (random() * 16 + 4)::integer, 'Object ' || x, ('{"object": '|| x ||'}')::json FROM generate_series(1, 10000000) x;
```

What about make it run in less than 1 second? 

I'm looking forward to your SQL!!!

## Analisys

You can find the analysis of this challenge with some answer [here](challenge1_analysis.md). Enjoy the reading!