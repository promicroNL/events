/* we go out to buy some whisky */

WHILE 1 = 1
BEGIN


DECLARE @SupplierName AS VARCHAR(50)
DECLARE @WhiskyName AS VARCHAR(50)
    SELECT top 1
        @SupplierName = p1.[SupplierName]
       
    FROM [dbo].[WhiskyPurchase] p1

    ORDER by ABS(CHECKSUM(NEWID()) % 3650)

	
    SELECT top 1
        @WhiskyName = p1.WhiskyName
       
    FROM [dbo].[WhiskyPurchase] p1

    ORDER by ABS(CHECKSUM(NEWID()) % 3650)

    INSERT WhiskyPurchase
    (
        SupplierName,
        WhiskyName,
        PurchaseDate
    )
    SELECT @SupplierName, @WhiskyName,
        DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 3650), '2010-01-01')


END


/* insert new badge */

WHILE 1 = 1
BEGIN

insert into [TasteWhisky].[dbo].[Badges]
values
('Drammer', ABS(CHECKSUM(NEWID()) % 3650) , Getdate())

END

select count(*) from dbo.WhiskyPurchase