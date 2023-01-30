
/*Could you please pull data on how many of our website visitors come back for another session?2014 to date is good-----email(november 01,2014*/

create view m1 as 
select * from website_session
where created_at>'2014-01-01' and created_at<'2014-11-01'

create view m2 as
select user_id,count( distinct website_session_id)-1 as repeat_time from m1
group by user_id



select repeat_time,count(user_id) amount from m2
group by repeat_time
order by repeat_time
/*Could you help me understand the minimum,maximum,and average time between the first and second session for cusomers who do come back?analyzing 2014 to date is good.-------email(november 03,2014)*/

create view t1 as
select website_session_id,created_at,user_id,is_repeat_session from website_session
where created_at>'2014-01-01' and created_at<'2014-11-03'

create view t2 as
select user_id,count(distinct website_session_id)-1 as repeat_time from t1
group by user_id
having count(distinct website_session_id)-1>=1


create view t3 as
select t2.user_id,t2.repeat_time,website_session_id,created_at from t2 
left join t1  
on t2.user_id=t1.user_id



create view first_visit as 
select user_id,min(created_at) as first_visit from t3 
group by  user_id


select * from t3
select * from first_visit


create view t4 as 
select t3.user_id,repeat_time,website_session_id,created_at,first_visit from t3
left join first_visit
on t3.user_id=first_visit.user_id


create view t5 as 
select user_id,min(created_at) as second_visit from t4 
where created_at>first_visit
group by user_id

create view t6 as
select t4.user_id,first_visit,second_visit from t4
left join t5
on t4.user_id=t5.user_id


select * from t6

select min(DATEDIFF(day,first_visit,second_visit)),
max(DATEDIFF(day,first_visit,second_visit)),
avg(DATEDIFF(day,first_visit,second_visit))
from t6
/*Comparing new vs.repeat session by channel would be eally valuable ,if you are able to pull it !2014 to date is great.*/


create view s1 as
select case when is_repeat_session>0 then 'reapeat' else 'non-first' end as view_time,
       (case  when utm_source is null  and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then 'organic-search'
       when utm_campaign='nonbrand' then 'paid_nonbrand'
	   when utm_campaign='brand' then 'paid_brand'
	   when utm_source='socialbook' then 'paid_social'
	    when utm_source is null and  http_referer is null then 'direct_type_in'
	   else 'other'
       end) as channel,
	   website_session_id

from website_session
where created_at>'2014-01-01'  and created_at<'2014-11-05'


select channel,view_time,count(website_session_id) from s1
group by channel,view_time


/* I would love to do a comparison of conversion rates and revenue per session for repeat sessions vs new sessions,Lets continue using data from 2014,year to date.--------email(November 08,2014)*/
create view s2 as
select website_session_id,case when is_repeat_session>0 then 'reapeat' else 'non-first' end as view_time from website_session
where created_at>'2014-01-01'  and created_at<'2014-11-08'

create view s3 as
select s2.website_session_id,view_time,order_id,price_usd from s2
left join orders
on s2.website_session_id=orders.website_session_id

select view_time,count(website_session_id) as session ,count(order_id) as order_amount,sum(price_usd) as revenue from s3
group by view_time

