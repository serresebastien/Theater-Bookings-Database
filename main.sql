#######################################################
#########        Creation des tables         ##########
#######################################################

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

create table Companies
(
  company_id   int auto_increment,
  company_name varchar(100) not null,
  company_city varchar(100) not null,
  primary key (company_id)
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
  event_showing_id   int auto_increment,
  theater_id         int  null,
  event_id           int  null,
  showing_from_date  date null,
  showing_to_date    date null,
  event_showing_cost int  null,
  primary key (event_showing_id),
  foreign key (theater_id) references Theaters(theater_id),
  foreign key (event_id) references Events_info(event_id)
);

create table Bookings
(
  booking_id         int auto_increment,
  customer_id        int  not null,
  theater_id         int  not null,
  event_showing_id   int  not null,
  seat_row           int  not null,
  seat_number        int  not null,
  booking_for_date   date not null,
  booking_made_date  date not null,
  booking_price      int  null,
  primary key (booking_id),
  foreign key (customer_id) references Customers(customer_id),
  foreign key (theater_id) references Theaters(theater_id)
);

create table Events_cost
(
  event_showing_id  int  not null,
  event_total_cost   int  default 0,
  event_total_income int  default 0,
  estimated_cost     int  default 0,
  primary key (event_showing_id),
  foreign key (event_showing_id) references Event_showings(event_showing_id)  
);

create table Row_seats
(
  theater_id   int not null,
  seat_row     int not null,
  seat_count   int not null,
  primary key (seat_row, theater_id),
  foreign key (theater_id) references Theaters(theater_id)
);

create table All_performance_seats
(
  theater_id       int  not null,
  seat_row         int  not null,
  seat_number      int  not null,
  seat_price       int  not null,
  primary key (theater_id, seat_row, seat_number),
  foreign key (theater_id) references Theaters(theater_id),
  foreign key (seat_row) references Row_seats(seat_row),
);

create table All_performance_seats_reserved
(
  theater_id       int  not null,
  seat_row         int  not null,
  seat_number      int  not null,
  seat_price       int  not null,
  booking_id       int  not null,
  primary key (theater_id, seat_row, seat_number),
  foreign key (theater_id) references All_performance_seats(theater_id),
  foreign key (seat_row) references All_performance_seats(seat_row),
  foreign key (seat_number) references All_performance_seats(seat_number)
);

create table All_performance_seats_reserved
(
  theater_id       int  not null,
  seat_row         int  not null,
  seat_number      int  not null,
  booking_id       int  not null,
  primary key (theater_id, seat_row, seat_number, booking_id),
  foreign key (theater_id, seat_row,seat_number) references All_performance_seats(theater_id, seat_row, seat_number),
  foreign key (booking_id) references Bookings(booking_id)
);

create table Booking_cost
(
  booking_id        int          not null,
  seat_price        int          not null,
  booking_promotion varchar(100) not null,
  booking_price     int          not null,
  primary key (booking_id),
  foreign key (booking_id) references Bookings(booking_id)
);

#######################################################
#########        Creation des règles         ##########
#######################################################

### Création des données dans la table All_performance_seats

create trigger populate_all_performance_seats after insert on Row_seats
  for each row
begin
  declare x,y int;
  set x = 1;
  while x <= new.seat_count do
    set y = (floor(rand()*(100)+60));
    insert into All_performance_seats (theater_id, seat_row, seat_number, seat_price)
    values (new.theater_id, new.seat_row, x, y);
    set x = x + 1;
  end while;
end;

### Calcul du champs theater_seat_capacity de la table Theaters

create trigger set_theater_seat_capacity after insert on Row_seats
  for each row
begin
  declare x int;
  set x = (select sum(Row_seats.seat_count) from Row_seats where Row_seats.theater_id = new.theater_id);
  update Theaters
  set theater_seat_capacity = x
  where Theaters.theater_id = new.theater_id;
end;

### Création des données dans la table Events_cost

create trigger populate_events_cost after insert on Event_showings
  for each row
begin
  declare x int;
  set x = (datediff(new.showing_to_date, new.showing_from_date) * new.event_showing_cost + (select event_cost from Events_info where Events_info.event_id = new.event_id));
  insert into Events_cost (event_showing_id, event_total_cost)
  values (new.event_showing_id, x);
end;

### Calcul de la valeurs event_total_income de la table Event_cost

create trigger update_events_cost after insert on Bookings
  for each row
begin
  declare x int;
  set x = new.booking_price;
  update Events_cost
  set Events_cost.event_total_income = Events_cost.event_total_income + x
  where Events_cost.event_showing_id = new.event_showing_id;
end;

### 

create trigger populate_all_performance_seats_reserved after insert on Bookings
  for each row
begin
  declare price int;
  set price = (select seat_price from All_performance_seats where All_performance_seats.theater_id = new.theater_id and All_performance_seats.seat_row = new.seat_row and All_performance_seats.seat_number = new.seat_number);
  insert into All_performance_seats_reserved (theater_id, seat_row, seat_number, booking_id, seat_price)
  values (new.theater_id, new.seat_row, new.seat_number, new.booking_id, price);
end;

###

create trigger set_booking_price after insert on All_performance_seats_reserved
  for each row
begin
  update Bookings
  set booking_price = new.seat_price
  where booking_id = Bookings.booking_id;
end;

#######################################################
#########         Population de BBD          ##########
#######################################################

insert into Theaters (theater_name, theater_city, theater_address, theater_phone)
values ('Opera Garnier', 'Paris', 'Boulevard des Capucines', '0145379674');
    
insert into Theaters (theater_name, theater_city, theater_address, theater_phone)
values ('Tête d Or', 'Lyon', 'Avenue Maréchal de Saxe', '0478629673');
    
insert into Theaters (theater_name, theater_city, theater_address, theater_phone)
values ('Grand Amphi', 'Villejuif', '32 avenue de la République', '0154763634');

insert into Row_seats (theater_id, seat_row, seat_count)
values ('1', '1', '10');

insert into Row_seats (theater_id, seat_row, seat_count)
values ('1', '2', '10');

insert into Row_seats (theater_id, seat_row, seat_count)
values ('1', '3', '10');

insert into Row_seats (theater_id, seat_row, seat_count)
values ('2', '1', '40');

insert into Row_seats (theater_id, seat_row, seat_count)
values ('3', '1', '30');

Insert into Companies (company_name, company_city)
values ('Il teatro magnifico', 'Paris');

Insert into Companies (company_name, company_city)
values ('La compagnie du love', 'Lyon');

Insert into Companies (company_name, company_city)
values ('YeMisticrik', 'Villejuif');

insert into Events_info (event_name, event_description, event_cost, event_company_id)
values ('Romeo & Juliette', 'Pièce de théatre par William Sakespeare', '1500', '1');

insert into Events_info (event_name, event_description, event_cost, event_company_id)
values ('Le vilain petit Canard', 'Comédie Musicale pour les enfants', '800', '2');

insert into Events_info (event_name, event_description, event_cost, event_company_id)
values ('La Belle et Sébastien', 'Pièce de théatre d épouvante', '500', '3');

insert into Event_showings (theater_id, event_id, showing_from_date, showing_to_date, event_showing_cost)
values ('1', '1', '2019-01-01', '2019-01-11', '500');

insert into Event_showings (theater_id, event_id, showing_from_date, showing_to_date, event_showing_cost)
values ('2', '2', '2019-01-01', '2019-01-11', '200');

insert into Event_showings (theater_id, event_id, showing_from_date, showing_to_date, event_showing_cost)
values ('3', '3', '2019-01-01', '2019-01-03', '50');

Insert into Customers (customer_name, customer_age, customer_phone)
values ('Tom Creuse', '34', '0769784565');

Insert into Customers (customer_name, customer_age, customer_phone)
values ('Gémal Opié', '68', '0549583748');

Insert into Customers (customer_name, customer_age, customer_phone)
values ('Saibe Hastien', '92', '0693827345');

insert into Bookings (customer_id, event_showing_id, seat_row, seat_number, booking_for_date, booking_made_date)
values ('1', '1', '1', '1', '2019-11-20', '2019-01-01');

insert into Bookings (customer_id, event_showing_id, seat_row, seat_number, booking_for_date, booking_made_date)
values ('2', '1', '1', '1', '2020-02-10', '2019-01-01');

insert into Bookings (customer_id, event_showing_id, seat_row, seat_number, booking_for_date, booking_made_date)
values ('3', '1', '1', '1', '2019-04-23', '2019-01-01');