CREATE TABLE Employees_2 (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(50),
    DeptID INT,
    Salary INT
);

INSERT INTO Employees_2 VALUES
(1, 'Ali', 101, 60000),
(2, 'Sara', 102, 75000),
(3, 'Hassan', 101, 50000),
(4, 'Ayesha', 103, 80000),
(5, 'Bilal', 102, 55000);

-----------------------------------------------------------------
 
 CREATE TABLE Projects_2 (
    ProjID INT PRIMARY KEY,
    ProjName VARCHAR(50),
    DeptID INT
);

INSERT INTO Projects_2 VALUES
(201, 'ERP System', 101),
(202, 'Recruitment Drive', 102),
(203, 'Budget Planning', 103);



CREATE TABLE EmployeeProjects_2 (
    EmpID INT,
    ProjID INT,
    HoursWorked INT,
    PRIMARY KEY (EmpID, ProjID)
);

INSERT INTO EmployeeProjects_2 VALUES
(1, 201, 120),
(2, 202, 80),
(3, 201, 100),
(4, 203, 150),
(2,203,100);



select * from Employees_2
select * from Projects_2
select * from EmployeeProjects_2


--------------------------------------------------------------------------------------
   ---------- SQL Scenarios---------------
            ---- Joins ----

   --Q1:List all employees with the projects they are working on.
   select E.EmpID,E.EmpName,P.ProjName from EmployeeProjects_2 as EP

   inner join Employees_2 as E 
   on E.EmpID = EP.EmpID

   inner join Projects_2 as P 
   on P.ProjID = EP.ProjID


   --Q2:Show employees who are not assigned to any project
   select E.EmpID , E.EmpName,EP.ProjID from  Employees_2 as E 

   left join EmployeeProjects_2 as EP
   on EP.EmpID = E.EmpID

   -- as all employess work on project so we  delete a record 
   delete from EmployeeProjects_2 where EmpID = 5


   -- Q3: Display all projects along with the employees working on them.
    select EP.ProjID , EP.EmpID  from   Projects_2 as P

   left join EmployeeProjects_2 as EP
   on EP.ProjID = p.ProjID

   -----------------------------------------------------------------------------
   ---- Joins + Aggregate Functions -----
   -- Q4: Find the average salary of employees working on each project.
    select E.EmpID,E.EmpName,EP.ProjID,AVG(E.Salary) as Average_Salary  from Employees_2 as E

   left  join  EmployeeProjects_2 as EP
   on EP.EmpID =  E.EmpID

   group by  E.EmpID,E.EmpName,EP.ProjID


   --- Q5:Show the total hours worked by each employee across all projects.
   select EmpID,ProjID,SUM(HoursWorked) from  EmployeeProjects_2
   group by EmpID,ProjID
   select * from EmployeeProjects_2

    
    ----Q6 : Find the project with the maximum total hours worked.
    select EmpID,ProjID,max(HoursWorked)as total from EmployeeProjects_2
    group by EmpID,ProjID
    Order by total desc

-----------------------------------------------------------------------------
 ---------- Aggregate  ---------------
 --Q7:Show the top 3 employees who worked the most hours overall.
SELECT TOP 3 
 e.EmpID, 
 e.EmpName, 
SUM(ep.HoursWorked) AS TotalHours
 FROM Employees_2 e
JOIN EmployeeProjects_2 ep ON e.EmpID = ep.EmpID
 GROUP BY e.EmpID, e.EmpName
 ORDER BY TotalHours DESC;


 -- Q7 : Find the employee who worked the maximum hours on a single project.
 select EmpID,ProjID,MAX(HoursWorked) as Total_Time  from EmployeeProjects_2 
 group by EmpID,ProjID 
 order by EmpID desc

 -- Q8 : Fetch the second last record 
 select * from EmployeeProjects_2
 order by EmpID desc
 offset 1 row
 fetch next 1 row only


 -- Q9 : List projects with more than 1 employee assigned.
 select P.ProjID,P.ProjName,Count(EP.EmpID) as  Employees_Working from EmployeeProjects_2 as EP
  
  inner join Projects_2 as P
  on EP.ProjID = P.ProjID

  group by P.ProjID, P.ProjName
  having Count(EP.EmpID)>1


  --- Q10: Calculate the average salary of employees per project and display project names
  select P.ProjID ,P.ProjName,E.EmpID,E.EmpName,AVG(E.Salary) as Average_Salary from EmployeeProjects_2 as EP

  inner join Employees_2 as E
  on EP.EmpID =E.EmpID

  inner join Projects_2 as P
  ON P.ProjID =EP.ProjID

  group by P.ProjID ,P.ProjName,E.EmpID,E.EmpName
  


  --------------------------------------------------------------------------------------------------
           ------------------Stored Procedure + Joins ------------------
  
  -- Stored Procedure that get EmpID as Input and returns 
  -- EmpName 
  -- Project the Emp working on 
  -- Total hours he worked on project 

Create Procedure Get_Emp_Data 
@empid int ,
@empname varchar (20) = Null
as 
Begin 

if exists (select * from Employees_2 where EmpID = @empid and EmpName = @empname)

Begin 

select E.EmpID, E.EmpName ,P.ProjName,Sum(HoursWorked) as Total_Hours 
from EmployeeProjects_2 as EP 

inner join Employees_2 as E
on E.EmpID = EP.EmpID

inner join Projects_2 as P 
on P.ProjID = EP.ProjID

where E.EmpID = @empid 

Group by E.EmpID, E.EmpName ,P.ProjName

end


Else 
begin


print 'Record not Found!'


End
END

exec Get_Emp_Data  2




----------------------------------------------------------------------------------------------------

 --   Create a stored procedure that accepts a ProjID or Project Name   and returns:
 -- Project name
 -- Number of employees assigned
 -- Total hours worked
 
 Create Procedure Get_Project_Data
 @projectid int ,
 @projectname varchar = null -- contain even null values if we did give its values it still give Data 
 as 
 begin 

 if exists (select * from Projects_2 where ProjID = @projectid OR ProjName = @projectname)
 begin
 

 select P.ProjID ,P.ProjName , Count(EP.EmpID) as No_Of_Working_Emp, Sum(EP.HoursWorked) as Total_Hours  from EmployeeProjects_2 as EP 
 
 inner join Employees_2 as E 
 on E.EmpID =Ep.EmpID 

 inner join Projects_2 as P 
 on EP.ProjID = P.ProjID

 where P.ProjID = @projectid

 Group by  P.ProjID ,P.ProjName
 end 


 ELSE 
 Begin 

 print 'No record Found !!!'

 end 

 End 

EXEC Get_Project_Data  201 ; 
 

 --------------------------------------------------------------------------------------------------------------

 --------------- Triggers -----------------
 
 --- Trigger that fire when a User insert/Update/Delete Data (Using Instead of Property)
 -- Trigger + Insertion ---
 create trigger trg_insert_Data
 On EmployeeProjects_2
 instead of Insert
 as 
 begin 

 Print 'Data Insertion is Not Allowed '

 end 

 -- Checking the Trigger 
 Insert into EmployeeProjects_2 
 values (4,201,100)


 ------------ Trigger + Updation   ---------------------
  create trigger trg_Update_Data
 On EmployeeProjects_2
 instead of Update
 as 
 begin  

 Print 'Data Updation  is Not Allowed '

 end 

 --- Checking the Trigger 
 update EmployeeProjects_2 set 
 ProjID = 201 where EmpID = 4 


 ------------ Trigger +  Deletion   -------------

  create trigger trg_Delete_Data
 On EmployeeProjects_2
 instead of delete 
 as 
 begin 

 Print 'Data  Deletion is Not Allowed '

 end 

 -- Checking the Trigger --
 delete from EmployeeProjects_2 where EmpID  = 1