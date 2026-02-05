-- Bus Station Information System schema

CREATE TABLE cities (
  city_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE routes (
  route_id SERIAL PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  origin_city_id INTEGER NOT NULL REFERENCES cities(city_id),
  destination_city_id INTEGER NOT NULL REFERENCES cities(city_id),
  distance_km INTEGER NOT NULL CHECK (distance_km > 0)
);

-- Stops define all cities a route passes through (including origin/destination if desired)
CREATE TABLE route_stops (
  route_stop_id SERIAL PRIMARY KEY,
  route_id INTEGER NOT NULL REFERENCES routes(route_id) ON DELETE CASCADE,
  city_id INTEGER NOT NULL REFERENCES cities(city_id),
  stop_order INTEGER NOT NULL CHECK (stop_order > 0),
  arrival_offset_min INTEGER CHECK (arrival_offset_min >= 0),
  departure_offset_min INTEGER CHECK (departure_offset_min >= 0),
  UNIQUE (route_id, city_id),
  UNIQUE (route_id, stop_order)
);

CREATE TABLE buses (
  bus_id SERIAL PRIMARY KEY,
  plate_number VARCHAR(20) NOT NULL UNIQUE,
  seat_capacity INTEGER NOT NULL CHECK (seat_capacity > 0)
);

-- Concrete departures for selling tickets
CREATE TABLE departures (
  departure_id SERIAL PRIMARY KEY,
  route_id INTEGER NOT NULL REFERENCES routes(route_id) ON DELETE CASCADE,
  bus_id INTEGER NOT NULL REFERENCES buses(bus_id),
  departure_time TIMESTAMP NOT NULL,
  arrival_time TIMESTAMP NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'scheduled'
);

CREATE TABLE cashiers (
  cashier_id SERIAL PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  hired_at DATE NOT NULL
);

-- Telephone orders (accepted by a cashier) for later purchase
CREATE TABLE telephone_orders (
  order_id SERIAL PRIMARY KEY,
  departure_id INTEGER NOT NULL REFERENCES departures(departure_id) ON DELETE CASCADE,
  customer_name VARCHAR(120) NOT NULL,
  phone_number VARCHAR(30) NOT NULL,
  seats_requested INTEGER NOT NULL CHECK (seats_requested > 0),
  order_time TIMESTAMP NOT NULL,
  hold_expires_at TIMESTAMP NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'held',
  cashier_id INTEGER NOT NULL REFERENCES cashiers(cashier_id)
);

-- Tickets sold at the station (including fulfillment of telephone orders)
CREATE TABLE tickets (
  ticket_id SERIAL PRIMARY KEY,
  departure_id INTEGER NOT NULL REFERENCES departures(departure_id) ON DELETE CASCADE,
  passenger_name VARCHAR(120) NOT NULL,
  seat_number INTEGER NOT NULL CHECK (seat_number > 0),
  price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
  sold_at TIMESTAMP NOT NULL,
  cashier_id INTEGER NOT NULL REFERENCES cashiers(cashier_id),
  telephone_order_id INTEGER REFERENCES telephone_orders(order_id),
  status VARCHAR(20) NOT NULL DEFAULT 'sold',
  UNIQUE (departure_id, seat_number)
);

-- Optional: track cancellations/refunds for sales statistics
CREATE TABLE ticket_refunds (
  refund_id SERIAL PRIMARY KEY,
  ticket_id INTEGER NOT NULL REFERENCES tickets(ticket_id) ON DELETE CASCADE,
  refunded_at TIMESTAMP NOT NULL,
  refund_amount NUMERIC(10, 2) NOT NULL CHECK (refund_amount >= 0),
  reason TEXT
);
