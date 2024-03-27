select *
from [dbo].[HR Data]

select [termdate]
from [dbo].[HR Data]
order by [termdate] desc

update [dbo].[HR Data]
set [termdate] = format(CONVERT(datetime,left([termdate],len([termdate])-3),120),'yyyy-MM-dd')

alter table [dbo].[HR Data] alter column [termdate] datetime
-- create age column
alter table  [dbo].[HR Data]  add age int
-----
update [dbo].[HR Data]
set age= datediff(YEAR,[birthdate],GETDATE())
-------------
-- Q/A
--What's the age distribution in the company?
select min(age) as minum ,MAX(age) as maxium ,AVG(age) as average 
from [dbo].[HR Data]
-- age group count
select age_catergory ,count(*) as #count from 
(select 
case 
when age between 21 and 30 then '21 to 30'
when age between 31 and 40 then '31 to 40'
when age between 41 and 50 then '41 to 50'
ELSE '50+'
end as age_catergory
from [dbo].[HR Data]
where termdate is not null
) as new_table
group by age_catergory
order by #count desc
-------
-- Age group by gender
select [gender],age_catergory,COUNT(*) as #count_age_per_gender
from (select [gender],
case 
when age between 21 and 30 then '21 to 30'
when age between 31 and 40 then '31 to 40'
when age between 41 and 50 then '41 to 50'
ELSE '50+'
end as age_catergory
from [dbo].[HR Data]
where termdate is not null
) as new_table
group by [gender],age_catergory
order by #count_age_per_gender desc
---------------------
-- 2) What's the gender breakdown in the company?
select [gender] ,COUNT(*) as #count
from [dbo].[HR Data]
WHERE termdate IS not NULL
group by [gender]
order by #count desc
-----------------------
--  How does gender vary across departments and job titles?
select [gender] ,department,COUNT(*) as #count
from [dbo].[HR Data]
WHERE termdate IS not NULL
group by [gender] ,department
order by #count desc
--------------------- 
select [gender] ,department,[jobtitle],COUNT(*) as #count
from [dbo].[HR Data]
WHERE termdate IS not NULL
group by [gender] ,department,[jobtitle]
order by #count desc
-----------------------
-- What's the race distribution in the company?
select race,COUNT(*) as #count
from [dbo].[HR Data]
WHERE termdate IS NULL
group by race 
order by #count desc
-----------------------
--What's the average length of employment in the company?
select AVG(DATEDIFF(year,[hire_date],termdate)) as average_time_in_company
from [dbo].[HR Data]
WHERE termdate IS not NULL and termdate<=GETDATE()
----------------------------
-- Which department has the highest turnover rate?
-- get total count
-- get terminated count
-- terminated count/total count
create view  total_count
as
select department,COUNT(*) as #count
from [dbo].[HR Data]
WHERE termdate IS not NULL
group by department
------------------
create view  terminated_count
as
select department,COUNT(*) as #left_count
from [dbo].[HR Data]
WHERE termdate IS not NULL and termdate<GETDATE()
group by department
-------------------
-- terminated count/total count
select tc.department ,#left_count,#count,round(round(cast(#left_count as real),2)/round(cast(#count AS real),2),2)as percantage_left
from total_count tc inner join terminated_count tt
on tc.department=tt.department
order by percantage_left desc
-------------
 -- What is the tenure distribution for each department?
 select department,AVG(DATEDIFF(year, hire_date,termdate)) AS tenure
from [dbo].[HR Data]
WHERE termdate IS not NULL and termdate<GETDATE()
group by department
-------------------
-- How many employees work remotely for each department?
select [location],COUNT(*) as #count
from [dbo].[HR Data]
WHERE termdate IS not NULL 
group by [location]
order by #count desc
--------------
-- What's the distribution of employees across different states?
select [location_state],COUNT(*) as #count
from [dbo].[HR Data]
WHERE termdate IS not NULL 
group by [location_state]
order by #count desc
---------------------------
-- How are job titles distributed in the company?
select jobtitle,COUNT(*) as #count
from [dbo].[HR Data]
WHERE termdate IS not NULL 
group by jobtitle
order by #count desc
----------------------------
-- How have employee hire counts varied over time?
--calculate hires
--calculate terminations
--(hires-terminations)/hires percent hire change
---------
--calculate hires per year
create view  hiring_count
as
select YEAR(hire_date) as hire_date ,COUNT(*) as #hire_count
from [dbo].[HR Data]
WHERE termdate IS not NULL 
group by  YEAR(hire_date)
-------------------
alter view  terminting_count
as
select YEAR(termdate) as term_date ,COUNT(*) as #termdate_count
from [dbo].[HR Data]
WHERE termdate IS not NULL  and termdate>hire_date and termdate <=GETDATE()
group by  YEAR(termdate)
----------------
select hire_date as [year],#hire_count-#termdate_count AS net_change,
(round(CAST(#hire_count-#termdate_count AS FLOAT)/#hire_count, 2)) * 100 AS percent_hire_change
from hiring_count tc inner join terminting_count tt
on tc.hire_date=tt.term_date




-- terminated_count