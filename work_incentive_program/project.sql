-- create join table
select *
from [dbo].[Absenteeism_at_work] A left join [dbo].[compensation] C
ON A.ID=C.ID
LEFT JOIN [dbo].[Reasons] R
ON R.Number=A.Reason_for_absence

--- FIND THE Healhist employee for bonus
select *
from [dbo].[Absenteeism_at_work]
where [Social_drinker] =0 and [Social_smoker]=0
and [Body_mass_index]<25
and [Absenteeism_time_in_hours] <(select AVG([Absenteeism_time_in_hours] ) from [dbo].[Absenteeism_at_work])
------ compensation rate for non smokers for budget 983,21
select COUNT(*) as Non_smoker
from [dbo].[Absenteeism_at_work]
where [Social_smoker] =0 
---------------------
select 
A.ID,R.[Reason],[Month_of_absence],
[Day_of_the_week],[Transportation_expense],
[Education],[Son],[Social_drinker],[Social_smoker],[Pet],
[Work_load_Average_day],[Absenteeism_time_in_hours],[Body_mass_index] as BMI,
case 
when [Body_mass_index] <18.5 then 'under_weight'
when [Body_mass_index] between 18.5 and 25 then 'Healthy_weight'
when [Body_mass_index] between 25 and 30 then 'Over_weight'
else 'un known' 
end as BMI_Catergory
,
case 
when [Month_of_absence] in (12,1,2) then 'winter'
when [Month_of_absence] in (3,4,5) then 'Spring'
when [Month_of_absence] in (6,7,8) then 'Summer'
when [Month_of_absence] in (9,10,11) then 'Fall'
else 'un known' 
end as season_name
from [dbo].[Absenteeism_at_work] A left join [dbo].[compensation] C
ON A.ID=C.ID
LEFT JOIN [dbo].[Reasons] R
ON R.Number=A.Reason_for_absence