create view saleview
as
select store, sum(weeklysales) AS sum_sales
	from sales s, holidays h
	where s.weekdate = h.weekdate
	AND h.isholiday = 'TRUE'
	group by store;
select store, sum_sales
from saleview
where (sum_sales = (select max(sum_sales)
	from saleview)
	OR sum_sales = (select min(sum_sales)
	from saleview)
	);
