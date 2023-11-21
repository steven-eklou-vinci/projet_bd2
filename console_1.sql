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

INSERT INTO projet_bd.etudiants (nom, prenom, email, semestre, mdp, nb_candidatures_en_attente)
VALUES
  ('Dupont', 'Jean', 'jean.dupont@student.vinci.be', 'Q1', 'MotDePasse123', 0),
  ('Martin', 'Marie', 'marie.martin@student.vinci.be', 'Q2', 'Securite456', 0),
  ('Leclerc', 'Paul', 'paul.leclerc@student.vinci.be', 'Q1', 'Confidentiel789', 0),
  ('Girard', 'Sophie', 'sophie.girard@student.vinci.be', 'Q2', 'Secret567', 0),
  ('Lefevre', 'Luc', 'luc.lefevre@student.vinci.be', 'Q1', 'MotDePasseComplex1', 0);

INSERT INTO projet_bd.mots_cles (nom) VALUES ('Java');
INSERT INTO projet_bd.mots_cles (nom) VALUES ('Web');
INSERT INTO projet_bd.mots_cles (nom) VALUES ('SQL');
INSERT INTO projet_bd.mots_cles (nom) VALUES ('Math');
INSERT INTO projet_bd.mots_cles (nom) VALUES ('Anglais');

-- PAS OUBLIER DE MODIFIER LE CHAMP MOT DE PASSE DANS DSD
INSERT INTO projet_bd.entreprises (id_entreprise, nom, adresse, email, mdp)
VALUES ('TEC', 'Tech Solutions', '123 Rue de l''Industrie', 'contact@techsolutions.com', 'motdepasseABC');

INSERT INTO projet_bd.entreprises (id_entreprise, nom, adresse, email, mdp)
VALUES ('INV', 'Innovate Co.', '456 Avenue Technologique', 'contact@innovateco.com', 'motdepasseXYZ');

INSERT INTO projet_bd.entreprises (id_entreprise, nom, adresse, email, mdp)
VALUES ('FUT', 'Future Tech', '789 Boulevard Innovant', 'contact@futuretech.com', 'motdepasseDEF');

INSERT INTO projet_bd.entreprises (id_entreprise, nom, adresse, email, mdp)
VALUES ('GLB', 'Global Innovations', '101 Rue Futuriste', 'contact@globalinnovations.com', 'motdepasseGHI');

INSERT INTO projet_bd.entreprises (id_entreprise, nom, adresse, email, mdp)
VALUES ('ADV', 'Advancement Solutions', '202 Avenue Avancée', 'contact@advancementsolutions.com', 'motdepasseJKL');

INSERT INTO projet_bd.offres_de_stage (code, semestre, etat, description, entreprise, etudiant)
VALUES ('TEC1', 'Q1', 'non_validee', 'Stage en développement logiciel', 'TEC', NULL);

INSERT INTO projet_bd.offres_de_stage (code, semestre, etat, description, entreprise, etudiant)
VALUES ('INV1', 'Q2', 'non_validee', 'Stage en innovation technologique', 'INV', NULL);

INSERT INTO projet_bd.offres_de_stage (code, semestre, etat, description, entreprise, etudiant)
VALUES ('FUT1', 'Q1', 'non_validee', 'Stage en technologies futures', 'FUT', NULL);

INSERT INTO projet_bd.offres_de_stage (code, semestre, etat, description, entreprise, etudiant)
VALUES ('GLB1', 'Q2', 'non_validee', 'Stage en solutions globales', 'GLB', NULL);

INSERT INTO projet_bd.offres_de_stage (code, semestre, etat, description, entreprise, etudiant)
VALUES ('ADV1', 'Q1', 'non_validee', 'Stage en avancement technologique', 'ADV', NULL);

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

INSERT INTO projet_bd.mots_cles_de_stage VALUES (1, 1);
INSERT INTO projet_bd.mots_cles_de_stage VALUES (1, 2);
INSERT INTO projet_bd.mots_cles_de_stage VALUES (1, 3);
-- INSERT INTO projet_bd.mots_cles_de_stage VALUES (1, 4); -- cette requête est sensé renvoyée l'erreur du trigger

-- Voir les offres de stage dans l’état « non validée ». Pour chaque offre, on affichera son
-- code, son semestre, le nom de l’entreprise et sa description
CREATE VIEW projet_bd.offre_stage_non_valide AS
    SELECT os.code, os.semestre, e.nom, os.description
    FROM projet_bd.offres_de_stage os, projet_bd.entreprises e
    WHERE os.entreprise = e.id_entreprise
    AND os.etat = 'non_validee';

SELECT * FROM projet_bd.offre_stage_non_valide;

-- Valider une offre de stage en donnant son code. On ne pourra valider que des offres
-- de stages « non validée ».
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
SELECT * FROM projet_bd.valider_offre(1); -- sensé renvoyer une exception car etat déjà changé
