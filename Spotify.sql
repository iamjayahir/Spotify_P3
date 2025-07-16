-- SQL Project On Sportify Datasets

-- Creating Table

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
-- VIEW TABLE
SELECT 
	*
FROM spotify
LIMIT 100;

-- Exploratry Data Analysis

-- Checking Total number of records
SELECT
	COUNT(*)
FROM 
	spotify;

-- Counting distintict artists
SELECT
	COUNT(DISTINCT(artist))
FROM 
	spotify;

-- Count of distinct albums
SELECT
	COUNT(DISTINCT(album))
FROM 
	spotify;

-- Types of Albums types
SELECT
	DISTINCT(album_type)
FROM 
	spotify;

-- Checking for MAX and MIN duration_min

SELECT
	MAX(duration_min)
FROM
	spotify;

SELECT
	MIN(duration_min)
FROM
	spotify;  -- Here I got the output with 0 min so I need to dig deep here.

-- Checking all the records with duration of 0 min

SELECT 
	*
FROM 
	spotify
WHERE
	duration_min = 0; -- I found 2 records with duration of 0 min so I am deleting  these records.

DELETE FROM spotify
WHERE duration_min = 0;

-- Checking again

SELECT 
	*
FROM 
	spotify
WHERE
	duration_min = 0; -- Done I do not have any record with 0 min duration.

--Checking for unique channles

SELECT 
	DISTINCT channel
FROM 
	spotify;

--Counting  the most used platfrom 

SELECT 
	most_played_on,
		COUNT(*)
FROM 
	spotify
GROUP BY
	1
ORDER BY
	2 DESC ;

-- --------------------------------------------
-- DATA ANALYSIS
-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
SELECT
	track
FROM 
	spotify
WHERE 
	stream > 1000000000;

-- 2. List all albums along with their respective artists.
SELECT 
	artist,
	album
FROM
	spotify
GROUP BY 
	1,
	2;

-- 3. Get the total number of comments for tracks where licensed = TRUE.

SELECT
	licensed,
	SUM(comments)
FROM
	spotify
WHERE 
	licensed = 'true'
GROUP BY licensed;
	
-- 4. Find all tracks that belong to the album type single.

SELECT
	track,
	album_type
FROM 
	spotify
WHERE album_type ='single';


-- 5. Count the total number of tracks by each artist.

SELECT 
	artist,
	COUNT(*)
FROM 
	spotify
GROUP BY
	1
ORDER BY 
	2 ;

-- 6. Calculate the average danceability of tracks in each album.

SELECT 
	album,
	AVG (danceability) avg_danceability
FROM Spotify
GROUP BY
	1
ORDER BY 
	2 DESC ;

-- 7. Find the top 5 tracks with the highest energy values.
SELECT 
	track,
	energy
FROM 
	spotify
ORDER BY 
	2 DESC
LIMIT 5;

-- 8. List all tracks along with their views and likes where official_video = TRUE.
SELECT 
	track,
	SUM(views) AS Total_views,
	SUM(likes) AS Total_likeS
FROM
	 spotify
WHERE 
	official_video = 'true'
GROUP BY
	track 
ORDER BY 
	2 DESC;
	
-- 9. For each album, calculate the total views of all associated tracks.
SELECT 
	album,
	track,
	SUM(views) AS Total_views
fROM 
	spotify
GROUP BY
	1,
	2
ORDER BY 
	2 DESC;
	
-- 10.Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT 
	*
FROM
(
	SELECT 
		track,
		-- most_played_on,
		COALESCE (SUM (CASE WHEN most_played_on = 'Spotify' THEN stream END ),0) AS Streamed_on_spotify,
		COALESCE (SUM (CASE WHEN most_played_on = 'Youtube' THEN stream END ),0) AS Streamed_on_youtube	
	FROM 
		spotify
	GROUP BY
		1
		
	) AS T1
	
WHERE 
	Streamed_on_spotify >  Streamed_on_youtube
	AND
	Streamed_on_youtube <> 0;

-- 11. Find the top 3 most-viewed tracks for each artist using window functions.

WITH ranking AS 
(
	SELECT
		artist,
		track,
		SUM(views) As_total_views,
		DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
	FROM
		spotify
	GROUP BY
		1,
		2
	ORDER BY
		1
	)

SELECT
	* 
FROM 
	ranking
WHERE rank <= 3;
	
-- 12. Write a query to find tracks where the liveness score is above the average.
SELECT 
	track
FROM 
	spotify
WHERE 
	liveness > (SELECT AVG(liveness) FROM spotify);

-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH energy AS (

	SELECT 
		album,
		MAX(energy) AS max_enegy,
		MIN (energy) AS min_energy
	FROM 
		spotify
	GROUP BY
		1
)

SELECT 
	album,
	(max_enegy - min_energy) AS diff_energy
FROM
	energy;


-- Query Optimaization

EXPLAIN ANALYZE -- PT 0.080 ms , ET 1.968 ms

SELECT
	artist,
	track,
	views
FROM
	spotify
WHERE 
	artist = 'Gorillaz'
ORDER BY
	stream DESC
LIMIT 
	25;


-- Creating Index

CREATE INDEX artist_index ON spotify (artist);

-- After creating index query execution time 

EXPLAIN ANALYZE -- PT 0.093 ms , ET 0.075 ms

SELECT
	artist,
	track,
	views
FROM
	spotify
WHERE 
	artist = 'Gorillaz'
ORDER BY
	stream DESC
LIMIT 
	25;



