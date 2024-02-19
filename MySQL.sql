#Q1 
select * from zomato_project.main;
select * from zomato_project.Currency;
select * from zomato_project.Country;

# Q2- Calender Table
CREATE table Zomato_project.Calender_Table
(Date_Key_Opening date,
Year int,
Monthno int,
Monthfullname text,
Quarter text,
YearMonth text,
Weekdayno int,
Weekdayname text,
FinancialMOnth text,
Financial_Quarter text
);

alter table zomato_project.main add column Date_Key_opening date;
select * from zomato_project.main;
update zomato_project.main set Date_Key_Opening =  concat(`year Opening`, '-', `Month Opening`,'-', `Day Opening`);

select * from zomato_project.calender_table;
select date_key_opening from zomato_project.main;
insert into zomato_project.calender_table (date_key_opening) select date_key_opening from zomato_project.main;
update zomato_project.calender_table set Year = Year(date_key_Opening);
update zomato_project.calender_table set Monthno = Month(date_key_Opening);
update zomato_project.calender_table set Monthfullname = monthname(date_key_Opening);
update zomato_project.calender_table set quarter = quarter(date_key_Opening);
update zomato_project.calender_table set YearMonth = concat(year(date_key_Opening),'-',date_format(date_key_opening,'%b')); # '%a' - 3 letter week name, '%b' - 3 letter month name
update zomato_project.calender_table set Weekdayno = weekday(date_key_Opening);
update zomato_project.calender_table set Weekdayname = dayname(date_key_Opening);
update zomato_project.calender_table 
	set FinancialMonth = case 
		When Month(date_key_Opening)=4 then 'FM-1' 
        When Month(date_key_Opening)=5 then 'FM-2'
        When month(date_Key_Opening)=6 then 'FM-3'
        When Month(date_key_Opening)=7 then 'FM-4' 
        When Month(date_key_Opening)=8 then 'FM-5'
        When month(date_Key_Opening)=9 then 'FM-6'
        When Month(date_key_Opening)=10 then 'FM-7' 
        When Month(date_key_Opening)=11 then 'FM-8'
        When Month(date_key_Opening)=12 then 'FM-9' 
        When Month(date_key_Opening)=1 then 'FM-10'
        When month(date_Key_Opening)=2 then 'FM-11'
        else 'FM-12' 
        end;
update zomato_project.calender_table 
	set Financial_Quarter = case 
		When Month(date_key_Opening)<4 then 'FM-4' 
        When Month(date_key_Opening)<7 then 'FM-1'
        When month(date_Key_Opening)<10 then 'FM-2'
        else 'FM-3' 
        end;
        
        
# Q3 - Convert the Average cost for 2 column into USD dollars (currently the Average cost for 2 in local currencies

Alter table zomato_project.main	add column Average_Cost_for_2_USD double;
update zomato_project.main as M join zomato_project.currency as C on M.currency = C.currency
 set Average_Cost_for_2_USD = M.Average_Cost_for_two * C.`USD Rate`;

# Q4 - Find the Numbers of Resturants based on City and Country.

Select C.Countryname as Country, M.City, Count(RestaurantID) as Restaurants from zomato_project.main M join Country C 
on M.CountryCode = C.CountryID group by country, City;


#Q5 - Numbers of Resturants opening based on Year , Quarter , Month

Select C.Year, C.Quarter, C.Monthfullname as Month, Count(RestaurantID) as Restaurants from
zomato_project.Main M join zomato_project.calender_table C 
On	M.Date_Key_Opening = C.Date_Key_Opening group by Year, Quarter, Month order by Year; 

#6 - Count of Resturants based on Average Ratings

Select Rating, Count(RestaurantID) from zomato_project.main group by Rating order by Rating;

#7 - Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets

Select (case when Average_Cost_for_two <100 Then '0-100'
			When Average_Cost_for_two < 200 Then '100-200'
            When Average_Cost_for_two < 500 Then '200 -500'
            When Average_Cost_for_two < 1000 Then '500-1000'
            Else '1000 and More'
            End) as Average_Price_Buckets, Count(RestaurantID) as Restaurants from zomato_project.main group by Average_Price_Buckets order by Average_Price_Buckets;

#8 - Percentage of Resturants based on "Has_Table_booking"

Select Has_Table_booking, round((count(RestaurantID)/(Select count(*) from zomato_project.main)*100)) As Percentage_of_Restaurants From zomato_project.main group by Has_Table_booking;

#9 - Percentage of Resturants based on "Has_Online_delivery"

Select Has_Online_delivery, round((count(RestaurantID)/(Select count(*) from zomato_project.main)*100)) As Percentage_of_Restaurants From zomato_project.main group by Has_Online_delivery;


#10 - Develop Charts based on Cusines, City, Ratings ( Candidate have to think about new KPI to analyse)
-- Top 10 Cuisines by count
Select Cuisines, Count(Cuisines) Total_Cuisines From zomato_project.main group by Cuisines order by Total_Cuisines Desc limit 10;
-- Top 10 ecnomic cuisines by average_cost_for_two
Select Cuisines, Average_Cost_for_two From zomato_project.main Where Average_Cost_for_two <> 0 order by Average_Cost_for_two ASC limit 10;
-- Top 10 cities by count of restaurants
select city, count(RestaurantID) Total_Restaurants from zomato_project.main group by City order by Total_Restaurants DESC limit 10;
-- City wise Voting
select city, Rating, Sum(Votes) Total_Votes from zomato_project.main group by City , Rating order by Total_Votes desc  limit 10;
-- Cities by Rating
Select City, Count(Rating) From zomato_project.main group by City Limit 5;

#11. Build a Dashboard for the KPI's Above.
        