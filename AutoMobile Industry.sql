use automotive_indu;
select * from auto_industry;
/**Question1: Write a query to find all cars that are Petrol, have a Manual transmission, are owned by the 'First Owner', 
and have been driven less than 15,000 km. Group them by fuel type and display the average price.**/
select round(avg(selling_price),2) as average, fuel
from auto_industry 
where transmission="Manual" and owner='First Owner' and km_driven<15000
group by fuel;

/**Question2: Identify car models where the price consistency fluctuates wildly. Specifically, find models 
where the difference between the maximum and minimum selling prices is significant (greater than $500,000 / ₹5,00,000). **/
select Name, max(selling_price) as maxs, min(selling_price) as mins, (max(selling_price)-min(selling_price)) as difference from auto_industry
group by Name
having difference>500000
order by difference desc;

/**Question3: The mileage column contains text labels (e.g., "19.03 kmpl"). Write a query to safely strip the units, 
convert the values into a true decimal format, and isolate the top 3 vehicle models with the highest average mileage among cars with 
more than 5 seats.**/
select Name, round(avg(cast(substring_index(mileage, ' ', 1) as decimal(5,2))), 2) as avg_numeric_mileage
from auto_industry
where seats > 5 and mileage is not null and mileage != '0.0 kmpl'
group by Name
order by avg_numeric_mileage desc
limit 3;

/**Question4: Which manufacturing years have an average car selling price greater than 1,500,000? **/
select year, avg(selling_price) as average from auto_industry group by year having average>1500000;

/**Question5: Create a query that categorizes cars into three tier buckets based on usage: 'Low Mileage' (under 10k km), 
'Moderate Mileage' (10k to 40k km), and 'High Mileage' (above 40k km). Show the count of cars in each category. **/
select case 
when mileage<10 then 'Low Mileage'
when mileage>10 and mileage<40 then 'Moderate Mileage'
else'High Mileage'
end as tier,
count(*) as No_of_cars
from auto_industry
group by tier;

/**Question6: Calculate a running cumulative sum of the sales value over the years, tracked separately for each unique car model.**/
select Name, year, selling_price, 
sum(selling_price) over (partition by Name order by year rows between unbounded preceding and current row) as cumulative_sales_value
FROM auto_industry;

/**Question7: An interviewer asks you to write a report displaying total inventory metrics horizontally. Write a query that groups by 
fuel type and shows the total count of Manual cars vs. Automatic cars in separate, side-by-side columns.**/
select fuel,count(case when transmission = 'Manual' then 1 end) as manual_count,
count(case when transmission = 'Automatic' then 1 end) as automatic_count,count(*) as total_combined_inventory
from auto_industry
group by fuel
order by total_combined_inventory desc;

/**Question8: Before doing a deep data analysis, we need to find missing or bad data points. Write a query that calculates the absolute count 
and percentage of rows where mileage, engine, or seats contain null values, blank strings, or evaluate to zero.**/
select count(*) as total_rows,
sum(case when mileage is null or mileage = '' or mileage like '0.0%' then 1 else 0 end) as invalid_mileage_count,
sum(case when engine is null or engine = '' then 1 else 0 end) as invalid_engine_count,
sum(case when seats is null or seats = 0 then 1 else 0 end) as invalid_seats_count,
round((sum(case when mileage is null or mileage = '' or mileage like '0.0%' then 1 else 0 end) / count(*)) * 100, 2) as mileage_error_rate_pct
FROM auto_industry;

/**Question9: Write a query that displays each manufacturing year, the total combined selling price of all cars from that year, and the 
percentage increase or decrease in sales value compared to the previous year.**/
WITH YearlySales as (
    -- Step 1: Calculate total sales value grouped by year
    select year,sum(selling_price) as total_sales_value
    from auto_industry
    group by year
),
SalesComparison AS (
    -- Step 2: Grab the prior year's total value using the LAG() window function
    select year,total_sales_value,LAG(total_sales_value) over (order by year) as previous_year_sales
    from YearlySales
)
-- Step 3: Run the percentage growth calculation
select year,total_sales_value as current_year_sales,coalesce(previous_year_sales, 0) as prior_year_sales,
    case 
        when previous_year_sales is null then '0.00% (Baseline Year)'
        else concat(round(((total_sales_value - previous_year_sales) / previous_year_sales) * 100, 2),'%')
    end as percentage_change
from SalesComparison
order by year desc;


