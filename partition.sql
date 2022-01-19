CREATE PROCEDURE Partition
AS
BEGIN
	IF NOT EXISTS (select * from sys.filegroups where name = 'g1')
	ALTER DATABASE DBMS_admin
	ADD FILEGROUP g1
	IF NOT EXISTS (select * from sys.filegroups where name = 'g2')
	ALTER DATABASE DBMS_admin
	ADD FILEGROUP g2

	ALTER DATABASE DBMS_admin
	ADD FILE
	(
	NAME = f1,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\f1.ndf'
	) TO FILEGROUP g1;

	ALTER DATABASE DBMS_admin
	ADD FILE
	(
	NAME = f2,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\f2.ndf'
	) TO FILEGROUP g2;

	CREATE PARTITION FUNCTION my_pf(bit)
	AS
	RANGE LEFT
	FOR VALUES (0)

	CREATE PARTITION SCHEME my_ps
	AS PARTITION my_pf
	TO (g1, g2)

	CREATE TABLE temp_table (id int, text_field text, part_id bit)
	ON my_ps(part_id);

	INSERT INTO temp_table SELECT * FROM Table_task3;


	DROP TABLE Table_task3;

	EXEC sp_rename temp_table, Table_task3;

END