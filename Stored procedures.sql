    -- Crear el procedimiento para actualizar el estado de la copia
    CREATE PROCEDURE SP_UPDATE_COPY_STATUS
        @COPY_ID int,
        @BOOK_ID int,
    	@STATUS char(1)
    AS
    	-- Actualizar el estado de la copia recibida por parámetros
    	UPDATE COPIES SET STATUS = @STATUS WHERE COPIES.BOOK_ID = @BOOK_ID AND COPIES.COPY_NUMBER = @COPY_ID

    -- Crear el procedimiento para actualizar el estado del cliente
    CREATE PROCEDURE SP_UPDATE_CUSTOMER_STATUS
        @CUSTOMER_ID int,
    	@STATUS char(1)
    AS
    	-- Actualizar el estado del cliente recibido por parámetros
    	UPDATE CUSTOMER SET STATUS = @STATUS WHERE CUSTOMER.ID = @CUSTOMER_ID

    -- Crear el procedimiento para inicializar un préstamo
    CREATE PROCEDURE SP_INITIALIZE_LOAN
        @BOOK_ID INT,
        @COPY_NUMBER INT,
        @CUSTOMER_ID INT,
        @START_DATE DATETIME,
        @END_DATE DATETIME
    AS
    BEGIN
        -- Iniciar la transacción
        BEGIN TRAN;

        DECLARE @COPY_STATUS CHAR(1);
        DECLARE @CUSTOMER_STATUS CHAR(1);

        -- Obtener el estado actual de la copia
        SELECT @COPY_STATUS = STATUS
        FROM COPIES
        WHERE BOOK_ID = @BOOK_ID AND COPY_NUMBER = @COPY_NUMBER;
        -- Verificar si la copia está disponible para préstamo
        IF @COPY_STATUS = 'D'
        BEGIN
            -- Obtener el estado del cliente
            SELECT @CUSTOMER_STATUS = STATUS
            FROM CUSTOMER
            WHERE ID = @CUSTOMER_ID;

            -- Verificar si el cliente está habilitado
            IF @CUSTOMER_STATUS = 'H'
            BEGIN
            
                -- Crear el préstamo
                INSERT INTO LOAN (BOOK_ID, COPY_NUMBER, CUSTOMER_ID, START_DATE, END_DATE, RETURN_DATE)
                VALUES (@BOOK_ID, @COPY_NUMBER, @CUSTOMER_ID, @START_DATE, @END_DATE, NULL);

				    -- Marcar la copia como prestada
                EXEC SP_UPDATE_COPY_STATUS @COPY_NUMBER, @BOOK_ID, 'P';

                -- Commit si todo fue exitoso
                COMMIT;
                PRINT 'Préstamo realizado exitosamente.';
            END
            ELSE
            BEGIN
                -- Rollback si el cliente no está habilitado
                ROLLBACK;
                PRINT 'No se puede realizar el préstamo. El cliente no está habilitado.';
            END
        END
        ELSE
        BEGIN
            -- Rollback si la copia no está disponible o esta prestada
            ROLLBACK;
            PRINT 'No se puede realizar el préstamo. La copia no está disponible o ya esta prestada.';
        END
    END;

