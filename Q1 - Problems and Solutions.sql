-- 10.1 Join table PEOPLE and ADDRESS, but keep only one address information for each person (we don't mind which record we take for each person). 
    -- i.e., the joined table should have the same number of rows as table PEOPLE
	--OPTION 1
SELECT P.ID, P.NAME, TEMP.ADDRESS
FROM PEOPLE P
JOIN
(
SELECT A.ID, MIN(A.ADDRESS) AS ADDRESS FROM ADDRESS A
GROUP BY ID
)
AS TEMP ON P.ID = TEMP.ID;

--OPTION 2
SELECT PEOPLE.ID, PEOPLE.NAME, MAX(ADDRESS) AS ADDRESS FROM ADDRESS JOIN PEOPLE ON ADDRESS.id = PEOPLE.ID
GROUP BY PEOPLE.ID, PEOPLE.NAME;



-- 10.2 Join table PEOPLE and ADDRESS, but ONLY keep the LATEST address information for each person. 
    -- i.e., the joined table should have the same number of rows as table PEOPLE

--OPTION 1
SELECT P.ID, P.NAME, TEMP.T
FROM PEOPLE P
JOIN
(
SELECT A.ID, MAX(A.UPDATEDATE) AS T FROM ADDRESS A
GROUP BY ID
)
AS TEMP ON P.ID = TEMP.ID;

--OPTION 2
SELECT PEOPLE.NAME, PEOPLE.ID, MAX(UPDATEDATE) AS UPDATEDATE FROM ADDRESS JOIN PEOPLE ON ADDRESS.id = PEOPLE.ID
GROUP BY PEOPLE.ID, PEOPLE.NAME;


with PAT as (

select name, Address.*, ROW_NUMBER() OVER(PARTITION BY PEOPLE.id ORDER BY people.id) AS ROWNUMBER FROM PEOPLE JOIN ADDRESS ON ADDRESS.ID = PEOPLE.ID

)
Select * FROM PAT WHERE ROWNUMBER > 1;