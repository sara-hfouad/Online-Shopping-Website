
GO

CREATE PROC postProduct
@vendorUsername VARCHAR(20), @product_name VARCHAR(20) , @category VARCHAR(20), 
@product_description text , @price decimal(10,2), @color VARCHAR(20) 
AS
INSERT INTO Product (vendor_username,product_name,category,product_description,price,final_price,color,available)
VALUES (@vendorUsername,@product_name,@category,@product_description,@price,@price,@color, '1')

GO
EXEC postProduct 'eslam.mahmod','pencil','stationary','HB0.7', 10, 'red'

GO

CREATE PROC vendorviewProducts
@vendorname VARCHAR(20)
AS
SELECT p.*
FROM Product p
WHERE p.vendor_username = @vendorname

GO
EXEC vendorviewProducts 'eslam.mahmod'

GO
CREATE PROC EditProduct
@vendorname VARCHAR(20), @serialnumber int, @product_name VARCHAR(20)= null ,
@category VARCHAR(20)= null, @product_description text = null , @price decimal(10,2)= null, @color VARCHAR(20)= null
AS



IF EXISTS(
    SELECT *
    FROM Product
    WHERE serial_no = @serialnumber AND vendor_username = @vendorname
) 
BEGIN
IF @product_name IS NOT NULL 
UPDATE Product 
SET product_name = @product_name
WHERE serial_no=@serialnumber

IF @category IS NOT NULL 
UPDATE Product 
SET category = @category
WHERE serial_no=@serialnumber

IF @product_description IS NOT NULL 
UPDATE Product 
SET product_description = @product_description
WHERE serial_no=@serialnumber


IF @price IS NOT NULL 
UPDATE Product 
SET price = @price
WHERE serial_no=@serialnumber


IF @color IS NOT NULL 
UPDATE Product 
SET color = @color
WHERE serial_no=@serialnumber

END

GO
--EXEC EditProduct  @vendorname='eslam.mahmod',@serialnumber= 6,@color= 'blue'
--drop proc EditProduct
GO
CREATE PROC deleteProduct
@vendorname VARCHAR(20), @serialnumber int
AS
--CHECK CASCADE 
DECLARE @flag BIT
IF(EXISTS(SELECT * FROM Product WHERE vendor_username= @vendorname  AND serial_no=@serialnumber ))
 SET @flag='1'
ELSE
SET @flag='0'


if(@flag='1')
BEGIN
DELETE FROM Product
WHERE serial_no=@serialnumber
END
GO
--DROP PROC deleteProduct



--EXEC deleteProduct 'eslam.mahmod',5
GO

CREATE PROC viewQuestions
@vendorname VARCHAR(20)
AS
SELECT q.*
FROM Product p INNER JOIN Customer_Quesiton_Product q 
ON p.serial_no=q.serial_no
WHERE p.vendor_username=@vendorname

GO
--EXEC viewQuestions  'hadeel.adel'
GO

CREATE PROC answerQuestions
@vendorname VARCHAR(20), @serialno int, @customername VARCHAR(20), @answer text
AS
IF EXISTS(
SELECT *
FROM Product 
WHERE @vendorname = vendor_username AND @serialno = serial_no
)
BEGIN
UPDATE Customer_Quesiton_Product
SET answer = @answer
WHERE serial_no = @serialno AND customer_name = @customername 
END
GO

--EXEC answerQuestions 'hadeel.adel',1 , 'ahmed.ashraf', '40'



 GO

CREATE PROC addOffer
@offeramount int, @expiry_date datetime
AS
INSERT INTO Offer (offer_amount,expiry_date) VALUES (@offeramount,@expiry_date)

GO
--EXEC addOffer 50, '11/10/2019'
--EXEC addOffer 50, '11/12/2019'

GO


CREATE PROC checkOfferonProduct
@serial int, @activeoffer bit OUTPUT
AS
IF (EXISTS (SELECT * FROM OffersOnProduct O WHERE O.serial_no=@serial))
BEGIN SET @activeoffer='1' END

ELSE
BEGIN SET @activeoffer = '0' END

GO

--DECLARE @op BIT
--EXEC checkOfferonProduct 1, @op OUTPUT
--print @op 
--check cascade
GO


CREATE PROC checkandremoveExpiredoffer
@offerid int
AS

IF(exists(SELECT * FROM offer WHERE  offer_id=@offerid AND expiry_date <= CURRENT_TIMESTAMP))
BEGIN

UPDATE Product 
SET final_price = price 

WHERE serial_no  IN (
    SELECT serial_no
    FROM OffersOnProduct 
    WHERE @offerid = offer_id
)


DELETE 
FROM Offer 
WHERE offer_id=@offerid 

DELETE
FROM offersOnProduct
WHERE offer_id=@offerid

END





GO
--drop proc checkandremoveExpiredoffer
--exec checkandremoveExpiredoffer 2

GO



CREATE PROC applyOffer
@vendorname VARCHAR(20), @offerid int, @serial int
AS 
IF (EXISTS(
SELECT *
FROM Product 
WHERE @vendorname = vendor_username AND @serial = serial_no
)) AND  (EXISTS(
SELECT *
FROM Offer 
WHERE @offerid = offer_id AND expiry_date > CURRENT_TIMESTAMP
)) AND (NOT EXISTS ( SELECT *
from offersOnProduct op INNER JOIN offer o on o.offer_id = op.offer_id
where serial_no = @serial and o.expiry_date > CURRENT_TIMESTAMP))
BEGIN
--UPDATE PRICE OF THE PRODUCT
DECLARE @offer_amount INT
DECLARE @perc DECIMAL(5,2)

SELECT @offer_amount = offer_amount
FROM Offer
WHERE offer_id = @offerid

SET @perc = @offer_amount *0.01



UPDATE Product
SET final_price = final_price- (final_price * @perc)
WHERE serial_no=@serial

INSERT INTO OffersOnProduct VALUES (@offerid,@serial)
END
GO



--EXEC applyOffer 'hadeel.adel',9 ,3
--EXEC applyOffer 'hadeel.adel',10 ,3

--EXEC applyOffer 'hadeel.adel',1, 3

GO

CREATE PROC checkExpired
@offerid int, @expired bit OUTPUT
AS

IF(exists(SELECT * FROM offer WHERE  offer_id=@offerid AND expiry_date <= CURRENT_TIMESTAMP))
BEGIN SET @expired='1' END

ELSE
BEGIN SET @expired = '0' END

GO


--DECLARE @op BIT
--EXEC checkExpired 3, @op OUTPUT
--print 'proc o/p: '
--print @op 
--check cascade
GO


GO

select *
from OffersOnProduct

GO

CREATE PROC notmyproduct
@vendorname VARCHAR(20), @serialno INT, @notmine BIT OUTPUT
AS

IF NOT EXISTS(
    SELECT *
    FROM Product
    WHERE serial_no = @serialno AND vendor_username = @vendorname
) 
BEGIN SET @notmine='1' END

ELSE
BEGIN SET @notmine = '0' END

GO


DECLARE @op BIT
EXEC notmyproduct 'eslam.mahmod',7, @op OUTPUT
print 'proc o/p: '
print @op

GO
CREATE PROC notaproduct
 @serialno INT, @nothere BIT OUTPUT
AS

IF NOT EXISTS(
    SELECT *
    FROM Product
    WHERE serial_no = @serialno
) 
BEGIN SET @nothere='1' END

ELSE
BEGIN SET @nothere = '0' END

GO




--DECLARE @op BIT
--EXEC notaproduct 2, @op OUTPUT
--print 'proc o/p: '
--print @op

GO

CREATE PROC notanoffer
 @offerid INT, @nothere BIT OUTPUT
AS

IF NOT EXISTS(
    SELECT *
    FROM offer
    WHERE offer_id = @offerid
) 
BEGIN SET @nothere='1' END

ELSE
BEGIN SET @nothere = '0' END

GO

DECLARE @op BIT
EXEC notanoffer 4 , @op OUTPUT
print 'proc o/p: '
print @op

GO

select *
from offer

---------------------
GO
CREATE PROC checkVendor
@vendor_username VARCHAR(20) , @checkVendor BIT OUTPUT

AS
IF(EXISTS (SELECT * FROM Vendor WHERE username =@vendor_username))
SET @checkVendor='1'
ELSE 
SET @checkVendor='0'
GO
----------------------------
GO

CREATE PROC checkExistingOrder
@order_no int , @checkorder BIT OUTPUT

AS
IF(EXISTS (SELECT * FROM Orders WHERE order_no =@order_no))
SET @checkorder='1'
ELSE 
SET @checkorder='0'
------------------------------------------
GO
CREATE PROC checkExistingProduct
@serial_no INT,
@activeProduct BIT OUTPUT
AS
IF(EXISTS (SELECT * FROM Product WHERE serial_no =@serial_no))
SET @activeProduct='1'
ELSE 
SET @activeProduct='0'
------------------------------------------
GO
CREATE PROC checkExistingTodaysDeal
@deal_id INT,
@activeDeal BIT OUTPUT
AS
IF(EXISTS (SELECT * FROM Todays_Deals WHERE deal_id =@deal_id))
SET @activeDeal='1'
ELSE 
SET @activeDeal='0'
----------------------------------------------
GO

CREATE PROC addTodaysDealOnProduct
@deal_id int, @serial_no int
AS

If ( EXISTS (SELECT deal_id FROM Todays_Deals where deal_id=@deal_id AND expiry_date > CURRENT_TIMESTAMP) )

BEGIN
INSERT INTO Todays_Deals_Product(deal_id,serial_no)
VALUES(@deal_id,@serial_no)


DECLARE @deal_amount INT
DECLARE @perc DECIMAL(5,2)

SELECT @deal_amount = deal_amount
FROM Todays_Deals
WHERE deal_id = @deal_id

SET @perc =  @deal_amount *0.01

UPDATE Product
SET  final_price = final_price-(final_price * @perc)
WHERE serial_no=@serial_no

END
GO
---------------------------------
GO 
CREATE PROC notactive
 @vendorname VARCHAR(20), @notactive BIT OUTPUT
AS

IF NOT EXISTS(
    SELECT *
    FROM Vendor
    WHERE activated = '1' and @vendorname= username
) 
BEGIN SET @notactive='1' END

ELSE
BEGIN SET @notactive = '0' END

GO



DECLARE @op BIT
EXEC notactive 'eslam.mahmod' , @op OUTPUT
print 'proc o/p: '
print @op



GO



GO
CREATE PROC viewoffers
as
Select *
From Offer
GO

exec viewoffers
