CREATE TABLE public.cars(
  id    bigserial PRIMARY KEY NOT NULL,
  brand character varying(100),
  model character varying(100),
  color character varying(100)
);