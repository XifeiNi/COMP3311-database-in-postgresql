create or replace function fixCoursesOnAddCourseEnrolment() returns trigger
as $$
declare
	_ns integer; _ne integer; _sum integer; _avg float;
begin
	select ns, ne, avgEval from Courses
	where new.id = id;
	_ns := ns + 1;
	if (new.stuEval is not null) then
		_ne := ne + 1;
		if (_ns < 10 or (3*_ne) < _ns) then
			_avg = null;
		else
			select sum(stuEval) into _sum from Courses c where new.id = c.id;
			_sum := _sum + new.stuEval;
			_avg := _sum::float/_ne;
		end if;
	end if;
	update Courses set ns = _ns, ne = _ne, avgEval = _avg where new.id = id;

	return new;
end;
$$
language plpsql;
