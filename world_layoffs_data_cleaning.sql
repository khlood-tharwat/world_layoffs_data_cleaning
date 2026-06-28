-- =================================================================================================================================================
-- world layoffs Data Cleaning Project 
-- Auther: khlood Tharwat 
-- ================================================================================================================================================

-- step 1: Create a working copy 
create table layofss2
select*,
row_number()over(partition by company ,location ,industry ,total_laid_off
,percentage_laid_off ,`date` ,stage ,country ,funds_raised_millions) as row_num
from world_layoffs.layoffs;

-- step 2: create a new table with a row number column to identify the duplicates
CREATE TABLE `layoffs3` (
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

insert layoffs3
select*
FROM world_layoffs.layofss2;


-- step 3: Remove duplicates 
-- Disable safe updates to allow data cleaning operations (delete , updates)
set sql_safe_updates = 0 ; 

-- Remove duplicates
with remove_cte as 
(
select*,
row_number()over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)as row_num
from world_layoffs.layoffs3
)
delete 
from remove_cte 
where row_num >1 ;

-- verify that duplicate records have been removed
select*
from world_layoffs.layoffs3
where row_num > 1;

-- step 4: sandardize the data 
-- company column 
select trim(company)
from world_layoffs.layoffs3;

update layoffs3 
set company =trim(company);

-- industry column
select industry
from world_layoffs.layoffs3
where industry like 'crypto%'
order by 1;

update layoffs3
set industry = 'crypto'
where industry like 'crypto%';

-- country column
select country
from world_layoffs.layoffs3
where country like '%united%';

select country , trim(trailing'.' from country) as ca
from world_layoffs.layoffs3
where country like 'united states.';

update layoffs3
set country = trim(trailing'.' from country);

-- verify that data have been standardized
select country
from world_layoffs.layoffs3
where country like 'united states.';

-- step 5: handle null or blank values 
-- fill missing values(null and blank) using a self join on matching records
-- industry column
update layoffs3
set industry = null 
where industry = '';

select lay.industry , offs.industry
from world_layoffs.layoffs3 as lay
join world_layoffs.layoffs3 as offs
on lay.company = offs.company 
where lay.industry is null
and 
offs.industry is not null;

update layoffs3 as lay
join layoffs3 as offs
on lay.company = offs.company 
set lay.industry = offs.industry
where lay.industry is null
and offs.industry is not null;

-- verify that missing data has filled
select *
from world_layoffs.layoffs3
where company = 'airbnb';

-- step 6: remove any unnesseray row
-- remove rows with no layoff information 
-- total_laid_off and percentage_laid_off columns
delete 
from world_layoffs.layoffs3
where  total_laid_off is null and percentage_laid_off is null ;

-- verify that rows with no layoff information have been removed
select total_laid_off , percentage_laid_off 
from world_layoffs.layoffs3
where total_laid_off is null and percentage_laid_off is null ;


-- step 7: convert data type 
alter table layoffs3
modify column `date` date ;

-- step 8: remove any unnesseray column
alter table layoffs3
drop row_num ; 


-- ==============================================================================================================================================
-- Data Cleaning Completed 
-- Cleaned Table : layoff3
-- Next Step : Exploratory Data Analysis (EDA)
-- =========================================================================================================================================












 

























