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

drop procedure if exists partition_by;
DELIMITER $$
CREATE PROCEDURE partition_by(table_name varchar(100),function_name varchar(100),groupBy varchar(100),orderBy varchar(100))
BEGIN
declare custom_exception condition for sqlstate '45000';
if(table_name = '') then signal custom_exception set message_text='Attribute Table name is missing';
elseif(function_name='') then signal custom_exception set message_text='Attribute Function Name is missing';
else
	if(lower(function_name)='rank')then
		if(orderBy='') then signal custom_exception set message_text='Attribute Order By is missing';
		else
			if(groupBy<>'')then
				set @rank:='';
				set @current1:='';
				set @query1:= concat('select * from (select *,@rank:=if(@current1=',groupBy,',@rank+1,1) as rank,@current1:=',groupBy,' from ',table_name,' order by ',
				groupBy,',',orderBy,' desc)ranked');

				call execute();
			else
				set @row:=0;
				set @query1:= concat('select *,@row:=@row+1 as rank from ',table_name,' order by ',orderBy);

				call execute();
			end if;
		end if;
	end if; #End of Rank
	
	if(lower(function_name)='row_num')then
		if(groupBy<>'')then
			set @row_num:='';
			set @current1:='';
			set @query1:= concat('select * from (select *,@row_num:=if(@current1=',groupBy,',@row_num+1,1) as row_num,@current1:=',groupBy,' from ',table_name,' order by ',
			groupBy,')row');
            
            call execute();
            
		else
			set @row:=0;
				set @query1:= concat('select *,@row:=@row+1 as row_num from ',table_name);

				call execute();
		end if;
	end if; #End of row_num
	
	if(lower(function_name)='dense_rank')then
		if(orderBy='') then signal custom_exception set message_text='Attribute Order By is missing';
		else
			if(groupBy<>'')then
				set @previous='';
				set @dense_rank=0;
				set @att='';
				set @val=1;
				
				set @query1:=concat('select * from (select *,@dense_rank:=if(@previous=',groupBy,',if(@att=',orderBy,',@dense_rank,@dense_rank+@val),1)as dense_rank,
				#@val:=if(@previous=',groupBy,',if(@att=',orderBy,',@val+1,1),1) as value,
				@previous:=',groupBy,',
				@att:=',orderBy,' from ',table_name,' order by ',groupBy,',',orderBy,' desc)dense');
				
				call execute();
			else
				set @dense_rank=0;
				set @att='';
				
				set @query1:=concat('select * from (select *,@dense_rank:=if(@att=',orderBy,',@dense_rank,@dense_rank+1) as dense_rank,@att:=',orderBy,' from ',table_name,' 
				order by ',orderBy,')dense');
				
				call execute();
			end if;
		end if;
	end if; #End of Dense_rank
	
	if(lower(function_name)='first_value')then
		if(groupBy='')then signal custom_exception set message_text='Attribute Group By is missing';
		else
			set @row_num:='';
			set @current1:='';
			set @query1:= concat('select * from (select *,@row_num:=if(@current1=',groupBy,',@row_num+1,1) as row_num,@current1:=',groupBy,' from ',table_name,' order by ',
			groupBy,')row where row_num=1');
            
            call execute();
		end if;
	end if; #End of First_value
	
	if(lower(function_name)='last_value')then
		if(groupBy='')then signal custom_exception set message_text='Attribute Group By is missing';
		else
			set @row_num:='';
			set @current1:='';
			drop table if exists table_last_value;
			set @query1:= concat('create table table_last_value as select * from (select *,@row_num:=if(@current1=',groupBy,',@row_num+1,1) as row_num,@current1:=',groupBy,' from ',table_name,' order by ',
			groupBy,')row');
			
			call execute();
			
			set @query1:=concat('select * from table_last_value where (',groupBy,',row_num) in (select ',groupBy,',max(row_num) from table_last_value group by ',groupBy,')');
			
			call execute();
		end if;
	end if; #End of Last_value
	
	if(lower(function_name)='min')then
		if(groupBy='')then signal custom_exception set message_text='Attribute Group By is missing';
		else
			if(orderBy='')then signal custom_exception set message_text='Attribute Order By is missing';	
			else
				set @query1:=concat('select * from ',table_name,' where (',groupBy,',',orderBy,') in (select ',groupBy,',min(',orderBy,') from ',table_name,' group by ',groupBy,')');
			
				call execute();
			end if;
		end if;
	end if; #End of Min
	
	if(lower(function_name)='max')then
		if(groupBy='')then signal custom_exception set message_text='Attribute Group By is missing';
		else
			if(orderBy='')then signal custom_exception set message_text='Attribute Order By is missing';	
			else
				set @query1:=concat('select * from ',table_name,' where (',groupBy,',',orderBy,') in (select ',groupBy,',max(',orderBy,') from ',table_name,' group by ',groupBy,')');
			
				call execute();
			end if;
		end if;
	end if; #End of Max
	
	if(lower(function_name)='avg')then
		if(groupBy='')then signal custom_exception set message_text='Attribute Group By is missing';
		else
			if(orderBy='')then signal custom_exception set message_text='Attribute Order By is missing';	
			else
				set @query1:=concat('select ',groupBy,',round(avg(',orderBy,')) as Average from ',table_name,' group by ',groupBy);
			
				call execute();
			end if;
		end if;
	end if; #End of Avg
	
	if(lower(function_name)='std')then
		if(groupBy='')then signal custom_exception set message_text='Attribute Group By is missing';
		else
			if(orderBy='')then signal custom_exception set message_text='Attribute Order By is missing';	
			else
				set @query1:=concat('select ',groupBy,',round(std(',orderBy,')) as Standard_deviation from ',table_name,' group by ',groupBy);
			
				call execute();
			end if;
		end if;
	end if; #End of Std
	
	
	
	if(lower(function_name)='cumulative')then
		if(orderBy='')then signal custom_exception set message_text='Attribute Order By is missing';
		else
			if(groupBy<>'')then
				set @sum:=0;
				set @previous:='';
				set @query1:=concat('select * from (select *,@sum:=if(@previous=',groupBy,',@sum+',orderBy,',',orderBy,') as cumulative,@previous:=',groupBy,' from ',table_name,')cum');
				
				call execute();
			else
				set @sum:=0;
				set @query1:=concat('select *,@sum:=@sum+',orderBy,' as cumulative from ',table_name);
				
				call execute();
			end if;
		end if;
	end if; #End of Cumulative
	
	if(lower(function_name)='missing')then
		if(groupBy='')then signal custom_exception set message_text='Attribute Group By is missing';
		else
			if(orderBy='')then signal custom_exception set message_text='Attribute Order By is missing';	
			else
				set @sum:=0;
				set @previous:='';
				
				set @query1:=concat('select ',groupBy,',max(missing) as missing from (select *,@sum:=if(@previous=',groupBy,',if(',orderBy,'='''',@sum+1,@sum),if(',orderBy,'='''',@sum+1,@sum)) 
				as missing,@previous:=',groupBy,' from ',table_name,')miss group by ',groupBy);
				
				call execute();
			end if;
		end if;	
	end if;
	
	if(lower(function_name)='percentile')then
		if(groupBy='')then signal custom_exception set message_text='Attribute Group By is missing';
		else
			if(orderBy='')then signal custom_exception set message_text='Attribute Order By is missing';	
			else
				set @query1:=concat('SELECT x.',groupBy,' 
				 , x.',orderBy,
				 ', ROUND( 100 * x.cnt  / total.tot ) AS percentile 
				FROM ( 
				select a.',groupBy,'
				   , a.',orderBy,'
				   , ( SELECT COUNT(*) FROM ',table_name,' AS b WHERE a.',groupBy,' = b.',groupBy,' and b.',orderBy,' <= a.',orderBy,' ) cnt
				  FROM ',table_name,' a 
				) x
				JOIN (
				  SELECT ',groupBy,'
					   , COUNT(*) AS tot
					FROM ',table_name,' 
				   group by ',groupBy,'
				  ) AS total
				 ON total.',groupBy,' = x.',groupBy,'
				ORDER BY ',groupBy,', percentile'); 
				
				call execute();
			end if;
		end if;
	end if; # End of Percentile
	
	
	
	if(lower(function_name)='median')then
		if(groupBy='')then signal custom_exception set message_text='Attribute Group By is missing';
		else
			if(orderBy='')then signal custom_exception set message_text='Attribute Order By is missing';	
			else
				SET @row_number:=0; 
				SET @median_group:='';

				set @query1:=concat('
				SELECT 
					median_group as ',groupBy,', AVG(',orderBy,') AS median
				FROM
					(SELECT 
						@row_number:=CASE
								WHEN @median_group = ',groupBy,' THEN @row_number + 1
								ELSE 1
							END AS count_of_group,
							@median_group:=',groupBy,' AS median_group,
							',groupBy,',
							',orderBy,',
							(SELECT 
									COUNT(*)
								FROM
									',table_name,'
								WHERE
									a.',groupBy,' = ',groupBy,') AS total_of_group
								FROM
									(SELECT 
									',groupBy,',',orderBy,'
								FROM
									',table_name,'
								ORDER BY ',groupBy,' , cast(',orderBy,' as unsigned)) AS a) AS b
							WHERE
								count_of_group BETWEEN total_of_group / 2.0 AND total_of_group / 2.0 + 1
							GROUP BY median_group');
			
				call execute();
			end if;
		end if;
	end if; #End of Median	
	
	if(lower(function_name)='lag')then
		if(groupBy='')then signal custom_exception set message_text='Attribute Group By is missing';
		else
			if(orderBy='')then signal custom_exception set message_text='Attribute Order By is missing';	
			else
				
				set @previous_group='';
				set @previous_value='';
				set @previous_value1='';
				set @query1:=concat('select * from (select *,@previous_value1:=if(@previous_group=',groupBy,',@previous_value,'''') as lag,
								@previous_group:=',groupBy,',@previous_value:=',orderBy,' from ',table_name,')la');
                
				call execute();

			
			end if;
		end if;
	end if;

end if; #End of Checking if parameters are missing
END$$
delimiter ;

call partition_by('train_details','lag','train_no','distance');





