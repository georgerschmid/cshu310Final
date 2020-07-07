create database cs310project;

use cs310project;


create table Item (
ID int auto_increment,
ItemCode varchar(5) unique,
ItemDescription varchar(50) not null,
Price decimal(4,2) default 0,
primary key (ID));



Insert into Item (ItemCode,ItemDescription, Price) Values ('A','aa',5),('A','aaaa',4);
Insert into Item (ItemCode,ItemDescription, Price) Values ('B','aa',5),('B','aaaa',4);

Insert into Item (ItemCode, Price) Values ('B',5);
Insert into Item (ItemCode, Price) Values ('J',5);
Insert into Item (ItemCode, Price) Values ('J',6);


Insert into Item(ItemCode, ItemDescription) Values ('beers','2oc beers') ;

Update Item Set Price =4.50 Where ItemCode='beers';


drop table Purchase;
create table Purchase (
ID int auto_increment
, ItemID int
, Quantity int not null
, PurchaseDate datetime not null
, primary key (ID)
, foreign key (ItemID) references Item(ID));


Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (-8, 1, Now());
Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (2, 1, Now());

Insert into Purchase (ItemID, PurchaseDate) Values (1,  Now());

Insert into Purchase (ItemID,Quantity) Values (1, 1);


Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (1, 1, Now());
Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (1, 1, Now());
Select * from Purchase ;


create table Shipment (
ID int auto_increment
, ShipmentDate datetime not null
, ItemID int 
, Quantity int not null
, primary key (ID)
, foreign key (ItemID) references Item(ID));


Insert into Shipment(ShipmentDate,ItemID,Quantity) Values (Now(), -9, 3);
Insert into Shipment(ShipmentDate,ItemID,Quantity) Values (Now(), 9, 3);

Insert into Shipment(ItemID,Quantity) Values (1, 3);

Insert into Shipment(ShipmentDate,ItemID) Values (Now(), 1);


Insert into Shipment(ShipmentDate,ItemID,Quantity) Values (Now(),1, 1);
Insert into Shipment(ShipmentDate,ItemID,Quantity) Values (Now(),1,1);
Select * from Shipment;


delimiter //

create procedure CreateItem (paramCode varchar(5), paramDescription varchar(50), paramPrice decimal(4,2))
begin
	insert into Item(ItemCode, ItemDescription, Price)
    values (paramCode, paramDescription, paramPrice);
end //

delimiter ;


delimiter //

create procedure CreateShipment (paramShipDate datetime, paramCode varchar(5), paramQuantity int)
begin    
	set @itemID := (select ID from Item where ItemCode = paramCode);
	insert into Shipment(ShipmentDate, ItemID, Quantity)
	values (paramShipDate, @itemID, paramQuantity);
end //

delimiter ;

-- Procedure for creating a purchase --
delimiter //

create procedure CreatePurchase (paramCode varchar(5), paramQuantity int, paramPurchaseDate datetime)
begin
	insert into Purchase (ItemID, Quantity, PurchaseDate)
    values ((select ID from Item where ItemCode = paramCode), paramQuantity, paramPurchaseDate);
end //

delimiter ;


Call CreateItem ('homes','All homes Same Price', 5.50);
Call CreateShipment(Now(),'homes',5);
Call CreatePurchase('homes', 1,Now());


delimiter //

create procedure GetItems (paramCode varchar(5))
begin
	select * from Item where ItemCode like paramCode;
end //

delimiter ;


delimiter //

create procedure GetShipments (thisDate date)
begin
	select * from Shipment where cast(ShipmentDate as date) = thisDate;
end //

delimiter ;


delimiter //

create procedure GetPurchases (thisDate date)
begin
	select * from Purchase where cast(PurchaseDate as date) = thisDate;
end //

delimiter ;


Call GetItems ('%');
Call GetItems ('d');
Call GetItems ('beers');
Call GetShipments("2020-05-10");
Call GetPurchases("2020-05-10");
Call GetShipments("2020-05-11");
Call GetPurchases("2020-05-11");


delimiter //

create procedure ItemsAvailable (pCode varchar(5)) 
begin
	select ItemCode as 'Code', ItemDescription as 'Description', ifnull(sum(Shipment.Quantity)-sum(Purchase.Quantity), 0) as 'Available Quantity'
    from Item
    inner join Shipment
		on Shipment.ItemID = Item.ID
	inner join Purchase
		on Purchase.ItemID = Item.ID
    where ItemCode like pCode
    group by ItemCode, ItemDescription;
end //

delimiter ;


Call ItemsAvailable('beers');
call ItemsAvailable('%');
call ItemsAvailable('homes');


insert into Item(ItemCode, ItemDescription, Price) values ('tools', 'All the tools', 5.00);
insert into Shipment(ShipmentDate, ItemID, Quantity) values (now(), 3, 0);
Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (3, 0, Now());
call ItemsAvailable('tools');




delimiter //

create procedure UpdateShipment (pShipmentDate date, pItemCode varchar(5), pQuantity int)
begin
	update Shipment
    set Quantity = pQuantity
    where Shipment.ItemID = (select ID from Item where ItemCode = pItemCode) and cast(Shipment.ShipmentDate as date) = pShipmentDate;
end //

delimiter ;


call UpdateShipment ("2020-05-11", 'beers', 5);
call UpdateShipment ("2020-05-10", 'homes', 1);
call UpdateShipment ("2020-05-11", 'beers', 1);
call UpdateShipment ("2020-05-10", 'homes', 5);
call UpdateShipment ('homes', 5);


delimiter //

create procedure UpdateItem (pItemCode varchar(5), pDescription varchar(50), pPrice decimal(4,2))
begin
	update Item
    set ItemDescription = pDescription, Price = pPrice
    where ItemCode = pItemCode;
end //

delimiter ;


call UpdateItem('homes', 'New homes', 5.50);
call UpdateItem('homes', 'All homes same price', 6.50);


delimiter //

create procedure UpdatePurchase (pItemCode varchar(5), pQuantity int, pPurchaseDate date)
begin
	update Purchase
    set Quantity = pQuantity
    where Purchase.ItemID = (select ID from Item where ItemCode = pItemCode) and cast(Purchase.PurchaseDate as date) = pPurchaseDate;
end //

delimiter ;


call UpdatePurchase ('beers', 5, "2018-02-11");
call UpdatePurchase ('homes', 5, "2018-02-19");
call UpdatePurchase ('beers', 1, "2018-02-11");
call UpdatePurchase ('homes', 1, "2018-02-19");
call UpdatePurchase ('homes', 5);




delimiter //

create procedure DeleteShipment (pShipmentDate date, pCode varchar(5))
begin
	delete from Shipment
    where cast(ShipmentDate as date) = pShipmentDate and ItemID = (select ID from Item where ItemCode = pCode);
end //

delimiter ;


call DeleteShipment(cast(now() as date), 'tools');
insert into Shipment(ShipmentDate, ItemID, Quantity) values (now(), 3, 0);
call DeleteShipment(cast(now() as date), 'tools');


delimiter //

create procedure DeleteItem (pCode varchar(5))
begin
	delete from Item
    where ItemCode = pCode;
end //

delimiter ;


call DeleteItem('tools');


delimiter //

create procedure DeletePurchase (pPurchaseDate date, pCode varchar(5))
begin
	delete from Purchase
    where cast(PurchaseDate as date) = pPurchaseDate and ItemID = (select ID from Item where ItemCode = pCode);
end //

delimiter ;


call DeletePurchase(cast(now() as date), 'tools');
Insert into Purchase (ItemID,Quantity, PurchaseDate) Values (3, 0, Now());
call DeletePurchase(cast(now() as date), 'tools');


call DeleteItem('tools');
