-- Create DDL for an actors table (part 1, done)
CREATE TABLE actors (
	actor TEXT,
	films film_type[],
	quality_class quality_class,
	is_active BOOLEAN,
	current_year INT
)