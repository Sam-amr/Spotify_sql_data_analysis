# SPOTIFY DATA ANALYSIS USING SQL

### Overview
The Spotify data analysis project focuses on exploring music streaming data to gain insights into songs, artists, albums, and listener engagement. Using SQL, the project involves cleaning the dataset, analyzing track popularity, album types, and streaming platforms, and performing calculations on metrics such as energy, danceability, views, and likes. Key analyses include identifying top-streamed tracks, most active artists, platform-specific performance, and trends in musical attributes. The project demonstrates how SQL can turn raw streaming data into actionable insights for music recommendation, marketing strategies, and content optimization.

### Objectives
1. Identify the most viewed, liked, and streamed tracks.
2. Determine top-performing artists and albums using aggregated metrics.
3. Study how energy, liveness, tempo, and other features impact engagement
4. Analyze differences in streaming trends between Spotify and YouTube
5. Calculate cumulative likes, views, and trends to understand audience preferences

### Schema 
``` sql
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
```

### Basic Operations
``` sql
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
```

## Business Problems and Solutions 

### 1. Retrieve the names of all tracks that have more than 1 billion streams.
``` sql
SELECT * FROM spotify
WHERE stream > 1000000000
```

### 2. List all albums along with their respective artists.
``` sql
SELECT 
 DISTINCT album, artist
FROM spotify
ORDER BY 1
```
### 3. Get the total number of comments for tracks where licensed = TRUE.
``` sql
SELECT 
    SUM(comments)
FROM spotify
    WHERE 
        licensed = 'true'
```

### 4. Find all tracks that belong to the album type single.
``` sql
SELECT 
	track
FROM spotify
       WHERE
	    album_type ILIKE 'single'
```
		
### 5. Count the total number of tracks by each artist.
``` sql 
SELECT 
artist,
COUNT(*) AS total_no_of_songs
FROM spotify
GROUP BY artist
```

### 6. Calculate the average danceability of tracks in each album.
``` sql
SELECT
      album,
	  avg(danceability) as avg_dability
FROM spotify
GROUP BY 1   
ORDER BY 2 DESC
```

### 7. Find the top 5 tracks with the highest energy values.
``` sql
SELECT
    track, 
    MAX(energy) as Max_energy
FROM spotify
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 5
 ```

### 8. List all tracks along with their views and likes where official_video = TRUE.
``` sql
SELECT 
   track,
   SUM(views) AS total_views,
   SUM(likes) AS total_likes
FROM spotify
WHERE  official_video = 'true'  
GROUP BY 1
ORDER BY 2 DESC
```

### 9. For each album, calculate the total views of all associated tracks.
``` sql
SELECT 
      album, 
	  track,
      SUM(views)
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC
```

### 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
``` sql
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
```

### 11. Find the top 3 most-viewed tracks for each artist using window functions.
``` sql
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
```

### 12. Write a query to find tracks where the liveness score is above the average.
``` sql
SELECT 
    track,
    liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);
```

### 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
``` sql
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
```

### 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
``` sql
SELECT 
    track,
    energy,
    liveness,
    (energy / NULLIF(liveness, 0)) AS energy_to_liveness_ratio
FROM spotify
WHERE (energy / NULLIF(liveness, 0)) > 1.2;
```

### 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
``` sql
SELECT 
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_likes
FROM spotify
ORDER BY views;
```

## Key Findings 
1. The dataset comprises a diverse set of artists, tracks, and albums, enabling analysis of content distribution and platform catalog structure.

2. Data preprocessing involved removing tracks with 0 duration, ensuring accuracy in downstream analysis.

3. Album and album type analysis (e.g., single, EP, full album) provides insights into content categorization and identifies the total number of unique albums and contributing artists.

4. Tracks exceeding 1 billion streams were identified, highlighting high-impact, globally popular content.

5. Artist-level aggregation reveals prolific contributors and their total track counts, demonstrating content creation trends.

6. Average danceability per album was computed to assess rhythmic and engagement characteristics of music collections.

7. High-energy tracks were highlighted to understand songs with intense musical dynamics.

8. Analysis of official videos including total views and likes offers insight into audience engagement on visual platforms.

9. Cross-platform comparison of Spotify vs. YouTube streams identifies platform-specific popularity and performance trends.

10. Top-performing tracks per artist were derived using window functions, emphasizing key hits and audience preferences.

11. Tracks with above-average liveness scores indicate higher audience interaction or live performance characteristics.

12. Energy variation per album and energy-to-liveness ratios provide detailed metrics on musical intensity and track dynamics.

13. Cumulative likes analysis by views helps identify trending tracks and understand the progressive growth of content popularity.
    
## Conclusion
In conclusion, this project demonstrates the ability to extract, clean, and analyze large-scale music streaming data using SQL. By exploring tracks, albums, and artists, the analysis provided insights into content popularity, engagement metrics, and platform-specific performance. Key outcomes include identifying top-streamed songs, high-energy tracks, audience engagement patterns, and trends across album types and artists. Overall, the project showcases technical proficiency in SQL, data aggregation, window functions, and analytical reasoning, highlighting the ability to turn raw data into actionable insights for music recommendation, marketing strategy, and content optimization.



