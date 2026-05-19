-- Cumulative table generation (part 2, done)
DO $$
DECLARE
    film_year INT;
BEGIN
    FOR film_year IN 1970..2021 LOOP
INSERT INTO actors
WITH yesterday AS (
		SELECT * FROM actors
		WHERE current_year = film_year
	),
today AS (
		SELECT * FROM actor_films
		WHERE year = film_year + 1
	)
--
SELECT
	COALESCE (t.actor, y.actor) AS actor,
	CASE WHEN y.films IS NULL
		THEN ARRAY[ROW(
			t.film,
			t.votes,
			t.rating,
			t.filmid
		)::film_type]
	WHEN t.film IS NOT NULL THEN y.films || ARRAY[ROW(
			t.film,
			t.votes,
			t.rating,
			t.filmid
		)::film_type]
	ELSE y.films
	END AS films,
	CASE 
		WHEN t.film IS NOT NULL THEN 
		(CASE
			WHEN t.rating > 8 THEN 'star'::quality_class
			WHEN t.rating > 7 THEN 'good'::quality_class
			WHEN t.rating > 6 THEN 'average'::quality_class
			ELSE 'bad'::quality_class
		END)
		ELSE y.quality_class
	END AS quality_class,
	CASE
		WHEN t.year = 2026 THEN TRUE
		ELSE FALSE
	END AS is_active,
	film_year AS current_year
	
FROM today t FULL OUTER JOIN yesterday y
	ON t.actor = y.actor;
END LOOP;
END $$

SELECT *
FROM actors
WHERE current_year = 2020