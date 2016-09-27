select case when  extract(month from weekdate) = 1 then 'Jan'
	When extract(month from weekdate) = 2 then 'Feb'
	When extract(month from weekdate) = 3 then 'Mar'
	When extract(month from weekdate) = 4 then 'Apr'
	When extract(month from weekdate) = 5 then 'May'
	When extract(month from weekdate) = 6 then 'Jun'
	When extract(month from weekdate) = 7 then 'Jul'
	When extract(month from weekdate) = 8 then 'Aug'
	When extract(month from weekdate) = 9 then 'Sept'
	When extract(month from weekdate) = 10 then 'Oct'
	When extract(month from weekdate) = 11 then 'Nov'
	When extract(month from weekdate) = 12 then 'Dec' end AS month,type, sum(weeklysales) as sum
from sales sa, stores st
where sa.store = st.store
group by st.type,  extract(month from weekdate)
order by extract(month from weekdate), type;
