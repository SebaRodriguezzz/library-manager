    CREATE VIEW INCONSISTENCY_VIEW_LOAN_COPIES
    AS
    SELECT
        -- Seleccionar campos de la tabla COPIES
        C.ID AS COPY_ID,
        C.BOOK_ID AS BOOK_ID,
        C.COPY_NUMBER AS COPY_NUMBER,
        C.STATUS AS COPY_STATUS,
    	-- Seleccionar campos de la tabla LOAN
        L.ID AS LOAN_ID,
        L.BOOK_ID AS LOAN_BOOK_ID,
        L.COPY_NUMBER AS LOAN_COPY_NUMBER,
        L.START_DATE AS START_DATE,
        L.END_DATE AS END_DATE,
        L.RETURN_DATE AS RETURN_DATE
    FROM
    	-- Combinar la tabla COPIES con la tabla LOAN 
        COPIES C
        LEFT JOIN LOAN L ON C.BOOK_ID = L.BOOK_ID AND C.COPY_NUMBER = L.COPY_NUMBER
    WHERE
        (C.STATUS IS NULL OR (L.ID IS NULL AND C.STATUS <> 'P') OR ((L.RETURN_DATE IS NULL AND GETDATE() > L.END_DATE) AND C.STATUS == 'P')) OR 
    	-- Alguno de los campos es nulos y el libro esta en la tabla prestamos
    	-- o el libro no fue devuelto y ya pasó la fecha de fin de prestamo
    	--
    	-- Se devolvió y el estado es distinto de devuelto
        (C.STATUS IS NOT NULL AND L.ID IS NOT NULL AND (L.RETURN_DATE IS NOT NULL AND C.STATUS <> 'D')); 
    	