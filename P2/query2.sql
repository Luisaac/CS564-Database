Select dept, norm_sales
from(
select dept, sum(weeklysales/size) AS norm_sales, rank()over(order by (sum(weeklysales/size)) desc) as sale_rank
from stores st, sales sa
Where st.store = sa.store 
Group by dept
)AS joined
Where sale_rank <=10;
