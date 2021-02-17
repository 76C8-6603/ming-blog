---
    title: "Mysql插入重复值追加后缀"
    date: 2020-04-13
    tags: ["mysql"]
    
---

实现方式是自定义触发器
```sql
drop trigger if exists trigger_name;

delimiter |

CREATE TRIGGER trigger_name BEFORE INSERT ON table_name
    FOR EACH ROW BEGIN
    declare original_column_name varchar(255);
    declare column_name_counter int;

    set original_column_name = new.column_name;
    set column_name_counter = 1;

    while exists (select true from pc_volumes where name = new.column_name) do
            set new.column_name = concat(original_column_name, '-', column_name_counter);
            set column_name_counter = column_name_counter + 1;
        end while;

END;
|
delimiter ;
```