use sql_hk_2018;

desc station_codes;

#1

select station_code from station_codes group by 1 having sum(cast(trains_passing as unsigned))=(
select sum from(
select station_code,sum(cast(trains_passing as unsigned)) as sum from station_codes group by 1 order by 2 desc limit 1)a);

#2

select sum(cast(trains_passing as unsigned)) from station_codes where lower(name) like '%bangalore%';

#3

select trim(location),count(trim(station_code)) from station_codes group by 1 order by 2;

#Since station_code is primary key every value will be 1

#4

select distinct a.temp from (
select station_code,substring('TAKKOLAM',ceil(rand() * 8),ceil(rand() * 8)) as temp from station_codes)a
join station_codes as b
on b.station_code!=a.temp limit 1;

#5

select a.station_code ,a.name,count(distinct b.train_no) as trains_passing from 
(select station_code,name from station_codes where trains_passing ='') a
left join
train_details b on trim(a.station_code)=trim(b.station_code)
group by a.station_code;


#If update query is required then

UPDATE station_codes as a
       left JOIN (select station_code,count(distinct train_no) as trains_passing from train_details group by 1) as b
       ON a.station_code=b.station_code
SET    a.trains_passing = b.trains_passing where a.trains_passing='';



#6

select * from(
select * from (
select distinct trimmed,station_code from (
select concat(substring(station_code,1,1),substring(station_code,3,2)) as trimmed,station_code from station_codes where length(station_code)=4
  union 
select  concat(substring(station_code,1,2),substring(station_code,4,1)) as trimmed,station_code from station_codes where length(station_code)=4
 union 
select  concat(substring(station_code,1,3)) as trimmed ,station_code from station_codes where length(station_code)=4) k
where trimmed not in 
(select station_code from station_codes) ) u)h group by station_code;


#7
select station_code from (
select 
STATION_CODE ,

 SUM(CASE WHEN LOCATE('A' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('B' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('C' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('D' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('E' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('F' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('G' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('H' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('I' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('J' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('K' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('L' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('M' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('N' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('O' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('P' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('Q' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('R' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('S' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('T' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('U' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('V' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('W' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('X' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('Y' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('Z' , STATION_CODE) > 0 THEN 1 ELSE 0 END) AS occurence
from station_codes group by STATION_CODE ) k
where occurence = 
(
select max(occurence) from (
select 
STATION_CODE ,

 SUM(CASE WHEN LOCATE('A' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('B' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('C' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('D' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('E' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('F' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('G' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('H' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('I' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('J' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('K' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('L' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('M' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('N' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('O' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('P' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('Q' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('R' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('S' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('T' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('U' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('V' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('W' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('X' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('Y' , STATION_CODE) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('Z' , STATION_CODE) > 0 THEN 1 ELSE 0 END) AS occurence
from station_codes group by STATION_CODE ) k1

)

;


#8

select STATION_CODE,occurence/len  from(
select 
STATION_CODE ,

 SUM(CASE WHEN LOCATE('A' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('B' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('C' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('D' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('E' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('F' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('G' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('H' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('I' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('J' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('K' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('L' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('M' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('N' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('O' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('P' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('Q' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('R' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('S' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('T' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('U' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('V' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('W' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('X' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('Y' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END)
+ SUM(CASE WHEN LOCATE('Z' , trim(STATION_CODE)) > 0 THEN 1 ELSE 0 END) AS occurence, length(trim(STATION_CODE)) as len
from station_codes group by trim(STATION_CODE) )k where occurence=len;




#9

select a.*,b.trains_passing from (
(select distinct a.station_code,b.distance-a.distance from train_details as a join train_details as b on (a.seq=(b.seq-1)
and b.station_name='NEW DELHI' and a.train_no=b.train_no and (b.distance-a.distance)<=50))
union
(select distinct b.station_code,b.distance-a.distance from train_details as a join train_details as b on (a.seq=(b.seq-1)
and a.station_name='NEW DELHI' and a.train_no=b.train_no and (b.distance-a.distance)<=50)))a
left join station_codes b on a.station_code=b.station_code where b.trains_passing > 100;



#10



select avg(distance/time_in_hrs) avg_speed_km_per_Hr from 
(
select 
train_number,
TIME_TO_SEC(case when arr > dep then timediff(arr,dep) else addtime(timediff(arr,dep),'24:00'))/3600 as time_in_hrs,
TIME_TO_SEC(timediff(arr,dep)) ,
dep,arr,distance
from 
(
select 
a.train_number,
time_format(a.source_depature_time,'%H:%i') as dep ,
time_format(a.destination_arrival_time,'%H:%i') as arr,
b.distance
from 
(select * from high_trains where lower(name) like '%shatabdi%') a
join
train_details b on a.train_number=b.train_no and a.destination_station=b.station_name 
) l
)p
;


