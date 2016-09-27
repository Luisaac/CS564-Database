select distinct store
from temporaldata t
where (exists(select store
from temporaldata
where unemploymentrate >10
AND t.store = store)
AND not exists(select store
from temporaldata
where fuelprice >4
AND t.store = store)
);
