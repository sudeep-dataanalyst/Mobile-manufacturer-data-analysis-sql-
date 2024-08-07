--SQL Advance Case Study
use Mobile_Manufacture

--Q1--BEGIN 

SELECT  l.State,f.[Date] 
FROM FACT_TRANSACTIONS f
JOIN DIM_LOCATION l ON l.IDLocation = f.IDLocation
JOIN DIM_MODEL m on m.IDModel=f.IDModel
WHERE [Date] between '2005-01-01' and GETDATE()

--Q1--END

--Q2--BEGIN

select top 1 l.State,sum([Quantity]) as most_buy
from [dbo].[DIM_LOCATION] l
inner join [dbo].[FACT_TRANSACTIONS] f on l.[IDLocation]=f.IDLocation
inner join [dbo].[DIM_MODEL] m on f.IDModel = m.IDModel
inner join [dbo].[DIM_MANUFACTURER] d on m.IDManufacturer=d.IDManufacturer
where l.Country ='us' and [Manufacturer_Name] ='samsung'
group by l.State

--Q2--END

--Q3--BEGIN 
select [IDModel],l.[State],l.[ZipCode], count(concat(f.[IDCustomer],[IDModel])) as no_transactiion
from [dbo].[FACT_TRANSACTIONS] f	
inner join [dbo].[DIM_LOCATION] l on f.IDLocation=l.IDLocation
inner join [dbo].[DIM_CUSTOMER] c on f.IDCustomer=c.IDCustomer
group by [IDModel],l.[State],l.[ZipCode]


--Q3--END

--Q4--BEGIN

select top 1[IDModel],[Model_Name],[Unit_price]
from [dbo].[DIM_MODEL]
order by [Unit_price] asc;

--Q4--END

--Q5--BEGIN
select [Model_Name],avg([Unit_price]) as avarage_price from [dbo].[DIM_MODEL] d
inner join [dbo].[DIM_MANUFACTURER] dm on dm.[IDManufacturer]=d.[IDManufacturer]
where [Manufacturer_Name] in
(
select top 5 [Manufacturer_Name]
from [dbo].[FACT_TRANSACTIONS] f
inner join [dbo].[DIM_MODEL] d on f.IDModel=d.IDModel
inner join [dbo].[DIM_MANUFACTURER] dm on d.IDManufacturer=dm.IDManufacturer
group by [Manufacturer_Name]
order by sum([Quantity]) desc
)
group by [Model_Name]
order by avg([Unit_price]) desc

--Q5--END

--Q6--BEGIN

select [Customer_Name],avg([TotalPrice]) as avgamt 
from [dbo].[DIM_CUSTOMER] d
inner join [dbo].[FACT_TRANSACTIONS] f on d.IDCustomer=f.IDCustomer
where YEAR([Date]) = '2009'
group by [Customer_Name]
having avg([TotalPrice]) > 500

--Q6--END
	
--Q7--BEGIN  

 select
        [Model_Name] from ( select [Model_Name],[YEAR] as orderyear,
        rank() OVER (partition by [YEAR] order by SUM([Quantity]) desc) as Rank
    from
        [dbo].[DIM_MODEL] d
    inner join
        [dbo].[FACT_TRANSACTIONS] f ON d.IDModel = f.IDModel
    inner join
        [dbo].[DIM_DATE] dd ON f.Date = dd.DATE
    where
        dd.[YEAR] IN ('2008', '2009', '2010')
    group by
        d.[Model_Name], [YEAR]) temp
where rank <=5
group by [Model_Name]
having count(distinct orderyear)=3
	

--Q7--END	
--Q8--BEGIN

;with rank as 
(select [Manufacturer_Name],[YEAR],sum([Quantity]) as total_qty,
ROW_NUMBER() over (partition by [YEAR] order by sum([Quantity]) desc) as rank
from [dbo].[DIM_MANUFACTURER] dm
inner join [dbo].[DIM_MODEL] d on dm.IDManufacturer=d.IDManufacturer
inner join [dbo].[FACT_TRANSACTIONS] f on d.IDModel=f.IDModel
inner join [dbo].[DIM_DATE] dd on f.Date=dd.DATE
where [YEAR] in ('2009','2010')
group by [Manufacturer_Name],[YEAR]
)
select [Manufacturer_Name],[YEAR],total_qty
from rank
where
rank =2;


--Q8--END
--Q9--BEGIN

select distinct [Manufacturer_Name]
from [dbo].[DIM_MANUFACTURER] dm 
inner join [dbo].[DIM_MODEL] d on dm.IDManufacturer=d.IDManufacturer
inner join [dbo].[FACT_TRANSACTIONS] f on d.IDModel=f.IDModel
inner join [dbo].[DIM_DATE] dd on f.Date=dd.DATE
where [YEAR] = '2010'
and [Manufacturer_Name] not in (
select distinct [Manufacturer_Name]
from [dbo].[DIM_MANUFACTURER] dm 
inner join [dbo].[DIM_MODEL] d on dm.IDManufacturer=d.IDManufacturer
inner join [dbo].[FACT_TRANSACTIONS] f on d.IDModel=f.IDModel
inner join [dbo].[DIM_DATE] dd on f.Date=dd.DATE
where [YEAR] = '2009')

--Q9--END

--Q10--

select top 10 [IDCustomer],
year([Date]) as yr,avg([TotalPrice]) as spend,avg([Quantity]) as qty,
--lag(avg([TotalPrice])) over (partition by IDCustomer order by year([Date])) as lag_avg
(avg([TotalPrice]))-lag(avg([TotalPrice])) over (partition by IDCustomer order by year([Date]))/ nullif(lag(avg([TotalPrice]))
over (partition by IDCustomer order by year([Date])),0)*100 as per_spend
from [dbo].[FACT_TRANSACTIONS] as f
where [IDCustomer] in 
(select [IDCustomer] from (select top 10 [IDCustomer],sum([TotalPrice]) as spend
from [dbo].[FACT_TRANSACTIONS]
group by [IDCustomer]
order by sum([TotalPrice]) desc)a)
group by [IDCustomer],year([Date])

--Q10--END
	