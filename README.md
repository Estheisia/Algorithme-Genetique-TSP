# Algorithme-Genetique-TSP
Résolution du TSP avec un algorithme génétique et un affichage graphique sous Processing 4 - Java

Processing 4 est disponible à ce lien : https://processing.org/download

berlin52.json provient de données dont le meilleur résultat est connu : https://www.researchgate.net/publication/221901574_Hybridizing_PSM_and_RSM_Operator_for_Solving_NP-Complete_ProblemsApplication_to_Travelling_Salesman_Problem

Il y a un certain nombre de PARAMETRES :
- NOMBRE_DE_BOUCLES : Le nombre d'essais pour trouver N distances minimum.
- NOMBRE_DE_VILLES : Le nombre de villes, utilisé en génération aléatoire.
- NOMBRE_D_INDIVIDUS : Le nombre d'individus, où un individu = une solution.
- TAUX_DE_MUTATION : Chance d'effectuer une mutation (voir MODE_MUTATION).
- MAXIMUM_NOMBRE_GENERATION : Condition de fin d'une boucle, le nombre de générations
- MAXIMUM_D_APTITUDE_IDENTIQUE : Condition de fin, le nombre de générations sans amélioration de performance.
- GRAINE_ALEATOIRE : Fixe l'aléatoire pour la réplicabilité.
- UTILISATION_ELITISME : Booléen, l'élitisme est le fait de conserver les meilleurs individus en les clonant dans la génération suivante.
- NOMBRE_ELITISME : Le nombre d'individus concernés par l'élitisme.
- NOMBRE_DE_MEILLEURS_PARENTS : Le nombre de meilleurs individus d'une génération N pour créer la génération N+1.
- MODE_MUTATION : 1 = aléatoire, 2 = découpage en deux, le début = la fin et la fin = le début.
- MODE_CROISEMENT : 1 = chaque individus est croisé avec un des N meilleurs parent, 2 = eugénisme, 4 meilleurs croisés entre eux, 3 = clonage, sans croisement, 4 = croisement double en gardant l'ordre.
- CROISEMENT_SIMPLE : Booléen, croisement en un point ou en deux points.
- MODE_CALCUL_APTITUDE : Laisser 1, censé gérer plusieurs calcul de l'aptitude, aptitude = distance.
- BERLIN52 : Booléen, si vrai, les villes sont celles du JSON, les mettre à l'échelle de la fenêtre graphique change le résultat minimum.
- MODE_DE_GENERATION : Si BERLIN52 = false, 1 = aléatoire, 2 = génération des villes en forme de cercle.

Un exemple d'affichage :
![alt text](https://github.com/Estheisia/Algorithme-Genetique-TSP/blob/main/exemple_affichage.PNG)
