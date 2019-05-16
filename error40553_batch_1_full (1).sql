use sql_hk_2018;


#1


select l.* from
(select a.*,case when substring(lower(trim(zone)),5,4)='nort' then 'North'
when substring(lower(trim(zone)),5,4)='sout' then 'South'
           when substring(lower(trim(zone)),5,4)='east' then 'East'
           when substring(lower(trim(zone)),5,4)='west' then 'West'
           when substring(lower(trim(zone)),5,4)='cent' then 'Central'
           when substring(lower(trim(zone)),5,4)='metr' then 'Metro'
           else 'Others' end as Zone1
            from zone_stats a) l 
order by FIELD(l.Zone1,'East','West','North','South','Central','Others','Metro');

#2

select trim(zone) from zone_stats where route_length =(select max(route_length) from zone_stats) 
and trim(zone) is not null;

#3

select trim(zone) from zone_stats where trim(zone) is not null group by 1 having sum(no_of_stations)= (select count from(
select trim(zone),sum(no_of_stations) as count from zone_stats group by 1 order by 2 desc limit 1)a);

#4

select trim(zone) from zone_stats where zone is not null group by 1 having sum(cast(replace(SUBSTRING_INDEX (revenue,"million",1),",","") as UNSIGNED))=(
select sum from (
select trim(zone),sum(cast(replace(SUBSTRING_INDEX (revenue,"million",1),",","") as UNSIGNED)) as sum from zone_stats group by 1 order by 2 limit 4,1)a);

   

#5

select distinct trim(headquarters) from zone_stats group by 1 having count(trim(zone))=(
select zone_count from(
(select trim(headquarters),count(trim(zone)) as zone_count from zone_stats group by 1 order by 2 desc limit 1)a));



#6

select trim(zone) from zone_stats where (lower(division) like '%chennai%' or lower(division) like '%mumbai%');



