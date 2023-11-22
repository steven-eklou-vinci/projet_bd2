DROP SCHEMA IF EXISTS projet_bd CASCADE;
CREATE SCHEMA projet_bd;
CREATE TYPE projet_bd.etats_offre AS ENUM('non_validee', 'validee', 'attribuee', 'annulee');
CREATE type projet_bd.semestres AS ENUM('Q1','Q2');
CREATE type projet_bd.etats_candidatures AS ENUM ('en_attente', 'acceptee', 'refusee','annulee');

CREATE TABLE projet_bd.etudiants(
    id_etudiant SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL CHECK (email SIMILAR TO '_%@student.vinci.be'),
    semestre projet_bd.semestres NOT NULL,
    mdp VARCHAR (50) NOT NULL,
    nb_candidatures_en_attente INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE projet_bd.entreprises(
    id_entreprise CHAR(3) CHECK (id_entreprise SIMILAR TO '[A-Z]{3}')PRIMARY KEY,
    nom VARCHAR(50) NOT NULL ,
    adresse VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    mdp VARCHAR(50) NOT NULL
);

CREATE TABLE projet_bd.offres_de_stage (
    id_offre SERIAL PRIMARY KEY,
    code VARCHAR UNIQUE NOT NULL CHECK (code SIMILAR TO entreprise ||'[1-9]{1}[0-9]{0,}'),
    semestre projet_bd.semestres NOT NULL,
    etat projet_bd.etats_offre NOT NULL DEFAULT 'non_validee',
    description VARCHAR NOT NULL,
    entreprise CHAR(3) NOT NULL REFERENCES projet_bd.entreprises(id_entreprise),
    etudiant INTEGER UNIQUE NULL REFERENCES projet_bd.etudiants(id_etudiant) DEFAULT NULL
);

CREATE TABLE projet_bd.mots_cles(
    id_mot_cle SERIAL PRIMARY KEY,
    nom VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE projet_bd.mots_cles_de_stage(
  offre_stage INTEGER NOT NULL REFERENCES projet_bd.offres_de_stage(id_offre),
  mot_cle INTEGER NOT NULL REFERENCES projet_bd.mots_cles(id_mot_cle),
  PRIMARY KEY (offre_stage, mot_cle)
);

CREATE TABLE projet_bd.candidatures(

    PRIMARY KEY (etudiant,offre_stage),
    etudiant INTEGER REFERENCES projet_bd.etudiants (id_etudiant) NOT NULL ,
    offre_stage INTEGER REFERENCES projet_bd.offres_de_stage (id_offre) NOT NULL,
    motivation VARCHAR(250) NOT NULL ,
    etat projet_bd.etats_candidatures NOT NULL DEFAULT 'en_attente'
);

--application professeur 1.
CREATE FUNCTION projet_bd.encoder_etudiant(nNom VARCHAR, nPrenom VARCHAR, nMail VARCHAR, nSemestre projet_bd.semestres, nMdp VARCHAR) RETURNS INTEGER AS $$
    DECLARE
        id INTEGER;
    BEGIN
        INSERT INTO projet_bd.etudiants(id_etudiant, nom, prenom, email, semestre, mdp) VALUES (DEFAULT, nNom, nPrenom, nMail, nSemestre,nMdp)
        RETURNING id_etudiant INTO id;
        RETURN id;
    END
    $$ LANGUAGE plpgsql
;
--insert application professeur 1.
SELECT * FROM projet_bd.encoder_etudiant('Dupont', 'Jean', 'jean.dupont@student.vinci.be', 'Q1', 'MotDePasse123');
SELECT * FROM projet_bd.encoder_etudiant ('Martin', 'Marie', 'marie.martin@student.vinci.be', 'Q2', 'Securite456');
SELECT * FROM projet_bd.encoder_etudiant('Leclerc', 'Paul', 'paul.leclerc@student.vinci.be', 'Q1', 'Confidentiel789');
SELECT * FROM projet_bd.encoder_etudiant('Girard', 'Sophie', 'sophie.girard@student.vinci.be', 'Q2', 'Secret567');
SELECT * FROM projet_bd.encoder_etudiant('Lefevre', 'Luc', 'luc.lefevre@student.vinci.be', 'Q1', 'MotDePasseComplex1');

-- application professeur 2
CREATE FUNCTION projet_bd.encoder_entreprise(nvx_id_entreprise CHAR(3),nvx_nom VARCHAR(100), nvx_adresse VARCHAR(150), nvx_mdp VARCHAR(100),nvx_mail VARCHAR(150)) RETURNS CHAR(3) AS $$
    DECLARE
        id CHAR(3);
    BEGIN
        INSERT INTO projet_bd.entreprises(id_entreprise,nom, adresse, email, mdp) VALUES (nvx_id_entreprise,nvx_nom, nvx_adresse, nvx_mail,nvx_mdp) RETURNING id_entreprise INTO id;
        RETURN id;
    END
    $$ LANGUAGE plpgsql;

-- insertion application professeur 2
SELECT * FROM projet_bd.encoder_entreprise('TEC', 'Tech Solutions', '123 Rue de l''Industrie', 'contact@techsolutions.com', 'motdepasseABC');
SELECT * FROM projet_bd.encoder_entreprise('INV', 'Innovate Co.', '456 Avenue Technologique', 'contact@innovateco.com', 'motdepasseXYZ');
SELECT * FROM projet_bd.encoder_entreprise('FUT', 'Future Tech', '789 Boulevard Innovant', 'contact@futuretech.com', 'motdepasseDEF');
SELECT * FROM projet_bd.encoder_entreprise('GLB', 'Global Innovations', '101 Rue Futuriste', 'contact@globalinnovations.com', 'motdepasseGHI');
SELECT * FROM projet_bd.encoder_entreprise('ADV', 'Advancement Solutions', '202 Avenue Avancée', 'contact@advancementsolutions.com', 'motdepasseJKL');

-- application professeur 3
CREATE OR REPLACE FUNCTION projet_bd.encoder_mot_cle(nvNom VARCHAR) RETURNS INTEGER AS $$
    DECLARE
        id INTEGER;
    BEGIN
        INSERT INTO projet_bd.mots_cles (nom) VALUES (nvNom) RETURNING id_mot_cle INTO id;
        RETURN id;
    END
    $$ LANGUAGE plpgsql;

-- insertion application professeur 3
SELECT * FROM projet_bd.encoder_mot_cle('Java');
SELECT * FROM projet_bd.encoder_mot_cle('Web');
SELECT * FROM projet_bd.encoder_mot_cle('SQL');
SELECT * FROM projet_bd.encoder_mot_cle('Math');
SELECT * FROM projet_bd.encoder_mot_cle('Anglais');

-- application professeur 4
CREATE VIEW projet_bd.offre_stage_non_valide AS
    SELECT os.code, os.semestre, e.nom, os.description
    FROM projet_bd.offres_de_stage os, projet_bd.entreprises e
    WHERE os.entreprise = e.id_entreprise
    AND os.etat = 'non_validee';

-- appel vue application professeur 4
SELECT * FROM projet_bd.offre_stage_non_valide;

-- application professeur 5
CREATE OR REPLACE FUNCTION projet_bd.valider_offre_stage() RETURNS TRIGGER AS $$
    DECLARE
    BEGIN
        IF ('non_validee' != (SELECT os.etat FROM projet_bd.offres_de_stage os WHERE os.id_offre = NEW.id_offre)) THEN
            RAISE 'Cette offre de stage est dans un autre état que non validée';
        END IF;
        RETURN NEW;
    END

    $$ LANGUAGE plpgsql;

CREATE TRIGGER valider_offre_de_stage_trigger BEFORE UPDATE ON projet_bd.offres_de_stage FOR EACH ROW EXECUTE PROCEDURE projet_bd.valider_offre_stage();

CREATE FUNCTION projet_bd.valider_offre(id_offre_to_modify INTEGER) RETURNS INTEGER AS $$
    DECLARE
    BEGIN
        UPDATE projet_bd.offres_de_stage os
        SET etat = 'validee'
        WHERE os.id_offre = id_offre_to_modify;
        RETURN id_offre_to_modify;
    END
    $$ LANGUAGE plpgsql;

SELECT * FROM projet_bd.valider_offre(1);
-- SELECT * FROM projet_bd.valider_offre(1); -- sensé renvoyer une exception car etat déjà changé

--application professeur 6.
CREATE VIEW projet_bd.offre_stage_valide AS
    SELECT os.code, os.semestre, e.nom, os.description
    FROM projet_bd.offres_de_stage os, projet_bd.entreprises e
    WHERE os.entreprise = e.id_entreprise
    AND os.etat = 'validee';

SELECT * FROM projet_bd.offre_stage_valide;

--application professeur 7.
CREATE VIEW projet_bd.etudiant_pas_de_stage AS
    SELECT et.nom, et.prenom, et.email, et.nb_candidatures_en_attente
    FROM projet_bd.etudiants et, projet_bd.candidatures ca
    WHERE et.id_etudiant = ca.etudiant
        AND ca.etat !='acceptee';

SELECT * FROM projet_bd.etudiant_pas_de_stage;

--application professeur 8.
CREATE VIEW projet_bd.offres_stage_attribuees AS
    SELECT ods.code, en.nom AS nom_entreprise, et.nom AS nom_etudiant, et.prenom AS prenom_etudiant
    FROM projet_bd.offres_de_stage ods, projet_bd.entreprises en, projet_bd.etudiants et
    WHERE ods.etudiant = et.id_etudiant
      AND ods.entreprise = en.id_entreprise
      AND ods.etat = 'attribuee';

SELECT * FROM projet_bd.offres_stage_attribuees;

-- application entreprises 1
CREATE OR REPLACE FUNCTION projet_bd.encoder_offres_de_stage() RETURNS TRIGGER AS $$
    DECLARE
        total INTEGER;
    BEGIN
        SELECT COUNT(*) FROM projet_bd.offres_de_stage as os WHERE os.entreprise = NEW.entreprise INTO total;
        NEW.code := NEW.entreprise || (total+1);
        RETURN NEW;
    END
    $$ LANGUAGE plpgsql;

CREATE TRIGGER offres_de_stage_trigger BEFORE INSERT ON projet_bd.offres_de_stage FOR EACH ROW EXECUTE PROCEDURE projet_bd.encoder_offres_de_stage();

CREATE OR REPLACE FUNCTION projet_bd.encoder_offre(nvSemestre projet_bd.semestres, nvDescription VARCHAR, nvEntreprise CHAR(3)) RETURNS INTEGER AS $$
    DECLARE
        id INTEGER;
    BEGIN
        INSERT INTO projet_bd.offres_de_stage (code, semestre, description, entreprise) VALUES (null, nvSemestre, nvDescription, nvEntreprise) RETURNING id_offre INTO id;
        RETURN id;
    END
    $$ LANGUAGE plpgsql;

SELECT * FROM projet_bd.encoder_offre('Q1', 'exemple de description', 'TEC');

-- application entreprises 3
CREATE OR REPLACE FUNCTION projet_bd.attribuer_mot_cle() RETURNS TRIGGER AS $$
    DECLARE
        total INTEGER;
    BEGIN
        SELECT COUNT(*) FROM projet_bd.mots_cles_de_stage mcs WHERE mcs.offre_stage = NEW.offre_stage INTO total;
        IF (total = 3) THEN
            RAISE 'Il y a déjà 3 mots clés associés à cette offre de stage';
        END IF;
        RETURN NEW;
    END
$$ LANGUAGE plpgsql;

CREATE TRIGGER mots_cles_de_stage_trigger BEFORE INSERT ON projet_bd.mots_cles_de_stage FOR EACH ROW EXECUTE PROCEDURE projet_bd.attribuer_mot_cle();

-- INSERT INTO projet_bd.mots_cles_de_stage VALUES (1, 1);
-- INSERT INTO projet_bd.mots_cles_de_stage VALUES (1, 2);
-- INSERT INTO projet_bd.mots_cles_de_stage VALUES (1, 3);
-- INSERT INTO projet_bd.mots_cles_de_stage VALUES (1, 4); -- cette requête est sensé renvoyée l'erreur du trigger