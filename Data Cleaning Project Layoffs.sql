-- -- SQL Project - Data Cleaning

-- Data Cleaning
-- 1. Remove Duplicates
-- 2. Standardize the data 
-- 3. Null Values or blank values
-- 4. Remove any columns


Select *
From layoffs;

-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens

Create table layoffs_staging
Like layoffs;

-- Want to insert all records from the layoffs table into the layoffs_staging table
-- Things to check before running this:
-- Column order matches — layoffs_staging must have the same number and order of columns as layoffs.
-- Data types align — the columns in both tables should have compatible data types.
-- No constraints blocking the insert — check for primary keys, unique constraints, or NOT NULL columns in layoffs_staging that could reject rows.
-- If you only want specific columns or want to control the order, it’s safer to write:
-- INSERT INTO layoffs_staging (col1, col2, col3, ...)
-- SELECT col1, col2, col3, ...
-- FROM layoffs


insert	into layoffs_staging    
select *
from layoffs;

Select *
From  layoffs_staging;

-- Here in the table we dont have an extra column that gives us the unique row id that makes removing duplicates easy
-- So we need to use window (), row number() and partion by every column(if not done leads to wrong results)
-- Now will filter it ,where row-no is >1 , which means it has duplicates
-- Use date with back ticks `date` as it is a keyword in sql
-- We need to delete one record of the duplicates and not both of them
-- 
-- For each unique combination of the columns:company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
-- it creates a partition (group)

-- Inside that partition, it assigns:

-- row_num = 1 to the first record.

-- row_num = 2, 3, ... to any duplicate records (same values in all partition columns).
-- This effectively marks duplicates:

 -- If a combination appears only once, the record gets row_num = 1.

--  If a combination appears multiple times, one gets row_num = 1, and the rest get row_num = 2, 3, etc

-- 1. Remove Duplicates
-- need to really look at every single row to be accurate, so partion by every column
Select *,row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;


with duplicate_cte As
(
Select *,row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
Select *
from duplicate_cte
where row_num > 1;

-- Now check the duplicate data

Select *
From  layoffs_staging
where company= 'casper';

-- Tried to delete duplicate ,gave error
with duplicate_cte As
(
Select *,row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
Delete 
from duplicate_cte
where row_num > 1;

-- This is the usual way , but it gives error as CTEs arent updatable or we cant delete from CTE but we haveto delete from an actual table
-- Need to create a table with the extra row row-num, layoff_staging2 that has the  duplicate_CTE data and then delete the duplicates
-- Use copy to clipboard > create statement> paste, and the add `row_num` int and 2 in layoffs_staging


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


Select *
From  layoffs_staging2;

-- Now Insert data into layoffs_staging 2 from the cte or the select statement above

Insert into layoffs_staging2
Select *,row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;

-- Delete the duplicates now from layoff staging2, after turning off safe sql mode

Select *
From  layoffs_staging2
where row_num >1;

set sql_safe_updates=0;

Delete
From  layoffs_staging2
where row_num >1;

Select *
From  layoffs_staging2;



-- 2. Standardizing data , finding issues in data and fixing it like spelling,extra space etc.


-- issue with Company Column, extra spaces, need to remove 

select company,trim(company)
from layoffs_staging2;

update layoffs_staging2
set company=trim(company);

select company
from layoffs_staging2;

-- Industry column, order albabetically and by distinct
select distinct industry
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like 'crypto%';

Set sql_safe_updates=0;

Update layoffs_staging2
set industry= 'Crypto'
where industry like 'Crypto%';

Select distinct industry
from layoffs_staging2;

-- Location column check

Select distinct location
from layoffs_staging2
order by 1;

Select distinct country
From  layoffs_staging2
order by 1;

-- Country column check, issue with United States,we have some "United States" and some "United States."

Select distinct country
from layoffs_staging2
order by 1;

select distinct Country ,trim(Trailing '.' from country) #remove any trailing '.' from country
from layoffs_staging2
order by 1;


Update layoffs_staging2  #doesnt delete the record just updates the country name
set country = Trim(Trailing '.' from country)
where country like 'United States%';

select *
from layoffs_staging2
where country like "United States%"; # or run the first two queries to check


/*select *
from layoffs_staging2
where country = "United States" and funds_raised_millions=1200 ;*/

select *
from layoffs_staging2;

-- Date column , issue with date format, imported as text, for time series analysis date needs to be formatted properly
-- use str_to_date() , %m for months,%d for days %Y for 4 digit date

select `date`,str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2;

Update layoffs_staging2
set `date`= str_to_date(`date`,'%m/%d/%Y');

-- Check
select `date`
from layoffs_staging2;

-- Now convert date  datatype into  date from text, as earlier it wouldn't have worked as it was not in the format

alter table layoffs_staging2
modify column `date` Date;


-- Null and Blank Values
-- industry,total_laid_off,percentage_laid_off,funds_raised_millions


-- Industry Column
select *
from layoffs_staging
where industry is null or
industry =''; 

-- Change blank to null so as the update statement works, as update statement here doesnt work on blanks
-- we should set the blanks to nulls since those are typically easier to work with
update layoffs_staging2
set industry =null
where industry='';

-- Check whether any of the Company 'Airbnb' industry record is populated so that we can use and fill the blank record, similar for other companies like juul etc
-- Populate the data that is populatable 
-- 
select *
from layoffs_staging2
where company like 'Airbnb'; # Gives a record where 'Airbnb' industry is filled with 'Travel', so we can populate

-- Need to do a self-join here between tables to compare null/blank values 

select *                                             
from layoffs_staging2 t1 join
layoffs_staging2 t2 on t1.company=t2.company #joining on same company and location,Safer, more precise
and t1.location=t2.location
where t1.industry is null
and t2.industry is not null;

select t1.industry,t2.industry
from layoffs_staging2 t1 join
layoffs_staging2 t2 on t1.company=t2.company
and t1.location=t2.location
where t1.industry is null
and t2.industry is not null;

/*select *
from layoffs_staging
where company ='Carvana';( 3 records, one null industry and two transportation industry)*/

-- now update

Update layoffs_staging2 t1 join
layoffs_staging2 t2 on t1.company=t2.company  #joining on same company and location,Safer, more precise
and t1.location=t2.location
Set t1.industry= t2.industry
where t1.industry is null and
t2.industry is not null;       
# 3 records updated as one Null  record of caravana was compared twice,because in total 3 records of caravan exist, 3 layoffs,1 null and two filled 


-- check 
select *
from layoffs_staging2
where industry is null; 

select *
from layoffs_staging2
where company like 'Bally%'; 

# it yields Company 'Bally's interactive' as it couldn't get updated as the company had only one layoff(row) and not another from which we could use info

select *
from layoffs_staging2;

-- Total laid off, percentage laid off ,funds raised millions
-- these can't be poulated with the data that we have here
-- we could have populated total laid off null values , if we had the 'company total before laid off', then if % laid off was '1', and 'total before laid off' was 50, 
-- then total laid off will be 50, but we dont have,also funds raised millions can be populated from internet but not part of data cleaning project

select *
from layoffs_staging2
where total_laid_off IS NULL
And percentage_laid_off is NULL; 

-- As we need the total laid off and % laid off data without these we cant work when doing EDA on them, so we can remove the null values involving them, as 
-- we cant trust that data
-- Still 100% not sure but can

SET SQL_SAFE_UPDATES = 0;

Delete
from layoffs_staging2
where total_laid_off IS NULL
And percentage_laid_off is NULL; 
-- It deletes only rows where both total_laid_off and percentage_laid_off are NULL at the same time.
/*SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL
or percentage_laid_off IS NULL;*/
-- Delete rows where total_laid_off is NULL
-- OR rows where percentage_laid_off is NULL
-- Including rows where both are NULL

select *
from layoffs_staging2;
 
-- Remove columns ; row_num

Alter table layoffs_staging2
drop column row_num;


-- Next , gona do EDA, find trends ,patters,  running complex queries on this cleaned data

-- Summary:
-- Removed Duplicates
-- Standardized the data
-- Dealt with Null or blank values
-- Removed any  unnecessary column or rows

-- Portfolio project