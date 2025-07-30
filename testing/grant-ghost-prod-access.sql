-- SQL commands to grant CFML user access to ghost_prod database
-- Run these commands as MySQL root or admin user

-- Grant all privileges on ghost_prod database to cfml user
GRANT ALL PRIVILEGES ON ghost_prod.* TO 'cfml'@'localhost';

-- Or for more specific permissions:
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ghost_prod.* TO 'cfml'@'localhost';

-- If you only need read access:
-- GRANT SELECT ON ghost_prod.* TO 'cfml'@'localhost';

-- Apply the changes
FLUSH PRIVILEGES;

-- Verify the grants
SHOW GRANTS FOR 'cfml'@'localhost';