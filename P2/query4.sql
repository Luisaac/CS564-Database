create view v1
as
select s1.weekdate, sum(weeklysales) AS weeksale_sum
from sales s1, holidays h1
where (s1.weekdate = h1. weekdate
	AND h1.isholiday = 'FALSE')
group by s1.weekdate;

create view v2
as
select avg(weeksale_sum) as average
from(
select sum(weeklysales) AS weeksale_sum
from sales s2, holidays h2
where s2.weekdate = h2.weekdate
	AND h2.isholiday = 'TRUE'
group by s2.weekdate
) as week_sum;

select count(weekdate)
from v1, v2
where v1.weeksale_sum > v2.average;
