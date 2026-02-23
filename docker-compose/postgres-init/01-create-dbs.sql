CREATE USER synapse WITH PASSWORD 'change-me-synapse-db';
CREATE DATABASE synapse ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE template0 OWNER synapse;

CREATE USER mas WITH PASSWORD 'change-me-mas-db';
CREATE DATABASE mas OWNER mas;
