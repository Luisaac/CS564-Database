Select quarA.year as yr, quarA.quar as qtr, quarA.sumA as store_a_sales, quarB.sumB as store_b_sales
From
(
Select extract(year from quarTab.weekdate) as year,  quarTab.quar, sum(quarTab.weeklysales) as sumA
From(
Select st.store, sa.weekdate, sa.weeklysales, 
Case when extract(month from weekdate) = 1 then '1'
	when extract(month from weekdate) = 2 then '1'
when extract(month from weekdate) = 3 then '1'
	when extract(month from weekdate) = 4 then '2'
	when extract(month from weekdate) = 5 then '2'
	when extract(month from weekdate) = 6 then '2'
	when extract(month from weekdate) = 7 then '3'
	when extract(month from weekdate) = 8 then '3'
	when extract(month from weekdate) = 9 then '3'
	when extract(month from weekdate) = 10 then '4'
	when extract(month from weekdate) = 11 then '4'
	when extract(month from weekdate) = 12 then '4' end as quar
from(
(Select *
From stores) as st
Inner join
(select *
From sales) as sa
On st.store = sa.store
)
Where st.type = 'A' 
) as quarTab
Group by year, quar
UNION ALL
Select extract(year from quarTab.weekdate) as year, Null, sum(quarTab.weeklysales) as sumA
From(
Select st.store, sa.weekdate, sa.weeklysales, 
Case when extract(month from weekdate) = 1 then '1'
	when extract(month from weekdate) = 2 then '1'
when extract(month from weekdate) = 3 then '1'
	when extract(month from weekdate) = 4 then '2'
	when extract(month from weekdate) = 5 then '2'
	when extract(month from weekdate) = 6 then '2'
	when extract(month from weekdate) = 7 then '3'
	when extract(month from weekdate) = 8 then '3'
	when extract(month from weekdate) = 9 then '3'
	when extract(month from weekdate) = 10 then '4'
	when extract(month from weekdate) = 11 then '4'
	when extract(month from weekdate) = 12 then '4' end as quar

from(
(Select *
From stores) as st
Inner join
(select *
From sales) as sa
On st.store = sa.store
)
Where st.type = 'A' 
) as quarTab
Group by year
order by year asc, quar asc
)as quarA
Inner join
(
Select extract(year from quarTab.weekdate) as year,  quarTab.quar, sum(quarTab.weeklysales) as sumB
From(
Select st.store, sa.weekdate, sa.weeklysales, 
Case when extract(month from weekdate) = 1 then '1'
	when extract(month from weekdate) = 2 then '1'
when extract(month from weekdate) = 3 then '1'
	when extract(month from weekdate) = 4 then '2'
	when extract(month from weekdate) = 5 then '2'
	when extract(month from weekdate) = 6 then '2'
	when extract(month from weekdate) = 7 then '3'
	when extract(month from weekdate) = 8 then '3'
	when extract(month from weekdate) = 9 then '3'
	when extract(month from weekdate) = 10 then '4'
	when extract(month from weekdate) = 11 then '4'
	when extract(month from weekdate) = 12 then '4' end as quar
from(
(Select *
From stores) as st
Inner join
(select *
From sales) as sa
On st.store = sa.store
)
Where st.type = 'B' 
) as quarTab
Group by year, quar
UNION ALL
Select extract(year from quarTab.weekdate) as year, Null, sum(quarTab.weeklysales) as sumB
From(
Select st.store, sa.weekdate, sa.weeklysales, 
Case when extract(month from weekdate) = 1 then '1'
	when extract(month from weekdate) = 2 then '1'
when extract(month from weekdate) = 3 then '1'
	when extract(month from weekdate) = 4 then '2'
	when extract(month from weekdate) = 5 then '2'
	when extract(month from weekdate) = 6 then '2'
	when extract(month from weekdate) = 7 then '3'
	when extract(month from weekdate) = 8 then '3'
	when extract(month from weekdate) = 9 then '3'
	when extract(month from weekdate) = 10 then '4'
	when extract(month from weekdate) = 11 then '4'
	when extract(month from weekdate) = 12 then '4' end as quar

from(
(Select *
From stores) as st
Inner join
(select *
From sales) as sa
On st.store = sa.store
)
Where st.type = 'B' 
) as quarTab
Group by year
order by year asc, quar asc
)as quarB
on(
(quarA.year = quarB.year AND quarA.quar = quarB.quar) OR
(quarA.year = quarB.year AND quarA.quar is null AND quarB.quar is null)
);

