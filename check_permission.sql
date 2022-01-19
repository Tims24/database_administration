-- task 1
CREATE PROCEDURE GetAllPermissions AS
BEGIN
	SELECT * INTO #Permissions FROM fn_my_permissions(NULL, 'SERVER') UNION SELECT * FROM fn_my_permissions(NULL, 'DATABASE');
	DECLARE p_cur cursor
	FOR
		SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
	OPEN p_cur
	DECLARE @t_name SYSNAME
	FETCH NEXT FROM p_cur INTO @t_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
	INSERT INTO #Permissions SELECT * FROM fn_my_permissions(@t_name, 'Object')
	FETCH NEXT FROM p_cur INTO @t_name
	END
	CLOSE p_cur
	DEALLOCATE p_cur
	SELECT * FROM #Permissions
	DROP TABLE #Permissions
END