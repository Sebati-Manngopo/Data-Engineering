-- Enable advanced options and xp_cmdshell
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

-- Drop the #FileList table if it exists
IF OBJECT_ID('tempdb..#FileList') IS NOT NULL
    DROP TABLE #FileList;

-- Create a table to hold file names
CREATE TABLE #FileList (FileName NVARCHAR(255));

-- Execute xp_cmdshell to get the list of files starting with "daily_fin_" in the directory c:\input\
INSERT INTO #FileList (FileName)
EXEC xp_cmdshell 'dir C:\input\daily_fin_*.csv /b';

DECLARE @FileName NVARCHAR(255);
DECLARE @Command NVARCHAR(MAX);
DECLARE @FullFilePath NVARCHAR(MAX);

-- Cursor to loop through the files
DECLARE FileCursor CURSOR FOR
    SELECT FileName
    FROM #FileList
    WHERE FileName IS NOT NULL;

-- Open the cursor
OPEN FileCursor;

FETCH NEXT FROM FileCursor INTO @FileName;

-- Loop through all matching files
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Construct full file path
    SET @FullFilePath = 'C:\input\' + @FileName;  -- Escape backslashes for the file path

    BEGIN TRY
    -- Construct the BULK INSERT command
    SET @Command = '
        BULK INSERT tbl_dailyfin
        FROM ''' + @FullFilePath + '''
        WITH (
            FIRSTROW = 1,                     
            FIELDTERMINATOR = '','',         
            ROWTERMINATOR = ''\n'',        
            TABLOCK                         
        );
    ';

    -- Execute the dynamic SQL
    EXEC sp_executesql @Command;

    PRINT 'Successfully imported: ' + @FullFilePath;
END TRY
BEGIN CATCH
    PRINT 'Failed to import: ' + @FullFilePath + '. Error: ' + ERROR_MESSAGE();
    PRINT 'Full Command: ' + @Command;  -- Log the BULK INSERT command for debugging
END CATCH;


    -- Fetch the next file
    FETCH NEXT FROM FileCursor INTO @FileName;
END;

-- Close and deallocate the cursor
CLOSE FileCursor;
DEALLOCATE FileCursor;

-- Drop the temporary table
DROP TABLE #FileList;

-- Disable xp_cmdshell for security
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
