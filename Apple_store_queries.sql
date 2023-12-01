--Combining all four description tables as as one table
CREATE TABLE store_desc(
  id INTEGER ,
  track_name VARCHAR,
  size_bytes BIGINT ,
  app_desc VARCHAR
  )
  
  INSERT INTO store_desc(id,track_name,size_bytes,app_desc)
  SELECT id,track_name,size_bytes,app_desc FROM "appleStore_description1"
  UNION ALL
  SELECT id,track_name,size_bytes,app_desc FROM "appleStore_description2"
  UNION ALL
  SELECT id,track_name,size_bytes,app_desc FROM "appleStore_description3"
  UNION ALL
  SELECT id,track_name,size_bytes,app_desc FROM "appleStore_description4";


**EXPLORATORY DATA ANALYSIS**
--check the number of unique data in both the tablesapple_store

SELECT COUNT(Distinct id) As unique_apps
FROM apple_store

SELECT COUNT(Distinct id) As unique_apps
FROM store_desc

-- check for any missing values in key fields 

SELECT COUNT(*)
FROM apple_store
WHERE track_name IS null OR user_rating IS null OR prime_genre IS NULL

SELECT COUNT(*)
FROM store_desc
WHERE app_desc IS NULL

1--Find out the number of apps per genre 
--(this will give the types distribution in apple store/gives dominats geners)
SELECT prime_genre, COUNT(prime_genre) AS Number_of_apps
FROM apple_store
GROUP BY 1
ORDER BY 2 DESC

--Get an overview of ratings

SELECT	MIN(user_rating) AS Max_rating,
		MAX(user_rating) AS Max_rating,
        AVG(user_rating) AS Avg_rating
FROM apple_store

2--Determine whether paids have higher ratings than free apps

SELECT CASE
			WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
       END AS App_Type,
       AVG(user_rating) AS Avg_rating
FROM apple_store
GROUP BY App_Type

3--check if apps with more supported language has higher ratings

SELECT CASE
			WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
       END AS language_bucket,
       AVG(user_rating) AS Avg_ratings
FROM apple_store
GROUP BY language_bucket
ORDER BY Avg_ratings DESC
4--middle bucket has higher ratings so we don't need to work on so many languages 

--check genre with lower ratings!

SELECT	prime_genre, 
		AVG(user_rating) AS Average_rating
FROM apple_store
GROUP BY 1
ORDER BY Average_rating ASC
LIMIT 10;
--Users gave bad ratings meaning that they are not satisfied 
--there might be a good oportunity to craete good apps in these category

5-- check if there is a correlation between the lenght of app description and the user ratings 

SELECT CASE
 			WHEN LENGTH(sd.app_desc) < 500 THEN 'Short'
            WHEN LENGTH(sd.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
            ELSE 'Long' 
            END AS app_desc_length,
            AVg(user_rating) AS Average_rating 
FROm apple_store AS ab
JOIN store_desc AS sd
ON ab.id = sd.id
GROUP BY app_desc_length
ORDER BY Average_rating DESC
-- longer the description better is the user rating on average 

6--check the top rated apps for each genre
SELECT prime_genre, track_name, user_rating
FROM(
  SELECT prime_genre,
              track_name,
              user_rating,
              RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC ) as rnk
              FROM   apple_store) AS ab
WHERE rnk = 1