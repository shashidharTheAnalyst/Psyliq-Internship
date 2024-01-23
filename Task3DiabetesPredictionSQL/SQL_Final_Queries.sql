/* Tasks performed using Postgresql */


create table diabetes_predictions(EmployeeName VARCHAR,	Patient_id VARCHAR,	gender VARCHAR,	age INT,	hypertension INT,	heart_disease INT,	smoking_history VARCHAR,	bmi DECIMAL(3,2),	HbA1c_level DECIMAL(2,4),	blood_glucose_level INT,	diabetes INT
)
COPY Diabetes_predictions FROM 'C:\\Program Files\\PostgreSQL\\Diabetes_prediction_1.csv' DELIMITER ',' CSV HEADER;
ALTER TABLE diabetes_predictions
ALTER COLUMN bmi
TYPE NUMERIC(5,2);
ALTER TABLE diabetes_predictions
ALTER COLUMN hba1c_level
TYPE NUMERIC(4,2);
ALTER TABLE diabetes_predictions
ALTER COLUMN age
TYPE NUMERIC(5,2);


-- 1. Retrieve the Patient_id and ages of all patients
SELECT patient_id,age 
FROM diabetes_predictions;

-- 2. Select all female patients who are older than 40
SELECT *
FROM diabetes_predictions
WHERE age>40 and gender='Female'

-- 3. Calculate the average BMI of patients.
SELECT avg(bmi) AS bmi_avg
FROM diabetes_predictions

-- 4. List patients in descending order of blood glucose levels.
SELECT *
FROM diabetes_predictions
ORDER BY blood_glucose_level DESC

-- 5. Find patients who have hypertension and diabetes.
SELECT *
FROM diabetes_predictions
WHERE hypertension=1 AND diabetes=1;

-- 6. Determine the number of patients with heart disease.
SELECT COUNT(patient_id) AS num_of_heart_patients
FROM diabetes_predictions
WHERE heart_disease=1;

-- 7. Group patients by smoking history and count how many smokers and nonsmokers there are
SELECT COUNT(smoking_history)
FROM diabetes_predictions
where smoking_history IN ('current','never','No Info')
GROUP BY smoking_history;

-- 8. Retrieve the Patient_ids of patients who have a BMI greater than the average BMI.
WITH avg_bmi AS (
  SELECT AVG(bmi) AS avg_value
  FROM diabetes_predictions
)
SELECT patient_id
FROM diabetes_predictions
WHERE bmi > (SELECT avg_value FROM avg_bmi);

/* 9. Find the patient with the highest HbA1c level and the patient with the lowest
HbA1clevel.*/
/*SELECT MAX(hba1c_level) AS highest_hba1c_level,MIN(hba1c_level)AS lowest_hba1c_level
FROM diabetes_predictions*/

--patient with highest hba1c level
WITH max_hba1c AS (
  SELECT MAX(hba1c_level) AS max_value
  FROM diabetes_predictions
)
SELECT patient_id, hba1c_level
FROM diabetes_predictions
WHERE hba1c_level = (SELECT max_value FROM max_hba1c);

--patient with lowest hba1c level
WITH min_hba1c AS (
  SELECT MIN(hba1c_level) AS min_value
  FROM diabetes_predictions
)
SELECT patient_id, hba1c_level
FROM diabetes_predictions
WHERE hba1c_level = (SELECT min_value FROM min_hba1c);

-- 10. Calculate the age of patients in years (assuming the current date as of now).
SELECT patient_id, age + EXTRACT(YEAR FROM AGE(CURRENT_DATE)) AS current_age
FROM diabetes_predictions;

-- 11. Rank patients by blood glucose level within each gender group.
SELECT gender, patient_id, blood_glucose_level,
RANK() OVER (PARTITION BY gender ORDER BY blood_glucose_level DESC) AS rank
FROM diabetes_predictions;

-- 12. Update the smoking history of patients who are older than 50 to "Ex-smoker."
UPDATE diabetes_predictions
SET smoking_history = 'Ex-smoker'
WHERE age > 50;

-- 13. Insert a new patient into the database with sample data.
INSERT INTO diabetes_predictions (EmployeeName, Patient_id, gender, age, hypertension, heart_disease, smoking_history, bmi, HbA1c_level, blood_glucose_level, diabetes)
VALUES ('shashidhar', 'PT100101', 'Male', 22, 0, 0, 'never', 23.56, 5.1, 60, 0);

-- 14. Delete all patients with heart disease from the database.
delete 
from diabetes_predictions
where heart_disease=1;

-- 15. Find patients who have hypertension but not diabetes using the EXCEPT operator
SELECT patient_id
FROM diabetes_predictions
WHERE hypertension = 1
EXCEPT
SELECT patient_id
FROM diabetes_predictions
WHERE diabetes = 1;


-- 16. Define a unique constraint on the "patient_id" column to ensure its values are unique
DELETE FROM diabetes_predictions
WHERE patient_id IN (
  SELECT patient_id
  FROM (
    SELECT patient_id, ROW_NUMBER() OVER(PARTITION BY patient_id ORDER BY patient_id) AS rn
    FROM diabetes_predictions
  ) t
  WHERE t.rn > 1
);

ALTER TABLE diabetes_predictions ADD CONSTRAINT unique_patient_id UNIQUE (patient_id);


-- 17. Create a view that displays the Patient_ids, ages, and BMI of patients.

CREATE VIEW patient_view AS
SELECT patient_id, age, bmi
FROM diabetes_predictions;


/*-- 18. Suggest improvements in the database schema to reduce data redundancy and
improve data integrity. */

/*to improve the database schema to reduce data redundancy and improve data integrity:

Normalization: Normalize your database to eliminate redundant data. This involves dividing your database into two or more related tables and defining relationships between the tables. The main aim of normalization is to add, delete, and modify data without causing data anomalies.

Use of Primary Keys: Ensure every table has a primary key. This will help maintain the integrity of your database by avoiding duplicate entries.

Use of Foreign Keys: Use foreign keys whenever relationships exist between tables. This ensures referential integrity in the relationship where a foreign key correctly points to a candidate key.

Use of Constraints: Use constraints like UNIQUE, NOT NULL, and CHECK to ensure data integrity. These constraints ensure that the data adheres to the defined rules.

Avoid Null Values: Avoid permitting null values whenever possible. This will make it easier to perform calculations, comparisons, or concatenations with the data.

Use of Indexes: Use indexes for frequently searched columns to speed up read operations. Be careful, as excessive use of indexes can slow down write operations.

Consistent Structure: Ensure that all instances of a repeating group (e.g., multiple addresses for a customer) are structured consistently.

Data Types: Ensure data types are appropriate for the data being stored. This can prevent the possibility of storing inconsistent types of data in the same column.

Use of Views: Use views to encapsulate the queries that access the structural part of the database. This can help protect the integrity of the underlying data.

Regular Audits: Regularly audit the data to ensure it adheres to the business rules and constraints.*/




-- 19. Explain how you can optimize the performance of SQL queries on this dataset.

/*strategies to optimize the performance of SQL queries:

Use Indexes: Indexes can significantly improve the performance of data retrieval queries. However, they can slow down data modification statements (INSERT, UPDATE, DELETE), so use them judiciously.
Avoid SELECT: Instead of using SELECT *, specify the columns you need. This reduces the amount of data that needs to be sent from the database to the client.
Use WHERE instead of HAVING for row filtering: WHERE clause is more efficient than HAVING clause. HAVING should only be used for conditions on aggregate functions.
Use LIMIT: If you only need a certain number of rows, use the LIMIT clause to restrict the data retrieved from the database.
Use JOINs wisely: Avoid unnecessary JOINs as they can result in large amounts of unnecessary data. Also, use INNER JOIN instead of OUTER JOIN whenever possible.
Avoid Correlated Subqueries: Correlated subqueries can slow down queries as they can result in repeated executions.
Use EXPLAIN PLAN: The EXPLAIN PLAN statement can be used to determine the execution plan that the PostgreSQL planner generates for a given SQL statement. This can help identify bottlenecks.
Database Maintenance: Regular database maintenance like updating statistics, rebuilding indexes, and vacuuming can help improve query performance.
Normalize Your Data: Normalization can lead to more efficient storage by eliminating redundant data.
Use Appropriate Data Types: Using the correct data type can save storage and improve performance.
*/

