Select selectTab.dept,selectTab.avgPor as avg
from(
Select dept, avg(porTab.por) as avgPor
from(
SELECT dept, (deptSale.deptSum/storeSale.storeSum) as por 
FROM
(Select store, dept, sum(WeeklySales) as deptSum
From sales
Group by store, dept) AS deptSale
INNER JOIN
(Select store, sum(WeeklySales) as storeSum
From sales
Group by store) AS storeSale
ON deptSale.store = storeSale.store) as porTab
Group by dept
)as selectTab
Where selectTab.dept IN (
SELECT dept FROM (
SELECT dept, deptSale.deptSum, storeSale.storeSum, (deptSale.deptSum/storeSale.storeSum) as por FROM
(Select store, dept, sum(WeeklySales) as deptSum
From sales
Group by store, dept) AS deptSale
INNER JOIN
(Select store, sum(WeeklySales) as storeSum
From sales
Group by store) AS storeSale
ON deptSale.store = storeSale.store
) as salePor
WHERE por>=0.05
Group by dept
Having COUNT(dept)>=3
);
