---- Trigger on update function
---- When table doc_ticket field sold will be updated, that trigger will add
---- new row into doc_ticket_report. It contains simple information about ticket sale.
CREATE TRIGGER AddNewRecordToTicketReport 
ON doc_ticket
AFTER UPDATE 
AS 
IF (UPDATE (sold))
	BEGIN 
		UPDATE trigger_permissions SET have_permission = 1 WHERE id = 0;
		INSERT INTO doc_ticket_report (id_ticket, sell_time, period)
		VALUES (
			(SELECT t.id FROM doc_ticket AS t JOIN inserted AS i  ON  t.id = i.id),
			CONVERT(datetime, GETDATE()),
			DATEPART(month, GETDATE())
		 );
		 UPDATE trigger_permissions SET have_permission = 0 WHERE id = 0;
	END;
GO

--In relations with AddNewRecordToTicketReport trigger
--Triger instead of type: INSERT
---- Ban INSERT operation for doc_ticket_report table
CREATE TRIGGER banOnDirectlyAddingIntoTicketReport
ON doc_ticket_report
INSTEAD OF INSERT
AS 
	DECLARE @sold_flag BIT;
BEGIN
	SELECT @sold_flag = have_permission
	FROM trigger_permissions
	WHERE id = 0;
	IF(@sold_flag != 1)
	BEGIN
		RAISERROR('Can not be added. Record adds automatically', -1, -1)
		ROLLBACK TRANSACTION;
		RETURN;
	END;
END;
GO



------Triger instead of type: DELETE
------Giving access to remove ticket from doc_ticket time of flight start when time is over
--CREATE TRIGGER RemoveOnlyIfTimeIsOver
--ON doc_ticket
--INSTEAD OF DELETE
--AS 
--	DECLARE @sold BIT
--	DECLARE @id INT
--	DECLARE @flight_id INT
--	DECLARE @start_time TIME
--BEGIN 
--	SELECT  @sold = t.sold , 
--				 @id = t.id, 
--				 @flight_id = t.flight_report
--	FROM  doc_ticket AS t
--	JOIN deleted as d
--	ON t.id = d.id WHERE t.id = d.id;

--	SELECT @start_time = cat_flight.start_time
--	FROM doc_flight_real, cat_flight
--	WHERE doc_flight_real.id = @flight_id  AND 
--				cat_flight.id = doc_flight_real.id_flight;

--	IF (@sold = 0 OR @start_time < (CONVERT(time, GETDATE())))
--	BEGIN 
--		DELETE FROM doc_ticket WHERE id = @id;
--	END;
--	ELSE
--		RAISERROR('Can not be deleted, ticket not sold', -1, -1)
--		ROLLBACK TRANSACTION;
--		RETURN;
--	END;
--GO




------Trigger instead of type: UPDATE
------Ban UPDATE operation for add_class table
--CREATE TRIGGER banOnClassUpdate
--ON add_class
--INSTEAD OF UPDATE
--AS
--	BEGIN
--		RAISERROR('Information about classes can not be updated.', -1, -1)
--		ROLLBACK TRANSACTION;
--		RETURN;
--	END;
--GO

------Trigger on UPDATE operation
------Adds new record to shedule, if flight status updated to id 0
--CREATE TRIGGER add_doc_schedule
--ON doc_flight_real
--AFTER UPDATE
--AS 
--	DECLARE @status INT;
--	DECLARE @status_now INT;
--	DECLARE @flight_status INT
--BEGIN
--	SELECT @status = add_status.id 
--	FROM add_status WHERE  id = 0;

--	SELECT @status_now = fr.flight_status,
--				@flight_status = fr.id
--	FROM doc_flight_real AS fr
--	JOIN inserted AS ins
--	ON fr.id = ins.id
--	WHERE fr.id = ins.id;

--		IF (UPDATE(flight_status) AND @status = @status_now)
--		BEGIN 
--			INSERT INTO doc_shedule (id_flight_report, gate_num) VALUES (
--				@flight_status, 
--				(SELECT TOP 1 id FROM add_gate_status WHERE gate_status = 0)
--			);
--		END;
--	END;
--GO
