-- COMP3311 19T3 Assignment 2
-- Written by <<insert your name here>>

-- Q1 Which movies are more than 6 hours long? 

create or replace view Q1(title)
	as
	select t.main_title from titles t where t.runtime > 360;



-- Q2 What different formats are there in Titles, and how many of each?

create or replace view Q2(format, ntitles)
	as
	select t.format, count(t.format) 
	from titles t 
	group by t.format;



-- Q3 What are the top 10 movies that received more than 1000 votes?

create or replace view Q3(title, rating, nvotes)
	as
	select t.main_title, t.rating, t.format 
	from titles t where t.format = 'movie' and t.nvotes > 1000 
	order by t.rating desc, t.main_title 
	limit 10;
--select t.main_title, t.rating, t.format from titles t where t.rating is not null and (t.format = 'tvSeries' or t.format =             'tvMiniSeries') order by t.rating desc;

-- Q4 What are the top-rating TV series and how many episodes did each have?

create or replace view Q4(title, nepisodes)
	as
	select _t.main_title, nepisodes 
	from (select t.id, count(t.id) nepisodes 
		from titles t 
		join episodes t2 
		on (t.id = t2.parent_id) 
		where t.rating is not null 
		and (t.format = 'tvSeries' or t.format = 'tvMiniSeries') 
		group by t.id) t2 join titles _t on (_t.id = t2.id) 
	where _t.rating = (select max(rating) from titles t);


-- Q5 Which movie was released in the most languages?

create or replace view Q5(title, nlanguages)
	as
	select _t.main_title, nlanguages                                                                                                                                                   
	from (select title_id, count(distinct language) nlanguages                                                                                                                                       
		from aliases where language is not null group by title_id) lang                                                                                                                  
	join titles _t on (title_id = _t.id)                                                                                                                                                     
	where nlanguages = (select max(nlang) from (select title_id, count(distinct language) nlang                                                                                                               
	from aliases where language is not null group by title_id) _l);



-- Movie with rating View
create or replace view movie_with_rating(movie_id, rating)                                                                                                              
	as                                                                                                                                                    
	select id, rating from titles t                                                                                                                               
	where t.rating is not null and t.format = 'movie';

-- name known title rate
create or replace view name_known_title_rate(name_id, title_id)                                                                                                                                        
	as                                                                                                                                                                                       
	select name_id, known.title_id                                                                                                                                                           
	from known_for known                                                                                                                                                                     
	where known.title_id in (select movie_id from movie_with_rating);

-- eligible worker
create or replace view eligible_worker                                                                                                                                              
	as                                                                                                                                                                                       
	select t.name_id                                                                                                                                                                         
	from name_known_title_rate t                                                                                                                                                             
	group by t.name_id                                                                                                                                                                       
	having count(distinct t.title_id) > 1;


-- eligible actors
create or replace view eligible_actors(name_id)
	as
	select name_id from worked_as worker 
	where worker.work_role = 'actor' and worker.name_id in (select * from eligible_worker);


-- actor to title id

create or replace view actor_to_movie(actor, movie)                                                                                                                                                                                      
	as                                                                                                                                                                                                                                            
	select ac.name_id, t.title_id from eligible_actors ac join known_for t on (t.name_id = ac.name_id);

create or replace view actor_to_rating as select ac.actor, ac.movie, t.rating from actor_to_movie ac join titles t on (t.id = ac.movie);

create or replace view act_to_avg(actor, rate) as select ac.actor, avg(ac.rating) from actor_to_rating ac group by ac.actor;
-- Q6 Which actor has the highest average rating in movies that they're known for?

create or replace view Q6(name)
	as
	select _names.name from
	act_to_avg avg
	join names _names on (_names.id = avg.actor)
	where avg.rate =
	(select max(rate) from act_to_avg);


-- Q7 For each movie with more than 3 genres, show the movie title and a comma-separated list of the genres
create or replace view id_to_genre(id, genres)                                                                                                                                                                                                                                   
	as                                                                                                                                                                                                                                                                                    
	select title_id, string_agg(genre, ',' order by genre)                                                                                                                                                                                                                                
	from title_genres                                                                                                                                                                                                                                                                     
	group by title_id                                                                                                                                                                                                                                                                     
	having count(genre) > 3;

create or replace view Q7(title,genres)
	as
	select t.main_title title, v.genres genres 
	from id_to_genre v 
	join titles t on (t.id = v.id);

-- Q8 Get the names of all people who had both actor and crew roles on the same movie

create or replace view ids(name_id)                                                                                                                                                                                                                                              
	as                                                                                                                                                                                                                                                                                    
	select distinct ac.name_id from
	actor_roles ac
	join crew_roles cr on (cr.name_id = ac.name_id and cr.title_id = ac.title_id)
	join titles t on (t.id = ac.title_id)
	where t.format = 'movie';

create or replace view Q8(name)
	as
	select _names.name 
	from ids _ids 
	join names _names 
	on (_names.id = _ids.name_id);

-- Q9 Who was the youngest person to have an acting role in a movie, and how old were they when the movie started?
create or replace view name_to_start(nameid, minyear)
	as
	select ac.name_id, min(_t.start_year)
	from actor_roles ac join titles _t on (_t.id = ac.title_id)
	where _t.format = 'movie'
	group by ac.name_id;
create or replace view name_to_age(name, age)
	as
	select _name.name, abs(ns.minyear - _name.birth_year)
	from name_to_start ns
	join names _name on (_name.id = ns.nameid);

create or replace view Q9(name,age)
	as
	select name, age
	from name_to_age
	where age = (select min(age) from name_to_age);

--

-- Q10 Write a PLpgSQL function that, given part of a title, shows the full title and the total size of the cast and crew
create or replace function                                                                                                                                                                  
	Q10(partial_title text) returns setof text                                                                                                                                               
	as $$                                                                                                                                                                                    
	declare                                                                                                                                                                                         
	 _regex text;                                                                                                                                                                             
	 titleid Record;                                                                                                                                                                          
	 count Integer;                                                                                                                                                                           
	 title_name text; 
	 retnum Integer;                                                                                                                                                               
	 begin                                                                                                                                                                                            
		 count := 0;                                                                                                                                                                             
		  _regex := '%'||partial_title||'%';
		  select count(id) into retnum from ((select id from titles where main_title ilike _regex) intersect ((select title_id from principals) union (select title_id from crew_roles) union (select title_id from actor_roles))) setId;                                                                                                                                                      
		  if retnum = 0 then                                                                                                                                                                           
		  	return next 'No matching titles';                                                                                                                                                     
		  end if;                                                                                                                                                         
		  for titleid in (select id from titles where main_title ilike _regex) intersect ((select title_id from principals) union (select title_id from crew_roles) union(select title_id from actor_roles))                                                                                                                                                                                        
			  loop                                                                                                                                                                                             
				  count := 0;                                                                                                                                                                              
				  select count(distinct name_id) into count from ((select name_id from principals where title_id = titleid.id) union (select name_id from crew_roles where title_id = titleid.id) union (select name_id from actor_roles where title_id = titleid.id)) idset;                                                                                                                       
				  select t.main_title into title_name from titles t where t.id = titleid.id;                                                                                                               
				  return next title_name::text || ' has ' || count::text || ' cast and crew ';                                                                                                     
			  end loop;                                                                                                                                                                
	  end;                                                                                                                                                                                     
$$ language plpgsql;
