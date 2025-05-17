-- Exploratory Data Analysis

-- Sometimes explore and clean at the same time
-- Gonna workmostly with total laid off and not percentage laid off asthere isnt an extra column telling us the total before laid off

Select * 
from layoffs_staging2;

-- Q. What is the total maximimum laid off on a particular day(in one go)

Select max(total_laid_off),max(percentage_laid_off)
from layoffs_staging2;  
-- 1 as max percentage laid off tells us 100% of the company was laid off

-- Which companies had 100% laid off
Select *
From layoffs_staging2
where percentage_laid_off=1
order by total_laid_off desc;

-- Companies which had a lot of funding and where 100% lay off place took place
Select *
From layoffs_staging2
where percentage_laid_off=1
order by funds_raised_millions desc;

-- Company-wise the highest laid off

select company ,sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;
-- here google had highest one-time time layoff

-- Date ranges
select min(`date`), max(`date`)
from layoffs_staging2;

-- Industry-wise the highest laid off
select industry ,sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- Country wise highest laid-off  (USA)
select country ,sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- date wise
-- individual date, not required
select `date` ,sum(total_laid_off)
from layoffs_staging2
group by `date`
order by 1 desc; -- recent date

-- By year

select year(`date`) ,sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc; --  2022 has the highest layoff, only 3  months of data of 2023

-- Stage of company as per layoff

select stage,sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;  

-- post ipo(initial public offering) ,highest, googles amazons of the word

-- Progression of lay-off, rolling sum, until the end (on the year)
-- Group by month  is invalid in standard sql, as the alias month dosesnt exist when group by clause is executed as per execution order of SQL
-- Exceptions ; some SQl dialects like Mysql or sql lite do allow you to use select aliases in group by ,even though its non standard ,a convenience feature
-- Best practice is to use the actual expression in the group by 

Select substring(`date`,1,7) as `Month`,sum(total_laid_off)
from layoffs_staging2
group by substring(`date`,1,7);

Select substring(`date`,1,7) as `Month`,sum(total_laid_off)
from layoffs_staging2
group by `month`;


Select substring(`date`,1,7) as `Month`,sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not Null
group by `Month`
order by 1 asc;

-- Now rolling Total using CTE and window function Sum(),Here sum(total_laid_off) is the total laid off per month aliased as total_off
-- Now by applying sum(total_off) over(order by `Month`)  in the outer query we get the rolling total(cumulative total) by month
-- For comparision also mention sum(total_laid_off) aliased as total_off in the outer query
-- Extracted the first seven characters of the Date using Substring(`date`,1,7)>(2021-09)
with Rolling_total as
(
Select substring(`date`,1,7) as `Month`,sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not Null
group by `Month`
order by 1 asc
)
Select `Month`,total_off,sum(total_off) over(order by `Month`) as rolling_total
from Rolling_total;

-- total_off shows the monthly laid_off and rolling _total shows the month by month progression of laid off

-- Company layoffs by year

Select company
from layoffs_staging2;
select company ,Year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,Year(`date`)
order by company;
-- order by company;It sorts the companies in alphabetical order, which includes:

-- Symbols and numbers come first, followed by uppercase letters (A–Z).

-- So, special characters like '&', '#', and numbers (100, 10X, etc.) appear before companies starting with letters like A, B, C, etc.


--  identify the top 5 companies with the highest total layoffs for each year/How does the ranking of companies with the highest layoffs vary across years?
select company ,Year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,Year(`date`)
order by 3 Desc;

-- used CTE, changed the name of columns of cte, 2 CTEs here, one for company _year,and another for company year rank, then apply filter on  Company_year_rank,
-- ist cte used in second,dense rank() handles ties with same rank and doesnt skip the next rank
with company_year(company,years,total_laid_off) as
(
select company ,Year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,Year(`date`)
), 
Company_Year_Rank AS
(
Select *,dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from company_year
where years is not Null
)
Select * 
from  Company_Year_Rank
where Ranking <=5;

/*CTE 1 (company_year):

Aggregates layoffs (SUM(total_laid_off)) by company and year.

CTE 2 (Company_Year_Rank):

Uses DENSE_RANK() to rank companies within each year based on the number of layoffs (highest first).

Filters out rows where year is NULL.

Final SELECT:

Retrieves only the top 5 companies per year with the highest total layoffs.*/



