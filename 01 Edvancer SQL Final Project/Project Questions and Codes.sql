-- Create database
create database Tenant;

-- Create table Tenancy_histories
create table Tenant.dbo.Tenancy_histories (
id int not null identity(1,1) primary key,
profile_id int not null,
house_id int not null,
move_in_date date not null,
move_out_date date null,
rent int not null,
Bed_type varchar(255) null,
move_out_reason varchar(255) null
)

-- Create table Profiles
create table Tenant.dbo.Profiles (
profile_id int not null identity(1,1) primary key,
first_name varchar(255) null,
last_name varchar(255) null,
email varchar(255) not null,
phone varchar(255) not null,
city_hometown varchar(255) null,
pan_card varchar(255) null,
created_at date not null,
gender varchar(255) not null,
referral_code varchar(255) null,
marital_status varchar(255) null
)

-- Create table Houses
create table Tenant.dbo.Houses (
house_id int not null identity(1,1) primary key,
house_type varchar(255) null,
bhk_details varchar(255) null,
bed_count int not null,
furnishing_type varchar(255) null,
beds_vacant int not null
)

-- Create table Addresses
create table Tenant.dbo.Addresses (
ad_id int not null identity(1,1) primary key,
name varchar(255) null,
description text null,
pincode int null,
city varchar(255) null,
house_id int not null
)

-- Create table Referrals
create table Tenant.dbo.Referrals (
ref_id int not null identity(1,1) primary key,
referrer_id int not null,
referrer_bonus_amount float null,
referral_valid tinyint null,
valid_from date null,
valid_till date null
)

-- Create table Employment_details
create table Tenant.dbo.Employment_details (
id int not null identity(1,1) primary key,
profile_id int not null,
latest_employer varchar(255) null,
official_mail_id varchar(255) null,
yrs_experience int null,
occupational_category varchar(255) null
)

-- Later I just removed the above tables and imported the respective CSVs provided.
-- Created Foreign keys using drag and drop in the database diagram as the query-based approach kept giving me errors.

-- PROJECT QUESTIONS
-- Question 1
-- Write a query to get Profile ID, Full Name and Contact Number of the tenant who has stayed with us for the longest time period in the past.
-- move_ou_date had NULLs so I had to create a new column move_out_date1 with ASDATE function, without disturbing the original move_out_date column.
alter table Tenancy_histories
add move_out_date1 as (case 
when ISDATE(move_out_date) = 1 then convert(date, move_out_date)
else null
end);
-- Then the query for the question 1.
select Profiles.profile_id as Profile_ID, concat(Profiles.first_name, ' ',
Profiles.last_name) as Full_Name, Profiles.phone as Phone_No,
datediff(day, Tenancy_histories.move_in_date, Tenancy_histories.move_out_date1) as Days_Stayed
from Profiles, Tenancy_histories 
where Profiles.profile_id = Tenancy_histories.profile_id
order by days_stayed desc;
-- The longest staying person would be Anusha Pariti i.e, 443 days.


-- Question 2
-- Write a query to get the Full name, email id, phone of tenants who are married and paying rent > 9000 using subqueries.
select concat(Profiles.first_name, ' ', Profiles.last_name) as Full_Name, Profiles.email_id as Email_ID,
Profiles.phone as Phone_No, Tenancy_histories.rent as Rent, Profiles.marital_status as Marital_Status
from Profiles
join Tenancy_histories ON Profiles.profile_id = Tenancy_histories.profile_id
where Tenancy_histories.rent > 9000 and Profiles.marital_status = 'Y';


-- Question 3
-- Write a query to display profile id, full name, phone, email id, city, house id, move_in_date, move_out date, rent, total number of referrals made,latest employer 
-- and the occupational category of all the tenants living in Bangalore or Pune in the time period of jan 2015 to jan 2016 sorted by their rent in descending order.
select distinct Profiles.profile_id as Profiles_ID, 
concat(Profiles.first_name, ' ', Profiles.last_name) as Full_Name,
Profiles.phone as Phone_No, Profiles.email_id as Email_ID, Profiles.city as City, 
Tenancy_histories.house_id as House_ID, 
Tenancy_histories.move_in_date as Move_in_Date, Tenancy_histories.move_out_date1 as Move_out_Date,
Tenancy_histories.rent as Rent,
count(*) over (partition by Profiles.first_name) as Total_No_of_Referrals_Made,
Employment_status.latest_employer as Latest_Employer, 
Employment_status.occupational_category as Occupational_Category
from Profiles
join Tenancy_histories on Profiles.profile_id = Tenancy_histories.profile_id
join Employment_status on Profiles.profile_id = Employment_status.profile_id
join Referrals on Profiles.profile_id = Referrals.profile_id
where Profiles.city in ('Bangalore', 'Pune') and year(Tenancy_histories.move_in_date) > 2014-12
and (year(isnull(move_out_date1, '1901-12-31')) < 2016 OR move_out_date1 is null)
order by Tenancy_histories.rent desc;


-- Question 4
-- Write a SQL snippet to find the full_name, email_id, phone number and referral code of all the tenants who have referred more than once.
-- Also find the total bonus amount they should receive given that the bonus gets calculated only for valid referrals.
select a.full_name as Full_Name, a.email_id as Email_ID, a.phone as Phone_No, 
a.referral_code as Referral_Code, a.No_of_Referrals_Made, a.Total_Bonus_Amount from (
select distinct concat(Profiles.first_name, ' ', Profiles.last_name) as full_name,
Profiles.email_id, Profiles.phone, Profiles.referral_code,
count(*) over (partition by Profiles.first_name) as No_of_Referrals_Made,
sum(Referrals.referrer_bonus_amount*Referrals.referral_valid*1.0) over 
(partition by Profiles.first_name) as Total_Bonus_Amount
from Profiles
join Referrals on Profiles.profile_id = Referrals.profile_id) as a
where no_of_referrals_made > 1;

-- Question 5
-- Write a query to find the rent generated from each city and also the total of all cities.
select b.city as City, b.Total_Rent_From_City, 
sum(Total_Rent_From_City) over () as Total_Overall_Rent from(select distinct a.city,
sum(a.rent) over (partition by a.city) as Total_Rent_From_City from (
select Addresses.city, Tenancy_histories.rent
from Addresses join Tenancy_histories on Addresses.house_id = Tenancy_histories.house_id) as a) as b;


-- Question 6
-- Create a view 'vw_tenant' find profile_id,rent,move_in_date,house_type,beds_vacant,description and city of tenants
-- who shifted on/after 30th april 2015 and are living in houses having vacant beds and its address.
create view vw_tenant as
select Tenancy_histories.profile_id as Profile_ID, Tenancy_histories.rent as Rent, 
Tenancy_histories.move_in_date as Move_in_Date, Houses.house_type as House_Type,
Houses.beds_vacant as Beds_Vacant, Addresses.description as Description, Addresses.city as City
from Tenancy_histories
join Houses on Tenancy_histories.house_id = Houses.house_id
join Addresses on Tenancy_histories.house_id = Addresses.house_id
where Tenancy_histories.move_in_date > '2015-04-30' and Houses.beds_vacant > 0;

select * from vw_tenant


-- Question 7
-- Write a code to extend the valid_till date for a month of tenants who have referred more than one time.
select a.full_name as Full_Name, a.referral_code as Referral_code,
a.no_of_referrals_made as No_of_Referrals_Made, a.valid_from as Valid_From, a.valid_till as Valid_Till,
dateadd(month, 1, a.valid_till) as Valid_Till_Extended from (
select distinct concat(Profiles.first_name, ' ', Profiles.last_name) as full_name,
Profiles.referral_code, Referrals.valid_from, Referrals.valid_till,
count(*) over (partition by Profiles.first_name) as no_of_referrals_made
from Profiles
join Referrals on Profiles.profile_id = Referrals.profile_id) as a
where no_of_referrals_made > 1;


-- Question 8
-- Write a query to get Profile ID, Full Name, Contact Number of the tenants along with a new column 'Customer Segment' wherein 
-- if the tenant pays rent greater than 10000, tenant falls in Grade A segment, if rent is between 7500 to 10000, tenant falls in Grade B else in Grade C
select Profiles.profile_id as Profile_ID, concat(Profiles.first_name, ' ', Profiles.last_name) as Full_Name,
Profiles.phone as Contact_Number, Tenancy_histories.rent as Rent,
case when Tenancy_histories.rent > 10000 then 'Grade A'
  	when Tenancy_histories.rent > 7500 and Tenancy_histories.rent < 10000 then 'Grade B'
	when Tenancy_histories.rent <= 7500 then 'Grade C' end as Customer_Segment
from Profiles
join Tenancy_histories on Profiles.profile_id = Tenancy_histories.profile_id;


-- Question 9
-- Write a query to get Fullname, Contact, City and House Details of the tenants who have not referred even once.
-- Referral table has these profile_ids: (2, 3, 5, 6, 9, 10, 12, 13, 20). I got my output by manually collecting and excluding them.
select Profiles.profile_id as Profile_ID, concat(Profiles.first_name, ' ', Profiles.last_name) as Full_Name,
Profiles.email_id as Email_ID, Profiles.phone as Phone_No, Profiles.city as City,
Houses.house_type as House_Type, Houses.bhk_type as BHK_Type, Houses.bed_count as Bed_Count,
Houses.furnishing_type as Furnishing_Type, Houses.beds_vacant as Beds_Vacant
from Tenancy_histories
join Profiles on Tenancy_histories.profile_id = Profiles.profile_id
join Houses on Tenancy_histories.house_id = Houses.house_id
where Profiles.profile_id not in (2, 3, 5, 6, 9, 10, 12, 13, 20);

-- Question 10
-- Write a query to get the house details of the house having highest occupancy.
-- By highest occupancy, I'm assuming a high bed_count and low beds_vacant. 
-- Basically the person with the highest bed_occupied = (bed_count - beds_vacant) should have the maximum number of family members i,e, highest occupancy.
select a.profile_id as Profile_ID, a.full_name as Full_Name, a.house_type as House_Type, 
a.bhk_type as BHK_Type, a.furnishing_type as Furnishing_Type, a.bed_count as Bed_Count,
a.beds_vacant as Beds_Vacant, a.beds_occupied as Beds_Occupied from 
(select Profiles.profile_id, concat(Profiles.first_name, ' ', Profiles.last_name) AS full_name, 
Houses.house_type, Houses.bhk_type, Houses.furnishing_type, Houses.bed_count, Houses.beds_vacant,
Houses.bed_count - Houses.beds_vacant AS beds_occupied,
dense_rank() over (order by Houses.bed_count - Houses.beds_vacant desc) as rank
from Tenancy_histories
join Houses on Tenancy_histories.house_id = Houses.house_id
join Profiles on Tenancy_histories.profile_id = Profiles.profile_id) as a  where rank = 1;
