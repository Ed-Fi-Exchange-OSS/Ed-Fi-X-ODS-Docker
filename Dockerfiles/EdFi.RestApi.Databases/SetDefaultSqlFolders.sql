EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE'
	, N'Software\Microsoft\MSSQLServer\MSSQLServer'
	, N'DefaultData'
	, REG_SZ
	, N'C:\SQL\Data'
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE'
	, N'Software\Microsoft\MSSQLServer\MSSQLServer'
	, N'DefaultLog'
	, REG_SZ
	, N'C:\SQL\Logs'
GO