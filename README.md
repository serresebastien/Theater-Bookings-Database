[🇫🇷](/README-fr.md "French")

# 🎭 Theater Bookings Database 🎭

## Diagram
![ScreenShot_Diagram](/img/diagram.png?raw=true "Database diagram")

## Triggers

### populate_all_performance_seats

This first trigger is used to automatically populate the table **All_performance_seats** whenever a new row is inserted in the table **Row_seats**. It's built with a while loop so it can easily create a single row for every seat of each seat row.
Moreover, a price between 60 and 160 is ramdomly applicated for each seat.

### populate_all_showings_cost

This trigger has as purpose to populate the table **All_showings_cost** whenever a new row is inserted in the table **Event_showings**.
To calculate the total cost of the event, we take the price of the event and we add the cost of each representation for each day the show will be performed. For every new event that will be show, the trigger looks if the theater where the company will perform is in the same city of the company. If is not, an additional cost of 500 will be adding to cover the travel cost.

### populate_all_performance_seats_reserved

When a new row is inserted in the table **Bookings**, this trigger automatically adds the seat of the reservation in the table **All_performance_seats_reserved**.

### populate_booking_cost

After an insertion of a new row in the table **Bookings**, this trigger will process to populate the table **Booking_cost**.
First, we find the price of the seat that is booked, then we check when the reservation has been made to know if we could apply a promotion. For this, we calculate the difference between the value *booking_for_date* and *booking_made_date*. If the different is up than 15 we apply a 20% discount, if it equal to 0 (that means the booking was made for the same day) we apply a 30% discount.

### set_theater_seat_capacity

The purpose of this trigger is to calculate the total number of seat that a theater have and to update it in the table **Theater**. For this, we just add the number of each new row that we insert in the table **Row_seats** inside the table **Theater**.

### update_all_showings_cost

This trigger is here to keep up to date the total theater income for an event. It is automatically calculated after an insertion in the table **Bookings** and the result is write in table **All_showings_cost**.
