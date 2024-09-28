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

SELECT * FROM spotify;

-- Exploratory data analysis
SELECT * FROM spotify;

SELECT COUNT(*) FROM spotify;

SELECT DISTINCT artist FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT DISTINCT channel FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;

SELECT MIN(duration_min) FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT * FROM spotify
WHERE duration_min = (SELECT MIN(duration_min) FROM spotify);

DELETE FROM spotify
WHERE duration_min = 0; -- Here, we deleted 2 reccords having duration is equal to zero.

-- Problem (1.) Retrieve the names of all tracks that have more than 1 billion streams.

SELECT track, stream FROM spotify
WHERE stream > 1000000000;

-- Problem (2.) Lists all albums along with their respective artists.

SELECT DISTINCT album, artist FROM spotify
ORDER BY album;

-- Problem (3.) Get the total number for tracks where licensed = TRUE

SELECT SUM(comments) FROM spotify
WHERE licensed = True;

-- Here we breakdown and seperated Total comments by each tracks for more analysis
WITH track_comments AS (
    SELECT 
        track, 
        SUM(comments) AS Total_comments
    FROM 
        spotify
    WHERE 
        licensed = True
    GROUP BY 
        track
)
SELECT 
    track, 
    Total_comments, 
    SUM(Total_comments) OVER() AS Total_comments_overall
FROM 
    track_comments;
-- Here, we created a CTE, because Windows function does not work with GROUP BY clause.

SELECT track, SUM(comments) OVER() FROM spotify
WHERE licensed = True;

-- Problem(4.) Find all tracks that belong to album type Single

SELECT * FROM spotify
WHERE album_type = 'single';

-- Problem(5.) Count the total number of tracks by each artists

SELECT artist, COUNT(*) AS tracks_count
	FROM spotify
GROUP BY artist
ORDER BY tracks_count DESC;

-- Problem(6.) Calculate the average danceability of tracks in each album.

SELECT album, AVG(danceability) AS avg_danceability
	FROM spotify
GROUP BY album
ORDER BY avg_danceability DESC;

-- Problem(7.) Find the top 5 tracks with the highest energy values.

SELECT
	track,
	MAX(energy)
FROM 
	spotify
GROUP BY track
ORDER BY MAX(energy) DESC
LIMIT 5;

-- Problem(8.) List all tracks along with their views and likes where official_video = True.

SELECT
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify
	WHERE official_video = 'true'
	GROUP BY track;

-- Problem(9.) For each album, calculated the total views of all associated tracks.

SELECT
	album,
	track,
	SUM(views) AS total_views
FROM spotify 
	GROUP BY album, track
	ORDER BY total_views DESC;

-- Problem(10.) Retrieve the track names that have been streamed on Spotify more than Youtube.
SELECT
	*
	FROM(
		SELECT
			track,
			COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) AS streamed_on_youtube,
			COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) AS streamed_on_spotify
		FROM
			spotify
		GROUP BY
			track) t1
	WHERE streamed_on_spotify > streamed_on_youtube
	AND
	streamed_on_youtube <> 0;

-- Problem(11.) Find the top 3 most-viewed tracks for each artist using window functions.
WITH ranking_artist
	AS(
		SELECT
			artist,
			track,
			SUM(views) AS total_views,
			DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
		FROM
			spotify
		GROUP BY
			artist,track
		ORDER BY
			artist, total_views DESC)
SELECT * FROM ranking_artist
	WHERE rank <= 3;

-- Problem(12.) Write a query to find the tracks where the liveness score is above the average.

SELECT * FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

-- Problem(13.) 
--Using a WITH clause to calculate the difference between the
--highest and lowest energy values for tracks in each album
WITH cte
	AS(
		SELECT
			album,
			MAX(energy) AS highest_energy,
			MIN(energy) AS lowest_energy
		FROM
			spotify
		GROUP BY
			album)
SELECT
	album,
	(highest_energy -  lowest_energy) AS energy_difference
FROM cte
ORDER BY energy_difference DESC;