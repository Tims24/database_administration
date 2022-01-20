CREATE PROCEDURE FullBackup
(@DB_name VARCHAR(100))
AS
BEGIN
    DECLARE @backupFilePath VARCHAR(300);
    DECLARE @backupExt VARCHAR(50);
    DECLARE @backupFolder VARCHAR(50);
	DECLARE @backupTime DATETIME;
	DECLARE @backupTimeText VARCHAR(50);

    SET @backupTime = CAST(GETDATE() AS DATETIME);
    SET @backupTimeText = FORMAT(CURRENT_TIMESTAMP, N'yyyy-mm-ddTHH');
    SET @backupExt = '.bak'
    SET @backupFolder = 'C:\Users\Tim\db_files\'
    SET @backupFilePath = CONCAT(@backupFolder, @backupTimeText, '_full', @backupExt)

	BACKUP DATABASE @DB_name
	TO
	DISK = @backupFilePath
	WITH INIT;
END


CREATE PROCEDURE DifferentialBackup
(@DB_name VARCHAR(100))
AS
BEGIN
	DECLARE @backupTime DATETIME;
	DECLARE @backupTimeText VARCHAR(50);
	DECLARE @backupFolder VARCHAR(50);
	DECLARE @backupExt VARCHAR(50);
	DECLARE @backupFilePath VARCHAR(100);

	SET @backupTime = CAST(GETDATE() AS DATETIME);
	SET @backupTimeText = FORMAT(CURRENT_TIMESTAMP, N'yyyy-mm-ddTHH');
	SET @backupExt = '.bak'
	SET @backupFolder = 'C:\Users\Tim\db_files\'
	SET @backupFilePath = CONCAT(@backupFolder, @backupTimeText, '_diff', @backupExt)

	BACKUP DATABASE @DB_name
	TO
	DISK = @backupFilePath
	WITH DIFFERENTIAL, INIT;
END


CREATE PROCEDURE RestoreBackupByDate
(@DB_name VARCHAR(100))
AS
BEGIN
	DECLARE @backupFilePath VARCHAR(300);
	DECLARE @fullBackupPath VARCHAR(200)
	DECLARE @differentialBackupPath VARCHAR(200)

	SET @backupFilePath = CONCAT('C:\Users\Tim\db_files\', @DB_name);

    -- Создадим таблицу, в которой будут хранится названия бэкапов

    CREATE TABLE #Backup_names (
    id INT IDENTITY(1, 1),
    database_name VARCHAR(200),
    depth INT,
    file BIT
    )

    -- хp_dirtree has three parameters:
    -- directory - This is the directory you pass when you call the stored procedure; for example 'D:\Backup'.
    -- depth  - This tells the stored procedure how many subfolder levels to display.  The default of 0 will display all subfolders.
    -- file - This will either display files as well as each folder.  The default of 0 will not display any files.

    INSERT INTO #Backup_names (database_name, depth, file) EXEC xp_dirtree @backupFilePath, 1, 1;

    SET @fullBackupPath = (SELECT TOP (1) database_name FROM #Backup_names
                           WHERE database_name LIKE '%full%'
                           AND file = 1
                           ORDER BY database_name DESC);

    SET @differentialBackupPath = (SELECT TOP (1) database_name FROM #Backup_names
                                   WHERE database_name LIKE '%diff%'
                                   AND file = 1
                                   ORDER BY database_name DESC);



	RESTORE DATABASE @DB_name FROM DISK = @backupFilePath + @fullBackupPath
	WITH NORECOVERY;

    --- т.к. в названиях бэкапов присутствует дата самого бэкапа, то можно сравнить разностный с полным по названию
    IF @differentialBackupPath IS NOT NULL AND @differentialBackupPath > @fullBackupPath
    BEGIN
        RESTORE DATABASE @DB_name FROM DISK = @backupFilePath + @differentialBackupPath
        WITH RECOVERY;
    END

	DROP TABLE #Backup_names

END