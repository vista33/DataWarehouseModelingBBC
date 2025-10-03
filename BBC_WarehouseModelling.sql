-- create the fact news table
create table fact_news (
	news_id int primary key,
	title varchar(500),
	summary varchar(2000),
	last_updated varchar(200),
	actual_time timestamp,
	id_category int,
	foreign key (id_category) references dim_category(id_category),
	publication_date date,
	foreign key (publication_date) references dim_date(date)
	);


-- create the dim date table
create table dim_date (
	date date primary key,
	day_name varchar (20),
	is_weekend boolean,
	month_name varchar (50),
	quarter int,
	year int
	);
ALTER TABLE dim_date
ALTER COLUMN is_weekend TYPE integer USING is_weekend::int;

-- create the dim category table
create table dim_category (
	id_category serial primary key, --create unique id
	category_name varchar(100)
	);

ALTER TABLE dim_category
ALTER COLUMN id_category TYPE integer USING id_category::int;

-- create the stagingnews table to process the data
create table StagingNews (
	title varchar(2000),
	summary varchar (5000),
	last_updated varchar (50),
	category varchar (100),
	url varchar (1000),
	actual_time timestamp,
	publication_date date
	);


-- make news_id for the news 
alter table stagingnews
add column news_id serial primary key; --create unique id

-- insert data category into dim category from stagingnews table
insert into dim_category (category_name)
select distinct s.category
from stagingnews s
left join dim_category d
on s.category = d.category_name
where d.category_name is null;

-- another sql code for insert category into dim category from stagingnews table
insert into dim_category (category_name)
select distinct category
from stagingnews
where category not in (select category_name from dim_category);


-- insert data dim_date using sql
insert into dim_date
select 
	d as date,
	extract (day from d) as day_name,
	extract (month from d) as month_name,
	extract (year from d) as year,
	extract (quarter from d) as quarter,
	case 
		when extract (dow from d) in (0,6) then 1 -- weekends
		else 0 -- weekdays
	end as is_weekend	
from generate_series ('2025-01-01'::date, '2030-12-31'::date, interval '1 day') d;

-- insert data fact_news
insert into fact_news
select 
	s.news_id as news_id,
	s.title as title,
	s.summary as summary,
	s.last_updated as last_updated,
	s.actual_time as actual_time, 
	dc.id_category as id_category,
	s.publication_date as publication_date
from stagingnews s
left join dim_category dc
on s.category = dc.category_name;


	