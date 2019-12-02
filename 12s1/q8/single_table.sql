create table Employee {
	id integer,
	primary key (id),
	position text,
	etype text not null check (etype in ('part-time', 'casual')),
	fraction float check (0.0 <= fraction <= 1.0),
	primary key (id),
	constraint checkValidData 
		check ((etype = 'part-time' and fraction is not null) or
			(etype = 'casual' and fraction is null))
};

create table WorkHours {
	id integer references Employee(id),
	onDate date,
	start time,
	end, time,
	primary key (id, onDate),
	constraint timing check (start < end)
};
