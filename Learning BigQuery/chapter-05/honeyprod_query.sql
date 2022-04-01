SELECT state, year, totalprod, yieldpercol, prodvalue
FROM `brioche-pudding.loony_university.honey_production_usa`
WHERE state = @state
AND year = @year