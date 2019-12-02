create table Employee {
	id integer,
	name text,
	position text,
	primary key (id)
};

create table Casual {
	id integer reference Employee(id),
	fraction float check (0.0 < fraction < 1.0),
	primary key (id)
};

create table Parttime {
	id integer reference Employee(id),
	primary key (id)

};

create table HoursWorked {
	id integer reference Casual(id),
	onDate date,
	start time,
	end time,
	primary key (id, onDate),
	constraint timing check (start < end)
}
