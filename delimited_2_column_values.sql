

#--------------------------------test_table----------------------------------------------
drop table if exists test11;
create table test11(a varchar(100));
insert into test11 values('a,b,b,c'),('a,a,b'),('b,b,b'),('a,k,l,i,u');

#-----------------------------------Functions_used--------------------------------------
drop procedure if exists execute;
DELIMITER $$
Create procedure execute()
BEGIN
PREPARE s FROM @query1;
EXECUTE s;
DEALLOCATE PREPARE s;
END$$
delimiter ;

DROP FUNCTION if exists SPLIT_STRING;
 
 CREATE FUNCTION `SPLIT_STRING`(
	str VARCHAR(255) ,
	delim VARCHAR(12) ,
	pos INT
) RETURNS VARCHAR(255) CHARSET utf8 RETURN REPLACE(
	SUBSTRING(
		SUBSTRING_INDEX(str , delim , pos) ,
		CHAR_LENGTH(
			SUBSTRING_INDEX(str , delim , pos - 1)
		) + 1
	) ,
	delim ,
	''
);

#--------------------------------------stored_procedure---------------------------------------------
drop procedure if exists col_count;
DELIMITER $$
CREATE PROCEDURE col_count(table_name varchar(100))
BEGIN

declare delimited_field varchar(50);
declare done int;
declare comma_count int;
declare cur1 cursor for select * from t;
declare continue handler for not found set done=1;

	drop table if exists t;
	set @query1:=concat('create temporary table t as select * from ',table_name );
	call execute();

	set @table_name1:=table_name;
	set @column_name1:='a';
#-----------------------------------for max num of comma---------------------------
	set @query1:=concat('select max(char_length(',@column_name1,')- char_length(replace(',@column_name1,', '','', ''''))) into @max_comma
	from ',@table_name1);
	call execute();

	#--------------------------------create table fin_table-------------------------------------
	set @depth1:=0;

	SELECT GROUP_CONCAT(CONCAT('temp',dep,' varchar(100)'))
	INTO @sqllist1 FROM
	(SELECT @depth1:=@depth1+1 dep FROM
	(SELECT distinct no from numbers where no < @max_comma+2) AA) A;
    
    drop table if exists fin_table;

	set @query1:=concat('Create table fin_table (',@sqllist1,',dist_count varchar(100))');
	call execute();
	
#-------------------------------------------------------------------------------

	
		 set done = 0;
		open cur1;
		igmLoop: loop
        fetch cur1 into delimited_field;
        if done = 1 then leave igmLoop; end if;
        select char_length(delimited_field) - char_length(replace(delimited_field, ',', '')) into comma_count; 
         set @comma_count1:=comma_count;     
        
        SET @depth = 0;
        SET @depth1 = 0;
        SET @counter = 1;
         SET @counter1 = 1;
   
   #--------------------------------count-----------------------------------------------
   
	set @depth1:=0;
	
	SELECT GROUP_CONCAT(CONCAT('SPLIT_STRING(''',delimited_field,''',',''','',',dep,')'))
	INTO @sqllist1 FROM
	(SELECT @depth1:=@depth1+1 dep FROM
	(SELECT distinct no from numbers where no < @comma_count1+2) AA) A;


	set @depth1:=0;
	SELECT GROUP_CONCAT(CONCAT('@temp',dep))
	INTO @sqltemplist1 FROM
	(SELECT @depth1:=@depth1+1 dep FROM
	(SELECT distinct no from numbers where no < @comma_count1+2) AA) A;


	SET @query1=concat('select ',@sqllist1,' into ',@sqltemplist1) ;
	call execute();
    
	drop table if exists q;
	create table q (count1 varchar(100));

	set @dis_count:=1;
	set @counter1:=1;

	while (@counter1<= @comma_count1+1)
	do
		set @sql1:=concat('select ','@temp',@counter1, ' into @check1');
		PREPARE p1 FROM @sql1;
		EXECUTE p1;
		
		insert into q values(@check1);
		set @counter1= @counter1+1;

	end while;
    
	select  count(distinct count1) into @dis_count from q;
	truncate table q;

         
    
#        ------------------------ table--------------------------------------
	set @depth:=0;
	SELECT GROUP_CONCAT(CONCAT('SPLIT_STRING(''',delimited_field,''',',''','',',dep,') '))
	INTO @sqllist FROM
	(SELECT @depth:=@depth+1 dep FROM
	(SELECT distinct no from numbers where no < comma_count+2) AA) A;


	set @depth:=0; 
	SELECT GROUP_CONCAT(CONCAT('temp',dep))
	INTO @tab_cols FROM
	(SELECT @depth:=@depth+1 dep FROM
	(SELECT distinct no from numbers where no < comma_count+2) AA) A;



	SET @query1 = CONCAT('insert into fin_table (', @tab_cols ,',dist_count)  SELECT ',@sqllist,',',@dis_count,';');
	call execute();



 end loop igmLoop;
    close cur1;
select * from fin_table;
END$$
delimiter ;

call col_count('test11');
