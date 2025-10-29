/*
                           _)\.-.                                                _/\__
         .-.__,___,_.-=-. )\`  a`\_                                        ---==/    \\
     .-.__\__,__,__.-=-. `/  \     `\     ___  _ _ _  ___           ___  ___    |.    \|\
     {~,-~-,-~.-~,-,;;;;\ |   '--;`)/     | __|| | | || _ \        | __|| __|   |  )   \\
      \-,~_-~_-,~-,(_(_(;\/   ,;/         | _| | | | |||_| |       | _| | _|    \_/ |  //|\\
       ",-.~_,-~,-~,)_)_)'.  ;;(          |_|  \_____/|___/    VS  |___||_|         /   \\\/\\
         `~-,_-~,-~(_(_(_(_\  `;\                                                   \    \/\\/\\

Created by: THR-2025-@promicroNL
*/


USE [master];

DECLARE @dbs TABLE (name sysname);
INSERT INTO @dbs (name) VALUES
    ('Agent-Hybrid-EF'),
    ('Agent-Hybrid-Flyway'),
    ('Agent-Hybrid-Shadow'),
    ('Agent-Hybrid-Production'),
    ('Agent-Inverted-EF'),
    ('Agent-Inverted-Flyway'),
    ('Agent-Inverted-Shadow'),
    ('Agent-Inverted-Production'),
    ('Agent-Simple-EF'),
    ('Agent-Simple-Flyway'),
    ('Agent-Simple-Shadow'),
    ('Agent-Simple-Production'),
    ('TasteWhisky_FWD');

DECLARE @db sysname;
DECLARE @sql NVARCHAR(MAX);

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT name FROM @dbs;
OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @db;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF DB_ID(@db) IS NOT NULL
    BEGIN
        SET @sql = N'ALTER DATABASE [' + @db + N'] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [' + @db + N'];';
        EXEC (@sql);
    END;

    SET @sql = N'CREATE DATABASE [' + @db + N'];';
    EXEC (@sql);

    FETCH NEXT FROM db_cursor INTO @db;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

