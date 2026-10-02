USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'CampusCafeteriaDB')
BEGIN
    ALTER DATABASE CampusCafeteriaDB 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    DROP DATABASE CampusCafeteriaDB;
END
GO