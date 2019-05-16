select * from fares_by_class;

select distinct train_type from fares_by_distance;

#1
select train_type,seat_type,min(charge) from fares_by_class group by 1,2;


#5
select * from (
select station_code,count(train_no) as count_train from train_details
 where source_station_code!=station_code and dest_station_code!=station_code
and time_to_sec(time_format(depature_time,'%H:%i')) - time_to_sec(time_format(arrival_time,'%H:%i'))>0
group by station_code) h1
where count_train= (select max(count_train) from  (
select station_code,count(train_no) as count_train from train_details
 where source_station_code!=station_code and dest_station_code!=station_code
and time_to_sec(time_format(depature_time,'%H:%i')) - time_to_sec(time_format(arrival_time,'%H:%i'))>0
group by station_code) h );


#8
#1)
select train_number,name,
((time_to_sec(time_format(source_depature_time,'%H:%i'))-
time_to_sec(time_format(destination_arrival_time,'%H:%i')) )/3600 ) Time_in_hrs
from high_trains 
where lower(name) like '%rajdhani%';

#2) Partially done


select g1.*,cast(substring_index(g2.distance,'-',1) as unsigned) as start1, cast(substring_index(g2.distance,'-',-1) as unsigned) as start2,
g2.fare
from (
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
from train_details  where seq=1  and train_name like '%RAJ%') a 
join (select * from train_details where train_name like '%RAJ%') b
on a.train_no=b.train_no and a.dest_station_code=b.station_code
) y) g  )g1
join 
fares_by_distance g2 where train_type='Rajdhani';



#10

#partial 


select train_no,count(station_code) as high_density_stations from (
select * from train_details where station_code in (
select distinct station_code from station_codes where trains_passing >=80) and train_name like '%RAJ%' and 
(source_station_name like '%NEW DELHI%' or source_station_name like '%HAZRAT NIZAMUDDIN JN%'))x group by 1;

select h.train_no,i.station_name from (
select train_no,max(trains_passing) as max from (
select distinct x.*,b.trains_passing from(
select * from train_details where station_code in (select distinct station_code from station_codes where trains_passing >=80) and train_name like '%RAJ%' and 
(source_station_name like '%NEW DELHI%' or source_station_name like '%HAZRAT NIZAMUDDIN JN%'))x
left join station_codes as b on x.station_code=b.station_code)q group by 1)h
left join train_details as i on h.train_no=i.train_no and h.max=i.trains_passing;

