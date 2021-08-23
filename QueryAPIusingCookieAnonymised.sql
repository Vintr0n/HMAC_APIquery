
-- RUN THE POWERSHELL TO CREATE THE HMAC (SHA-512) which queries the API and collects the cookies
EXEC xp_cmdshell 'powershell -ExecutionPolicy ByPass -File \\ntghdwhdb2\Uploads\MediViewer\HMAC.ps1"',no_output
---------

CREATE TABLE [#Cookie]
(
[Cookie] VARCHAR(MAX)
)
BULK INSERT [#Cookie]
FROM
    '\\server\location\Cookies.txt'
WITH
    (DATAFILETYPE = 'char',
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '\n');

DECLARE @Cookie VARCHAR(MAX)
SET @Cookie = (SELECT TOP (1) * FROM [#Cookie] ORDER BY LEN([Cookie]) DESC)
--SELECT @Cookie AS [Cookie]
DROP TABLE [#Cookie]

SET @Cookie = 'Cookie: '+@Cookie

DECLARE @URL AS VARCHAR(MAX)
SET @URL = 'https://website.domain/api/endpointyouarequerying'

DECLARE @Object AS INT;
DECLARE @HTTPStatus AS INT
DECLARE @Response TABLE (txt NVARCHAR(MAX));

EXEC sp_OACreate 'MSXML2.serverXMLHTTP', @Object OUT;
EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET',
             @URL,
			 'false';
EXEC sp_OAMethod @Object,'setRequestHeader', null, 'cookie', @Cookie
EXEC sp_OAMethod @Object, 'send';
INSERT INTO @Response (txt)
EXEC sp_OAMethod @Object, 'responseText'
EXEC sp_OAGetProperty @Object, 'status', @HTTPStatus OUT
EXEC sp_OADestroy @Object  

DECLARE @temp VARCHAR(MAX)
SET @temp = (SELECT txt FROM @Response)

SELECT @HTTPStatus AS ResponseStatus
SELECT * FROM @Response AS Body

DECLARE @replace VARCHAR(MAX)
SET @replace = @temp

SELECT * 
INTO [#Users]
FROM  
	OPENJSON (@replace)
	WITH ([id] VARCHAR(MAX) '$.user.ids[0].idValue'
	 ,[Ward] VARCHAR(MAX) '$.user.username'
	 ,[MV_Spell] VARCHAR(MAX) '$.firstname'
 ) 

