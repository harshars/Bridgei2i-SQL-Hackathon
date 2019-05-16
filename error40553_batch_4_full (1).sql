select * from train_details;

#1

set @counter=0;
set @final = 0;
set @train_no=(select min(train_no) from train_details);
select *,(case when @train_no=train_no then @final := @final + result else @final:=result end) as final,@train_no:=train_no as new_train_no
from(
select train_no,seq_a,start_a,start_b,
case when start_b>start_a then @counter
when start_b<start_a then @counter+1  end as result
from(
select a.train_no,a.seq as seq_a,a.start as start_a,b.seq as seq_b,b.start as start_b from
(select train_no,a.seq,a.station_code,a.arrival_time,a.depature_time,
time_to_sec(time_format(a.arrival_time,'%H:%i'))/3600  as start,
time_to_sec(time_format(a.depature_time,'%H:%i'))/3600 as end1
from train_details a) a
join
(select train_no,a.seq,a.station_code,a.arrival_time,a.depature_time,
time_to_sec(time_format(a.arrival_time,'%H:%i'))/3600  as start,
time_to_sec(time_format(a.depature_time,'%H:%i'))/3600 as end1
from train_details a) b
on a.seq+1=b.seq  and a.train_no=b.train_no) g )q;

# Final variable has the days travelled by the train


#2

select train_no,distance/(journey_time_sec/3600) from (
select train_no,source_station_code,dest_station_code,
case when dep_in_sec>arr_in_sec then (86400-dep_in_sec)+arr_in_sec
else arr_in_sec-dep_in_sec end as journey_time_sec,distance
from
(select train_no,source_station_code,dest_station_code,
time_to_sec(time_format(dep,'%H:%i')) as dep_in_sec,time_to_sec(time_format(arr,'%H:%i'))  as arr_in_sec,
distance
from
(
select 
a.train_no,
a.station_code ,
a.source_station_code,
a.depature_time as dep,
a.dest_station_code,
b.arrival_time  as arr,
b.distance
 from 
(select train_no,station_code,source_station_code,dest_station_code ,depature_time
from train_details  where seq=1 ) a 
join train_details b
on a.train_no=b.train_no and a.dest_station_code=b.station_code
) y) g ) e

where distance/(journey_time_sec/3600)=

(
select min(distance/(journey_time_sec/3600)) from (
select train_no,source_station_code,dest_station_code,
case when dep_in_sec>arr_in_sec then (86400-dep_in_sec)+arr_in_sec
else arr_in_sec-dep_in_sec end as journey_time_sec,distance
from
(select train_no,source_station_code,dest_station_code,
time_to_sec(time_format(dep,'%H:%i')) as dep_in_sec,time_to_sec(time_format(arr,'%H:%i'))  as arr_in_sec,
distance
from
(
select 
a.train_no,
a.station_code ,
a.source_station_code,
a.depature_time as dep,
a.dest_station_code,
b.arrival_time  as arr,
b.distance
 from 
(select train_no,station_code,source_station_code,dest_station_code ,depature_time
from train_details  where seq=1 ) a 
join train_details b
on a.train_no=b.train_no and a.dest_station_code=b.station_code
) y) g ) e);

#3

select code1,code2,max(distance) from(
select code1,code2,round(6373 * acos( 
                cos( radians(y_dest) ) 
              * cos( radians(y_source) ) 
              * cos( radians(x_source) - radians(x_dest) ) 
              + sin( radians(y_dest) ) 
              * sin( radians(y_source) )
                )) as distance from (
select code as code1,
name as name1,
coordinates_0 as x_source, 
coordinates_1 as y_source,
code_from_b as code2,
name_from_b as name2,
x_from_b as x_dest,
y_from_b as y_dest
from (
select a.*, b.code as code_from_b,b.name as name_from_b,b.coordinates_0 as x_from_b,b.coordinates_1 as y_from_b
from (select * from geo_codes) a 
join (select * from geo_codes) b on substring(a.code,1,1)= substring(b.code,1,1)
and a.code!=b.code ) h)p )q group by substring(code1,1,1);

#4


select train_no,source_station_code,dest_station_code,distance-final from(
select w.train_no,w.source_station_code,w.dest_station_code,distance,
x_dest,x_source,y_dest,y_source,
round(6373 * acos( 
                cos( radians(y_dest) ) 
              * cos( radians(y_source) ) 
              * cos( radians(x_source) - radians(x_dest) ) 
              + sin( radians(y_dest) ) 
              * sin( radians(y_source) )
                )) as final
from (
select o.*,
o1.coordinates_0 as x_source,
o1.coordinates_1 as y_source,
o2.coordinates_0 as x_dest,
o2.coordinates_1 as y_dest from 
(
select train_no,source_station_code,source_station_name,dest_station_code,dest_station_name,distance
from
(
select 
a.train_no,
a.station_code ,
a.source_station_code,
a.depature_time as dep,
a.dest_station_code,
a.source_station_name,
b.arrival_time  as arr,
a.dest_station_name,
b.distance
 from 
(select train_no,station_code,source_station_name,source_station_code,dest_station_code ,dest_station_name,depature_time
from train_details  where seq=1 ) a 
join train_details b
on a.train_no=b.train_no and a.dest_station_code=b.station_code and a.source_station_code<>a.dest_station_code
) y
) o
join
(select coordinates_0,coordinates_1,code from geo_codes ) o1 on o.source_station_code= o1.code
join
(select coordinates_0,coordinates_1,code from geo_codes ) o2 on o.dest_station_code= o2.code ) w)h
order by distance-final desc limit 1;

#5

select * from 
(
select distinct a.name,a.station_code,b.name as name1,b.station_code  as station_code2,
case when length(a.station_code)=4 
			then case when substring(a.station_code,2,1)!=substring(b.station_code,2,1) 
						   and  substring(a.station_code,3,1)!=substring(b.station_code,3,1) 
                           and substring(a.station_code,4,1)!=substring(b.station_code,4,1)  then 3 
			      when (substring(a.station_code,2,1)!=substring(b.station_code,2,1) and substring(a.station_code,3,1)!=substring(b.station_code,3,1))
                              or  (substring(a.station_code,3,1)!=substring(b.station_code,3,1) and substring(a.station_code,4,1)!=substring(b.station_code,4,1))   
                              or  (substring(a.station_code,2,1)!=substring(b.station_code,2,1) and substring(a.station_code,4,1)!=substring(b.station_code,4,1))   then 2
                  when concat(substring(a.station_code,1,1),substring(a.station_code,3,2))= concat(substring(b.station_code,1,1),substring(b.station_code,3,2))
                               or substring(a.station_code,1,3)=substring(b.station_code,1,3)
                                or concat(substring(a.station_code,1,2),substring(a.station_code,4,1)) =concat(substring(b.station_code,1,2),substring(b.station_code,4,1)) 
                                or concat(substring(a.station_code,1,1),substring(a.station_code,2,2))= concat(substring(b.station_code,1,1),substring(b.station_code,2,2)) then 1 end
else case when length(a.station_code)=3
			then case when substring(a.station_code,2,1)!=substring(b.station_code,2,1) and substring(a.station_code,3,1)!=substring(b.station_code,3,1) then 2
                      when (substring(a.station_code,1,2)=substring(b.station_code,1,2))
                            or concat(substring(a.station_code,1,1),substring(a.station_code,3,1))=concat(substring(b.station_code,1,1),substring(b.station_code,3,1)) then 1 end
else case when length(a.station_code)=2
             then case when a.station_code!=b.station_code then 1 end
             
    end end end as Hamming_score
    
 from
 station_codes a join station_codes b
 on substring(a.station_code,1,1)=substring(b.station_code,1,1)
 and a.station_code!=b.station_code
 and length(a.station_code)=length(b.station_code) )o 
 where hamming_score=

(
select min(hamming_score) from 
(
select distinct a.name,a.station_code,b.name as name1,b.station_code  as station_code2,
case when length(a.station_code)=4 
			then case when substring(a.station_code,2,1)!=substring(b.station_code,2,1) 
						   and  substring(a.station_code,3,1)!=substring(b.station_code,3,1) 
                           and substring(a.station_code,4,1)!=substring(b.station_code,4,1)  then 3 
			      when (substring(a.station_code,2,1)!=substring(b.station_code,2,1) and substring(a.station_code,3,1)!=substring(b.station_code,3,1))
                              or  (substring(a.station_code,3,1)!=substring(b.station_code,3,1) and substring(a.station_code,4,1)!=substring(b.station_code,4,1))   
                              or  (substring(a.station_code,2,1)!=substring(b.station_code,2,1) and substring(a.station_code,4,1)!=substring(b.station_code,4,1))   then 2
                  when concat(substring(a.station_code,1,1),substring(a.station_code,3,2))= concat(substring(b.station_code,1,1),substring(b.station_code,3,2))
                               or substring(a.station_code,1,3)=substring(b.station_code,1,3)
                                or concat(substring(a.station_code,1,2),substring(a.station_code,4,1)) =concat(substring(b.station_code,1,2),substring(b.station_code,4,1)) 
                                or concat(substring(a.station_code,1,1),substring(a.station_code,2,2))= concat(substring(b.station_code,1,1),substring(b.station_code,2,2)) then 1 end
else case when length(a.station_code)=3
			then case when substring(a.station_code,2,1)!=substring(b.station_code,2,1) and substring(a.station_code,3,1)!=substring(b.station_code,3,1) then 2
                      when (substring(a.station_code,1,2)=substring(b.station_code,1,2))
                            or concat(substring(a.station_code,1,1),substring(a.station_code,3,1))=concat(substring(b.station_code,1,1),substring(b.station_code,3,1)) then 1 end
else case when length(a.station_code)=2
             then case when a.station_code!=b.station_code then 1 end
             
    end end end as Hamming_score
    
 from
 station_codes a join station_codes b
 on substring(a.station_code,1,1)=substring(b.station_code,1,1)
 and a.station_code!=b.station_code
 and length(a.station_code)=length(b.station_code) )o); 

#6

set @runs_on='fri';
set @source1='UDAIPUR CITY';
set @dest1='JAMMU TAWI';
set @order = 'source_depature_time';
select train_number from high_trains where runs_on like concat('%',substring(upper(@runs_on),1,3),'%')
and source_station like concat('%',upper(@source1),'%') and destination_station like concat('%',upper(@dest1),'%')
order by @order;

#7

select station_code,name from station_codes where length(name)=(select max(length(name)) from station_codes)
and length(station_code)=(select max(length(station_code)) from station_codes);

#8

select count(distinct station_name) as junctions from train_details where station_name like '% JN%';

#9

select train_no from train_details group by 1 having count(station_code)=(
select max(count) from (
select train_no,count(station_code) as count from train_details group by 1 order by 2 desc)a);


#10


select x.station_code,count(x.train_no) from(
select a.train_no,a.station_code from (
select train_no,station_code,time_to_sec(time_format(arrival_time,'%H:%i')) as sec_a from train_details)a 
left join (select train_no,station_code,time_to_sec(time_format(arrival_time,'%H:%i')) as sec_b from train_details)b 
on a.station_code=b.station_code and  a.train_no!=b.train_no and 
case when sec_a>sec_b then sec_a-sec_b<=600
else sec_b-sec_a<=600 end
) x group by 1;














                
