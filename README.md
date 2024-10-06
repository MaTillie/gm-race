Racing script

=== Commandes ===

gmr_liste {} :
    Liste des circuits

gmr_prepare {{name = 'id', help = 'Numéro du circuit'}} :
    Prépare le circuit numéro id. 

gmr_start {{name = 'id', help = 'Numéro de circuit'},{name = 'tour', help = 'Nombre de tour'}} : 
    Commencer la course du circuit préalablement préparé.

gmr_stop {{name = 'id', help = 'Numéro de circuit'}} :
    Arrête la course en cour du cuircuit numéro id.

gmr_create {{name = 'nom', help = 'Nom du circuit'},{name = 'precision', help = 'Distance de validation des checkpoints'}} :
    Active le mode création de circuit. 
    Si le nom du circuit contient des espaces, il faut la mettre entre " ex: Mon super circuit => "Mon super circuit"
    Precision est la distance de validation des checkpoints, pour exemple avec une distance de 25 et un point mis au centre de la route, ça fait la largeur de la route de la place centrale sans les trotoires.

gmr_add {} :
    Ajoute un checkpoint, au circuit en cours de création, à l'emplacement où se situe le joueur.

gmr_remove {} :
    Retire le dernier checkpoint ajouté au circuit en cours de création.

gmr_cancel {} :
    Annule la création de circuit 

gmr_save {} :
    Sauvegarde le circuit qui est en cours de création

gmr_ranking {{name = 'id', help = 'Numéro du circuit'}} :
    Donne le classement de la dernière course effectuée sur le circuit de numéro id. Si la course avait plusieurs tour, ne donne que le résultat de la course entière.

gmr_rankingdet {{name = 'id', help = 'Numéro de circuit'}} :   
    Donne le classement des tours les plus rapides de la dernière course effectuée sur le circuit de numéro id.

gmr_rankinggene {{name = 'id', help = 'Numéro de circuit'}} :
    Donne le classement de toutes les courses effectuées sur le circuit de numéro id.

gmr_rankinggenedet {{name = 'id', help = 'Numéro de circuit'}} :
    Donne le classement des tours les plus rapides de toutes les courses effectuées sur le circuit de numéro id.

=== SQL ===
CREATE TABLE `gm_race_races` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`route` TINYINT(4) NULL DEFAULT '1',
	`precision` TINYINT(4) NULL DEFAULT '20',
	`repair` TINYINT(4) NULL DEFAULT '0',
	`label` TINYTEXT NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`checkpoint` MEDIUMTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	INDEX `id` (`id`) USING BTREE
)
COLLATE='utf8mb3_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=13
;


CREATE TABLE `gm_race_result` (
	`race` INT(11) NULL DEFAULT NULL,
	`tour` INT(11) NULL DEFAULT '999',
	`player` TEXT NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`min` INT(11) NULL DEFAULT NULL,
	`sec` INT(11) NULL DEFAULT NULL,
	`ms` INT(11) NULL DEFAULT NULL,
	`numRace` INT(11) NULL DEFAULT NULL
)
COLLATE='utf8mb3_general_ci'
ENGINE=InnoDB
;
