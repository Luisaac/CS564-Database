CREATE TABLE movie(
mid int primary key,
title varchar(50),
genre varchar(10),
release_date date,
review float(2)
);
CREATE TABLE actor(
aid int primary key,
name varchar(40),
gender varchar(6),
birth_date date,
nationality varchar(20)
);
CREATE TABLE director(
did int primary key,
name varchar(40),
nationality varchar(20)
);
CREATE TABLE movie_info(
iid int primary key,
mid int,
aid int,
did int,
FOREIGN KEY(mid) REFERENCES movie(mid),
FOREIGN KEY(aid) REFERENCES actor(aid),
FOREIGN KEY(did) REFERENCES director(did)
);
insert into movie values(0,'Fight Club','Drama', '1999-10-15', 8.9);
insert into actor values(0,'Brad Pitt', 'male', '1963-12-18', 'USA');
insert into director values(0, 'David Fincher', 'USA');
insert into movie_info values(0, 0, 0, 0);

