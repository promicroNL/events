DECLARE @Copy as int = 1
DECLARE @CloneDBName as VARCHAR(20) = CONCAT('Cloned-WhiskyTrace', @Copy)
DECLARE @CloneMdfLocation as VARCHAR(100) = CONCAT('C:\mnt\clone', @Copy, '\WhiskyTrace.mdf')
DECLARE @CloneLdfLocation as VARCHAR(100) = CONCAT('C:\mnt\clone', @Copy, '\WhiskyTrace_log.ldf')

IF (EXISTS
(
    SELECT name
    FROM master.dbo.sysdatabases
    WHERE (
              '[' + name + ']' = @CloneDBName
              OR name = @CloneDBName
          )
)
   )
BEGIN
    EXEC master.dbo.sp_detach_db @dbname = @CloneDBName
    PRINT 'DB detached'
END
ELSE
BEGIN
    EXEC sp_attach_db @dbname = @CloneDBName,
                      @filename1 = @CloneMdfLocation,
                      @filename2 = @CloneLdfLocation
    PRINT 'DB attached'
END


SET @CloneDBName = CONCAT('Cloned-TasteWhisky', @Copy)
SET @CloneMdfLocation = CONCAT('C:\mnt\clone', @Copy, '\TasteWhisky.mdf')
SET @CloneLdfLocation = CONCAT('C:\mnt\clone', @Copy, '\TasteWhisky_log.ldf')

IF (EXISTS
(
    SELECT name
    FROM master.dbo.sysdatabases
    WHERE (
              '[' + name + ']' = @CloneDBName
              OR name = @CloneDBName
          )
)
   )
BEGIN
    EXEC master.dbo.sp_detach_db @dbname = @CloneDBName
    PRINT 'DB detached'
END
ELSE
BEGIN
    EXEC sp_attach_db @dbname = @CloneDBName,
                      @filename1 = @CloneMdfLocation,
                      @filename2 = @CloneLdfLocation
    PRINT 'DB attached'
END
