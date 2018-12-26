[🇬🇧](/README.md "Anglais")

# 🎭 Theater Bookings Database 🎭

## Diagram
![ScreenShot_Diagram](/img/diagram.png?raw=true "Database diagram")

## Triggers

### populate_all_performance_seats

Ce premier trigger est utilisé pour renseigner automatiquement la table **All_performance_seats** chaque fois qu'une nouvelle ligne est insérée dans la table **Row_seats**. Il est construit avec une boucle while afin de pouvoir facilement créer une seule entrée pour chaque siège de chaque rangée.
De plus, un prix compris entre 60 et 160 est appliqué pour chaque siège.

### populate_all_showings_cost

Ce trigger a pour but de renseigner la table **All_showings_cost** chaque fois qu'une nouvelle ligne est insérée dans la table **Event_showings**.
Pour calculer le coût total de l'événement, nous prenons le prix de l'événement et nous ajoutons le coût de chaque représentation pour chaque jour où le spectacle sera présenté. Pour chaque nouvel événement présenté, le déclencheur vérifie si le théâtre dans lequel la compagnie se produira se trouve dans la même ville que la société. Si ce n'est pas le cas, un coût supplémentaire de 500 s'ajoutera pour couvrir les frais de déplacement.

### populate_all_performance_seats_reserved

Lorsqu'une nouvelle ligne est insérée dans la table **Bookings**, ce trigger ajoute automatiquement le siège de la réservation dans la table **All_performance_seats_reserved**.

### populate_booking_cost

Après l'insertion d'une nouvelle ligne dans la table **Bookings**, ce trigger se charge de remplir la table **Booking_cost**.
Premièrement, il cherche le prix de la place réservée, puis il vérifie le moment où la réservation a été faite pour savoir si nous pouvons appliquer une promotion. Pour cela, nous calculons la différence entre la valeur *booking_for_date* et *booking_made_date*. Si la différence est supérieure à 15, nous appliquons une réduction de 20%. Si la différence est égale à 0 (cela signifie que la réservation a été effectuée pour le jour même), nous appliquons une réduction de 30%.

### set_theater_seat_capacity

Ce trigger a pour but de calculer le nombre total de sièges d’un théâtre et de le mettre à jour dans la table **Théâtre**. Pour cela, nous ajoutons simplement le nombre de siège de chaque nouvelle rangée de siège que nous insérons dans la table **Row_seats** à l'intérieur de la table **Theater**.

### update_all_showings_cost

Ce trigger est là pour garder à jour le revenu total du théâtre pour un événement. Il est automatiquement calculé après une insertion dans la table **Bookings** et le résultat est écrit dans la table **All_showings_cost**.