CREATE TABLE spotify (

    track_id VARCHAR(50) PRIMARY KEY,
    track_name VARCHAR(255),
    artist_name VARCHAR(255),
    album_name VARCHAR(255),
    release_date DATE,
    genre VARCHAR(100),
    duration_ms INTEGER,
    popularity INTEGER,
    danceability NUMERIC(4,2),
    energy NUMERIC(4,2),
    key INTEGER,
    loudness NUMERIC(6,2),
    mode INTEGER,
    instrumentalness NUMERIC(6,3),
    tempo NUMERIC(6,2),
    stream_count BIGINT,
    country VARCHAR(100),
    explicit BOOLEAN,
    label VARCHAR(255),
    year INTEGER

);


-- data importing
COPY spotify
FROM 'D:\d for chrome\01spotify_cleaned.csv'
DELIMITER ','
CSV HEADER ;


-- rename column name key to musical key
ALTER TABLE spotify
RENAME COLUMN key TO musicals_key;

-- check total columns
SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name='spotify';


-- check data types
SELECT
column_name,
data_type
FROM information_schema.columns
WHERE table_name='spotify';

-- duplicate check in track_id
SELECT
track_id,
COUNT(*)
FROM spotify
GROUP BY track_id
HAVING COUNT(*) > 1;

-- null values check
SELECT
COUNT(*) FILTER (WHERE track_id IS NULL) AS track_id,
COUNT(*) FILTER (WHERE track_name IS NULL) AS track_name,
COUNT(*) FILTER (WHERE artist_name IS NULL) AS artist_name,
COUNT(*) FILTER (WHERE album_name IS NULL) AS album_name,
COUNT(*) FILTER (WHERE release_date IS NULL) AS release_date,
COUNT(*) FILTER (WHERE genre IS NULL) AS genre,
COUNT(*) FILTER (WHERE duration_ms IS NULL) AS duration_ms,
COUNT(*) FILTER (WHERE popularity IS NULL) AS popularity,
COUNT(*) FILTER (WHERE danceability IS NULL) AS danceability,
COUNT(*) FILTER (WHERE energy IS NULL) AS energy,
COUNT(*) FILTER (WHERE musical_key IS NULL) AS musical_key,
COUNT(*) FILTER (WHERE loudness IS NULL) AS loudness,
COUNT(*) FILTER (WHERE mode IS NULL) AS mode,
COUNT(*) FILTER (WHERE instrumentalness IS NULL) AS instrumentalness,
COUNT(*) FILTER (WHERE tempo IS NULL) AS tempo,
COUNT(*) FILTER (WHERE stream_count IS NULL) AS stream_count,
COUNT(*) FILTER (WHERE country IS NULL) AS country,
COUNT(*) FILTER (WHERE explicit IS NULL) AS explicit,
COUNT(*) FILTER (WHERE label IS NULL) AS label,
COUNT(*) FILTER (WHERE year IS NULL) AS year
FROM spotify;

-- blank values check
SELECT *
FROM spotify
WHERE
TRIM(track_name)=''
OR TRIM(artist_name)=''
OR TRIM(album_name)=''
OR TRIM(genre)=''
OR TRIM(country)=''
OR TRIM(label)='';

-- remove extra space
UPDATE spotify
SET
track_name = TRIM(track_name),
artist_name = TRIM(artist_name),
album_name = TRIM(album_name),
genre = TRIM(genre),
country = TRIM(country),
label = TRIM(label);

-- information
select * from spotify ;

-- remove multipul space
UPDATE spotify
SET artist_name =
REGEXP_REPLACE(artist_name,'\s+',' ','g');

-- invalid popularity
SELECT *
FROM spotify
WHERE popularity < 0
OR popularity > 100;


-- find invalid duration
SELECT *
FROM spotify
WHERE duration_ms <= 0;

-- invalid danceability
SELECT * FROM spotify
WHERE danceability <0
OR danceability >1 ;

-- invalid energy
SELECT * FROM spotify
WHERE energy <0
OR energy >1 ;


-- invalid tempo
SELECT * FROM spotify
WHERE tempo <= 0 ;

-- check invalid year
SELECT * FROM spotify
WHERE year <1990
OR year > EXTRACT (year FROM CURRENT_DATE) ; 

-- release date formate check
SELECT DISTINCT release_date 
FROM spotify
LIMIT 20 ;

-- check data
SELECT COUNT(*)
FROM spotify;

SELECT * FROM spotify
LIMIT 10 ;

-- invalid loudness
SELECT * FROM spotify
WHERE loudness >0 ;

-- invalid tempo
SELECT * FROM spotify
WHERE tempo NOT BETWEEN 20 AND 300 ;

-- invalid steam count
SELECT * FROM spotify
WHERE stream_count < 0 ;

-- all columns remove extra space
UPDATE spotify
SET
track_name = REGEXP_REPLACE(TRIM(track_name), '\s+', ' ', 'g'),
artist_name = REGEXP_REPLACE(TRIM(artist_name), '\s+', ' ', 'g'),
album_name = REGEXP_REPLACE(TRIM(album_name), '\s+', ' ', 'g'),
genre = REGEXP_REPLACE(TRIM(genre), '\s+', ' ', 'g'),
country = REGEXP_REPLACE(TRIM(country), '\s+', ' ', 'g'),
label = REGEXP_REPLACE(TRIM(label), '\s+', ' ', 'g');

-- replace blank string with null 
UPDATE spotify
SET album_name = NULL
WHERE TRIM(album_name) = '';

-- final quality check
SELECT
COUNT(*) AS total_rows,
COUNT(DISTINCT track_id) AS unique_tracks,
COUNT(DISTINCT artist_name) AS unique_artists,
COUNT(DISTINCT genre) AS unique_genres,
COUNT(DISTINCT country) AS unique_countries
FROM spotify;

-- check null records
SELECT *
FROM spotify
WHERE track_name IS NULL
   OR album_name IS NULL;


-- handle track name null   
DELETE FROM spotify
WHERE track_name IS NULL;

-- handle album name null
UPDATE spotify
SET album_name = 'Unknown Album'
WHERE album_name IS NULL;

-- data validation summery
SELECT COUNT(*) AS total_records,
COUNT (DISTINCT track_id) AS unique_track,
COUNT (DISTINCT artist_name) AS unique_artists,
COUNT (DISTINCT album_name) AS unique_album,
COUNT (DISTINCT genre) AS unique_genre,
COUNT (DISTINCT country) AS unique_country
FROM spotify ;

-- duration statistics
SELECT
    ROUND(MIN(duration_ms)/60000.0,2) AS min_duration,
    ROUND(MAX(duration_ms)/60000.0,2) AS max_duration,
    ROUND(AVG(duration_ms)/60000.0,2) AS avg_duration
FROM spotify;

-- instrumentalness check
ALTER TABLE spotify
ADD CONSTRAINT chk_instrumentalness
CHECK (instrumentalness BETWEEN 0 AND 1);

-- set not null in track_name
ALTER TABLE spotify
ALTER COLUMN track_name SET NOT NULL;

-- set not null in artist_name
ALTER TABLE spotify
ALTER COLUMN artist_name SET NOT NULL ;

-- ARTIST NAMES 
CREATE INDEX idx_artist
ON spotify (artist_name) ;

-- genration search 
CREATE INDEX idx_genre
ON spotify (genre) ;

-- year search
CREATE INDEX idx_year
ON spotify (year) ;

-- popularity 
CREATE INDEX idx_popularity
ON spotify (popularity) ;

-- veryfy index
SELECT *
FROM pg_indexes
WHERE tablename='spotify';

-- artistic names like 'tyler swift' find
EXPLAIN ANALYZE

SELECT *
FROM spotify
WHERE artist_name='Taylor Swift';

-- create a view
CREATE VIEW popular_songs AS
SELECT
track_name,
artist_name,
genre,
popularity,
stream_count
FROM spotify
WHERE popularity >= 80;

-- view check
SELECT * FROM popular_songs
LIMIT 20 ;

-- create duration in minuts
CREATE VIEW spotify_analysis AS
SELECT
track_name,
artist_name,
genre,
ROUND(duration_ms/60000.0,2) AS duration_minutes,
popularity,
stream_count,
country,
year
FROM spotify;

-- total songs by eatch artist
SELECT artist_name,
COUNT (*) AS total_songs
fROM spotify
GROUP BY artist_name
ORDER BY total_songs DESC ;

-- top 10 songs
SELECT artist_name,
COUNT(*) AS total_songs
FROM spotify
GROUP BY artist_name
ORDER BY total_songs DESC 
LIMIT 10 ;

-- average popularity of eatch artist
SELECT artist_name,
ROUND(AVG(popularity),2) AS avg_popularity
FROM spotify
GROUP BY artist_name
ORDER BY avg_popularity DESC ;

-- artist with high stream count
SELECT artist_name,
SUM(stream_count) AS total_streams
FROM spotify
GROUP BY artist_name
ORDER BY total_streams DESC
LIMIT 10;

-- average song duration by arrtist
SELECT artist_name,
ROUND (AVG (duration_ms)/60000.0,2) AS avg_duration_minuts
FROM spotify
GROUP BY artist_name
ORDER BY avg_duration_minuts DESC ;

-- Number of songs by genre
SELECT genre,
COUNT(*) AS total_songs
FROM spotify
GROUP BY genre
ORDER BY total_songs DESC ;

-- ave popularity by gen
SELECT genre,
ROUND(AVG(popularity),2) AS avg_popularity
FROM spotify
GROUP BY genre
ORDER BY avg_popularity DESC ;

-- genre of high stream
SELECT genre,
SUM(stream_count) AS total_stream
FROM spotify
GROUP BY genre
ORDER BY total_stream DESC ;

-- most energatic genre
SELECT genre,
ROUND (AVG(energy),2) AS total_energy
FROM spotify
GROUP BY genre
ORDER BY total_energy ;

-- most danceble genre
SELECT genre,
ROUND(AVG(danceability),2) AS avg_danceability
FROM spotify
GROUP BY genre
ORDER BY avg_danceability DESC ;


-- country analisis
SELECT country,
COUNT(*) total_songs
FROM spotify
GROUP BY country
ORDER BY total_songs DESC ;

-- top countrys by stream count
SELECT country,
SUM(stream_count) AS total_stream
FROM spotify
GROUP BY country
ORDER BY total_stream DESC ;

-- average popularity by country
SELECT country,
ROUND(AVG(popularity),2) AS total_popularity
FROM spotify
GROUP BY country
ORDER BY total_popularity DESC ;

-- songs release each year
SELECT year,
COUNT(*) AS total_songs
FROM spotify
GROUP BY year
ORDER BY year ;

-- average popularity by year
SELECT year,
ROUND(AVG(popularity),2) AS avg_popularity
FROM spotify
GROUP BY year
ORDER BY year 

-- strean by year
SELECT year,
SUM (stream_count) AS total_stream
FROM spotify
GROUP BY year
ORDER BY year

-- top 20 most popular songs
SELECT 
track_name,
artist_name,
popularity
FROM spotify
ORDER BY popularity
LIMIT 20 ;

-- top 20 most streamed songs
SELECT
track_name,
artist_name,
stream_count
FROM spotify
ORDER BY stream_count DESC
LIMIT 20 ;

-- song avobe average popularitry
SELECT * FROM spotify
WHERE popularity >
(SELECT AVG(popularity)
FROM spotify

) ;


-- rank song by popularity
SELECT
track_name,
artist_name,
popularity,
RANK() OVER(
ORDER BY popularity DESC
) AS song_rank
FROM spotify ;

-- dense rank
SELECT
track_name,
artist_name,
popularity,
DENSE_RANK() OVER(
ORDER BY popularity DESC
) AS densc_rank
FROM spotify ;

-- row number
SELECT
ROW_NUMBER () OVER(
ORDER BY popularity
) AS row_num,
track_name,
artist_name,
popularity
FROM spotify ;


-- top song from every gen
SELECT * FROM
(
SELECT
track_name,
genre,
popularity,
ROW_NUMBER() OVER(
PARTITION BY genre
ORDER BY popularity DESC
) rn
FROM spotify
) x
WHERE rn=1 ;

-- top 3 songs from every genre
SELECT * FROM 
(
SELECT
track_name,
genre,
popularity,
DENSE_RANK() OVER
(
PARTITION BY genre
ORDER BY popularity DESC
) AS ranking
FROM spotify
) t
WHERE ranking <=3 ;


-- preveus song popularity
SELECT
track_name,
year,
popularity,
LAG(popularity)
OVER(
ORDER BY year
)
AS previus_popularity
FROM spotify ;

-- popularity difrence
SELECT
track_name,
year,
popularity,
LAG(popularity)
OVER(
ORDER BY year
)
AS differnce
FROM spotify ;

-- show next row value
SELECT
track_name,
year,
popularity,
LEAD(popularity)
OVER(
ORDER BY year
)
AS next_popularity
FROM spotify ;

-- frist value()
SELECT
genre,
track_name,
FIRST_VALUE(track_name) 
OVER (
PARTITiON BY genre
ORDER BY popularity DESC
)
AS best_song
FROM spotify ;

-- last value()
SELECT
genre,
track_name,
LAST_VALUE(track_name)
OVER (
PARTITION BY genre
ORDER BY popularity
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
)
AS least_popular
FROM spotify ;

-- Ntill 
SELECT
track_name,
popularity,
NTILE(4)
OVER
(
ORDER BY popularity DESC
)
AS quartile
FROM spotify ;

-- artist having average popularity (CTE)
WITH artist_popularity AS
(
SELECT 
artist_name,
AVG(popularity) avg_popularity
FROM spotify
GROUP BY artist_name
)
SELECT * FROM artist_popularity
WHERE avg_popularity >80 ;

-- multiple CTE
WITH genre_streams AS
(
SELECT
genre,
SUM(stream_count) streams
FROM spotify
GROUP BY genre
),
avg_stream AS 
(
SELECT AVG(streams) avg_streams
FROM genre_streams
)
SELECT * FROM genre_streams
WHERE streams >
(
SELECT avg_stream
AS avg_streams
) ;

-- lalaser hai
WITH genre_streams AS
(
SELECT
genre,
SUM(stream_count) streams
FROM spotify
GROUP BY genre
),
avg_stream AS
(
SELECT AVG(streams) avg_stream
FROM genre_streams
)
SELECT *
FROM genre_streams
WHERE streams >
(
SELECT avg_stream
FROM avg_stream
);

-- give song category about song population (CASE WHEN)

SELECT
track_name,
artist_name,
Popularity,

CASE 
WHEN popularity >= 90 THEN 'super hit'
WHEN popularity >= 75 THEN 'hit'
WHEN popularity >= 50 THEN 'average'
ELSE 'Low popularity'
END AS popularity_category
FROM spotify ;

-- handling NULL values(coalesce)
SELECT
track_name,
COALESCE(album_name,'Unknown Album') AS album_name
FROM spotify;

-- convert blank values to null
SELECT
NULLIF(TRIM(album_name),'')
FROM spotify ;

-- genre most popular song
SELECT
s1.track_name,
s1.genre,
s1.popularity
FROM spotify s1
WHERE popularity =
(
SELECT MAX(popularity)
FROM spotify s2
WHERE s1.genre = s2.genre
) ;

-- each artist exists 90+ popularity songs
SELECT DISTINCT artist_name
FROM spotify s1
WHERE EXISTS 
(
SELECT 1
FROM spotify s2
WHERE s1.artist_name = s2.artist_name
AND popularity >=90
) ;

-- moving average
SELECT
track_name,
popularity,
AVG(popularity)
OVER
(
ORDER BY year
ROWS BETWEEN 2 PRECEDING
AND CURRENT ROW
)
AS moving_average
FROM spotify;

-- percent rank
SELECT
track_name,
popularity,
PERCENT_RANK()
OVER
(
ORDER BY popularity
)
FROM spotify;

-- CUME_DIST
SELECT
track_name,
popularity,
CUME_DIST()
OVER
(
ORDER BY popularity
)
FROM spotify;

-- top 5 songs every artist
SELECT *
FROM
(
SELECT
artist_name,
track_name,
popularity,
ROW_NUMBER()
OVER
(
PARTITION BY artist_name
ORDER BY popularity DESC
)
AS rn
FROM spotify
)t

WHERE rn<=5;

-- second most popular songs
SELECT *
FROM
(
SELECT
track_name,
artist_name,
popularity,
DENSE_RANK()
OVER
(
ORDER BY popularity DESC
)
AS ranking
FROM spotify
)t
WHERE ranking=2;

-- artist performance reports
SELECT
artist_name,
COUNT(*) total_songs,
ROUND(AVG(popularity),2) avg_popularity,
SUM(stream_count) total_streams,
ROUND(AVG(duration_ms)/60000.0,2) avg_duration
FROM spotify
GROUP BY artist_name
ORDER BY total_streams DESC;

-- genre performance report
SELECT
genre,
COUNT(*) total_songs,
ROUND(AVG(popularity),2) avg_popularity,
SUM(stream_count) total_streams,
ROUND(AVG(energy),2) avg_energy,
ROUND(AVG(danceability),2) avg_danceability
FROM spotify
GROUP BY genre
ORDER BY total_streams DESC;

-- dashboard query
SELECT
COUNT(*) total_songs,
COUNT(DISTINCT artist_name) total_artists,
COUNT(DISTINCT genre) total_genres,
SUM(stream_count) total_streams,
ROUND(AVG(popularity),2) avg_popularity,
ROUND(AVG(duration_ms)/60000.0,2) avg_duration
FROM spotify;


-- recursive CTE
WITH RECURSIVE numbers AS
(
SELECT 1 AS n
UNION ALL
SELECT n+1
FROM numbers
WHERE n<10
)
SELECT *
FROM numbers;

-- recursive year generatar
WITH RECURSIVE years AS
(
SELECT MIN(year) AS yr
FROM spotify
UNION ALL
SELECT yr+1
FROM years
WHERE yr <
(
SELECT MAX(year)
FROM spotify
)
)
SELECT *
FROM years;

-- pivot table
-- genre vs explicit songs
SELECT
genre,
COUNT(*) FILTER (WHERE explicit=true) AS explicit_song,
COUNT(*) FILTER (WHERE explicit=false) AS clean_song
FROM spotify
GROUP BY genre;

-- condition aggregation
SELECT
artist_name,
COUNT(*) total_song,
SUM
(
CASE
WHEN popularity>=80
THEN 1
ELSE 0
END
) AS hit_song
FROM spotify
GROUP BY artist_name;

-- STRING_AGG()
-- one artist total album
SELECT
artist_name,
STRING_AGG(album_name, ', ')
FROM spotify
GROUP BY artist_name;

-- ARRAY_AGE(
SELECT
artist_name,
ARRAY_AGG(track_name)
FROM spotify
GROUP BY artist_name;

-- top artist per country
SELECT *
FROM
(
SELECT
country,
artist_name,
SUM(stream_count) total_stream,
ROW_NUMBER()
OVER
(
PARTITION BY country
ORDER BY SUM(stream_count) DESC
)
rn
FROM spotify
GROUP BY country,artist_name
)t
WHERE rn=1;

-- top artist per year
SELECT *
FROM
(
SELECT
year,
album_name,
SUM(stream_count) streams,
RANK()
OVER
(
PARTITION BY year
ORDER BY SUM(stream_count) DESC
)
ranking
FROM spotify
GROUP BY year,album_name
)t
WHERE ranking=1;

-- corellatin analisis
-- popularity vs stream
SELECT
CORR(popularity,stream_count)
FROM spotify;

-- z score
SELECT
track_name,
popularity,
ROUND(
(
popularity-
AVG(popularity)
OVER()
)
/
STDDEV(popularity)
OVER()
,2)
AS z_score
FROM spotify;

-- materialisd view
CREATE MATERIALIZED VIEW artist_summary
AS
SELECT
artist_name,
COUNT(*) total_song,
AVG(popularity) avg_popularity,
SUM(stream_count) total_stream
FROM spotify
GROUP BY artist_name;

-- refresh
REFRESH MATERIALIZED VIEW artist_summary;


-- stored function
CREATE OR REPLACE FUNCTION artist_song_count
(
artist VARCHAR
)
RETURNS INTEGER
AS
$$
SELECT COUNT(*)
FROM spotify
WHERE artist_name=artist;
$$
LANGUAGE SQL;

-- business kpi report
SELECT
COUNT(*) total_song,
COUNT(DISTINCT artist_name) total_artist,
COUNT(DISTINCT genre) total_genre,
ROUND(AVG(popularity),2) avg_popularity,
SUM(stream_count) total_stream,
ROUND(AVG(duration_ms)/60000.0,2) avg_duration
FROM spotify;



-- cleaned data save
-- df.to_csv("spotify_cleaned.csv", index=False)
















