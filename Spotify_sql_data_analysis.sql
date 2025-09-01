DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify 
(
    artist VARCHAR(300),
    track VARCHAR(300),
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
    likes FLOAT,       
    comments FLOAT,     
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

SELECT * FROM spotify;

---TOTAL ALBUMS---
SELECT COUNT(*) FROM spotify

---Number of artists---
SELECT COUNT(DISTINCT artist) FROM spotify

---No. of albums---
SELECT COUNT(DISTINCT album) FROM spotify

--Number of album types---
SELECT COUNT(DISTINCT album_type) FROM spotify

---What are the different tyoes of album---
SELECT DISTINCT album_type FROM spotify

---Is itan official video or not (TRUE/FALSE)---
SELECT COUNT(DISTINCT official_video) FROM spotify

---Max duration of song ---
SELECT MAX(duration_min) FROM spotify

---Min duration of song---
SELECT MIN(duration_min) FROM spotify

---Find and Delete data where duration is 0 min---
SELECT * FROM spotify
WHERE duration_min=0

DELETE FROM spotify
WHERE duration_min=0

---Which are the distinct channels from spotify---
SELECT DISTINCT channel FROM spotify 

---Songs most played on which medium---
SELECT DISTINCT most_played_on FROM spotify 

---BUSINESS QUESTIONS---

---1. Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify
WHERE stream > 1000000000

---2. List all albums along with their respective artists.
SELECT 
 DISTINCT album, artist
FROM spotify
ORDER BY 1

---3. Get the total number of comments for tracks where licensed = TRUE.
SELECT 
    SUM(comments)
FROM spotify
    WHERE 
        licensed = 'true'

---4. Find all tracks that belong to the album type single.
SELECT 
	track
FROM spotify
       WHERE
	    album_type ILIKE 'single'
		
---5. Count the total number of tracks by each artist.
SELECT 
artist,
COUNT(*) AS total_no_of_songs
FROM spotify
GROUP BY artist

---6. Calculate the average danceability of tracks in each album.
SELECT
      album,
	  avg(danceability) as avg_dability
FROM spotify
GROUP BY 1   
ORDER BY 2 DESC

---7. Find the top 5 tracks with the highest energy values.
SELECT
    track, 
    MAX(energy) as Max_energy
FROM spotify
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 5
 
---8. List all tracks along with their views and likes where official_video = TRUE.
SELECT 
   track,
   SUM(views) AS total_views,
   SUM(likes) AS total_likes
FROM spotify
WHERE  official_video = 'true'  
GROUP BY 1
ORDER BY 2 DESC

---9. For each album, calculate the total views of all associated tracks.
SELECT 
      album, 
	  track,
      SUM(views)
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC

---10. Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM 
(
SELECT
     track,
	 COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as most_youtube,
	 COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as most_spotify
FROM spotify
GROUP BY 1
) AS t1
WHERE 
    most_spotify > most_youtube
	AND 
	most_youtube<> 0;

---11. Find the top 3 most-viewed tracks for each artist using window functions.
WITH ranking_artist 
AS
(
SELECT 
    artist,
	track,
	SUM(views) as total_views,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views)DESC ) as ranks
FROM spotify
GROUP BY 1, 2
ORDER BY 1,3 DESC
) 
SELECT * FROM ranking_artist
WHERE ranks <= 3

----12. Write a query to find tracks where the liveness score is above the average.
SELECT 
    track,
    liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

---13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH energy_stats AS (
    SELECT 
        album,
        MAX(energy) AS max_energy,
        MIN(energy) AS min_energy
    FROM spotify
    GROUP BY album
)
SELECT 
    album,
    (max_energy - min_energy) AS energy_difference
FROM energy_stats;

---14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT 
    track,
    energy,
    liveness,
    (energy / NULLIF(liveness, 0)) AS energy_to_liveness_ratio
FROM spotify
WHERE (energy / NULLIF(liveness, 0)) > 1.2;

---15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_likes
FROM spotify
ORDER BY views;
