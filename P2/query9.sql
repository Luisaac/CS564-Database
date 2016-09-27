Select dept, tenDept.year as yr, tenDept.month as mo, SUM(tenDept.monSale) OVER(partition by dept ORDER BY dept asc, year asc, month asc) AS cumulative_sales
from(
Select dept, extract(month from weekdate) as month, extract(year from weekdate) as year, sum(WeeklySales) as monSale
From sales
Where dept IN (
Select dept
from(
select dept, sum(weeklysales/size) AS norm_sales, rank()over(order by (sum(weeklysales/size)) desc) as sale_rank
from stores st, sales sa
Where st.store = sa.store 
Group by dept
)AS joined
Where sale_rank <=10
) 
Group by dept, month, year
order by dept asc, year asc, month asc
) as tenDept;
