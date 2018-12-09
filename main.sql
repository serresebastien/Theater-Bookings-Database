#######################################
#####    Creation des tables     ######
#######################################

create table Theaters
(
  theater_id            int auto_increment,
  theater_name          varchar(100) not null,
  theater_city          varchar(100) not null,
  theater_address       varchar(255) not null,
  theater_phone         varchar(10)  not null,
  theater_seat_capacity int          default '0',
  primary key (theater_id)
);

create table Customers
(
  customer_id    int auto_increment,
  customer_name  varchar(100) not null,
  customer_age   int          not null,
  customer_phone varchar(10)  not null,
  primary key (customer_id),
  constraint chk_Customers check (customer_age>=6 and customer_age<=120)
);

create table Bookings
(
  booking_id         int auto_increment,
  customer_id        int  not null,
  booking_for_date   date not null,
  booking_made_date  date not null,
  booking_seat_count int  not null,
  booking_price      int  null,
  primary key (booking_id),
  foreign key (customer_id) references Customers(customer_id)
);

create table Row_seats
(
  theater_id   int not null,
  `row_number` int not null,
  seat_count   int not null,
  primary key (`row_number`, theater_id),
  foreign key (theater_id) references Theaters(theater_id)
);

create table All_performance_seats
(
  theater_id       int  not null,
  `row_number`     int  not null,
  seat_number      int  not null,
  performance_date date not null,
  seat_price       int  not null,
  is_booked        boolean default false,
  booking_id       int  null,
  primary key (theater_id, `row_number`, seat_number, performance_date),
  foreign key (booking_id) references Bookings(booking_id),
  foreign key (theater_id) references Theaters(theater_id),
  foreign key (`row_number`) references Row_seats(`row_number`)
);

create table Companies
(
  company_id         int auto_increment,
  company_name       varchar(100) not null,
  company_theater_id int          not null,
  primary key (company_id),
  foreign key (company_theater_id) references Theaters(theater_id)
);

create table Events_info
(
  event_id          int auto_increment,
  event_name        varchar(100) not null,
  event_description varchar(255) null,
  event_cost        int          not null,
  event_company_id  int          not null,
  primary key (event_id),
  foreign key (event_company_id) references Companies(company_id)
);

create table Event_showings
(
  event_showings_id  int auto_increment,
  theater_id         int  null,
  event_id           int  null,
  showing_from_date  date null,
  showing_to_date    date null,
  event_showing_cost int  null,
  primary key (event_showings_id),
  foreign key (theater_id) references Theaters(theater_id),
  foreign key (event_id) references Events_info(event_id)
);

create table Events_cost
(
  event_showings_id  int  not null,
  event_total_cost   int  default 0,
  event_total_income int  default 0,
  estimated_cost     int  default 0,
  primary key (event_showings_id),
  foreign key (event_showings_id) references Event_showings(event_showings_id)  
)

#######################################
#####     Création des règles     #####
#######################################

### Création des données dans la table All_performance_seats

create trigger populate_all_performance_seats after insert on Row_seats
  for each row
begin
  declare x int;
  set x = 1;
  while x <= new.seat_count do
  insert into All_performance_seats (theater_id, `row_number`, seat_number)
  values (new.theater_id, new.`row_number`, x);
  set x = x + 1;
  end while;
end;

### Calcul du champs theater_seat_capacity de la table Theaters

create trigger set_theater_seat_capacity after insert on Row_seats
  for each row
begin
  declare x int;
  set x = (select sum(Row_seats.seat_count) from Row_seats, Theaters where Row_seats.theater_id = new.theater_id);
  update Theaters
  set theater_seat_capacity = x
  where Theaters.theater_id = new.theater_id;
end;

### Attribut des valeurs random au champ seat_price de la table All_performance_seats

create trigger set_seat_price after insert on Row_seats
  for each row
begin
  declare x int;
  declare y int;
  set y = 1;
  while y <= new.seat_count do
    set x = (floor(rand()*(100)+60));
    update All_performance_seats
    set All_performance_seats.seat_price = x
    where All_performance_seats.theater_id = new.theater_id and All_performance_seats.`row_number` = new.`row_number` and All_performance_seats.seat_number = y;
    set y = y+1;
  end while;
end;

### Création des données dans la table Events_cost

create trigger populate_events_cost after insert on Event_showings
  for each row
begin
  declare x int;
  set x = (datediff(new.showing_to_date, new.showing_from_date) * new.event_showing_cost + (select event_cost from Events_info where Events_info.event_id = new.event_id));
  insert into Events_cost (event_showings_id, event_total_cost)
  values (new.event_showings_id, x);
end;

#######################################
#####    Population des tables     ####
#######################################

insert into Theaters (theater_name, theater_city, theater_address, theater_phone)
values ('Opera Garnier', 'Paris', 'Boulevard des Capucines', '0145379674');
    
insert into Theaters (theater_name, theater_city, theater_address, theater_phone)
values ('Tête d Or', 'Lyon', 'Avenue Maréchal de Saxe', '0478629673');
    
insert into Theaters (theater_name, theater_city, theater_address, theater_phone)
values ('Grand Amphi', 'Villejuif', '32 avenue de la République', '0154763634');

insert into Row_seats (theater_id, `row_number`, seat_count)
values ('1', '1', '50');

insert into Row_seats (theater_id, `row_number`, seat_count)
values ('2', '1', '40');

insert into Row_seats (theater_id, `row_number`, seat_count)
values ('3', '1', '30');

Insert into Customers (customer_name, customer_age, customer_phone)
values ('Tom Creuse', '34', '0769784565');

Insert into Customers (customer_name, customer_age, customer_phone)
values ('Gémal Opié', '68', '0549583748');

Insert into Customers (customer_name, customer_age, customer_phone)
values ('Saibe Hastien', '92', '0693827345');

Insert into Companies (company_name, company_theater_id)
values ('Il teatro magnifico', '1');

Insert into Companies (company_name, company_theater_id)
values ('La compagnie du love', '2');

Insert into Companies (company_name, company_theater_id)
values ('YeMisticrik', '3');

insert into Events_info (event_name, event_description, event_cost, event_company_id)
values ('Romeo & Juliette', 'Pièce de théatre par William Sakespeare', '45', '1');

insert into Events_info (event_name, event_description, event_cost, event_company_id)
values ('Le vilain petit Canard', 'Comédie Musicale pour les enfants', '60', '2');

insert into Events_info (event_name, event_description, event_cost, event_company_id)
values ('La Belle et Sébastien', 'Pièce de théatre d épouvante', '50', '3');

insert into Event_showings (theater_id, event_id, showing_from_date, showing_to_date, event_showing_cost)
values ('3', '3', '2018-12-14', '2019-01-16', '300');

insert into Event_showings (theater_id, event_id, showing_from_date, showing_to_date, event_showing_cost)
values ('1', '1', '2019-02-28', '2020-03-18', '1000');
	
insert into Event_showings (theater_id, event_id, showing_from_date, showing_to_date, event_showing_cost)
values ('2', '2', '2018-12-30', '2020-06-03', '750');

insert into Bookings (customer_id, booking_for_date, booking_made_date, booking_seat_count)
values ('1', '2019-11-20', '2019-01-02', '2');

insert into Bookings (customer_id, booking_for_date, booking_made_date, booking_seat_count)
values ('2', '2020-02-10', '2019-06-07', '6');

insert into Bookings (customer_id, booking_for_date, booking_made_date, booking_seat_count)
values ('3', '2019-04-23', '2018-12-15', '3');