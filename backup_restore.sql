-- USE part_demo;
CREATE PROCEDURE FullBackup
AS
BEGIN
	BACKUP DATABASE part_demo
	TO
	DISK = 'C:\Users\Tim\db_files\full\part_demo.bak'
	WITH INIT;
END

CREATE PROCEDURE DifferentialBackup
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
	SET @backupFolder = 'C:\Users\Tim\db_files\differential\'
	SET @backupFilePath = CONCAT(@backupFolder, @backupTimeText, @backupExt)
	BACKUP DATABASE part_demo
	TO
	DISK = @backupFilePath
	WITH DIFFERENTIAL, INIT;
END

-- USE master;
CREATE PROCEDURE RestoreFromDifferentialBackupByDate
(@dateToRestoreFrom VARCHAR(100))
AS
BEGIN
	DECLARE @backupFilePath VARCHAR(100);
	SET @backupFilePath = CONCAT('C:\Users\Tim\db_files\differential\', @dateToRestoreFrom, '.bak');

	BACKUP LOG part_demo
	TO DISK = 'C:\Users\Tim\db_files\log\part_demo_log.TRN'
	WITH NORECOVERY;

	RESTORE DATABASE part_demo FROM DISK = 'C:\Users\Tim\db_files\full\part_demo.bak'
	WITH NORECOVERY;

	RESTORE DATABASE part_demo FROM DISK = @backupFilePath
	WITH RECOVERY;
END