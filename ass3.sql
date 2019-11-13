-- COMP3311 19T3 Assignment 3
-- Helper views and functions (if needed)

-- Q1
create or replace view course_count(id, enrolcount) 
	as select e.course_id, count(e.person_id) 
	from course_enrolments e
	join courses c on c.id = e.course_id
	where (c.term_id = 5199 and c.quota > 50) 
	group by e.course_id;

create or replace view id_quota_enrolments(id, quota, enrollments)
	as select c.subject_id, c.quota, d.enrolcount 
	from courses c 
	join course_count d on d.id = c.id 
	where c.quota < d.enrolcount;

create or replace view code_quota_enrollments(code, quota, enrollments)
	as select s.code, q.quota, q.enrollments 
	from id_quota_enrolments q 
	join subjects s on s.id = q.id
	order by s.code;

-- Q2
create or replace view subject_sub(id, first, second)
	as select id, substring(code, 1, 4), substring(code, 5, 8)
	from subjects;

create or replace view subject_count(count,lastfour , firstfour)
	as select count(id), second, string_agg(first, ' ' order by first) 
	from subject_sub 
	group by second 
	order by second;

create or replace function
	get_x_same_subject(same_number integer) returns setof text
	as $$
	declare
		subrecord Record;
	begin
		for subrecord in (select * from subject_count where count = same_number)
			loop
				return next subrecord.lastfour::text || ': ' || subrecord.firstfour::text;
			end loop;   
	end;
$$ language plpgsql;

-- Q3
create or replace view course_id_to_room(course_id, room_id)
	as select distinct c.course_id, m.room_id 
	from classes c 
	join meetings m 
	on m.class_id = c.id;

create or replace view course_id_room_t2(course_id, room_id)
	as select c.course_id, c.room_id 
	from course_id_to_room c 
	join courses cour on cour.id = c.course_id 
	where cour.term_id = 5196;

create or replace view course_id_to_building_t2(course_id, building)
	as select c.course_id, r.within 
	from course_id_room_t2 c 
	join rooms r on r.id = c.room_id;

create or replace view course_id_to_building_name(name, id)
	as select b.name, c.course_id 
	from course_id_to_building_t2 c 
	join buildings b on b.id = c.building;

create or replace view code_to_building(firstfour, code, building)
	as select substring(sub.code, 1, 4), sub.code, c.name 
	from course_id_to_building_name c 
	join courses s on s.id = c.id 
	join subjects sub on sub.id = s.subject_id 
	order by sub.code;

create or replace function 
	get_building_from_prefix(prefix text) returns table(code text, building text)
	as $$
	begin
		return query
		select distinct c.code::text, c.building::text from code_to_building c 
		where firstfour = prefix;
	end;
$$ language plpgsql;

-- Q4

create or replace view code_term_id(firstfour, code, term, course_id)
         as select substring(s.code, 1, 4), s.code, c.term_id, c.id 
         from subjects s 
         join courses c on c.subject_id = s.id 
         order by s.code;

create or replace view course_id_to_count(id, enrolments)
	as select course_id, count(person_id) from course_enrolments group by course_id; 

create or replace view code_to_count(firstfour, code, term, enrolments)
	as select a.firstfour, a.code, a.term, b.enrolments 
	from code_term_id a join course_id_to_count b 
	on a.course_id = b.id;

create or replace function
	get_enrolments_from_prefix(prefix text) returns table(code text, term text, enrolments integer)
	as $$
	begin
		return query
		select c.code::text, c.term::text, c.enrolments::integer from code_to_count c
		where c.firstfour = prefix;
	end;
	$$ language plpgsql;

-- Q5
create or replace view class_counts(enrolments, class_id)
	as select count(person_id), class_id 
	from class_enrolments 
	group by class_id;

create or replace view term3courseid(id, subject_id)
	as select id, subject_id from courses where term_id = 5199;

create or replace view term3original(class_id, course_id, tag, quota, type_id, subject_id)
	as select c.id, c.course_id, c.tag, c.quota, c.type_id, t.subject_id
	from classes c 
	join term3courseid t 
	on c.course_id = t.id;

create or replace view term3type(class_id, course_id, tag, quota, typename, subject_id)
	as select o.class_id, o.course_id, o.tag, o.quota, t.name, o.subject_id 
	from term3original o 
	join classtypes t 
	on o.type_id = t.id;

create or replace view term3literal(tag, quota, enrolments, typename, code)
	as select t.tag, t.quota, c.enrolments, t.typename, s.code 
	from term3type t 
	join class_counts c 
	on c.class_id = t.class_id 
	join subjects s 
	on s.id = t.subject_id
	order by typename, tag;

create or replace function 
	get_class_from_course(coursecode text) returns setof text
	as $$
	declare
		courserecord Record;
	begin
		for courserecord in (select * from term3literal t where t.code = coursecode)
		loop
			continue when courserecord.quota = 0;
			if courserecord.enrolments::numeric / courserecord.quota::numeric < 0.5 then
				return next courserecord.typename || ' ' || courserecord.tag || ' is ' || floor(100*courserecord.enrolments::numeric / courserecord.quota::numeric)::text || '% full';  
			end if;
		end loop;
		
	end;
	$$ language plpgsql;

-- Q6
create or replace function
	get_binary_string(weeks text) returns text
	as $$
	declare
		week_array text array;
		ret integer array[11];
		string text;
		retstring text;
	begin
		if weeks like '%N%' or weeks like '%<%' then
			return '00000000000';
		end if;
		retstring := '';
		week_array := string_to_array(weeks, ',');
		foreach string in array week_array
		loop
			if string like '%-%' then
				for i in (string_to_array(string, '-'))[1]::integer..(string_to_array(string, '-'))[2]::integer loop
					ret[i] := 1;
				end loop;
			else
				ret[string::integer] := 1;
			end if;
			
		
		end loop;		
		for i in 1..11
		loop
			if ret[i] = 1 then
				retstring := retstring || '1';
			else
				retstring := retstring || '0';
			end if;
		end loop;
		return retstring;
	end;
	$$ language plpgsql;

-- Q7
create or replace view class_course_term(class_id, course_id, term_id) 
	as select cla.id, cla.course_id, co.term_id 
	from classes cla 
	join courses co 
	on co.id = cla.course_id;

create or replace view meeting_term(room_id, day, start_time, end_time, weeks_binary, term_id) 
	as select m.room_id, m.day, m.start_time, m.end_time, m.weeks_binary, c.term_id 
	from meetings m join class_course_term c 
	on c.class_id = m.class_id;
