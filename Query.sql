/* OPERAZIONE 1 */
INSERT INTO Pacchetto_viaggio (nome, proprietario_pacchetto, numerosità, fascia_prezzo, tipologia, data_inizio, data_fine, commento) 
VALUES ('Dolomites', 'maria123', 4, 1000, 'Avventura', '2023-03-01', '2023-03-08', 'Exciting trip to the mountains');

/* OPERAZIONE 2 */
DELETE FROM Utente WHERE nickname = 'stefania_84';

/* OPERAZIONE 3 */
SELECT Recensione.proprietario_pacchetto AS "Proprietario Pacchetto", Recensione.pacchetto_recensito as "Pacchetto Viaggio", AVG(Recensione.punteggio) as Punteggio
FROM Recensione GROUP BY Recensione.pacchetto_recensito, Recensione.proprietario_pacchetto  ORDER BY Punteggio DESC
LIMIT 10;

/* OPERAZIONE 4 */
SELECT 
    Metodo_pagamento.nome_utente AS Utente,
    Luoghi_alloggio.importo AS Importo,
    Luoghi_alloggio.nome AS "Luogo Alloggio"
FROM
    Metodo_pagamento
        JOIN
    Luoghi_alloggio ON Metodo_pagamento.numero_carta = Luoghi_alloggio.dati_pagamento
WHERE
    Luoghi_alloggio.nome IN (SELECT 
            Luoghi_alloggio.nome
        FROM
            Luoghi_alloggio
                JOIN
            Città ON Città.latitudine = Luoghi_alloggio.latitudine_city
                AND Città.longitudine = Luoghi_alloggio.longitudine_city
        WHERE
            Città.nazione = 'Italy');
            
/* Versione alternativa - Totale pagato da ciascuno utente per i luoghi alloggio*/
SELECT 
    Metodo_pagamento.nome_utente AS Utente,
    SUM(Luoghi_alloggio.importo) AS "Totale Pagato" 
FROM
    Metodo_pagamento
        JOIN
    Luoghi_alloggio ON Metodo_pagamento.numero_carta = Luoghi_alloggio.dati_pagamento GROUP BY Metodo_pagamento.nome_utente;

/* OPERAZIONE 5 */
SELECT 
    Città.nome AS Città, Evento.nome_evento AS Evento, data_evento AS "Data Evento"
FROM
    Città
        JOIN
    Evento ON Evento.latitudine_city = Città.latitudine
        AND Evento.longitudine_city = Città.longitudine
WHERE
    Evento.tipologia LIKE '%Music%';

/* OPERAZIONE 6 */
SELECT DISTINCT
    Pacchetto_viaggio.nome AS "Pacchetto Viaggio",
    Acquisizione.proprietario_pacchetto AS "Proprietario Pacchetto"
FROM
    Pacchetto_viaggio
        LEFT JOIN
    Acquisizione ON Pacchetto_viaggio.nome = Acquisizione.nome_pacchetto
WHERE
    Pacchetto_viaggio.proprietario_pacchetto = 'claudia90'
        OR Acquisizione.acquisitore = 'claudia90';

/* OPERAZIONE 7 */
SELECT Città.nome AS "Nome Città", Luoghi_visitati.nome AS "Luogo più visitato", COUNT(*) AS "Numero di visite"
FROM Luoghi_visitati
JOIN Città ON Luoghi_visitati.latitudine_city = Città.latitudine AND Luoghi_visitati.longitudine_city = Città.longitudine
GROUP BY Città.nome, Luoghi_visitati.nome
ORDER BY Città.nome, "Numero di visite" DESC;

/*Metodo 2 - nazione come parametro*/
SELECT Città.nome AS "Nome Città", Luoghi_visitati.nome AS "Luogo più visitato", COUNT(*) AS "Numero di visite"
FROM Città
JOIN (
  SELECT nome, latitudine_city, longitudine_city
  FROM Luoghi_visitati
) AS Luoghi_visitati
ON Città.latitudine = Luoghi_visitati.latitudine_city AND Città.longitudine = Luoghi_visitati.longitudine_city
WHERE Città.nazione = 'Italy'
GROUP BY Città.nome, Luoghi_visitati.nome
ORDER BY Città.nome, "Numero di visite" DESC;
              
/* OPERAZIONE 8 */
SELECT c.nome_pacchetto AS "Nome Pacchetto", lv.nome AS "Luogo Visitato", CONCAT(lv.orario_apertura," -- ",lv.orario_chiusura) AS "Orario Apertura - Chiusura"
FROM Luoghi_visitati lv
INNER JOIN Composizione c ON lv.civico = c.civico AND lv.cap = c.cap AND lv.via = c.via
WHERE c.nome_pacchetto IN (SELECT c.nome_pacchetto FROM Composizione);

/* METODO 2 - usata in Python per poter usare il parametro*/
SELECT c.nome_pacchetto AS "Nome Pacchetto", lv.nome AS "Luogo Visitato", CONCAT(lv.orario_apertura," -- ",lv.orario_chiusura) AS "Orario Apertura - Chiusura"
FROM Luoghi_visitati lv
INNER JOIN Composizione c ON lv.civico = c.civico AND lv.cap = c.cap AND lv.via = c.via
WHERE c.nome_pacchetto = 'Viaggio a Rio de Janeiro';

/* OPERAZIONE 9 */
SELECT 
    Luoghi_visitati.nome AS 'Luogo Visitato',
    CONCAT(Luoghi_visitati.via,
            ', ',
            Luoghi_visitati.civico,
            ' , ',
            Luoghi_visitati.cap) AS Indirizzo
FROM
    Luoghi_visitati
        JOIN
    Città ON Luoghi_visitati.longitudine_city = Città.longitudine
        AND Luoghi_visitati.latitudine_city = Città.latitudine
WHERE
    Città.nazione = 'Italy'
        AND Luoghi_visitati.barriere_architettoniche = TRUE;

/* Operazione 10 */
SELECT Acquisizione.nome_pacchetto AS "Nome Pacchetto", Galleria.nome AS "Nome Galleria", Galleria.foto AS Foto, Galleria.commento AS Commento
FROM (
  SELECT nome_pacchetto, acquisitore
  FROM Acquisizione
  WHERE acquisitore = 'Anna4'
) AS Acquisizione
INNER JOIN Galleria USING (nome_pacchetto); /* poiche' le colonne hanno lo stesso nome */

/* Operazione 11 */
SELECT 
    Pacchetto_viaggio.nome AS 'Nome Pacchetto',
    Pacchetto_viaggio.proprietario_pacchetto AS 'Proprietario Pacchetto',
    COUNT(Acquisizione.acquisitore) AS 'Numero Acquisizioni'
FROM
    Pacchetto_viaggio
        JOIN
    Acquisizione ON Pacchetto_viaggio.nome = Acquisizione.nome_pacchetto
        AND Pacchetto_viaggio.proprietario_pacchetto = Acquisizione.proprietario_pacchetto
WHERE
    Pacchetto_viaggio.commento LIKE '%mare%'
GROUP BY Pacchetto_viaggio.nome , Pacchetto_viaggio.proprietario_pacchetto
ORDER BY COUNT(Acquisizione.acquisitore) DESC;

/* Operazione 12 */
SELECT p.nome AS "Pacchetto Viaggio Consigliato", p.proprietario_pacchetto AS "Proprietario Pacchetto", p.numerosità AS Numerosità, p.fascia_prezzo AS "Fascia Prezzo", p.tipologia AS Tipologia, CONCAT(p.data_inizio," -- ",p.data_fine) AS "Data Inizio - Fine"
FROM Pacchetto_viaggio p
INNER JOIN Algoritmo a ON p.nome = a.pacchetto_consigliato AND p.proprietario_pacchetto = a.proprietario_pacchetto
WHERE a.ricevitore = 'Giovanni5' AND NOT EXISTS (
  SELECT * FROM Acquisizione acq WHERE acq.nome_pacchetto = p.nome AND acq.acquisitore = p.proprietario_pacchetto
);

/* OPERAZIONE 13 */
SELECT utente, COUNT(Follow.utente_follower) AS "Numero Followers", AVG(TIMESTAMPDIFF(YEAR, Utente.data_nascita, NOW())) AS "Eta' media dei followers"
FROM Follow JOIN Utente ON Follow.utente_follower = Utente.nickname
GROUP BY utente
ORDER BY COUNT(Follow.utente_follower) DESC
LIMIT 10;

/* OPERAZIONE 14*/
SELECT 
    Pacchetto_viaggio.nome AS 'Pacchetto Viaggio',
    Pacchetto_viaggio.proprietario_pacchetto AS 'Proprietario Pacchetto',
    COUNT(Acquisizione.acquisitore) AS 'Numero Acquisizioni'
FROM
    Pacchetto_viaggio
        LEFT JOIN
    Acquisizione ON Pacchetto_viaggio.nome = Acquisizione.nome_pacchetto
        AND Pacchetto_viaggio.proprietario_pacchetto = Acquisizione.proprietario_pacchetto
GROUP BY Pacchetto_viaggio.nome , Pacchetto_viaggio.proprietario_pacchetto
HAVING COUNT(Acquisizione.acquisitore) < 2
ORDER BY COUNT(Acquisizione.acquisitore) DESC;

/* VIEWS */
/* Mostra la valutazione media di ogni pacchetto, insieme alla fascia di prezzo e al tipo*/
CREATE VIEW StatistichePacchetto AS
SELECT pac.nome AS pacchetto, pac.tipologia, pac.fascia_prezzo, AVG(r.punteggio) AS media_punteggio
FROM Pacchetto_viaggio pac
JOIN Recensione r ON pac.nome = r.pacchetto_recensito AND pac.proprietario_pacchetto = r.proprietario_pacchetto
GROUP BY pac.nome, pac.tipologia, pac.fascia_prezzo;

SELECT * FROM StatistichePacchetto;

/* Luoghi alloggio raggrupati per citta */
CREATE VIEW LuoghiAlloggioPerCitta AS
SELECT 
    c.nome AS NomeCitta,
    la.nome AS NomeAlloggio,
    CONCAT(la.civico, ', ', la.via, ', ', la.cap) AS Indirizzo,
    la.sito_web AS SitoWeb
FROM 
    Luoghi_alloggio la
    JOIN Città c ON la.longitudine_city = c.longitudine AND la.latitudine_city = c.latitudine
GROUP BY 
    c.nome, la.nome, la.civico, la.via, la.cap, la.sito_web;
    
SELECT * FROM LuoghiAlloggioPerCitta;