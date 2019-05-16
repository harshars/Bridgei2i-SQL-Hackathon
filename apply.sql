use sql_hk_2018;

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

drop procedure if exists apply;
DELIMITER $$
Create procedure apply(table_name varchar(100),row_column int,function_name varchar(100))
BEGIN

	
	
	
	set @query1:=concat('select group_concat(column_name),group_concat(column_name separator ",'','',") into @temp,@temp1 from information_schema.columns where TABLE_NAME=''',table_name,
    ''' and data_type=''int''');
    
    call execute();
    
    
    
    drop table if exists temp;
    set @query1:=concat('create table temp as select ',@temp,' from ',table_name);
    
	call execute();
    
    select count(*) into @n from temp;
    
    select char_length(@temp) - char_length(replace(@temp, ',', '')) into @comma_count;
   
    if(lower(function_name)='sum')then
		if(row_column=1)then
				set @j:=1;
				set @temp4:='';    
					while(@j<=@comma_count+1) do
						set @query1:=concat('select concat(''sum(',split_string(@temp,",",@j),')'') into @temp3');
						call execute();
						set @temp4 := concat(@temp3,',',@temp4);
						set @j:=@j+1;
					end while;
					
				set @query1:=concat('select ',substr(@temp4,1,length(@temp4)-1),' from temp');
				call execute();
		end if;
    
		if(row_column=0)then
				set @temp1:=@temp;
				set @temp1:=replace(@temp1,',','+');
				set @parameter:=0;
				set @query1:=concat('select * from (select *,@parameter:=',@temp1,' as sum from temp)x');
				call execute();
		end if;
    end if; # End of Sum
    
    if(lower(function_name)='avg')then
		
		if(row_column=0)then
				drop table if exists final;
				create table final(x int);
				
				set @i:=0;
				while(@i < @n) do
					set @query1:= concat('select concat(',@temp1,') into @temp2 from temp limit ',@i,',1');
					call execute();
					drop table if exists q;
					create table q(val int);
					set @j:=1;
					
					while(@j<=@comma_count+1) do
						insert into q values(split_string(@temp2,',',@j));
						set @j:=@j+1;
					end while;
					
					set @i:=@i+1;
					select avg(val) into @temp2 from q;
					
					insert into final values(@temp2);
				
				end while;
					select * from final;
		end if;
            
		if(row_column=1)then
				set @j:=1;
				set @temp4:='';    
					while(@j<=@comma_count+1) do
						set @query1:=concat('select concat(''avg(',split_string(@temp,",",@j),')'') into @temp3');
						call execute();
						set @temp4 := concat(@temp3,',',@temp4);
						set @j:=@j+1;
					end while;
					
				set @query1:=concat('select ',substr(@temp4,1,length(@temp4)-1),' from temp');
				call execute();
		end if;
	end if; #End of Avg 
    
    if(lower(function_name)='std')then
		
		if(row_column=0)then
				drop table if exists final;
				create table final(x int);
				
				set @i:=0;
				while(@i < @n) do
					set @query1:= concat('select concat(',@temp1,') into @temp2 from temp limit ',@i,',1');
					call execute();
					drop table if exists q;
					create table q(val int);
					set @j:=1;
					
					while(@j<=@comma_count+1) do
						insert into q values(split_string(@temp2,',',@j));
						set @j:=@j+1;
					end while;
					
					set @i:=@i+1;
					select std(val) into @temp2 from q;
					
					insert into final values(@temp2);
				
				end while;
					select * from final;
		end if;
            
		if(row_column=1)then
				set @j:=1;
				set @temp4:='';    
					while(@j<=@comma_count+1) do
						set @query1:=concat('select concat(''std(',split_string(@temp,",",@j),')'') into @temp3');
						call execute();
						set @temp4 := concat(@temp3,',',@temp4);
						set @j:=@j+1;
					end while;
					
				set @query1:=concat('select ',substr(@temp4,1,length(@temp4)-1),' from temp');
				call execute();
		end if;
	end if; #End of std
   
   if(lower(function_name)='missing')then
		if(row_column=1)then
			set @j:=1;
				  
					while(@j<=@comma_count+1) do
						set @query1:=concat('select count(',split_string(@temp,",",@j),') from ',table_name,' where ',split_string(@temp,",",@j),'=""');
						call execute();
						
						set @j:=@j+1;
					end while;
		end if;
        
        if(row_column=0) then
			drop table if exists final;
				create table final(x int);
				
				set @i:=0;
				while(@i < @n) do
					set @query1:= concat('select concat(',@temp1,') into @temp2 from temp limit ',@i,',1');
					call execute();
                    
					drop table if exists q;
					create table q(val int);
					set @j:=1;
					
					while(@j<=@comma_count+1) do
						insert into q values(split_string(@temp2,',',@j));
						set @j:=@j+1;
					end while;
					
					set @i:=@i+1;
					select count(val) into @temp2 from q where val='';
					
					insert into final values(@temp2);
				
				end while;
					select * from final;
		end if;	
	end if; # End of missing
    
    if(lower(function_name)='missing%')then
		if(row_column=1)then
			set @j:=1;
				  
					while(@j<=@comma_count+1) do
						set @query1:=concat('select count(*) into @temp11 from ',table_name);
                        call execute();
                        
						set @query1:=concat('select count(',split_string(@temp,",",@j),')/@temp11 from ',table_name,' where ',split_string(@temp,",",@j),'=""');
						call execute();
						
						set @j:=@j+1;
					end while;
		end if;
        
        if(row_column=0) then
			drop table if exists final;
				create table final(x int);
				
				set @i:=0;
				while(@i < @n) do
					set @query1:= concat('select concat(',@temp1,') into @temp2 from temp limit ',@i,',1');
					call execute();
                    
					drop table if exists q;
					create table q(val int);
					set @j:=1;
					
					while(@j<=@comma_count+1) do
						insert into q values(split_string(@temp2,',',@j));
						set @j:=@j+1;
					end while;
					
					set @i:=@i+1;
					select count(val)/(@comma_count+1) into @temp2 from q where val='';
					
					insert into final values(@temp2);
				
				end while;
					select * from final;
		end if;	
	end if; # End of missing %
    
    if(lower(function_name)='median')then
		if(row_column=1)then
			set @j:=1;
				  
					while(@j<=@comma_count+1) do
						
						
                        set @query1:=concat('select avg(',split_string(@temp,",",@j),') from
									(
										select @counter:=@counter+1 as row_id, t1.',split_string(@temp,",",@j), 
										' from ',table_name,' t1 , (select @counter:=0) t2
										order by cast(t1.',split_string(@temp,",",@j),' as unsigned)
									) o1
									join
									(
										select count(*) as total_rows
										from ',table_name,'
									) o2
									where o1.row_id in (floor((o2.total_rows + 1)/2), floor((o2.total_rows + 2)/2))');
                        
                        call execute();
						set @j:=@j+1;
					end while;
		end if;
        
        if(row_column=0) then
			drop table if exists final;
				create table final(x int);
				
				set @i:=0;
				while(@i < @n) do
					set @query1:= concat('select concat(',@temp1,') into @temp2 from temp limit ',@i,',1');
					call execute();
                    
					drop table if exists q;
					create table q(val int);
					set @j:=1;
					
					while(@j<=@comma_count+1) do
						insert into q values(split_string(@temp2,',',@j));
						set @j:=@j+1;
					end while;
					select * from q;
					set @i:=@i+1;
					#select count(val) into @temp2 from q where val='';
                    
                    select avg(val) into @temp2 from
					(
						select @counter:=@counter+1 as row_id, t1.val 
						from q t1 , (select @counter:=0) t2
						order by cast(t1.val as unsigned)
					) o1
					join
					(
						select count(*) as total_rows
						from q
					) o2
					where o1.row_id in (floor((o2.total_rows + 1)/2), floor((o2.total_rows + 2)/2));
					
					insert into final values(@temp2);
				
				end while;
					select * from final;
		end if;	
	end if; # End of median
    
END$$
delimiter ;

call apply('train_details1',0,'missing%');







