-- Initial database setup
-- This file will be executed when PostgreSQL container starts for the first time

-- Create database if not exists (handled by docker-compose)
-- CREATE DATABASE bardb;

-- Connect to the database
\c bardb;

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Placeholder for future schema migrations
-- Tables will be created through migration system in task 2
