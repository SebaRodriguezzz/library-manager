	CREATE TABLE AUTHOR (ID int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
				 FIRST_NAME char(22) NOT NULL,
				 LAST_NAME char(22) NOT NULL)

	--

	CREATE TABLE GENRE (ID int NOT NULL IDENTITY(1, 1) PRIMARY KEY,
				 NAME char(40) UNIQUE)

	--

	CREATE TABLE BOOK (ID int NOT NULL IDENTITY(1, 1) PRIMARY KEY, 
				 TITLE char(40) NOT NULL,
				 AUTHOR_ID int NOT NULL,
				 GENRE_ID int NOT NULL,
				 RELEASE_YEAR int NOT NULL,
				 PRICE smallmoney NOT NULL,
				 FOREIGN KEY (AUTHOR_ID) REFERENCES AUTHOR(ID),
				 FOREIGN KEY (GENRE_ID) REFERENCES GENRE(ID)
				 )

	--

	CREATE TABLE ADDRESS (ID int PRIMARY KEY IDENTITY(1, 1) NOT NULL,
				 STREET char(30) NOT NULL,
				 NUMBER int NOT NULL,
	             CITY char(20) NOT NULL,
				 ZIP_CODE int NOT NULL)

	--

	CREATE TABLE CUSTOMER (ID int PRIMARY KEY IDENTITY(1, 1) NOT NULL,
	             FIRST_NAME char(22) NOT NULL,
				 LAST_NAME char(22) NOT NULL,
	             ADDRESS_ID int NOT NULL,
				 STATUS char(1) NOT NULL,
				 FOREIGN KEY (ADDRESS_ID) REFERENCES ADDRESS(ID)
				 )

	--

	CREATE TABLE COPIES (ID int PRIMARY KEY IDENTITY(1, 1) NOT NULL,
				 BOOK_ID int NOT NULL,
	             COPY_NUMBER int,
		   	     STATUS char(1) NOT NULL,
				 FOREIGN KEY (BOOK_ID) REFERENCES BOOK(ID)
				)

	--

	CREATE TABLE LOAN (ID int IDENTITY(1, 1) NOT NULL,
	             BOOK_ID int NOT NULL,
	             COPY_NUMBER smallint NOT NULL,
				 CUSTOMER_ID int NOT NULL,
				 DAILY_COST smallmoney,
			     START_DATE datetime DEFAULT GETDATE(),
			     END_DATE datetime NOT NULL,
				 RETURN_DATE datetime,
			     CONSTRAINT PK_LOAN PRIMARY KEY CLUSTERED 
				(
					ID,
					CUSTOMER_ID,
					BOOK_ID,
					COPY_NUMBER
				),
				FOREIGN KEY (BOOK_ID) REFERENCES BOOK(ID),
				FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMER(ID)
				)

	-------

	-- Agregar constraints de valores permitidos
	ALTER TABLE COPIES
	ADD CONSTRAINT CK_COPIES_ALLOWED_VALUES
	CHECK (STATUS IN ('P', 'D', 'N'));

	ALTER TABLE CUSTOMER
	ADD CONSTRAINT CK_CUSTOMER_ALLOWED_VALUES
	CHECK (STATUS IN ('H', 'I'));

	-- Agregar constraint de rango de fechas para que END_DATE no pueda ser antes de START_DATE
	ALTER TABLE LOAN
	ADD CONSTRAINT CK_LOAN_DATE_RANGE 
	CHECK (START_DATE <= END_DATE);