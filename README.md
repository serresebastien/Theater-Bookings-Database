[🇫🇷](/README-fr.md "French")

# 🎭 Theater Bookings Database 🎭

## Diagram
![ScreenShot_Diagram](/img/diagram.png?raw=true "Database diagram")

## Tables

## Triggers

### populate_all_performance_seats

This first trigger is used to automatically populate the table **All_performance_seats** whenever a new row is inserted in the table **Row_seats**.
It's build on a while loop to create a single row for every seat of each seat row. Moreover, a price between 60 and 160 is ramdomly applicated for each seat.

### populate_all_showings_cost

This trigger has as purpose to populate the table **All_showings_cost** whenever a new row is inserted in the table **Event_showings**.
To calculate the total cost of the event, we take the price of the event and we added the cost of each representation for each day the show will perform.
For every new event that will be show, the trigger look if the theater where the company will perform is in the same city of the company. If is not, an additional cost of 500 will be adding for cover deplacement cost.

### populate_all_performance_seats_reserved

When a new row is inserted in the table **Bookings** this trigger automatically add the seat of the reservation in the table **All_performance_seats_reserved**.

### populate_booking_cost



### set_theater_seat_capacity



### update_all_showings_cost




