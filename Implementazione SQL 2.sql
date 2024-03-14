CREATE TABLE Utente (
    nickname varchar(255) PRIMARY KEY NOT NULL,
    email varchar(255) NOT NULL UNIQUE,
    pwd varchar(255) NOT NULL,
    sesso varchar(1) /*NOT NULL*/ CHECK (sesso IN ('M', 'F')),
    nome varchar(255) /*NOT NULL*/,
    cognome varchar(255) /*NOT NULL*/,
    data_nascita date,
    mac_utente varchar(17),
    FOREIGN KEY (mac_utente) REFERENCES Dispositivo(indirizzo_mac)
);


CREATE TABLE Follow (
    utente varchar(255) NOT NULL,
    utente_follower varchar(255) NOT NULL,
    PRIMARY KEY (utente, utente_follower),
    FOREIGN KEY (utente) REFERENCES Utente(nickname) /* ON DELETE CASCADE ON UPDATE CASCADE*/,
    FOREIGN KEY (utente_follower) REFERENCES Utente(nickname),
    CHECK (utente <> utente_follower)
);

CREATE TABLE Dispositivo (
    indirizzo_mac varchar(17) PRIMARY KEY NOT NULL,
    sistema_operativo varchar(255),
    ultima_localizzazione varchar(255) NOT NULL
);


CREATE TABLE Metodo_pagamento (
    numero_carta NUMERIC(19) PRIMARY KEY,
    cvv INT(4),
    data_scadenza date,
    titolare varchar(255),
    nome_utente varchar(255),
    FOREIGN KEY (nome_utente) REFERENCES Utente(nickname)
);


CREATE TABLE Abbonamento (
    utente varchar(255) NOT NULL PRIMARY KEY,
    durata int,
    data_inizio date,
    credito int NOT NULL DEFAULT 0,
    tipologia varchar(255) NOT NULL DEFAULT 'Base',
    FOREIGN KEY (utente) REFERENCES Utente(nickname),
    CHECK (credito >= 0)
);


CREATE TABLE Acquisto (
    n_carta NUMERIC(19) NOT NULL PRIMARY KEY,
    utente varchar(255) NOT NULL,
    costo float NOT NULL CHECK (costo >= 0),
    FOREIGN KEY (n_carta) REFERENCES Metodo_pagamento(numero_carta),
    FOREIGN KEY (utente) REFERENCES Utente(nickname)
);

CREATE TABLE Pacchetto_viaggio (
    nome varchar(255) NOT NULL,
    proprietario_pacchetto varchar(255) NOT NULL,
    numerosità int,
    fascia_prezzo float,
    tipologia varchar(255),
    data_inizio date,
    data_fine date,
    commento TEXT,
    PRIMARY KEY(nome, proprietario_pacchetto),
    FOREIGN KEY (proprietario_pacchetto) REFERENCES Utente(nickname),
    CHECK (numerosità >= 0),
    CHECK (fascia_prezzo >= 0)
);

CREATE TABLE Acquisizione (
  nome_pacchetto VARCHAR(255) NOT NULL,
  proprietario_pacchetto VARCHAR(255) NOT NULL,
  acquisitore VARCHAR(255) NOT NULL,
  PRIMARY KEY(nome_pacchetto, proprietario_pacchetto, acquisitore),
  FOREIGN KEY (nome_pacchetto) REFERENCES Pacchetto_viaggio(nome),
  FOREIGN KEY (acquisitore) REFERENCES Utente(nickname),
  FOREIGN KEY (proprietario_pacchetto) REFERENCES Utente(nickname),
  CHECK (proprietario_pacchetto <> acquisitore)
);

CREATE TABLE Algoritmo (
  pacchetto_consigliato VARCHAR(255) NOT NULL,
  proprietario_pacchetto VARCHAR(255) NOT NULL,
  ricevitore VARCHAR(255) NOT NULL,
  PRIMARY KEY (pacchetto_consigliato, proprietario_pacchetto, ricevitore),
  FOREIGN KEY (pacchetto_consigliato) REFERENCES Pacchetto_viaggio(nome),
  FOREIGN KEY (ricevitore) REFERENCES Utente(nickname),
  FOREIGN KEY (proprietario_pacchetto) REFERENCES Utente(nickname),
  CHECK (proprietario_pacchetto <> ricevitore)
);

CREATE TABLE Galleria (
  nome_pacchetto VARCHAR(255) NOT NULL,
  proprietario_pacchetto VARCHAR(255) NOT NULL,
  creatore VARCHAR(255) NOT NULL,
  foto BLOB,
  commento TEXT,
  nome VARCHAR(255) NOT NULL,
  PRIMARY KEY(nome_pacchetto, proprietario_pacchetto, creatore),
  FOREIGN KEY (nome_pacchetto) REFERENCES Pacchetto_viaggio(nome),
  FOREIGN KEY (creatore) REFERENCES Utente(nickname),
  FOREIGN KEY (proprietario_pacchetto) REFERENCES Utente(nickname),
  CHECK (creatore != proprietario_pacchetto)
);

CREATE TABLE Recensione (
  pacchetto_recensito VARCHAR(255) NOT NULL,
  proprietario_pacchetto VARCHAR(255) NOT NULL,
  recensitore VARCHAR(255) NOT NULL,
  testo TEXT,
  punteggio float NOT NULL CHECK (punteggio >= 0 AND punteggio <= 5),
  titolo VARCHAR(255) NOT NULL,
  PRIMARY KEY (pacchetto_recensito, proprietario_pacchetto, recensitore),
  FOREIGN KEY (pacchetto_recensito) REFERENCES Pacchetto_viaggio(nome),
  FOREIGN KEY (proprietario_pacchetto) REFERENCES Utente(nickname),
  FOREIGN KEY (recensitore) REFERENCES Utente(nickname),
  CHECK (recensitore <> proprietario_pacchetto)
);

CREATE TABLE Genere (
  nome_genere VARCHAR(255) NOT NULL PRIMARY KEY
);

CREATE TABLE Classificazione (
  nome_pacchetto VARCHAR(255) NOT NULL,
  proprietario_pacchetto VARCHAR(255) NOT NULL,
  nome_genere VARCHAR(255) NOT NULL,
  PRIMARY KEY (nome_pacchetto, proprietario_pacchetto, nome_genere),
  FOREIGN KEY (nome_pacchetto) REFERENCES Pacchetto_viaggio(nome),
  FOREIGN KEY (proprietario_pacchetto) REFERENCES Utente(nickname),
  FOREIGN KEY (nome_genere) REFERENCES Genere(nome_genere)
);

CREATE TABLE Città (
  longitudine DECIMAL(11, 8) NOT NULL CHECK (longitudine >= -180 and longitudine <= 180),
  latitudine  DECIMAL(10, 8) NOT NULL CHECK (latitudine >= -90 and latitudine <= 90),
  nome VARCHAR(255) NOT NULL,
  nazione VARCHAR(255) NOT NULL,
  UNIQUE(longitudine,latitudine),
  PRIMARY KEY (longitudine,latitudine) 
);

CREATE TABLE Riferimento (
  nome_pacchetto VARCHAR(255) NOT NULL,
  proprietario_pacchetto VARCHAR(255) NOT NULL,
  latitudine_city DECIMAL(10, 8) NOT NULL,
  longitudine_city DECIMAL(11, 8) NOT NULL,
  ordine_visite INT NOT NULL CHECK (ordine_visite >=1),
  UNIQUE(longitudine_city,latitudine_city),
  PRIMARY KEY (nome_pacchetto, proprietario_pacchetto, longitudine_city,latitudine_city),
  FOREIGN KEY (nome_pacchetto) REFERENCES Pacchetto_viaggio(nome),
  FOREIGN KEY (proprietario_pacchetto) REFERENCES Utente(nickname),
  FOREIGN KEY (longitudine_city, latitudine_city) REFERENCES Città(longitudine, latitudine)
);

CREATE TABLE Evento (
  nome_evento VARCHAR(255) NOT NULL,
  latitudine_city DECIMAL(10, 8) NOT NULL,
  longitudine_city DECIMAL(11, 8) NOT NULL,
  tipologia VARCHAR(255) NOT NULL,
  data_evento DATE NOT NULL,
  UNIQUE(latitudine_city,longitudine_city),
  PRIMARY KEY (nome_evento),
  FOREIGN KEY (longitudine_city, latitudine_city) REFERENCES Città(longitudine, latitudine)
);

CREATE TABLE Luoghi_visitati (
  civico INT NOT NULL CHECK (civico > 0),
  cap INT NOT NULL CHECK (cap > 0),
  via VARCHAR(255) NOT NULL,
  nome VARCHAR(255) NOT NULL,
  sito_web VARCHAR(255),
  genere VARCHAR(255),
  recensioni float CHECK (recensioni >= 0 AND recensioni <= 5),
  orario_apertura TIME NOT NULL,
  orario_chiusura TIME NOT NULL,
  barriere_architettoniche BOOLEAN,
  latitudine_city DECIMAL(10, 8) NOT NULL,
  longitudine_city DECIMAL(11, 8) NOT NULL,
  PRIMARY KEY (civico, cap, via),
  FOREIGN KEY (longitudine_city, latitudine_city) REFERENCES Città(longitudine, latitudine)
);

CREATE TABLE Luoghi_alloggio (
  civico INT NOT NULL CHECK (civico > 0),
  cap INT NOT NULL CHECK (cap > 0),
  via VARCHAR(255) NOT NULL,
  nome VARCHAR(255) NOT NULL,
  sito_web VARCHAR(255),
  genere VARCHAR(255),
  recensioni float CHECK (recensioni >= 0 AND recensioni <= 5),
  orario_apertura TIME NOT NULL,
  orario_chiusura TIME NOT NULL,
  latitudine_city DECIMAL(10, 8) NOT NULL,
  longitudine_city DECIMAL(11, 8) NOT NULL,
  dati_pagamento  NUMERIC(19),
  importo DECIMAL(10, 2),
  UNIQUE(civico, cap, via),
  PRIMARY KEY (civico, cap, via),
  FOREIGN KEY (longitudine_city, latitudine_city) REFERENCES Città(longitudine, latitudine),
  FOREIGN KEY (dati_pagamento) REFERENCES Metodo_pagamento(numero_carta)
);


CREATE TABLE Composizione (
  civico INT NOT NULL,
  via VARCHAR(255) NOT NULL,
  cap INT NOT NULL,
  nome_pacchetto VARCHAR(255) NOT NULL,
  proprietario_pacchetto VARCHAR(255) NOT NULL,
  data_visite DATE,
  UNIQUE(civico, cap, via),
  PRIMARY KEY (civico, cap, via, nome_pacchetto, proprietario_pacchetto),
  FOREIGN KEY (nome_pacchetto) REFERENCES Pacchetto_viaggio (nome),
  FOREIGN KEY (proprietario_pacchetto) REFERENCES Utente(nickname),
  FOREIGN KEY (civico, cap, via) REFERENCES Luoghi_visitati(civico, cap, via)
);


CREATE TABLE Collocazione (
  civico INT NOT NULL,
  via VARCHAR(255) NOT NULL,
  cap INT NOT NULL,
  nome_pacchetto VARCHAR(255) NOT NULL,
  proprietario_pacchetto VARCHAR(255) NOT NULL,
  data_alloggi DATE,
  UNIQUE(civico, cap, via),
  FOREIGN KEY (nome_pacchetto) REFERENCES Pacchetto_viaggio(nome),
  FOREIGN KEY (proprietario_pacchetto) REFERENCES Utente(nickname),
  FOREIGN KEY (civico, cap, via) REFERENCES Luoghi_alloggio(civico, cap, via),
  PRIMARY KEY(civico, cap, via, nome_pacchetto, proprietario_pacchetto)
);


/* DATI */
/***************************************************************************************************************************************/
/*Utente*/
/***************************************************************************************************************************************/

INSERT INTO Utente (nickname, email, pwd, sesso, nome, cognome, data_nascita, mac_utente)
VALUES ('Alessandro1', 'alessandro1@email.com', 'abc123', 'M', 'Alessandro', ' Rossi', '1990-01-01', 'AA:BB:CC:DD:EE:FF');
INSERT INTO Utente (nickname, email, pwd, sesso, nome, cognome, data_nascita, mac_utente)
VALUES ('Sara2', 'sara2@email.com', 'xyz456', 'F', 'Sara', 'Bianchi', '1991-02-01', 'AA:BB:CC:DD:EE:F1');
INSERT INTO Utente (nickname, email, pwd, sesso, nome, cognome, data_nascita, mac_utente)
VALUES ('Luca3', 'luca3@email.com', 'pqr789', 'M', 'Luca', 'Verdi', '1992-03-01', 'AA:BB:CC:DD:EE:F2');
INSERT INTO Utente (nickname, email, pwd, sesso, nome, cognome, data_nascita, mac_utente)
VALUES ('Anna4', 'anna4@email.com', 'def124', 'F', 'Anna', 'Rossi', '1993-04-01', 'AA:BB:CC:DD:EE:F3');
INSERT INTO Utente (nickname, email, pwd, sesso, nome, cognome, data_nascita, mac_utente)
VALUES ('Giovanni5', 'giovanni5@email.com', 'ghi456', 'M', 'Giovanni', 'Bianchi', '1994-05-01', 'AA:BB:CC:DD:EE:F4');
INSERT INTO Utente (nickname, email, pwd, sesso, nome, cognome, data_nascita, mac_utente)
VALUES ('Francesca6', 'francesca6@email.com', 'jkl678', 'F', 'Francesca', 'Verdi', '1995-06-01', 'AA:BB:CC:DD:EE:F5');
INSERT INTO Utente (nickname, email, pwd, sesso, nome, cognome, data_nascita, mac_utente)
VALUES ('Maurizio7', 'maurizio7@email.com', 'mno123', 'M', 'Maurizio', 'Rossi', '1996-07-01', 'AA:BB:CC:DD:EE:F6');
INSERT INTO Utente (nickname, email, pwd, sesso, nome, cognome, data_nascita, mac_utente)
VALUES ('Chiara8', 'chiara8@email.com', 'pqr246', 'F', 'Chiara', 'Bianchi', '1997-08-01', 'AA:BB:CC:DD:EE:F7');
INSERT INTO Utente (nickname, email, pwd, sesso, nome, cognome, data_nascita, mac_utente) 
VALUES
('giovanni99', 'giovanni99@gmail.com', 'giovanni99password', 'M', 'Giovanni', 'Rossi', '1999-05-12', '00:11:22:33:44:55'),
('maria123', 'maria123@gmail.com', 'maria123password', 'F', 'Maria', 'Bianchi', '2001-03-14', '11:22:33:44:55:66'),
('lucasito', 'lucasito@gmail.com', 'lucasitopassword', 'M', 'Luca', 'Ferrari', '1998-07-19', '22:33:44:55:66:77'),
('francesca456', 'francesca456@gmail.com', 'francesca456password', 'F', 'Francesca', 'Esposito', '1997-12-02', '33:44:55:66:77:88'),
('davide78', 'davide78@gmail.com', 'davide78password', 'M', 'Davide', 'Rizzo', '1999-08-25', '44:55:66:77:88:99'),
('claudia90', 'claudia90@gmail.com', 'claudia90password', 'F', 'Claudia', 'Colombo', '2002-01-11', '55:66:77:88:99:00'),
('alessio111', 'alessio111@gmail.com', 'alessio111password', 'M', 'Alessio', 'Moretti', '2000-06-23', '66:77:88:99:00:11'),
('caterina222', 'caterina222@gmail.com', 'caterina222password', 'F', 'Caterina', 'Fontana', '2002-04-08', '77:88:99:00:11:22'),
('federico333', 'federico333@gmail.com', 'federico333password', 'M', 'Federico', 'Galli', '1999-02-17', '88:99:00:11:22:33'),
('gabriella444', 'gabriella444@gmail.com', 'gabriella444password', 'F', 'Gabriella', 'Conti', '2001-05-29', '99:00:11:22:33:44');

INSERT INTO Utente (nickname, email, pwd, sesso, nome, cognome, data_nascita, mac_utente)
VALUES
('giuseppina_90', 'giuseppina_90@gmail.com', 'giuseppina_90pwd', 'F', 'Giuseppina', 'Moretti', '1990-01-05', 'AE:B1:C0:D9:E8:F7'),
('luciano_88', 'luciano_88@gmail.com', 'luciano_88pwd', 'M', 'Luciano', 'Bianchi', '1988-03-15', 'AE:B1:C0:D9:E8:F8'),
('paolo_87', 'paolo_87@gmail.com', 'paolo_87pwd', 'M', 'Paolo', 'Rossi', '1987-07-20', 'AE:B1:C0:D9:E8:F9'),
('maria_86', 'maria_86@gmail.com', 'maria_86pwd', 'F', 'Maria', 'Ferrari', '1986-09-10', 'AE:B1:C0:D9:E8:G0'),
('federico_85', 'federico_85@gmail.com', 'federico_85pwd', 'M', 'Federico', 'Rizzo', '1985-12-25', 'AE:B1:C0:D9:E8:G1'),
('stefania_84', 'stefania_84@gmail.com', 'stefania_84pwd', 'F', 'Stefania', 'Bruno', '1984-05-30', 'AE:B1:C0:D9:E8:G2'),
('massimo_83', 'massimo_83@gmail.com', 'massimo_83pwd', 'M', 'Massimo', 'Galli', '1983-08-10', 'AE:B1:C0:D9:E8:G3'),
('rossella_82', 'rossella_82@gmail.com', 'rossella_82pwd', 'F', 'Rossella', 'Conti', '1982-11-15', 'AE:B1:C0:D9:E8:G4'),
('alessandro_81', 'alessandro_81@gmail.com', 'alessandro_81pwd', 'M', 'Alessandro', 'Romano', '1981-02-20', 'AE:B1:C0:D9:E8:G5'),
('valentina_80', 'valentina_80@gmail.com', 'valentina_80pwd', 'F', 'Valentina', 'Moretti', '1980-06-05', 'AE:B1:C0:D9:E8:G6'),
('fabrizio_79', 'fabrizio_79@gmail.com', 'fabrizio_79pwd', 'M', 'Fabrizio', 'Bianchi', '1979-07-30', 'AE:B1:C0:D9:E8:G7'),
('claudia_78', 'claudia78@email.com', 'secret_pwd', 'F', 'Claudia', ' Rossi', '1978-03-12', 'AE:B1:C0:D9:E8:G8');

/***************************************************************************************************************************************/
/*    Dispositivo   */
/***************************************************************************************************************************************/

INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('00:11:22:33:44:55', 'Windows 10', 'Rome, Italy');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('11:22:33:44:55:66', 'macOS Catalina', 'Paris, France');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('22:33:44:55:66:77', 'Ubuntu 20.04', 'Berlin, Germany');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('33:44:55:66:77:88', 'Windows 8.1', 'London, UK');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('44:55:66:77:88:99', 'macOS Mojave', 'Madrid, Spain');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('55:66:77:88:99:00', 'Fedora 33', 'Amsterdam, Netherlands');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('66:77:88:99:00:11', 'Windows 7', 'Brussels, Belgium');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('77:88:99:00:11:22', 'macOS High Sierra', 'Lisbon, Portugal');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('88:99:00:11:22:33', 'CentOS 8', 'Vienna, Austria');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('99:00:11:22:33:44', 'Windows 10', 'Budapest, Hungary');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('AA:BB:CC:DD:EE:F1', 'macOS Big Sur', 'Prague, Czech Republic');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('AA:BB:CC:DD:EE:F2', 'Debian 10', 'Stockholm, Sweden');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione) 
VALUES ('AA:BB:CC:DD:EE:F3', 'Windows', 'Rome, Italy');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AA:BB:CC:DD:EE:F4', 'Windows 10', 'Milano, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AA:BB:CC:DD:EE:F5', 'Mac OS X', 'Roma, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AA:BB:CC:DD:EE:F6', 'Windows 8.1', 'Napoli, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AA:BB:CC:DD:EE:F7', 'Mac OS X', 'Firenze, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AA:BB:CC:DD:EE:FF', 'Windows 10', 'Palermo, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:F7', 'Mac OS X', 'Genova, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:F8', 'Windows 7', 'Torino, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:F9', 'Mac OS X', 'Bologna, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:G0', 'Windows 10', 'Verona, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:G1', 'Mac OS X', 'Catania, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:G2', 'Windows 8.1', 'Bari, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:G3', 'Mac OS X', 'Cagliari, IT');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:G4', 'Mac OS', 'New York');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:G5', 'Windows 10', 'Rome, Italy');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:G6', 'macOS Catalina', 'Venice, Italy');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:G7', 'iOS 14', 'Milan, Italy');
INSERT INTO Dispositivo (indirizzo_mac, sistema_operativo, ultima_localizzazione)
VALUES ('AE:B1:C0:D9:E8:G8', 'Windows 8.1', 'Turin, Italy');

/***************************************************************************************************************************************/
/*Follow*/
/***************************************************************************************************************************************/
INSERT INTO Follow (utente, utente_follower) VALUES ('giovanni99', 'maria123');
INSERT INTO Follow (utente, utente_follower) VALUES ('giovanni99', 'lucasito');
INSERT INTO Follow (utente, utente_follower) VALUES ('giovanni99', 'francesca456');
INSERT INTO Follow (utente, utente_follower) VALUES ('maria123', 'davide78');
INSERT INTO Follow (utente, utente_follower) VALUES ('maria123', 'claudia90');
INSERT INTO Follow (utente, utente_follower) VALUES ('lucasito', 'alessio111');
INSERT INTO Follow (utente, utente_follower) VALUES ('lucasito', 'caterina222');
INSERT INTO Follow (utente, utente_follower) VALUES ('francesca456', 'federico333');
INSERT INTO Follow (utente, utente_follower) VALUES ('francesca456', 'gabriella444');
INSERT INTO Follow (utente, utente_follower) VALUES ('davide78', 'Sara2');
INSERT INTO Follow (utente, utente_follower) VALUES ('davide78', 'Luca3');
INSERT INTO Follow (utente, utente_follower) VALUES ('claudia90', 'Anna4');
INSERT INTO Follow (utente, utente_follower) VALUES ('claudia90', 'Giovanni5');
INSERT INTO Follow (utente, utente_follower) VALUES ('alessio111', 'Francesca6');
INSERT INTO Follow (utente, utente_follower) VALUES ('alessio111', 'Maurizio7');
INSERT INTO Follow (utente, utente_follower) VALUES ('caterina222', 'Chiara8');
INSERT INTO Follow (utente, utente_follower) VALUES ('caterina222', 'Alessandro1');
INSERT INTO Follow (utente, utente_follower) VALUES ('federico333', 'giuseppina_90');
INSERT INTO Follow (utente, utente_follower) VALUES ('federico333', 'luciano_88');
INSERT INTO Follow (utente, utente_follower) VALUES ('gabriella444', 'valentina_80');
INSERT INTO Follow (utente, utente_follower) VALUES ('Sara2', 'fabrizio_79');
INSERT INTO Follow (utente, utente_follower) VALUES ('Luca3', 'claudia_78');
INSERT INTO Follow (utente, utente_follower) VALUES ('Anna4', 'giovanni99');
INSERT INTO Follow (utente, utente_follower) VALUES ('Giovanni5', 'maria123');
INSERT INTO Follow (utente, utente_follower) VALUES ('Francesca6', 'lucasito');
INSERT INTO Follow (utente, utente_follower) VALUES ('Maurizio7', 'francesca456');
INSERT INTO Follow (utente, utente_follower) VALUES ('Chiara8', 'davide78');
INSERT INTO Follow (utente, utente_follower) VALUES ('Alessandro1', 'claudia90');
INSERT INTO Follow (utente, utente_follower) VALUES ('giuseppina_90', 'alessio111');
INSERT INTO Follow (utente, utente_follower) VALUES ('luciano_88', 'caterina222');

/***************************************************************************************************************************************/
/*METODO PAGAMENTO*/
/***************************************************************************************************************************************/
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente)
VALUES ('1234567890123456', '1234', '2023-12-31', 'Giovanni Rossi', 'giovanni99');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente)
VALUES ('2345678901234567', '2345', '2024-06-30', 'Claudia Bianchi', 'claudia90');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente)
VALUES ('3456789012345678', '3456', '2024-03-31', 'Federico Neri', 'federico333');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente)
VALUES ('4567890123456789', '4567', '2024-11-30', 'Anna Rossi', 'Anna4');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente)
VALUES ('5678901234567890', '5678', '2024-01-31', 'Francesca Bianchi', 'Francesca6');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente)
VALUES ('6789012345678901', '6789', '2024-02-28', 'Massimo Neri', 'massimo_83');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente)
VALUES ('7890123456789012', '7890', '2024-04-30', 'Paolo Rossi', 'paolo_87');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente)
VALUES ('8901234567890123', '8901', '2024-05-31', 'Valentina Bianchi', 'valentina_80');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente) 
VALUES ('1234567890123406', '1934', '2025-12-01', 'Lucasito', 'lucasito');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente) 
VALUES ('2345678909234567', '1854', '2024-06-01', 'Davide78', 'davide78');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente) 
VALUES ('3456789012844678', '0284', '2023-12-01', 'Alessio111', 'alessio111');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente) 
VALUES ('4567890123498789', '1764', '2025-01-01', 'Caterina222', 'caterina222');
INSERT INTO Metodo_pagamento (numero_carta, cvv, data_scadenza, titolare, nome_utente) 
VALUES ('5678901234568890', '1234', '2024-09-01', 'Gabriella444', 'gabriella444');

/***************************************************************************************************************************************/
/*Abbonamento*/
/***************************************************************************************************************************************/
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('giovanni99', 12, '2023-02-10', 726, 'Premium');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('claudia90', 12, '2023-02-10', 222, 'Premium');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('federico333', 12, '2023-02-10',998, 'Premium');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('Anna4', 12, '2023-02-10',449, 'Premium');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('Francesca6', 12, '2023-02-10',190, 'Premium');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('massimo_83', 1, '2023-02-10',641, 'Premium');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('paolo_87', 12, '2023-02-10', 832, 'Premium');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('valentina_80', 6, '2023-02-10',103, 'Premium');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('maria123', 12, '2023-02-10', 0,'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('lucasito', 12, '2023-02-10',0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('francesca456', 12, '2023-02-10',0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('davide78', 12, '2023-02-10',0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('alessio111', 12, '2023-02-10',0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('caterina222', 12, '2023-02-10',0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('gabriella444', 12, '2023-02-10', 0,'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('Sara2', 12, '2022-12-01', 0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('Luca3', 12, '2022-12-01', 0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('Giovanni5', 12, '2022-12-01', 0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('Maurizio7', 12, '2022-12-01', 0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('Chiara8', 12, '2022-12-01', 0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('Alessandro1', 12, '2022-12-01', 0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('giuseppina_90', 12, '2022-12-01', 0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES
("luciano_88", 12, "2022-10-01", 0, "Base"),
("stefania_84", 24, "2022-11-01", 0, "Base"),
("rossella_82", 12, "2022-12-01", 0, "Base"),
("alessandro_81", 24, "2022-09-01", 0, "Base"),
("fabrizio_79", 12, "2022-10-01", 0, "Base"),
("claudia_78", 24, "2022-11-01", 0, "Base");
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('maria_86', 12, '2022-12-01', 0, 'Base');
INSERT INTO Abbonamento (utente, durata, data_inizio, credito, tipologia)
VALUES ('federico_85', 12, '2022-12-01', 0, 'Base');

/***************************************************************************************************************************************/
/*Acquisto*/
/***************************************************************************************************************************************/
INSERT INTO Acquisto (n_carta, utente, costo) VALUES ('4567890123456789', 'Anna4', 75.99);
INSERT INTO Acquisto (n_carta, utente, costo) VALUES ('2345678901234567', 'claudia90', 75.99);
INSERT INTO Acquisto (n_carta, utente, costo) VALUES ('3456789012345678', 'federico333', 75.99);
INSERT INTO Acquisto (n_carta, utente, costo) VALUES ('5678901234567890', 'Francesca6', 75.99);
INSERT INTO Acquisto (n_carta, utente, costo) VALUES ('1234567890123456', 'giovanni99', 75.99);
INSERT INTO Acquisto (n_carta, utente, costo) VALUES ('6789012345678901', 'massimo_83', 15.99);
INSERT INTO Acquisto (n_carta, utente, costo) VALUES ('7890123456789012', 'paolo_87', 75.99);
INSERT INTO Acquisto (n_carta, utente, costo) VALUES ('8901234567890123', 'valentina_80', 55.99);

/***************************************************************************************************************************************/
/*Genere*/
/***************************************************************************************************************************************/
INSERT INTO Genere(nome_genere) VALUES
('avventura'),('per famiglie'),('per gruppo di amici'),('culturale'),('relax');

/***************************************************************************************************************************************/
/*Pacchetto viaggio*/
/***************************************************************************************************************************************/
INSERT INTO Pacchetto_viaggio (nome, proprietario_pacchetto, numerosità, fascia_prezzo, tipologia, data_inizio, data_fine, commento)
VALUES 
('Safari in Tanzania', 'claudia90', 5, 800, 'avventura', '2023-08-01', '2023-08-10', 'Un viaggio indimenticabile alla scoperta della fauna selvaggia della Tanzania!'),
('Visita ai Musei di Parigi', 'federico333', 2, 700, 'culturale', '2023-07-01', '2023-07-05', 'Un viaggio alla scoperta della cultura francese attraverso le opere d\'arte dei musei di Parigi'),
('Settimana al mare in Calabria', 'Francesca6', 4, 500, 'relax', '2023-08-15', '2023-08-22', 'Un\'esperienza rilassante al mare in Calabria'),
('Escursione alle isole greche', 'giovanni99', 8, 900, 'per gruppo di amici', '2023-09-01', '2023-09-07', 'Un\'avventura indimenticabile con il gruppo di amici alle isole greche!'),
('Vacanze in montagna', 'massimo_83', 6, 700, 'per famiglie', '2023-12-20', '2023-12-27', 'Un\'esperienza indimenticabile per la famiglia alle montagne invernali'),
('Tour della Toscana', 'paolo_87', 3, 600, 'culturale', '2023-06-01', '2023-06-05', 'Un viaggio alla scoperta della cultura toscana'),
('Viaggio a New York', 'valentina_80', 2, 1000, 'avventura', '2023-09-01', '2023-09-07', 'Un\'avventura a New York City!'),
('Safari in Kenya', 'claudia90', 7, 800, 'avventura', '2023-08-15', '2023-08-22', 'Un viaggio indimenticabile alla scoperta della fauna selvaggia del Kenya!'),
('Visita ai Giardini di Versailles', 'federico333', 4, 700, 'culturale', '2023-07-15', '2023-07-18', 'Un viaggio alla scoperta della cultura francese attraverso i giardini di Versailles'),
('Settimana al mare in Sardegna', 'Francesca6', 6, 500, 'relax', '2023-08-01', '2023-08-08', 'Un\'esperienza rilassante al mare in Sardegna'),
('Escursione alle isole Baleari', 'giovanni99', 5, 900, 'per gruppo di amici', '2023-09-01', '2023-09-06', 'Un esperienza indimenticabile tra spiagge mozzafiato e divertimento notturno.');
INSERT INTO Pacchetto_viaggio (nome, proprietario_pacchetto, numerosità, fascia_prezzo, tipologia, data_inizio, data_fine, commento)
VALUES ('Viaggio a Berlino', 'paolo_87', 6, 800.0, 'culturale', '2023-04-20', '2023-04-27', 'Berlino è una città ricca di storia e cultura, che offre molte opportunità per esplorare i suoi quartieri e monumenti storici.');
INSERT INTO Pacchetto_viaggio (nome, proprietario_pacchetto, numerosità, fascia_prezzo, tipologia, data_inizio, data_fine, commento)
VALUES ('Vacanze in Sardegna', 'claudia_90', 4, 700.0, 'relax', '2023-07-05', '2023-07-12', 'La Sardegna è una destinazione perfetta per una vacanza al mare, con spiagge incontaminate e una ricca vita notturna.');
INSERT INTO Pacchetto_viaggio (nome, proprietario_pacchetto, numerosità, fascia_prezzo, tipologia, data_inizio, data_fine, commento)
VALUES ('Viaggio a Rio de Janeiro', 'massimo_83', 10, 5000.0, 'avventura', '2023-06-15', '2023-06-22', 'Rio de Janeiro è una città vibrante che offre molte opportunità per vivere avventure all aria aperta, come surf e escursioni sulla montagna.');

/***************************************************************************************************************************************/
/*Acquisizone*/
/***************************************************************************************************************************************/
INSERT INTO Acquisizione (nome_pacchetto, proprietario_pacchetto, acquisitore)
VALUES
('Safari in Tanzania', 'claudia90', 'giovanni99'),
('Visita ai Musei di Parigi', 'federico333', 'maria123'),
('Settimana al mare in Calabria', 'Francesca6', 'lucasito'),
('Escursione alle isole greche', 'giovanni99', 'francesca456'),
('Vacanze in montagna', 'massimo_83', 'davide78'),
('Tour della Toscana', 'paolo_87', 'claudia90'),
('Viaggio a New York', 'valentina_80', 'alessio111'),
('Safari in Kenya', 'claudia90', 'caterina222'),
('Visita ai Giardini di Versailles', 'federico333', 'valentina_80'),
('Settimana al mare in Sardegna', 'Francesca6', 'gabriella444'),
('Escursione alle isole Baleari', 'giovanni99', 'Sara2'),
('Safari in Tanzania', 'claudia90', 'lucasito'),
('Visita ai Musei di Parigi', 'federico333', 'Anna4'),
('Settimana al mare in Calabria', 'Francesca6', 'Giovanni5'),
('Escursione alle isole greche', 'giovanni99', 'Francesca6'),
('Vacanze in montagna', 'massimo_83', 'Maurizio7'),
('Tour della Toscana', 'paolo_87', 'Chiara8'),
('Viaggio a New York', 'valentina_80', 'Alessandro1'),
('Safari in Kenya', 'claudia90', 'giuseppina_90'),
('Visita ai Giardini di Versailles', 'federico333', 'luciano_88'),
('Viaggio a Berlino', 'paolo_87', 'federico333'), 
('Escursione alle isole Baleari', 'giovanni99', 'alessio111'),
('Viaggio a Rio de Janeiro', 'massimo_83', 'paolo_87');

/***************************************************************************************************************************************/
/*Algoritmo*/
/***************************************************************************************************************************************/
INSERT INTO Algoritmo (pacchetto_consigliato, proprietario_pacchetto, ricevitore)
VALUES
('Safari in Kenya', 'claudia90', 'giovanni99'),
('Safari in Tanzania', 'claudia90', 'maria123'),
('Vacanze in Sardegna', 'claudia90', 'lucasito'),
('Visita ai Giardini di Versailles', 'federico333', 'francesca456'),
('Visita ai Musei di Parigi', 'federico333', 'davide78'),
('Settimana al mare in Calabria', 'Francesca6', 'claudia90'),
('Settimana al mare in Sardegna', 'Francesca6', 'alessio111'),
('Escursione alle isole Baleari', 'giovanni99', 'caterina222'),
('Escursione alle isole greche', 'giovanni99', 'federico333'),
('Vacanze in montagna', 'massimo_83', 'gabriella444'),
('Viaggio a Rio de Janeiro', 'massimo_83', 'Sara2'),
('Tour della Toscana', 'paolo_87', 'Luca3'),
('Viaggio a Berlino', 'paolo_87', 'Anna4'),
('Viaggio a New York', 'valentina_80', 'Giovanni5'),
('Tour della Toscana', 'paolo_87', 'Francesca6'),
('Vacanze in montagna', 'massimo_83', 'Maurizio7'),
('Viaggio a Rio de Janeiro', 'massimo_83', 'Chiara8'),
('Escursione alle isole Baleari', 'giovanni99', 'Alessandro1'),
('Safari in Kenya', 'claudia90', 'giuseppina_90'),
('Viaggio a Berlino', 'paolo_87', 'luciano_88'),
('Vacanze in montagna', 'massimo_83', 'Giovanni5'),
('Viaggio a Rio de Janeiro', 'massimo_83', 'alessio111'),
('Tour della Toscana', 'paolo_87', 'Giovanni5'),
('Viaggio a Berlino', 'paolo_87', 'Sara2'),
('Viaggio a New York', 'valentina_80', 'alessandro_81');

/***************************************************************************************************************************************/
/*Galleria*/
/***************************************************************************************************************************************/

INSERT INTO Galleria (nome_pacchetto, proprietario_pacchetto, creatore, foto, commento, nome)
VALUES
('Safari in Tanzania', 'claudia90', 'giovanni99', 'safari_foto1', 'Un viaggio incredibile, ho visto animali che non avevo mai visto prima', 'ciao12_safari_1'),
('Safari in Tanzania', 'claudia90', 'Anna4', 'safari_foto2', 'Un viaggio indimenticabile, la natura selvaggia è spettacolare', 'federico33_safari_2'),
('Visita ai Musei di Parigi', 'federico333', 'maria123', 'musei_parigi_foto1', 'La visita ai musei di Parigi è stata un esperienza unica', 'ciao12_musei_parigi_1'),
('Visita ai Musei di Parigi', 'federico333', 'rossella_82', 'musei_parigi_foto2', 'Ho scoperto molte opere d arte interessanti', 'giovanni99_musei_parigi_2'),
('Settimana al mare in Calabria', 'Francesca6', 'lucasito', 'calabria_foto1', 'Il mare della Calabria è stupendo', 'valentina_80_calabria_1'),
('Settimana al mare in Calabria', 'Francesca6', 'Giovanni5', 'calabria_foto2', 'Mi sono divertito moltissimo in questa settimana al mare', 'massimo_83_calabria_2'),
('Escursione alle isole greche', 'giovanni99', 'francesca456', 'isole_greche_foto1', 'Ho passato una settimana indimenticabile con i miei amici alle isole greche', 'ciao12_isole_greche_1'),
('Escursione alle isole greche', 'giovanni99', 'davide78', 'isole_greche_foto2', 'Ho scoperto paesaggi mozzafiato e la cultura greca', 'paolo_87_isole_greche_2'),
('Vacanze in montagna', 'massimo_83', 'Maurizio7', 'montagne_foto1', 'Ho trascorso una settimana indimenticabile in montagna con la mia famiglia', 'federico33_montagne_1'),
('Vacanze in montagna', 'massimo_83', 'rossella_82', 'montagne_foto2', 'La natura incontaminata e i paesaggi mozzafiato hanno reso questo viaggio indimenticabile', 'valentina_80_montagne_2');

/***************************************************************************************************************************************/
/*Recensione*/
/***************************************************************************************************************************************/

INSERT INTO Recensione (pacchetto_recensito, proprietario_pacchetto, recensitore, testo, punteggio, titolo)
VALUES ('Safari in Tanzania', 'claudia90', 'giovanni99', 'Ho trascorso 10 giorni indimenticabili in Tanzania! La fauna selvaggia che ho potuto osservare è stata fantastica. Consiglio questo pacchetto a chiunque voglia vivere un esperienza unica.', 4.5, 'Safari indimenticabile'),
('Visita ai Musei di Parigi', 'federico333', 'maria123', 'Ho trascorso 5 giorni immersa nella cultura francese, visitando i musei di Parigi. E stata una full immersion nell arte che consiglio a tutti.', 4.0, 'Full immersion nell arte francese'),
('Settimana al mare in Calabria', 'Francesca6', 'lucasito', 'Ho trascorso una settimana di relax al mare in Calabria. Mare cristallino e posti incantevoli, consiglio questo pacchetto a chi cerca una pausa dallo stress quotidiano.', 4.5, 'Relax al mare'),
('Escursione alle isole greche', 'giovanni99', 'francesca456', 'Ho trascorso una settimana indimenticabile con il mio gruppo di amici alle isole greche. Spiagge incantevoli e notti divertenti, consiglio questo pacchetto a chi cerca un avventura con gli amici.', 4.7, 'Avventura indimenticabile con gli amici'),
('Vacanze in montagna', 'massimo_83', 'Maurizio7', 'Ho trascorso una settimana indimenticabile con la mia famiglia alle montagne invernali. Paesaggi mozzafiato e attività per tutti i gusti, consiglio questo pacchetto a chi cerca un esperienza in montagna con la famiglia.', 4.2, 'Vacanze in montagna per la famiglia'),
('Tour della Toscana', 'paolo_87', 'Chiara8', 'Ho trascorso 5 giorni alla scoperta della cultura toscana. Paesaggi incantevoli e città ricche di storia, consiglio questo pacchetto a chi cerca un viaggio culturale.', 4.5, 'Scoperta della cultura toscana');

/*********************************************************************************************************************************/
/*Classificazione*/
/***************************************************************************************************************************************/
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Safari in Tanzania', 'claudia90', 'avventura');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Visita ai Musei di Parigi', 'federico333', 'culturale');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Settimana al mare in Calabria', 'Francesca6', 'relax');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Escursione alle isole greche', 'giovanni99', 'per gruppo di amici');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Vacanze in montagna', 'massimo_83', 'per famiglie');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Tour della Toscana', 'paolo_87', 'culturale');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Viaggio a New York', 'valentina_80', 'avventura');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Safari in Kenya', 'claudia90', 'avventura');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Visita ai Giardini di Versailles', 'federico333', 'culturale');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Settimana al mare in Sardegna', 'Francesca6', 'relax');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Escursione alle isole Baleari', 'giovanni99', 'per gruppo di amici');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Viaggio a Berlino', 'paolo_87', 'culturale');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Vacanze in Sardegna', 'claudia90', 'relax');
INSERT INTO Classificazione (nome_pacchetto, proprietario_pacchetto, nome_genere)
VALUES ('Viaggio a Rio de Janeiro', 'massimo_83', 'per famiglie');

/**************************************************************************************************************************/
/*Città*/
/***************************************************************************************************************************************/
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (36.84, -1.29, 'Safari in Tanzania', 'Tanzania');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (48.86, 2.35, 'Paris', 'France');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (38.24, 16.30, 'Calabria', 'Italy');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (37.97, 23.72, 'Greek islands', 'Greece');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (47.23, 7.37, 'The Alps', 'Switzerland');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (43.47, 11.25, 'Tuscany', 'Italy');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (40.71, -74.01, 'New York', 'USA');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (36.82, -1.30, 'Safari in Kenya', 'Kenya');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (39.55, 2.65, 'Balearic islands', 'Spain');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (39.20, 9.12, 'Sardegna', 'Italy');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (-22.91, -43.19, 'Rio de Janeiro', 'Brazil');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (52.52, 13.41, 'Berlin', 'Germany');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (48.80, 2.12, 'Versailles', 'France');
INSERT INTO Città (longitudine, latitudine, nome, nazione)
VALUES (9.4027, 40.0617, 'Sardegna', 'Italy');

/***************************************************************************************************************************************/
/*Riferimento*/
/***************************************************************************************************************************************/
INSERT INTO Riferimento (nome_pacchetto, proprietario_pacchetto, latitudine_city, longitudine_city, ordine_visite)
VALUES
('Safari in Tanzania', 'claudia90', -1.29, 36.84, 1),
('Visita ai Musei di Parigi', 'federico333', 2.35,48.86, 1),
('Settimana al mare in Calabria', 'Francesca6', 16.30, 38.24, 1),
('Escursione alle isole greche', 'giovanni99', 23.72,37.97, 1),
('Vacanze in montagna', 'massimo_83',7.37,47.23, 1),
('Tour della Toscana', 'paolo_87', 11.25, 43.47, 1),
('Viaggio a New York', 'valentina_80',-74.01 ,40.71, 1),
('Safari in Kenya', 'claudia90', -1.30, 36.82, 1),
('Visita ai Giardini di Versailles', 'federico333',2.12,48.80 , 1),
('Settimana al mare in Sardegna', 'Francesca6', 40.06170, 9.4027, 1),
('Escursione alle isole Baleari', 'giovanni99',2.65,39.55, 1),
('Viaggio a Berlino', 'paolo_87',13.41,52.52, 1),
('Viaggio a Rio de Janeiro', 'massimo_83', -43.19, -22.91, 2),
('Vacanze in Sardegna', 'claudia90', 9.12, 39.20, 2);

/***************************************************************************************************************************************/
/*Evento*/
/***************************************************************************************************************************************/
INSERT INTO Evento (nome_evento, latitudine_city, longitudine_city, tipologia, data_evento)
VALUES ('Calabria Music Festival', 16.30, 38.24, 'Music', '2023-07-15');

INSERT INTO Evento (nome_evento, latitudine_city, longitudine_city, tipologia, data_evento)
VALUES ('New York Fashion Week', -74.01, 40.71, 'Fashion', '2023-09-15');

INSERT INTO Evento (nome_evento, latitudine_city, longitudine_city, tipologia, data_evento)
VALUES ('Rio de Janeiro Carnival', -43.19, -22.91, 'Carnival', '2023-02-25');

/***************************************************************************************************************************************/
/*Luoghi_visitati*/
/***************************************************************************************************************************************/
INSERT INTO Luoghi_visitati (civico, cap, via, nome, sito_web, genere, recensioni, orario_apertura, orario_chiusura, barriere_architettoniche,longitudine_city,latitudine_city)
VALUES (100, 12345, 'Rua das Flores', 'Copacabana Beach', 'www.riodejaneiro.com', 'Beach', 4.8, '10:00:00', '22:00:00', false, -22.91, -43.19),
(2, 12345, "Rua das praias", "Christ the Redeemer", "https://riodejaneiro.com/", "Monument", 4.7, "9:00:00", "17:00:00", FALSE, -22.91, -43.19),
(2, 30000, "Viale della Spiaggia", "Costa Smeralda", "https://sardegna.com/", "Island", 4.2, "9:00:00", "17:00:00", FALSE, 9.4027, 40.0617),
(200, 30000, 'Strada del Sole', 'La Maddalena Archipelago', 'www.sardegna.it', 'Island', 4.5, '09:00:00', '19:00:00', FALSE, 9.4027, 40.0617),
(3, 40000, "Viale dei Fiumi", "Mombasa", "https://MombasaCity.com/", "City", 4.9, "6:00:00", "18:00:00", FALSE, 36.82, -1.30),
(300, 40000, 'Maasai Mara National Reserve', 'Masai Mara National Reserve', 'www.kenyasafari.com', 'Safari', 5.0, '06:00:00', '18:00:00', false, 36.82, -1.30),
(500, 56789, 'Mykonos Island', 'Mykonos Island', 'www.greekislands.com', 'Island', 4.7, '08:00:00', '20:00:00', false, 37.97, 23.72),
(5, 56789, "Viale delle Isole", "Santorini", "https://greek-islands.com/", "Island", 4.5, "9:00:00", "17:00:00", TRUE, 37.97, 23.72),
(400, 45678, 'Serengeti National Park', 'Serengeti National Park', 'www.tanzaniasafari.com', 'Wildlife', 4.9, '06:00:00', '18:00:00', false, 36.84, -1.29),
(4, 45678, "Viale della Giungla", "Tarangire National Park", "https://tanzania-safari.com/", "Wildlife", 4.8, "6:00:00", "18:00:00", TRUE, 36.84, -1.29),
(7, 30000, "Viale della Sardegna", "Porto Cervo", "https://sardegna.com/", "Island", 4.2, "9:00:00", "17:00:00", FALSE, 9.4027, 40.0617),
(6, 70000, "Viale della Calabria", "Reggia di Calabria", "https://calabria.com/", "Region", 4.1, "9:00:00", "17:00:00", FALSE, 38.24, 16.30),
(8, 90000, "Viale delle Baleari", "Mallorca", "https://balearic-islands.com/", "Island", 4.6, "9:00:00", "17:00:00", TRUE, 39.55, 2.65),
(9, 10001, "Fifth Ave", "Statue of Liberty", "https://newyork.com/", "Monument", 4.9, "9:00:00", "17:00:00", FALSE, 40.71, -74.01),
(10, 10002, "Viale della Toscana", "Florence Cathedral", "https://tuscany.com/", "Cathedral", 4.4, "9:00:00", "17:00:00", FALSE, 43.47, 11.25),
(3, 75000, 'Champs-Elysées', 'Arc de Triomphe', 'https://arc-de-triomphe.paris/en', 'Historical Monument', 4.5, '10:00:00', '22:00:00', FALSE, 48.86, 2.35),
(13, 10787, 'Unter den Linden', 'Berlin Wall Memorial', 'https://www.berliner-mauer-gedenkstaette.de/en/', 'Memorial', 4.8, '09:00:00', '17:00:00', TRUE, 52.52, 13.41),
(75, 10001, 'Fifth Ave', 'Museum of Modern Art', 'https://www.moma.org/', 'Museum', 4.6, '10:00:00', '17:00:00', FALSE, 40.71, -74.01),
(19, 10001, 'Empire State Building', 'Empire State Building', 'https://www.esbnyc.com/', 'Observatory', 4.5, '08:00:00', '02:00:00', TRUE, 40.71, -74.01),
(19, 75000, 'Avenue des Gobelins', 'Musée national du Moyen Âge', 'https://www.musee-moyenage.fr/en/', 'Museum', 4.7, '10:00:00', '18:00:00', FALSE, 48.86, 2.35),
(200, 10787, 'Brandenburg Gate', 'Brandenburg Gate', 'brandenburggate.de', 'Tourist Attraction', 4.8, '8:00:00', '22:00:00', FALSE, 52.52, 13.41),
(200, 10787, 'Platz der Republik', 'Reichstag Building', 'reichstag-berlin.de', 'Tourist Attraction', 4.6, '9:00:00', '18:00:00', TRUE, 52.52, 13.41),
(8, 10002, 'Piazza del Campo', 'Torre del Mangia', 'https://www.torredelmangia.it', 'Torre Storica', 4.7, '10:00:00', '18:00:00', TRUE, 43.47, 11.25),
(2, 10001, 'Central Park West', 'American Museum of Natural History', 'https://www.amnh.org', 'Museo', 4.6, '9:00:00', '20:00:00', TRUE, 40.71, -74.01);

/***************************************************************************************************************************************/
/*Luoghi_alloggio*/
/***************************************************************************************************************************************/
INSERT INTO Luoghi_alloggio (civico, cap, via, nome, sito_web, genere, recensioni, orario_apertura, orario_chiusura, longitudine_city,latitudine_city, dati_pagamento, importo)
VALUES 
(40, 30000 , 'Via dei mari', 'Villa dei mari', 'www.villadeimari.it', 'Villa', 4.2, '08:00:00', '21:00:00', 9.4027, 40.0617, '5678901234568890', 250.00),
(1, 10001, 'Broadway', 'Hilton New York', 'hilton.com', 'Hotel', 4.7, '09:00:00', '23:00:00', 40.71, -74.01, '3456789012844678', 200.00),
(2, 75000, 'Champs-Elysées', 'Hotel Paris Champs-Elysées', 'hotelparis.com', 'Hotel', 4.8, '08:00:00', '22:00:00', 48.86, 2.35, '4567890123456789', 250.00),
(4, 56789, 'Athens Street', 'Acropolis Hotel', 'acropolishotel.com', 'Hotel', 4.2, '09:00:00', '23:00:00', 37.97, 23.72, '5678901234567890', 400.00),
(5, 92000, 'Bern Street', 'Swiss Chalet Hotel', 'swisschalet.com', 'Hotel', 4.9, '09:00:00', '23:00:00', 47.23, 7.37, '2345678909234567', 500.00),
(45, 30000, 'Via dei girasoli', 'Villa dei girasoli', 'www.villadeigirasoli.com', 'Resort', 4.7, '09:00:00', '18:00:00',9.4027, 40.0617, '5678901234568890', 250.50),
(23, 30000, 'Via del mare', 'Albergo del mare', 'www.albergodelmare.com', 'Hotel', 4.5, '08:00:00', '19:00:00', 9.4027, 40.0617, '5678901234568890', 150.25),
(76, 92000, 'Via delle montagne', 'Chalet delle montagne', 'www.chaletdellemontagne.com', 'Chalet', 4.8, '09:00:00', '18:00:00', 47.23, 7.37, '2345678909234567', 500.75),
(98, 10002, 'Via delle colline', 'Villa delle colline', 'www.villadellcolline.com', 'Villa', 4.9, '08:00:00', '19:00:00', 43.47, 11.25, '2345678901234567', 300.50),
(123, 70000, 'Via dei fiori', 'Casa dei fiori', 'www.casadeifiori.com', 'Bed and Breakfast', 4.6, '09:00:00', '18:00:00',38.24, 16.30, '1234567890123406', 200.25),
(1, 40000, 'Ngong Road', 'Serena Hotel', 'www.serenahotels.com', 'Luxury Hotel', 4.5, '09:00:00', '22:00:00', 36.82, -1.30, '4567890123498789', 200.00),
(2, 40000, 'Langata Road', 'Fairmont The Norfolk Hotel', 'www.fairmont.com', 'Luxury Hotel', 4.0, '08:00:00', '23:00:00', 36.82, -1.30, '4567890123498789', 300.00),
(10, 45678, 'Tanzania Street', 'Tanzania Resorts', 'www.tanzaniaresorts.com', 'Resort', 4.9, '09:00:00', '18:00:00',36.84, -1.29, '1234567890123456', 200),
(20, 45678, 'Tanzania Road', 'Tanzania Lodges', 'www.tanzania-lodges.com', 'Lodge', 4.8, '08:00:00', '19:00:00', 36.84, -1.29, '1234567890123406', 150),
(100, 10787, 'Alexanderplatz', 'Hotel Berlin', 'www.hotelberlin.de', 'Hotel', 4.5, '08:00:00', '23:00:00', 52.52, 13.41, '3456789012345678', 100.00),
(200, 10787, 'Unter den Linden', 'Berlin Hostel', 'www.berlinhostel.de', 'Hostel', 3.5, '07:00:00', '22:00:00', 52.52, 13.41, '3456789012345678', 50.00),
(32,  12345, 'Rua da Lapa', 'Casa da Lapa', 'www.casadalapa.com', 'Guest House', 4.7, '08:00:00', '22:00:00', -22.91, -43.19, '7890123456789012', 85.50),
(12,  12345, 'Rua das Flores', 'Casa das Flores', 'www.casadasflores.com', 'Guest House', 4.3, '08:00:00', '21:00:00', -22.91, -43.19, '7890123456789012', 80.00),
(14, 20224, 'Rue du Trianon', 'Hotel du Trianon', 'https://hoteldutrianon.com', 'Hotel', 4.5, '09:00:00', '22:00:00', 48.80, 2.12, '8901234567890123', 150.00),
(23, 92000, 'Alpine Road', 'Alpine Chalet', 'www.alpinechalet.com', 'Lodge', 4.7, '09:00:00', '18:00:00', 47.23, 7.37, '2345678909234567', 200.00),
(13, 90000, 'Calle De La Luna', 'The Moon Hotel', 'www.themoonhotel.com', 'Hotel', 4.9, '09:00:00', '23:00:00', 39.55, 2.65, '3456789012844678', 200.00),
(24, 90000, 'Calle De Las Estrellas', 'The Star Hotel', 'www.thestarhotel.com', 'Hotel', 4.8, '08:00:00', '22:00:00', 39.55, 2.65, '3456789012844678', 180.00);

/***************************************************************************************************************************************/
/*Composizione*/
/***************************************************************************************************************************************/
INSERT INTO  Composizione (civico,cap,via,nome_pacchetto,proprietario_pacchetto)
VALUES 
(100, 12345, 'Rua das Flores', 'Viaggio a Rio de Janeiro', 'massimo_83'),
(2, 12345, "Rua das praias", 'Viaggio a Rio de Janeiro', 'massimo_83'),
(2, 30000, "Viale della Spiaggia", 'Settimana al mare in Sardegna', 'Francesca6'),
(200, 30000, 'Strada del Sole', 'Settimana al mare in Sardegna', 'Francesca6'),
(3, 40000, "Viale dei Fiumi", 'Safari in Kenya', 'claudia90'),
(300, 40000, 'Maasai Mara National Reserve', 'Safari in Kenya', 'claudia90'),
(500, 56789, 'Mykonos Island', 'Escursione alle isole greche', 'giovanni99'),
(5, 56789, "Viale delle Isole", 'Escursione alle isole greche', 'giovanni99'),
(400, 45678, 'Serengeti National Park','Safari in Tanzania', 'claudia90'),
(4, 45678, "Viale della Giungla", 'Safari in Tanzania', 'claudia90'),
(7, 30000, "Viale della Sardegna", 'Settimana al mare in Sardegna', 'Francesca6'),
(6, 70000, "Viale della Calabria",'Settimana al mare in Calabria', 'Francesca6'),
(8, 90000, "Viale delle Baleari", 'Escursione alle isole Baleari', 'giovanni99'),
(9, 10001, "Fifth Ave",'Viaggio a New York', 'valentina_80'),
(10, 10002, "Viale della Toscana", 'Tour della Toscana', 'paolo_87'),
(3, 75000, 'Champs-Elysées', 'Visita ai Musei di Parigi', 'federico333'),
(13, 10787, 'Unter den Linden', 'Viaggio a Berlino', 'paolo_87'),
(75, 10001, 'Fifth Ave', 'Viaggio a New York', 'valentina_80'),
(19, 10001, 'Empire State Building', 'Viaggio a New York', 'valentina_80'),
(19, 75000, 'Avenue des Gobelins', 'Visita ai Musei di Parigi', 'federico333'),
(200, 10787, 'Brandenburg Gate', 'Viaggio a Berlino', 'paolo_87'),
(200, 10787, 'Platz der Republik','Viaggio a Berlino', 'paolo_87'),
(8, 10002, 'Piazza del Campo','Tour della Toscana', 'paolo_87'),
(2, 10001, 'Central Park West','Viaggio a New York', 'valentina_80');

/***************************************************************************************************************************************/
/*Collocazione*/
/***************************************************************************************************************************************/
INSERT INTO Collocazione (civico,cap,via, nome_pacchetto, proprietario_pacchetto)
VALUES 
(40, 30000 , 'Via dei mari','Settimana al mare in Sardegna', 'Francesca6');
INSERT INTO Collocazione (civico,cap,via, nome_pacchetto, proprietario_pacchetto)
VALUES 
(45, 30000, 'Via dei girasoli','Settimana al mare in Sardegna', 'Francesca6');
INSERT INTO Collocazione (civico,cap,via, nome_pacchetto, proprietario_pacchetto)
VALUES 
(23, 30000, 'Via del mare', 'Settimana al mare in Sardegna', 'Francesca6');
INSERT INTO Collocazione (civico,cap,via, nome_pacchetto, proprietario_pacchetto)
VALUES 
(1, 10001, 'Broadway', 'Viaggio a New York', 'valentina_80');
INSERT INTO Collocazione (civico,cap,via, nome_pacchetto, proprietario_pacchetto)
VALUES 
(2, 75000, 'Champs-Elysées', 'Visita ai Musei di Parigi', 'federico333');
INSERT INTO Collocazione (civico,cap,via, nome_pacchetto, proprietario_pacchetto)
VALUES 
(4, 56789, 'Athens Street', 'Escursione alle isole greche', 'giovanni99');
INSERT INTO Collocazione (civico,cap,via, nome_pacchetto, proprietario_pacchetto)
VALUES 
(5, 92000, 'Bern Street', 'Vacanze in montagna', 'massimo_83'),
(76, 92000, 'Via delle montagne', 'Vacanze in montagna', 'massimo_83'),
(98, 10002, 'Via delle colline', 'Tour della Toscana', 'paolo_87'),
(123, 70000, 'Via dei fiori', 'Settimana al mare in Calabria', 'Francesca6'),
(1, 40000, 'Ngong Road', 'Safari in Kenya', 'claudia90'),
(2, 40000, 'Langata Road', 'Safari in Kenya', 'claudia90'),
(10, 45678, 'Tanzania Street', 'Safari in Tanzania', 'claudia90'),
(20, 45678, 'Tanzania Road', 'Safari in Tanzania', 'claudia90'),
(100, 10787, 'Alexanderplatz', 'Viaggio a Berlino', 'paolo_87'),
(200, 10787, 'Unter den Linden', 'Viaggio a Berlino', 'paolo_87'),
(32,  12345, 'Rua da Lapa', 'Viaggio a Rio de Janeiro', 'massimo_83'),
(12,  12345, 'Rua das Flores', 'Viaggio a Rio de Janeiro', 'massimo_83'),
(14, 20224, 'Rue du Trianon', 'Visita ai Giardini di Versailles', 'federico333'),
(23, 92000, 'Alpine Road', 'Vacanze in montagna', 'massimo_83'),
(13, 90000, 'Calle De La Luna', 'Escursione alle isole Baleari', 'giovanni99'),
(24, 90000, 'Calle De Las Estrellas', 'Escursione alle isole Baleari', 'giovanni99');




/*
SET foreign_key_checks = 0;
drop table Utente;
drop table Follow;
drop table Dispositivo;
drop table Metodo_pagamento;
drop table Abbonamento;
drop table Acquisto;
drop table Pacchetto_viaggio;
drop table Acquisizione;
drop table Algoritmo;
drop table Galleria;
drop table Recensione;
drop table Genere;
drop table Classificazione;
drop table Città;
drop table Riferimento;
drop table Evento;
drop table Luoghi_visitati;
drop table Luoghi_alloggio;
drop table Composizione;
drop table Collocazione;
SET foreign_key_checks = 1; */
