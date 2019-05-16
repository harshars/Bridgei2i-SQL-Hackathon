create table cast_data_check 
(BU varchar(100),Category varchar(100),Maths int,Science int,Geography int);


insert into cast_data_check values ('BPS','Elitebook',90,40,10);
insert into cast_data_check values ('CPS','Elitebook',90,40,10);
insert into cast_data_check values ('CPS','Elite1',90,40,10);
insert into cast_data_check values ('CPS','Elite2',90,40,10);




drop procedure if exists Melt_sql;
DELIMITER $$
CREATE PROCEDURE Melt_sql(table_name varchar(100),group_var varchar(1000),melt_var varchar(1000))
BEGIN

	set @table_name:=table_name;
	set @MeltByFn:=melt_var;
    set @groupByFn:=group_var;
    set @depth1:=0;
    
    
     select char_length(@MeltByFn) - char_length(replace(@MeltByFn, ',', '')) 
     into @comma_count;  
     
      SELECT GROUP_CONCAT(CONCAT('SPLIT_STRING(''',@MeltByFn,''',',''','',',dep,')'))
	  INTO @sqllist1 FROM
      (SELECT @depth1:=@depth1+1 dep FROM
      (SELECT distinct no from numbers where no < @comma_count+2) AA) A;
      
      set @depth1:=0;
	  SELECT GROUP_CONCAT(CONCAT('@temp',dep))
	  INTO @sqltemplist1 FROM
	  (SELECT @depth1:=@depth1+1 dep FROM
	  (SELECT distinct no from numbers where no < @comma_count+2) AA) A;
      
      
      set @query1:=concat('select ',@sqllist1,' into ',@sqltemplist1 );
      call execute();
      
      
      set @counter:=1;
      set @sqlstmt1:='';
      set @check1:='';
      while (@counter<=@comma_count+1)
      do
        
        set @temp_counter=concat('temp',@counter);
        set @query1:=concat('select ','@temp',@counter, ' into @check1');
        call execute();
        set @sqlstmt= concat('select ',@groupByFn,',''',@check1,''' as field ,',@check1,' as Value from ',@table_name,' union ');
		set @counter=@counter+1;
        set @sqlstmt1:=concat(@sqlstmt1,@sqlstmt);
	end while;
        set  @query1:=substring(@sqlstmt1,1,char_length(@sqlstmt1)-6); 
        call execute();
           
END$$
delimiter ;


call Melt_sql('cast_data_check','BU,Category','Maths,Science,Geography');






