#select * from a1n;
#drop table a1n;
create table rev_cast_r (BU varchar(100),category varchar(100),product varchar(100),rev int);

insert into rev_cast_r values ('BPS','Elitebook','elite1',10);
insert into rev_cast_r values ('BPS','Elitebook','elite1',20);
insert into rev_cast_r values ('BPS','Pro','elite1',40);
insert into rev_cast_r values ('BPS','Pro','elite2',10);
insert into rev_cast_r values ('BPS','spectre','elite1',80);
insert into rev_cast_r values ('BPS','spectre','elite2',20);
insert into rev_cast_r values ('OPS','spectre','elite2',20);



drop procedure if exists Cast_sql;
DELIMITER $$
CREATE PROCEDURE Cast_sql(table_name varchar(100),group_by_param varchar(1000),melt_param varchar(100),melt_value varchar(100))
BEGIN

	SET @sql = NULL; 
	set @table_name:=table_name;
	set @group_by_param:=group_by_param;
	set @melt_param:=melt_param;
	set @melt_value:=melt_value;


	set @query1:=concat('SELECT GROUP_CONCAT(DISTINCT CONCAT( ''round(avg(case when ',  @melt_param,'='''''',',
	@melt_param ,','''''' then ', @melt_value, ' end),2)'',',@melt_param,')) INTO @sql from ',@table_name);

	call execute();

	SET @query1 = CONCAT('SELECT ',group_by_param,',', @sql, ' FROM ',@table_name,' GROUP BY ',@group_by_param);
 
	call execute();


END$$
delimiter ;
call Cast_sql('rev_cast_r','BU,Category','product','rev');

