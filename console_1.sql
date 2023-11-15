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
    code VARCHAR UNIQUE NOT NULL,
    semestre projet_bd.semestres NOT NULL,
    etat projet_bd.etats_offre NOT NULL DEFAULT 'non_validee',
    description VARCHAR NOT NULL,
    entreprise CHAR(3) NOT NULL REFERENCES projet_bd.entreprises(id_entreprise),
    etudiant INTEGER UNIQUE NULL REFERENCES projet_bd.etudiants(id_etudiant)
);

CREATE TABLE projet_bd.mots_cles(
    id_mot_cle SERIAL PRIMARY KEY,
    nom VARCHAR(10) UNIQUE NOT NULL
);

CREATE TABLE projet_bd.mots_cles_de_stage(
  mot_cle INTEGER NOT NULL REFERENCES projet_bd.mots_cles(id_mot_cle),
  offre_stage INTEGER NOT NULL REFERENCES projet_bd.offres_de_stage(id_offre),
  PRIMARY KEY (mot_cle, offre_stage)
);

CREATE TABLE projet_bd.candidatures(

    PRIMARY KEY (etudiant,offres_stage),
    etudiant INTEGER REFERENCES projet_bd.etudiants (id_etudiant) NOT NULL ,
    offres_stage INTEGER REFERENCES projet_bd.offres_de_stage (id_offre) NOT NULL,
    motivation VARCHAR(250) NOT NULL ,
    etat projet_bd.etats_candidatures NOT NULL DEFAULT 'en_attente'
);

--- Ajout d'étudiants
INSERT INTO projet_bd.etudiants (nom, prenom, email, semestre, mdp, nb_candidatures_en_attente)
VALUES
  ('Dupont', 'Jean', 'jean.dupont@student.vinci.be', 'Q1', 'MotDePasse123', 0),
  ('Martin', 'Marie', 'marie.martin@student.vinci.be', 'Q2', 'Securite456', 0),
  ('Leclerc', 'Paul', 'paul.leclerc@student.vinci.be', 'Q1', 'Confidentiel789', 0),
  ('Girard', 'Sophie', 'sophie.girard@student.vinci.be', 'Q2', 'Secret567', 0),
  ('Lefevre', 'Luc', 'luc.lefevre@student.vinci.be', 'Q1', 'MotDePasseComplex1', 0);


--- Ajout de mots clés
INSERT INTO projet_bd.mots_cles (nom) VALUES ('Java');
INSERT INTO projet_bd.mots_cles (nom) VALUES ('Web');
INSERT INTO projet_bd.mots_cles (nom) VALUES ('SQL');
INSERT INTO projet_bd.mots_cles (nom) VALUES ('Math');
INSERT INTO projet_bd.mots_cles (nom) VALUES ('Anglais');

--- Ajout d'entreprises
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
VALUES ('TS1', 'Q1', 'non_validee', 'Stage en développement logiciel', 'TEC', NULL);

INSERT INTO projet_bd.offres_de_stage (code, semestre, etat, description, entreprise, etudiant)
VALUES ('IC1', 'Q2', 'non_validee', 'Stage en innovation technologique', 'INV', NULL);

INSERT INTO projet_bd.offres_de_stage (code, semestre, etat, description, entreprise, etudiant)
VALUES ('FT1', 'Q1', 'non_validee', 'Stage en technologies futures', 'FUT', NULL);

INSERT INTO projet_bd.offres_de_stage (code, semestre, etat, description, entreprise, etudiant)
VALUES ('GI1', 'Q2', 'non_validee', 'Stage en solutions globales', 'GLB', NULL);

INSERT INTO projet_bd.offres_de_stage (code, semestre, etat, description, entreprise, etudiant)
VALUES ('AS1', 'Q1', 'non_validee', 'Stage en avancement technologique', 'ADV', NULL);

--Ajout d'offre de stage
INSERT INTO projet_bd.mots_cles_de_stage (mot_cle, offre_stage)
VALUES (1, 1);

INSERT INTO projet_bd.mots_cles_de_stage (mot_cle, offre_stage)
VALUES (2, 2);

INSERT INTO projet_bd.mots_cles_de_stage (mot_cle, offre_stage)
VALUES (3, 3);

INSERT INTO projet_bd.mots_cles_de_stage (mot_cle, offre_stage)
VALUES (4, 4);

INSERT INTO projet_bd.mots_cles_de_stage (mot_cle, offre_stage)
VALUES (5, 5);
--tv'

