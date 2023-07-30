CREATE TABLE appleStore_description_combined AS

SELECT * from appleStore_description1

UNION ALL

SELECT * from appleStore_description2

UNION ALL

SELECT * from appleStore_description3

union ALL

SELECT * from appleStore_description4


**Exploratory Data Analysis**

-- check the number of unique apps in both tables

-- In AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs1
from AppleStore

-- In appleappleStore_description_combined

SELECT COUNT(DISTINCT id) as UniqueAppIDs2
from appleStore_description_combined


-- Check for any missing values in key fields

select count(*) as MissingValues
from AppleStore
where track_name is NULL or user_rating is null or prime_genre is NULL

select count(*) as MissingValues
from appleStore_description_combined
where app_desc is NULL

-- Find out the number of apps per genre

SELECT prime_genre, COUNT(id) as NumApps 
from AppleStore
GROUP by prime_genre
order by NumApps desc

-- Get an overview of the apps' ratings

SELECT min(user_rating) as MinRating,
   	   max(user_rating) as MaxRating,
	   avg(user_rating) as AvgRating
from AppleStore

-- Determine whether paid apps have higher ratings than free apps

SELECT case
			when price > 0 then 'Paid'
            Else 'Free'
       End as App_Type,
       avg(user_rating) as Avg_Rating
from AppleStore
group by App_Type

--Check if apps with more supported languages have higher ratings

select case 
			when lang_num < 10 Then '<10 Languages'
            when lang_num BETWEEN 10 and 30 then '10 - 30 Languages'
            else '> 30 Languages'
        end as language_bucket,
        avg(user_rating) as Avg_Rating
from AppleStore
group by language_bucket
ORDER by Avg_Rating Desc

-- Check Genres with Low Rating

select prime_genre,
	   avg(user_rating) as Avg_Rating
From AppleStore
group by prime_genre
order by Avg_Rating
limit 10

-- Check if there is correlation between the length of the app description and the user rating

SELECT case 
			when length(B.app_desc) < 500 then 'Short'
			when length(B.app_desc) between 500 and 1000 then 'Medium'
            else 'Long'
       end as description_length_bucket,
       avg(A.user_rating) as Avg_Rating
FROM
	AppleStore as A
Join
	appleStore_description_combined as B
on
	A.id = B.id

group by description_length_bucket
order by Avg_Rating desc

-- Check the top-rated apps for each genre

SELECT prime_genre,
	   track_name,
       user_rating
FROM (SELECT prime_genre, track_name, user_rating,
      RANK() OVER(PARTITION BY prime_genre ORDER by user_rating desc, rating_count_tot desc)
      as Rank
      from
      AppleStore
      ) as A
   WHERE A.Rank = 1