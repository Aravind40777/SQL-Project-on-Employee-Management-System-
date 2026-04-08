create database Employee_Management_system;
use Employee_Management_system;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

select * from jobdepartment;
select * from salarybonus;
select * from employee;
select * from qualification;
select * from leaves;
select * from payroll;


describe employee;
describe jobdepartment;
describe leaves;
describe salarybonus;
describe qualification;
describe payroll;


-- 1. EMPLOYEE INSIGHTS

-- How many unique employees are currently in the system?
SELECT COUNT(DISTINCT emp_ID) AS unique_employee_count 
FROM Employee;

-- Which departments have the highest number of employees?
select * from jobdepartment;

SELECT jd.jobdept, COUNT(e.emp_ID) AS employee_count
FROM JobDepartment as jd
INNER JOIN Employee as e 
ON jd.Job_ID = e.Job_ID
GROUP BY jd.jobdept
ORDER BY employee_count DESC; 

-- What is the average salary per department?
SELECT jd.jobdept, AVG(sb.amount) as average_salary
FROM JobDepartment as jd
JOIN SalaryBonus as sb 
ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

-- Who are the top 5 highest-paid employees?
-- Joining employee with payroll to see actual total amounts paid
select * from employee;
SELECT e.firstname, e.lastname, p.total_amount
FROM Employee as e
JOIN Payroll as p 
ON e.emp_ID = p.emp_ID
ORDER BY p.total_amount DESC
LIMIT 5;

-- What is the total salary expenditure across the company?
SELECT SUM(total_amount) as total_expenditure 
FROM Payroll;


-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

-- How many different job roles exist in each department?
SELECT jobdept, COUNT(DISTINCT name) AS role_count
FROM JobDepartment
GROUP BY jobdept;

-- What is the average salary range per department? 
select * from jobdepartment;
SELECT jobdept AS Department, salaryrange AS Salary_Range
FROM JobDepartment
GROUP BY jobdept, salaryrange;

-- Which job roles offer the highest salary?
SELECT jd.name AS job_role, sb.amount
FROM JobDepartment as jd
JOIN SalaryBonus as sb 
ON jd.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC;

-- Which departments have the highest total salary allocation?
 SELECT jd.jobdept AS Department, SUM(sb.amount) AS Total_Salary_Allocation
FROM JobDepartment as jd
INNER JOIN SalaryBonus as sb 
ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY Total_Salary_Allocation DESC;


-- 3. QUALIFICATION AND SKILLS ANALYSIS 

-- How many employees have at least one qualification listed? 
SELECT COUNT(DISTINCT Emp_ID) as qualified_employee_count 
FROM Qualification;

-- Which positions require the most qualifications?
SELECT Position, COUNT(QualID) AS Total_Qualifications_Required
FROM Qualification
GROUP BY Position
ORDER BY Total_Qualifications_Required DESC;

-- Which employees have the highest number of qualifications?
SELECT e.firstname, e.lastname, COUNT(q.QualID) AS num_qualifications
FROM Employee as e
JOIN Qualification as  q 
ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY num_qualifications DESC;

 
 -- 4. LEAVE AND ABSENCE PATTERNS
 select * from leaves;
 
 -- Which year had the most employees taking leaves?
 SELECT YEAR(date) AS leave_year, COUNT(leave_ID) AS leave_count
FROM Leaves
GROUP BY leave_year
ORDER BY leave_count DESC
LIMIT 1;

-- What is the average number of leave days taken by its employees per department?
SELECT jd.jobdept as Department, COUNT(l.leave_ID) / COUNT(DISTINCT e.emp_ID) AS Avg_Leaves_Per_Employee
FROM JobDepartment as jd
JOIN Employee as e 
ON jd.Job_ID = e.Job_ID
LEFT JOIN Leaves l 
ON e.emp_ID = l.emp_ID
GROUP BY jd.jobdept;

-- Which employees have taken the most leaves? 
SELECT e.firstname, e.lastname, COUNT(l.leave_ID) as total_leaves
FROM Employee as e
JOIN Leaves as l 
ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY total_leaves DESC;

-- What is the total number of leave days taken company-wide? 
SELECT COUNT(leave_ID) AS Total_Company_Leaves
FROM Leaves;

-- How do leave days correlate with payroll amounts?
SELECT e.firstname,e.lastname, COUNT(l.leave_ID) AS Total_Leaves, p.total_amount AS Net_Pay
FROM Employee as e
JOIN Payroll as p 
ON e.emp_ID = p.emp_ID
LEFT JOIN Leaves as l 
ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname, p.total_amount
ORDER BY Total_Leaves DESC;


-- 5. PAYROLL AND COMPENSATION ANALYSIS
select * from payroll;

-- What is the total monthly payroll processed?
SELECT report AS Payroll_Month, 
SUM(total_amount) AS Total_Monthly_Payroll
FROM Payroll
GROUP BY Payroll_Month,report;

-- What is the average bonus given per department?
SELECT jd.jobdept AS Department, AVG(sb.bonus) AS Average_Bonus
FROM JobDepartment as jd
JOIN SalaryBonus as sb 
ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;

-- Which department receives the highest total bonuses?
 SELECT jd.jobdept AS Department, SUM(sb.bonus) AS Total_Bonuses_Paid
FROM JobDepartment as jd
JOIN SalaryBonus as  sb 
ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY Total_Bonuses_Paid DESC
LIMIT 1;

-- What is the average value of total_amount after considering leave deductions?
SELECT AVG(total_amount) as Average_Net_Payment
FROM Payroll;

