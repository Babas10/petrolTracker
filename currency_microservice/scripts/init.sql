-- Database initialization script for currency exchange rates

-- Create database if it doesn't exist (PostgreSQL specific)
-- This file will be executed by docker-entrypoint-initdb.d

-- Enable extension for better performance
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Create the exchange_rates table (this will be created by SQLAlchemy too, but including for reference)
-- SQLAlchemy will handle the actual table creation

-- Create indexes for better query performance
-- These will be created after the tables are initialized by the application

-- Log successful initialization
INSERT INTO pg_stat_statements_info VALUES ('Currency Exchange Rate DB initialized successfully');