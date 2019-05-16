use sql_hk_2018;

#1
select distinct t.train_no from 
(
select train_no,source_station_code,dest_station_code,
case when dep_in_sec>arr_in_sec then (86400-dep_in_sec)+arr_in_sec
else arr_in_sec-dep_in_sec end as journey_time_sec
from
(select train_no,source_station_code,dest_station_code,
time_to_sec(time_format(dep,'%H:%i')) as dep_in_sec,time_to_sec(time_format(arr,'%H:%i'))  as arr_in_sec
from
(
select 
a.train_no,
a.station_code ,
a.source_station_code,
a.depature_time as dep,
a.dest_station_code,
b.arrival_time  as arr
 from 
(select train_no,station_code,source_station_code,dest_station_code ,depature_time
from train_details  where seq=1 ) a 
join train_details b
on a.train_no=b.train_no and a.dest_station_code=b.station_code
) y) g

) t

JOIN

(
select train_no,source_station_code,dest_station_code,
case when dep_in_sec>arr_in_sec then (86400-dep_in_sec)+arr_in_sec
else arr_in_sec-dep_in_sec end as journey_time_sec
from
(select train_no,source_station_code,dest_station_code,
time_to_sec(time_format(dep,'%H:%i')) as dep_in_sec,time_to_sec(time_format(arr,'%H:%i'))  as arr_in_sec
from
(
select 
a.train_no,
a.station_code ,
a.source_station_code,
a.depature_time as dep,
a.dest_station_code,
b.arrival_time  as arr
 from 
(select train_no,station_code,source_station_code,dest_station_code ,depature_time
from train_details  where seq=1 ) a 
join train_details b
on a.train_no=b.train_no and a.dest_station_code=b.station_code
) y) g
) t1
on t.source_station_code=t1.dest_station_code
and t.dest_station_code=t1.source_station_code
and t.journey_time_sec<>t1.journey_time_sec;


#2

select y.*,distance_from2/(journey_time_sec/3600) as speed  from 

(
select train_no_from1,dep,arr,
case when dep_in_sec>arr_in_sec then (86400-dep_in_sec)+arr_in_sec
else arr_in_sec-dep_in_sec end as journey_time_sec,distance_from2

 from 

(
select train_no_from1,time_format(dep_from1,'%H:%i') as dep,
TIME_TO_SEC(time_format(dep_from1,'%H:%i')) as dep_in_sec, time_format(arr_from2,'%H:%i') as arr,
TIME_TO_SEC(time_format(arr_from2,'%H:%i')) as arr_in_sec,distance_from2

from
(
select a.train_no as train_no_from1,a.seq as seq_from1 ,a.arrival_time as arr_from1,a.depature_time as dep_from1,a.dest_station_code as dest_from1,
b.train_no as  train_no_from2,b.seq  as seq_from2,b.arrival_time as arr_from2,b.depature_time as dep_from2,b.station_code as station_code_from2,b.distance as distance_from2
 from 
(
select * from train_details where train_no in(
select distinct train_no from train_details where lower(source_station_name) like '%delhi%' 
and lower(dest_station_name)  like '%howrah%' ) and seq=1
) a
join
(
select * from train_details where train_no in(
select distinct train_no from train_details where lower(source_station_name) like '%delhi%' 
and lower(dest_station_name)  like '%howrah%' )) b
on a.train_no=b.train_no and a.dest_station_code=b.station_code
) j1 ) t) y

where distance_from2/(journey_time_sec/3600)=

(

select max(distance_from2/(journey_time_sec/3600) )  from 

(
select train_no_from1,dep,arr,
case when dep_in_sec>arr_in_sec then (86400-dep_in_sec)+arr_in_sec
else arr_in_sec-dep_in_sec end as journey_time_sec,distance_from2

 from 

(
select train_no_from1,time_format(dep_from1,'%H:%i') as dep,
TIME_TO_SEC(time_format(dep_from1,'%H:%i')) as dep_in_sec, time_format(arr_from2,'%H:%i') as arr,
TIME_TO_SEC(time_format(arr_from2,'%H:%i')) as arr_in_sec,distance_from2

from
(
select a.train_no as train_no_from1,a.seq as seq_from1 ,a.arrival_time as arr_from1,a.depature_time as dep_from1,a.dest_station_code as dest_from1,
b.train_no as  train_no_from2,b.seq  as seq_from2,b.arrival_time as arr_from2,b.depature_time as dep_from2,b.station_code as station_code_from2,b.distance as distance_from2
 from 
(
select * from train_details where train_no in(
select distinct train_no from train_details where lower(source_station_name) like '%delhi%' 
and lower(dest_station_name)  like '%howrah%' ) and seq=1
) a
join
(
select * from train_details where train_no in(
select distinct train_no from train_details where lower(source_station_name) like '%delhi%' 
and lower(dest_station_name)  like '%howrah%' )) b
on a.train_no=b.train_no and a.dest_station_code=b.station_code
) j1 ) t) y

);







#3


select x.runs_on from(
select runs_on,
case when time_format(destination_arrival_time,'%H:%i') > time_format(source_depature_time,'%H:%i') then timediff(time_format(destination_arrival_time,'%H:%i'),time_format(source_depature_time,'%H:%i'))  
else addtime(timediff(time_format(destination_arrival_time,'%H:%i'),time_format(source_depature_time,'%H:%i')),"24:00")
end as time1 from high_trains 
where lower(source_station) like '%delhi%' and lower(destination_station) like '%howrah%' and time_format(source_depature_time,'%H:%i') < time_format('12:00','%H:%i'))x
where time1=(select min(time1) from (select runs_on,
case when time_format(destination_arrival_time,'%H:%i') > time_format(source_depature_time,'%H:%i') then timediff(time_format(destination_arrival_time,'%H:%i'),time_format(source_depature_time,'%H:%i'))  
else addtime(timediff(time_format(destination_arrival_time,'%H:%i'),time_format(source_depature_time,'%H:%i')),"24:00")
end as time1 from high_trains 
where lower(source_station) like '%delhi%' and lower(destination_station) like '%howrah%')h);




#4

select distinct substring_index(SUBSTRING_INDEX(name," ",-2),"Express" ,1) as category from high_trains;



#5

select category,count(distinct train_number) as count from(
select substring_index(SUBSTRING_INDEX(name," ",-2),"Express" ,1) as category,train_number,LENGTH(runs_on) - LENGTH(REPLACE(runs_on, ',', ''))+1 as length 
from high_trains)x where length >4 group by 1;



#6

select category,count(distinct train_number)/(select count(*) from high_trains) as ratio from(
select substring_index(SUBSTRING_INDEX(name," ",-2),"Express" ,1) as category,train_number,LENGTH(runs_on) - LENGTH(REPLACE(runs_on, ',', ''))+1 as length 
from high_trains)x where length >3 group by 1;


#7

SELECT distinct t.*
FROM (select substring_index(SUBSTRING_INDEX(name," ",-2),"Express" ,1) as category,source_station,count(*) as count
from high_trains group by 1,2) t
inner JOIN (SELECT x.category, MAX(x.count) AS max_count
FROM (select substring_index(SUBSTRING_INDEX(name," ",-2),"Express" ,1) as category,source_station,count(*) as count
from high_trains group by 1,2)x
GROUP BY category) q
ON t.category = q.category AND t.count = q.max_count;











