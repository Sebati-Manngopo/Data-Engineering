-- 8.1 Obtain the names of all physicians that have performed a medical procedure they have never been certified to perform.

--OPTION 1

SELECT P.NAME AS PHYSICIAN_NAME FROM PHYSICIAN P 
WHERE P.EMPLOYEEID IN (SELECT U.PHYSICIAN FROM UNDERGOES U
WHERE NOT EXISTS (SELECT T.PHYSICIAN FROM TRAINED_IN T WHERE U.PROCEDURES = T.TREATMENT AND U.PHYSICIAN = T.PHYSICIAN));

--OPTION 2

SELECT P.NAME AS PHYSICIAN_NAME
FROM PHYSICIAN P JOIN PATIENT PP ON P.EMPLOYEEID = PP.PCP
JOIN UNDERGOES U ON U.PATIENT = PP.SSN JOIN PROCEDURES PRO ON PRO.CODE = U.PROCEDURES
WHERE NOT EXISTS (SELECT T.PHYSICIAN FROM TRAINED_IN T WHERE U.PROCEDURES = T.TREATMENT AND U.PHYSICIAN = T.PHYSICIAN);

-- 8.2 Same as the previous query, but include the following information in the results: Physician name, name of procedure, date when the procedure was carried out, name of the patient the procedure was carried out on.

SELECT P.NAME AS PHYSICIAN_NAME, PP.NAME AS PATIENT_NAME, PRO.Name AS PROCEDURE_NAME, U.DATEUNDERGOES AS PROCEDURE_DATE
FROM PHYSICIAN P JOIN PATIENT PP ON P.EMPLOYEEID = PP.PCP
JOIN UNDERGOES U ON U.PATIENT = PP.SSN JOIN PROCEDURES PRO ON PRO.CODE = U.PROCEDURES
WHERE NOT EXISTS (SELECT T.PHYSICIAN FROM TRAINED_IN T WHERE U.PROCEDURES = T.TREATMENT AND U.PHYSICIAN = T.PHYSICIAN);

-- 8.3 Obtain the names of all physicians that have performed a medical procedure that they are certified to perform, but such that the procedure was done at a date (Undergoes.Date) after the physician's certification expired (Trained_In.CertificationExpires).

--OPTION 1

SELECT P.NAME AS PHYSICIAN_NAME FROM PHYSICIAN P 
WHERE P.EMPLOYEEID IN (SELECT U.PHYSICIAN FROM UNDERGOES U
WHERE EXISTS (SELECT T.PHYSICIAN FROM TRAINED_IN T 
WHERE U.PROCEDURES = T.TREATMENT AND U.PHYSICIAN = T.PHYSICIAN AND T.CERTIFICATIONEXPIRES < U.DATEUNDERGOES ));

--OPTION 2

SELECT P.NAME AS PHYSICIAN_NAME
FROM PHYSICIAN P JOIN UNDERGOES U ON P.EMPLOYEEID = U.PHYSICIAN
WHERE EXISTS (SELECT T.PHYSICIAN FROM TRAINED_IN T 
WHERE U.PROCEDURES = T.TREATMENT AND U.PHYSICIAN = T.PHYSICIAN AND T.CERTIFICATIONEXPIRES < U.DATEUNDERGOES);

---OPTION 3

SELECT P.NAME AS PHYSICIAN_NAME FROM PHYSICIAN P 
WHERE P.EMPLOYEEID IN (SELECT U.PHYSICIAN FROM UNDERGOES U, TRAINED_IN T 
WHERE T.PHYSICIAN = U.PHYSICIAN AND T.CERTIFICATIONEXPIRES < U.DATEUNDERGOES)

-- 8.4 Same as the previous query, but include the following information in the results:
--Physician name, name of procedure, date when the procedure was carried out
--name of the patient the procedure was carried out on, and date when the certification expired.

--SELECT * FROM PHYSICIAN RIGHT JOIN Undergoes ON EmployeeID = Physician JOIN PATIENT ON Patient = PATIENT.SSN

SELECT DISTINCT P.NAME AS PHYSICIAN_NAME, 
PRO.NAME AS PROCEDURE_NAME, U.DATEUNDERGOES, PAT.NAME AS PATIENT_NAME,
T.CERTIFICATIONEXPIRES AS EXPIRY_DATE_OF_CERT FROM PHYSICIAN P 
JOIN UNDERGOES U ON P.EMPLOYEEID = U.PHYSICIAN
JOIN PATIENT PAT ON U.PATIENT = PAT.SSN
JOIN PROCEDURES PRO ON U.PROCEDURES = PRO.CODE
JOIN TRAINED_IN T ON P.EMPLOYEEID = T.PHYSICIAN
WHERE U.PHYSICIAN = P.EMPLOYEEID AND T.CERTIFICATIONEXPIRES < U.DATEUNDERGOES


-- 8.5 Obtain the information for appointments where a patient met with a physician other than his/her primary care physician.
--Show the following information: Patient name, physician name, nurse name (if any), start and end time of appointment,
--examination room, and the name of the patient's primary care physician. - NEEDS A LITTLE FIX TO BE 100% CORRECT

WITH AB as (SELECT DISTINCT PAT.NAME AS PATIENT_NAME, P.NAME AS PRIMARY_PHYSICIAN, P.Name, N.Name AS NURSE_NAME, 
AP.STARTDATE, AP.ENDDATE FROM PATIENT PAT 
JOIN APPOINTMENT AP ON PAT.SSN = AP.PATIENT
LEFT JOIN NURSE N ON N.EMPLOYEEID = AP.PREPNURSE
LEFT JOIN PHYSICIAN P ON AP.PHYSICIAN = P.EMPLOYEEID
WHERE PAT.PCP != AP.Physician),

av as (select ph.name from Physician ph where EmployeeID in (select Physician from Appointment where physician not in (select pcp from patient)))

SELECT * from ab, av
where av.name != PRIMARY_PHYSICIAN

select * from patient
select * from Physician
select * from Appointment


-- 8.6 The Patient field in Undergoes is redundant, since we can obtain it from the Stay table.
--There are no constraints in force to prevent inconsistencies between these two tables.
--More specifically, the Undergoes table may include a row where the patient ID does not
--match the one we would obtain from the Stay table through the Undergoes.
--Stay foreign key. Select all rows from Undergoes that exhibit this inconsistency.

SELECT * FROM STAY WHERE STAYID NOT IN (SELECT STAY FROM UNDERGOES)
SELECT * FROM STAY WHERE PATIENT NOT IN (SELECT PATIENT FROM UNDERGOES)

-- 8.7 Obtain the names of all the nurses who have ever been on call for room 123.

SELECT DISTINCT N.NAME FROM NURSE N LEFT JOIN UNDERGOES U ON N.EMPLOYEEID = U.ASSISTINGNURSE
JOIN STAY S ON U.STAY = S.STAYID
WHERE S.ROOM = 123

-- 8.8 The hospital has several examination rooms where appointments take place.
-- Obtain the number of appointments that have taken place in each examination room.

ALTER TABLE APPOINTMENT
ALTER COLUMN EXAMINATIONROOM VARCHAR(2)

SELECT EXAMINATIONROOM, COUNT(APPOINTMENTID) AS APPOINTMENTS FROM APPOINTMENT
GROUP BY EXAMINATIONROOM

-- 8.9 Obtain the names of all patients (also include, for each patient, the name of the patient's primary care physician), such that \emph{all} the following are true:
    -- The patient has been prescribed some medication by his/her primary care physician.
    -- The patient has undergone a procedure with a cost larger that $5,000
    -- The patient has had at least two appointment where the nurse who prepped the appointment was a registered nurse.
    -- The patient's primary care physician is not the head of any department.

---PATIENT, PHYSICIAN, PRESCRIBES, UNDERGOES, PROCEDURES, APPOINTMENT. NURSE, DEPARTMENT

SELECT DISTINCT PAT.NAME AS PATIENT_NAME,
P.NAME AS PRIMARY_PHYSICIAN FROM PATIENT PAT LEFT JOIN PHYSICIAN P ON P.EMPLOYEEID = PAT.PCP
JOIN PRESCRIBES PR ON P.EMPLOYEEID = PR.PHYSICIAN
JOIN UNDERGOES U ON U.PATIENT = PAT.SSN
JOIN PROCEDURES PRO ON PRO.CODE = U.PROCEDURES
JOIN APPOINTMENT AP ON AP.PATIENT = PAT.SSN
JOIN DEPARTMENT D ON D.HEAD != P.EMPLOYEEID
JOIN NURSE N ON N.EMPLOYEEID = AP.PREPNURSE
WHERE N.REGISTERED = 1 AND PRO.COST > 5000
AND 1 NOT IN (SELECT COUNT(PATIENT) FROM APPOINTMENT
GROUP BY PREPNURSE
HAVING COUNT(PATIENT) > 1
)