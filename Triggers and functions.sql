    -- Crear la función que evalúa si la devolución fue luego de la fecha estipulada
    CREATE FUNCTION FAULT_DELIVERY(@end_date DATETIME, @return_date DATETIME)
    RETURNS BIT
    AS
    BEGIN
        DECLARE @resultado BIT;
    	-- Establecer el resultado basado en si la fecha de devolución es posterior a la fecha límite
        SET @resultado = CASE WHEN @return_date > @end_date  THEN 1 ELSE 0 END;
    	
        RETURN @resultado;
    END;

    -- Crear un trigger que se activa después de una actualización de RETURN_DATE en la tabla LOAN
    CREATE TRIGGER AUTO_UPDATE_COPY_STATUS
    ON LOAN
    AFTER UPDATE
    AS
    BEGIN
        -- Verificar si la columna STATUS ha sido actualizada en la tabla
        IF UPDATE(RETURN_DATE)
        BEGIN
            -- Obtener los datos actualizados de la tabla
            DECLARE @COPY_ID INT, @BOOK_ID INT;
    		SELECT @COPY_ID = COPIES.COPY_NUMBER,
                   @BOOK_ID = COPIES.BOOK_ID
            FROM COPIES
            WHERE COPIES.BOOK_ID = BOOK_ID AND COPIES.COPY_NUMBER = COPY_NUMBER;

    		DECLARE @END_DATE DATETIME, @RETURN_DATE DATETIME, @FUNCTION_RESULT BIT, @CUSTOMER_ID INT;

            -- Obtener los datos actualizados de la tabla
            SELECT @END_DATE = LOAN.END_DATE,
                   @RETURN_DATE = LOAN.RETURN_DATE,
                   @CUSTOMER_ID = LOAN.CUSTOMER_ID
            FROM inserted LOAN;

            -- Llamar a la función FAULT_DELIVERY para evaluar si la devolución fue tardía
            SET @FUNCTION_RESULT = dbo.FAULT_DELIVERY(@END_DATE, @RETURN_DATE);

            -- Verificar el resultado y ejecutar SP_UPDATE_CUSTOMER_STATUS para actualizar el estado del cliente si es necesario
            IF @FUNCTION_RESULT = 1
            BEGIN
                EXEC dbo.SP_UPDATE_CUSTOMER_STATUS @CUSTOMER_ID, 'I';
    			PRINT 'El cliente ha sido inhabilitado por devolver el libro luego de la fecha estipulada';
            END;
            PRINT 'Libro devuelto. Estado actualizado';
        END;
    END;

	-- Crear la función para calcular el DAILY_COST
	CREATE FUNCTION CALCULATE_DAILY_COST(@BookID INT)
	RETURNS SMALLMONEY
	AS
	BEGIN
		DECLARE @Price SMALLMONEY;

		-- Obtener el precio del libro
		SELECT @Price = PRICE
		FROM BOOK
		WHERE ID = @BookID;

		-- Calcular el 5% del precio total del libro
		RETURN @Price * 0.05;
	END;
	GO

	-- Crear trigger para insertar el DAILY_COST automaticamente
	CREATE TRIGGER INSERT_DAILY_COST
	ON LOAN
	AFTER INSERT
	AS
	BEGIN
		UPDATE LOAN
		SET DAILY_COST = CALCULATE_DAILY_COST(INSERTED.BOOK_ID)
		FROM INSERTED
		WHERE LOAN.ID = INSERTED.ID;
	END;
	GO

	-- Crear trigger para verificar la persistencia de datos
	CREATE TRIGGER VERIFY_INSERTED_LOAN_DATA
	ON LOAN
	AFTER INSERT
	AS
	BEGIN
			DECLARE @BOOK_ID INT, @COPY_NUMBER INT, @CUSTOMER_ID INT, @START_DATE DATETIME, @END_DATE DATETIME;

			SELECT TOP 1
				@BOOK_ID = BOOK_ID,
				@COPY_NUMBER = COPY_NUMBER,
				@CUSTOMER_ID = CUSTOMER_ID,
				@START_DATE = START_DATE,
				@END_DATE = END_DATE
			FROM INSERTED;

			-- Llamar al procedimiento SP_INITIALIZE_LOAN
			EXEC SP_INITIALIZE_LOAN @BOOK_ID, @COPY_NUMBER, @CUSTOMER_ID, @START_DATE, @END_DATE;
	END;
	GO

