-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.9.3-beta
-- PostgreSQL version: 12.0
-- Project Site: pgmodeler.io
-- Model Author: ---

SET check_function_bodies = false;
-- ddl-end --


-- Database creation must be done outside a multicommand file.
-- These commands were put in this file only as a convenience.
-- -- object: shoplist | type: DATABASE --
-- -- DROP DATABASE IF EXISTS shoplist;
-- CREATE DATABASE shoplist;
-- -- ddl-end --
-- 

-- object: shoplist | type: SCHEMA --
-- DROP SCHEMA IF EXISTS shoplist CASCADE;
CREATE SCHEMA shoplist;
-- ddl-end --
ALTER SCHEMA shoplist OWNER TO postgres;
-- ddl-end --

SET search_path TO pg_catalog,public,shoplist;
-- ddl-end --

-- object: shoplist.item | type: TABLE --
-- DROP TABLE IF EXISTS shoplist.item CASCADE;
CREATE TABLE shoplist.item (
    name character varying(256) NOT NULL,
    in_cart bool NOT NULL DEFAULT true,
    created_at timestamp NOT NULL DEFAULT now(),
    CONSTRAINT item_pk PRIMARY KEY (name)

);
-- ddl-end --
COMMENT ON COLUMN shoplist.item.name IS E'the name of the item';
-- ddl-end --
COMMENT ON COLUMN shoplist.item.in_cart IS E'whether it''s currently in the cart (needs to be bought)';
-- ddl-end --
ALTER TABLE shoplist.item OWNER TO postgres;
-- ddl-end --

-- object: shoplist.log | type: TABLE --
-- DROP TABLE IF EXISTS shoplist.log CASCADE;
CREATE TABLE shoplist.log (
    ts timestamp NOT NULL,
    name character varying(256) NOT NULL,
    cart_action boolean NOT NULL
);
-- ddl-end --
COMMENT ON TABLE shoplist.log IS E'log of actions performed on the item table';
-- ddl-end --
COMMENT ON COLUMN shoplist.log.ts IS E'timestamp of the event';
-- ddl-end --
COMMENT ON COLUMN shoplist.log.name IS E'name of the item';
-- ddl-end --
COMMENT ON COLUMN shoplist.log.cart_action IS E'whether the item was added (true) or removed (false)';
-- ddl-end --
ALTER TABLE shoplist.log OWNER TO postgres;
-- ddl-end --

-- object: shoplist.fn_trg_item_history | type: FUNCTION --
-- DROP FUNCTION IF EXISTS shoplist.fn_trg_item_history() CASCADE;
CREATE FUNCTION shoplist.fn_trg_item_history ()
    RETURNS trigger
    LANGUAGE plpgsql
    VOLATILE 
    CALLED ON NULL INPUT
    SECURITY INVOKER
    COST 1
    AS $$
BEGIN
    INSERT INTO shoplist.log (ts, name, cart_action)
    VALUES (now(), NEW.name, NEW.in_cart);
    RETURN NEW;
END
$$;
-- ddl-end --
ALTER FUNCTION shoplist.fn_trg_item_history() OWNER TO postgres;
-- ddl-end --

-- object: idx_log_name | type: INDEX --
-- DROP INDEX IF EXISTS shoplist.idx_log_name CASCADE;
CREATE INDEX idx_log_name ON shoplist.log
    USING btree
    (
      name,
      ts
    );
-- ddl-end --

-- object: trg_item_history | type: TRIGGER --
-- DROP TRIGGER IF EXISTS trg_item_history ON shoplist.item CASCADE;
CREATE TRIGGER trg_item_history
    AFTER INSERT OR UPDATE
    ON shoplist.item
    FOR EACH ROW
    EXECUTE PROCEDURE shoplist.fn_trg_item_history();
-- ddl-end --

-- object: fk_log_item_name | type: CONSTRAINT --
-- ALTER TABLE shoplist.log DROP CONSTRAINT IF EXISTS fk_log_item_name CASCADE;
ALTER TABLE shoplist.log ADD CONSTRAINT fk_log_item_name FOREIGN KEY (name)
REFERENCES shoplist.item (name) MATCH FULL
ON DELETE NO ACTION ON UPDATE CASCADE DEFERRABLE INITIALLY IMMEDIATE;
-- ddl-end --


