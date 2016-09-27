Create view v6
as 
Select store, dept, extract(month from weekdate) as month, extract(year from weekdate) as year,sum(weeklysales)
From sales
Group by store,dept,month, year;

select store
from stores
except
select distinct store
from v6 v
where exists(select year from v6 where year = '2010' AND store = v.store)
 	AND exists(select year from v6 where year = '2011' AND store = v.store)
AND exists(select year from v6 where year = '2012' AND store = v.store)
AND v.sum<=0;
