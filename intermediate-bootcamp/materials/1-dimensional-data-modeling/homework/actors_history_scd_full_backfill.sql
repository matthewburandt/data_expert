INSERT INTO actors_history_scd
WITH streak_started AS (
	SELECT
		actor,
		current_year,
		quality_class,
		is_active,
		LAG(quality_class, 1) OVER (
			PARTITION BY actor
			ORDER BY current_year
		) <> quality_class
		OR LAG(quality_class, 1) OVER (
			PARTITION BY actor
			ORDER BY current_year
		) IS NULL
		OR LAG(is_active, 1) OVER (
			PARTITION BY actor
			ORDER BY current_year
		) <> is_active
        AS change_indicator
	FROM actors
),
streak_identified AS (
    SELECT
        actor,
		current_year,
        quality_class,
		is_active,
        SUM(CASE WHEN change_indicator THEN 1 ELSE 0 END) OVER (
            PARTITION BY actor
            ORDER BY current_year
        ) AS streak_identified
    FROM streak_started
),
aggregated AS (
    SELECT
        actor,
        quality_class,
        streak_identified,
		is_active,
        MIN(current_year) AS start_date,
        MAX(current_year) AS end_date
    FROM streak_identified
    GROUP BY
        actor,
        quality_class,
        streak_identified,
		is_active
)

SELECT 
	actor,
	start_date,
	end_date,
	quality_class,
	is_active,
	2026 AS current_year
FROM aggregated
ORDER BY actor, start_date

SELECT *
FROM actors_history_scd