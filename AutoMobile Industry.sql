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
SELECT Name, year, selling_price, 
sum(selling_price) over (partition by Name order by year rows between unbounded preceding and current row) as cumulative_sales_value
FROM auto_industry;



