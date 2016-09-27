Create view v7
as
Select corr(weeklysales, temperature) as corrT,
 corr(weeklysales, cpi) as corrC,
 corr(weeklysales, fuelprice) as corrF,
 corr(weeklysales, unemploymentrate) as corrU,
Case  when corr(weeklysales, temperature)>=0 then '+'
	When corr(weeklysales, temperature)<0 then '-' end as signT,
Case  when corr(weeklysales, cpi)>=0 then '+'
	When corr(weeklysales, cpi)<0 then '-' end as signC,
Case  when corr(weeklysales, fuelprice)>=0 then '+'
	When corr(weeklysales, fuelprice)<0 then '-' end as signF,
Case  when corr(weeklysales, unemploymentrate)>=0 then '+'
	When corr(weeklysales, unemploymentrate)<0 then '-' end as signU
From temporaldata t, sales s
Where t.store = s.store and t.weekdate = s.weekdate;

Create table t7
(Attribute varchar(20),
CorrSign char(1),
CorrValue float);

Insert into t7 values('Temperature');
Insert into t7 values('Fuelprice');
Insert into t7 values('Cpi');
Insert into t7 values('Unemploymentrate');

update t7 
set corrsign = (select signT from v7), corrvalue = (select corrT from v7) 
where attribute = 'Temperature';

update t7 
set corrsign = (select signC from v7), corrvalue = (select corrC from v7) 
where attribute = 'Cpi';

update t7 
set corrsign = (select signU from v7), corrvalue = (select corrU from v7) 
where attribute = 'Unemploymentrate';

update t7 
set corrsign = (select signF from v7), corrvalue = (select corrF from v7) 
where attribute = 'Fuelprice';

Select * from t7;
