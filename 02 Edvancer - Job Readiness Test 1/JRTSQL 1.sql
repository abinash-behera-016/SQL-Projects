use abinashdb
select * from jrtsql1
-- Q1
-- How many records have both sales and reason_for_null are both NULL at same time?
select count(*) from jrtsql1 where sales is null and reason_for_null is null

-- Q2
-- How many records are there in data when when naics_code is not NULL?
select count(*) from jrtsql1 where naics_code is not null

-- Q3
-- Highest year of sale for kind_of_business = 'Retail and food services sales, total'
select max(year(sales_month)) as highest_sales_year,  sum(sales) from jrtsql1 where kind_of_business = 'Retail and food services sales, total' 

-- Q4
-- Filter for 'Book stores','Sporting goods stores','Hobby, toy, and game stores' and determine total sales from year 1992 untill 2020.
select year(sales_month) as sales_year, kind_of_business, sum(sales) as sales_figure from jrtsql1 where kind_of_business in
('Book stores','Sporting goods stores','Hobby, toy, and game stores') group by year(sales_month), kind_of_business order by year(sales_month)

-- Q5
-- Filter for 'Men's clothing stores', 'Women's clothing stores' and determine total sales from year 1992 untill 2020.
select year(sales_month) as sales_year, kind_of_business, sum(sales) as sales_figure from jrtsql1 where kind_of_business in
('Men''s clothing stores', 'Women''s clothing stores') group by year(sales_month), kind_of_business order by year(sales_month)

-- Q6
-- Create two columns of men's clothing and women's clothing sales for every year make sure every year has only one record.
select year(sales_month) as year_of_sale, sum(case when kind_of_business = 'Men''s clothing stores' then sales else 0 end) as mens_sales,
sum(case when kind_of_business = 'Women''s clothing stores' then sales else 0 end) as wommens_sales from jrtsql1 group by year(sales_month)
order by year(sales_month)

-- Q7
-- For both men's clothing and women's clothing determine the proportion for men and women in a month for example: in 1992 January,
-- man clothing sales were : 701 compared to women: 1873, hence they are 27, 72 percentage respectively
select a.year_of_sale, a.month_of_sale, a.mens_sales, a.womens_sales, (a.mens_sales + a.womens_sales) as total_sales,
cast(round(mens_sales*100.0/(a.mens_sales + a.womens_sales), 2) as decimal(10, 2)) as mens_pct_sales, 
cast(round(womens_sales*100.0/(mens_sales + womens_sales), 2) as decimal(10,2)) as womens_pct_sales
from (
select year(sales_month) as year_of_sale, day(sales_month) as month_of_sale, 
sum(case when kind_of_business = 'Men''s clothing stores' then sales else 0 end) as mens_sales, 
sum(case when kind_of_business = 'Women''s clothing stores' then sales else 0 end) as womens_sales from jrtsql1 group by year(sales_month),
day(sales_month)
) as a order by a.year_of_sale, a.month_of_sale

-- Q8
-- For both men's clothing and women's clothing determine the proportion for men and women for each month within their respective gender
-- for example: total sale by men is 10179 in January 1992 it was 702 , so that is 6.88 percent
select a.year, a.month, a.total_monthly_sales, sum(a.total_monthly_sales) over(partition by a.year) as total_yearly_sales,
cast(round(a.total_monthly_sales*100.0/sum(a.total_monthly_sales) over(partition by a.year), 2) as decimal(10, 2)) as pct_monthly_sales from (
select year(sales_month) as year, day(sales_month) as month, sum(sales) as total_monthly_sales
from jrtsql1 where kind_of_business = 'Men''s clothing stores' group by day(sales_month), year(sales_month)) as a
order by a.year, a.month;

select a.year, a.month, a.total_monthly_sales, sum(a.total_monthly_sales) over(partition by a.year) as total_yearly_sales,
cast(round(a.total_monthly_sales*100.0/sum(a.total_monthly_sales) over(partition by a.year), 2) as decimal(10, 2)) as pct_monthly_sales from (
select year(sales_month) as year, day(sales_month) as month, sum(sales) as total_monthly_sales
from jrtsql1 where kind_of_business = 'Women''s clothing stores' group by day(sales_month), year(sales_month)) as a
order by a.year, a.month;


-- Q9
-- Calculate the moving average for women's clothing for last 11 and inclusive of it's own to generate moving average across every record, 
-- note if there are no 12 record prior then pick whatever available, with this logic, your first record has same value as total sales


-- Q10
-- Calcualte the cumulative sum for total sales in an year, note the it shouldn't roll to next year
select sales_month, day(sales_month) as month, kind_of_business, sales, sum(sales) over (partition by day(sales_month), year(sales_month) order by kind_of_business)
as cumulative_monthly_sales, sum(sales) over (partition by day(sales_month), year(sales_month)) as total_monthly_sales, 
sum(sales) over (partition by year(sales_month)) as total_monthly_sales from JRTSQL1 order by year(sales_month), day(sales_month)