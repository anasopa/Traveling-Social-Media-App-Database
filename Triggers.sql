/*TRIGGERS*/

DELIMITER $$
CREATE TRIGGER data_fine_after_data_inizio
AFTER INSERT ON Pacchetto_viaggio
FOR EACH ROW
BEGIN
    IF NEW.data_inizio >= NEW.data_fine THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La data di fine deve essere successiva alla data di inizio';
    END IF;
END$$

DELIMITER $$
CREATE TRIGGER check_email_format
BEFORE INSERT ON Utente
FOR EACH ROW
BEGIN
  IF NEW.email NOT LIKE '%@%.%' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Il formato della mail non e\' corretto';
  END IF;
END$$


DELIMITER $$
CREATE TRIGGER utente_data_nascita_before_insert
BEFORE INSERT ON Utente
FOR EACH ROW
BEGIN
    IF NEW.data_nascita > NOW() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La data di nascita non può essere nel futuro';
    END IF;
END$$

/* Avvisa quando un pacchetto raggiunge oltre 1000 acquisizioni */
/*Questo trigger si attiva dopo ogni inserimento nella tabella Acquisizione e verifica il conteggio delle acquisizioni per l'utente che ha creato il pacchetto (proprietario_pacchetto)
e l'utente che ha effettuato l'acquisizione (acquisitore). Se il conteggio è 1000 o superiore mostra il messaggio "Il pacchetto (nome del pacchetto) ha raggiunto piu' di 1000 acquisizioni."*/
DELIMITER $$
CREATE TRIGGER trigger__acquisizioni
AFTER INSERT ON Acquisizione
FOR EACH ROW
BEGIN
    DECLARE num_acquisizioni INT;
    SELECT COUNT(*) INTO num_acquisizioni
    FROM Acquisizione
    WHERE proprietario_pacchetto = NEW.proprietario_pacchetto
    AND acquisitore = NEW.acquisitore AND nome_pacchetto=NEW.nome_pacchetto;
    IF num_acquisizioni >= 1000 THEN
         SET @message_text = CONCAT("Il pacchetto ", NEW.nome_pacchetto," ha raggiunto piu' di 1000 acquisizioni.");
         SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = @message_text;
    END IF;
END$$

/* Trigger per pacchetti con basse recensioni */
/*Questo trigger si attiva dopo che ogni nuova Recensione viene inserita nella tabella. Calcola la valutazione media del pacchetto recensito e del suo proprietario.
Se la valutazione media scende al di sotto di 2.0, indicando valutazioni costantemente basse mostra il messaggio */
DELIMITER $$
CREATE TRIGGER trigger_basse_recensioni
AFTER INSERT ON Recensione
FOR EACH ROW
BEGIN
  DECLARE avg_rating FLOAT;
  SET avg_rating = (SELECT AVG(punteggio) FROM Recensione WHERE pacchetto_recensito = NEW.pacchetto_recensito AND proprietario_pacchetto = NEW.proprietario_pacchetto);

  IF avg_rating < 2.0 THEN
		SET @message_text = CONCAT("Il pacchetto ", NEW.pacchetto_recensito," ha basse recensioni");
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = @message_text;
  END IF;
END$$

/* Aggiorna automaticamente la tabella Acquisto */
DELIMITER $$
CREATE TRIGGER aggiorna_acquisto_al_cambio_di_metodo_pagamento
AFTER UPDATE ON Metodo_pagamento
FOR EACH ROW
BEGIN
    UPDATE Acquisto SET n_carta = NEW.numero_carta WHERE n_carta = OLD.numero_carta;
    UPDATE Acquisto SET cvv = NEW.cvv WHERE n_carta = OLD.numero_carta;
    UPDATE Acquisto SET data_scadenza = NEW.data_scadenza WHERE n_carta = OLD.numero_carta;
    UPDATE Acquisto SET titolare = NEW.titolare WHERE n_carta = OLD.numero_carta;
END$$




