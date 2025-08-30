use classicmodels;

select * from account;

select * from `oppertuninty table`;

select * from `lead`;

select count(`Total Leads`) from `lead`;


use project_crm;
 
select * from `lead`;

select * from `oppertuninty table`;


-- Lead Dashboard

-- Q1) Total Leads
select count(`Total Leads`) from `lead`;


-- Q2) Expected Amount from converted leads
select sum(`Expected Amount`) from `lead_1`;



-- Q3) Conversion rate
SELECT 
    ROUND(
        (COUNT(CASE WHEN `# Converted Accounts` = '1' THEN 1 END) / COUNT(*)) * 100,
        2
    ) AS Conversion_Rate_Percent
FROM `Lead`; 

-- Q4) Converted Accounts
select count(distinct `Converted Account ID`) from `lead`;


SELECT 
    COUNT(`Converted Account ID`) AS Converted_Accounts
FROM `Lead`
WHERE `# Converted Accounts`= '1'
  AND `Converted Account ID` IS NOT NULL;


-- Q5) Converted Opportunities
SELECT 
    COUNT(TRIM(`Converted Opportunity ID`)) AS Converted_Opportunities
FROM `Lead`
WHERE CAST(`# Converted Accounts` AS UNSIGNED) = 1
  AND TRIM(`Converted Opportunity ID`) != '';


-- Q6) Lead by source
select `Lead Source`, count(`Lead ID`) as Count_leads
from `lead`
group by `Lead Source`
order by Count_leads desc;


-- Q7) Lead by Industry
select `Industry`, count(`Lead ID`) as Count_leads
from `lead`
group by `Industry`
order by Count_leads desc;


-- Q8) Lead by Stage
select `Stage`, count(`Lead ID`) as Count_leads
from `lead_1`
group by `Stage`
order by Count_leads desc;




-- Opportunity Dashboard

-- Q1) Expected amount
SELECT 
   concat( ROUND(
        SUM(
            CAST(REPLACE(REPLACE(`Expected Amount`, '$', ''), ',', '') AS DECIMAL(18,2))
        ) / 1000000, 2  ) ,'M'
    ) AS Expected_Amount_Million
FROM 
    `oppertuninty table`;


-- Q2) Active opportunities
select `Stage`,count(`Stage`) as `total_stage_count`
from `oppertuninty table`
where `Stage` not in('Closed Won','Closed Lost')
group by `Stage`
order by `total_stage_count` desc;



-- Q3) Conversion rate
select *
from
	(select `Stage`,count(`Stage`) as `total_stage_count`
	from `oppertuninty table` 
	where `Stage`='Closed Won'
	group by `Stage`) as `win_opportunities`;

select count(stage) as total_stage_count
from `oppertuninty table`;


select 
    (win.total_stage_count / total.total_stage_count) * 100 as win_percentage
from 
    (select count(*) as total_stage_count from `oppertuninty table`) as total,
    (select count(*) as total_stage_count from `oppertuninty table` where `Stage` = 'Closed Won') as win;
    
    
-- Q4) Win Rate
select 
    (win.total_win_stage_count/(win.total_win_stage_count + lost.total_lost_stage_count)) * 100 as win_percentage
from 
    (select count(*) as total_stage_count from `oppertuninty table`) as total,
    (select count(*) as total_win_stage_count from `oppertuninty table` where `Stage` = 'Closed Won') as win,
     (select count(*) as total_lost_stage_count from `oppertuninty table` where `Stage` = 'Closed lost') as lost;
    
    
-- Q5) Lost Rate
    SELECT 
    ROUND(
        (COUNT(CASE WHEN Stage = 'CLOSED LOST' THEN 1 END) * 100.0) /
        NULLIF(
            COUNT(CASE WHEN Stage IN ('CLOSED WON', 'CLOSED LOST') THEN 1 END),
            0
        ),
        2
    ) AS Loss_Rate_Percent
FROM 
    `oppertuninty table`;
    
-- Loss Rate   
   
select 
    (lost.total_lost_stage_count/(win.total_win_stage_count + lost.total_lost_stage_count)) * 100 as win_percentage
from 
    (select count(*) as total_stage_count from `oppertuninty table`) as total,
    (select count(*) as total_win_stage_count from `oppertuninty table` where `Stage` = 'Closed Won') as win,
     (select count(*) as total_lost_stage_count from `oppertuninty table` where `Stage` = 'Closed lost') as lost;


-- Q6) Trend analysis
SELECT 
    DATE_FORMAT(STR_TO_DATE(`Created Date`, '%m/%d/%Y'), '%Y-%m') AS Month,
    COUNT(*) AS Total_Opportunities
FROM 
    `oppertuninty table`
WHERE 
    `Created Date` IS NOT NULL
GROUP BY 
    Month
ORDER BY 
    Month;
    
    -- Total_Expected_Amount
    SELECT 
    DATE_FORMAT(STR_TO_DATE(`Created Date`, '%m/%d/%Y'), '%Y-%m') AS Month,
    ROUND(
        SUM(
            CAST(REPLACE(REPLACE(`Expected Amount`, ',', ''), '$', '') AS DECIMAL(18,2))
        ), 2
    ) AS Total_Expected_Amount
FROM 
    `oppertuninty table`
WHERE 
    `Created Date` IS NOT NULL
GROUP BY 
    Month
ORDER BY 
    Month;
    
    -- Won_Opportunities
    SELECT 
    DATE_FORMAT(STR_TO_DATE(`Close Date`, '%m/%d/%Y'), '%Y-%m') AS Month,
    COUNT(*) AS Won_Opportunities
FROM 
    `oppertuninty table`
WHERE 
    LOWER(TRIM(Won)) = 'true'
    AND `Close Date` IS NOT NULL
GROUP BY 
    Month
ORDER BY 
    Month;


-- a) Expected Vs Forecast
SELECT 
    DATE_FORMAT(STR_TO_DATE(`Created Date`, '%m/%d/%Y'), '%Y-%m') AS Month,
   concat( ROUND(
        SUM(
            CAST(REPLACE(REPLACE(`Expected Amount`, ',', ''), '$', '') AS DECIMAL(18,2))
        ) / 1000,
        2),'K'
    ) AS Forecasted_Expected_Amount_K
FROM 
    `oppertuninty table`
WHERE 
    LOWER(TRIM(`Internal Forecast`)) = 'true'
    AND `Expected Amount` IS NOT NULL
    AND `Created Date` IS NOT NULL
GROUP BY 
    Month
ORDER BY 
    Month;



-- b) Active Vs Total Opportunities
SELECT 
    Month,
    SUM(Total_Opportunities) OVER (ORDER BY Month) AS Cumulative_Total,
    SUM(Active_Opportunities) OVER (ORDER BY Month) AS Cumulative_Active
FROM (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(`Created Date`, '%m/%d/%Y'), '%Y-%m') AS Month,
        COUNT(*) AS Total_Opportunities,
        COUNT(CASE 
            WHEN LOWER(TRIM(Stage)) NOT IN ('closed won', 'closed lost') THEN 1 
            END) AS Active_Opportunities
    FROM 
        `oppertuninty table`
    WHERE 
        `Created Date` IS NOT NULL
    GROUP BY 
        Month
) AS sub
ORDER BY 
    Month;




-- c) Closed won vs total opportunities
SELECT 
    `Industry`,
    COUNT(`Opportunity ID`) AS Total_Opportunities,
    COUNT(CASE 
        WHEN LOWER(TRIM(`Stage`)) = 'closed won' THEN 1 
    END) AS Closed_Won_Opportunities,
    ROUND(
        COUNT(CASE 
            WHEN LOWER(TRIM(`Stage`)) = 'closed won' THEN 1 
        END) * 100.0 / NULLIF(COUNT(`Opportunity ID`), 0),
        2
    ) AS Win_Percentage
FROM 
    `oppertuninty table`
WHERE 
    `Industry` IS NOT NULL
GROUP BY 
    `Industry`
ORDER BY 
    Win_Percentage DESC;
    
    
    
-- Closed won Vs Total Closed
SELECT 
    DATE_FORMAT(STR_TO_DATE(`Close Date`, '%m/%d/%Y'), '%Y-%m') AS Month,
    
    COUNT(CASE 
        WHEN LOWER(TRIM(Stage)) = 'closed won' THEN 1 
    END) AS Closed_Won_Opportunities,

    COUNT(CASE 
        WHEN LOWER(TRIM(Stage)) IN ('closed won', 'closed lost') THEN 1 
    END) AS Total_Closed_Opportunities,

    ROUND(
        COUNT(CASE 
            WHEN LOWER(TRIM(Stage)) = 'closed won' THEN 1 
        END) * 100.0 / NULLIF(
            COUNT(CASE 
                WHEN LOWER(TRIM(Stage)) IN ('closed won', 'closed lost') THEN 1 
            END), 0
        ),
        2
    ) AS Win_After_Closure_Percent

FROM 
    `oppertuninty table`
WHERE 
    `Close Date` IS NOT NULL
GROUP BY 
    Month
ORDER BY 
    Month;



-- Q7) Expected amount by opportunity type
select `Opportunity Type`, sum(cast(replace(replace(`Expected Amount`,'$',' '),',',' ') as decimal(18,2))) as `total_expected_amount`
from `oppertuninty table`
group by `Opportunity Type`;



SELECT 
    `Opportunity Type`,
    CONCAT(
        ROUND(
            SUM(
                CAST(REPLACE(REPLACE(`Expected Amount`, '$', ''), ',', '') AS DECIMAL(18,2))
            ) / 1000, 0
        ),
        'K'
    ) AS Total_Expected_Amount
FROM 
    `oppertuninty table`
WHERE 
    `Expected Amount` IS NOT NULL
    AND `Opportunity Type` IS NOT NULL
GROUP BY 
    `Opportunity Type`
ORDER BY 
    SUM(
        CAST(REPLACE(REPLACE(`Expected Amount`, '$', ''), ',', '') AS DECIMAL(18,2))
    ) DESC;




-- Q8) Opportunity by industry
select `Industry`,count(`Opportunity ID`) as `count_opportunity`
from `oppertuninty table`
group by `Industry`
order by `count_opportunity` desc;




