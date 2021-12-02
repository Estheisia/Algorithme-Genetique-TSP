//--------------------Déclaration des paramètres de la simulation--------------------
//Défini le nombre de boucles à faire, où une boucle est la génération des villes, de la population et son évolution suivant son aptitude
int NOMBRE_DE_BOUCLES = 7;
//Défini le nombre de villes
int NOMBRE_DE_VILLES = 52;
//Défini la taille de la population, le nombre de solution "à évaluer" par génération
int NOMBRE_D_INDIVIDUS = 50;
//Défini la probabilité qu'une mutation survienne, comprendre une modification de l'individu, effectuée lors de la création d'une nouvelle génération
float TAUX_DE_MUTATION = 0.001;
//Défini le nombre maximum de générations, condition de fin de boucle
int MAXIMUM_NOMBRE_GENERATION = 300;
//Défini le nombre maximum de générations successives ayant la même valeur d'aptitude, condiiton de fin de boucle
int MAXIMUM_D_APTITUDE_IDENTIQUE = 3000;
//Défini l'aléatoire pour la réplicabilité
int GRAINE_ALEATOIRE = 3;
//Défini si on utilise l'élitisme qui est de conserver NOMBRE_ELITISME d'individus dans la génération suivante, sans aucun croisement ni aucune mutation
boolean UTILISATION_ELITISME = false;
//Défini le nombre d'individus concerné par l'élitisme, choisis comme les N meilleurs individus d'une génération
int NOMBRE_ELITISME = 2;

//Défini le nombre de meilleurs individus d'une génération à choisir pour croiser dans la N+1 génération, dans le MODE_CROISEMENT = 1
int NOMBRE_DE_MEILLEURS_PARENTS = 5;
/*
 * En 300 MAXIMUM_NOMBRE_GENERATION 80 NOMBRE_D_INDIVIDUS : MODE_MUTATION - MODE_CROISEMENT : Résultat sur berlin52.json (~7540 meilleur)
 * 1 - 1 : Nul à chier (16k) // 1 - 2 : Bof (13k) // 1 - 3 : Bof (13k) // 1 - 4 : OK (10k)
 * 2 - 1 : Rien (21k) // 2 - 2 : Bien (9k) // 2 - 3 : Cassé (25k) // 2 - 4 : OK (10k) (meilleur avec l'ancienne version de 4 -> double croisement)
 */
//Défini le type de mutation à effectuer : 1 -> Mutation aléatoire, comprendre échanger la valeur de deux emplacements de la solution d'un individu
//                                         2 -> Demi-mutation, comprendre couper un individu en deux, le début devient la fin et inversement
int MODE_MUTATION = 2;
//Défini le type de croisement à effectuer : 1 -> Pour toute la population de la génération actuellen croisement de l'individu avec un des NOMBRE_DE_MEILLEURS_PARENTS aléatoirement choisi
//                                           2 -> Eugénisme
//                                           3 -> Clonage, comprendre sans croisement avec mutation
//                                           4 -> CrossOver en gardant l'ordre au maximum
int MODE_CROISEMENT = 4;
//Défini si le croisement utilisé sera simple (true), un seul point, ou double (false), deux points
boolean CROISEMENT_SIMPLE = true;
//Défini le mode de calcul de l'aptitude : 1 -> aptitude = distance entre les villes
//                                         2 -> aptitude = 1/distance
//                                         3 -> ...distance standardisée?
//Ne fonctionne qu'avec mode = 1 pour le moment
int MODE_CALCUL_APTITUDE = 1;

//Défini si on utilise le jeu de données berlin52.json pour les villes ou si on génère manuellement, si true NOMBRE_DE_VILLES = 52 automatiquement
boolean BERLIN52 = false;
//Défini le type de génération manuelle, si BERLIN52 = false, sinon aucun effet : 1 -> coordonnées aléatoires
//                                                                                2 -> coordonnées circulaires
int MODE_DE_GENERATION = 1;

//--------------------Définition des variables globales--------------------
//Tableau contenant les listes représentant les individus de la génération actuelle, chaque listes représentent une solution possible : un chromosome
IntList[] tableauDesChromosomes;
//Tableau contenant les vecteurs représentant les villes, PVector(x, y, z), x et y les coordonnées spatiales et z l'indice de création utilisé comme référence dans les chromosomes
PVector[] tableauDesCoordonnees;
//Tableau qui pour chaque chromosome associe une valeur d'aptitude évaluant la qualité de la solution
float[] tableauDesAptitudes;
//Distance la plus courte, meilleure solution trouvée jusqu'à maintenant
float plusCourteDistance;
//Solution donnant la plusCourteDistance
IntList meilleureSolution;
//Distance la plus faible de la génération précédente, utilisé pour compter le nombre de génération ayant la même meilleure plusCourteDistance
float distanceGenPrecedente;
//Entier servant de compteur pour la condiiton de fin MAXIMUM_D_APTITUDE_IDENTIQUE
int memeAptitude;
//Entier servant de compteur pour la condition de fin MAXIMUM_NOMBRE_GENERATION
int niemeGen;
//Liste des valeurs successives de plusCourteDistance pour construire le graphique d'une boucle
IntList graph;
//JSON ayant les coordonnées des villes, fonctionne avec BERLIN52 = true
JSONArray json;

//Seule variable qui ne doit pas reset() à chaque boucle, conserve les valeurs de fin de boucle
FloatList resultats = new FloatList();

//--------------------Initialisation--------------------
//Initialisation du programme et de la fenêtre
void setup() {
  //Taille de la fenêtre
  size(1000, 800);
  //Chargement du JSON complet
  JSONObject jsonO = loadJSONObject("berlin52.json");
  //Récupération de la liste des coordonnées
  json = jsonO.getJSONArray("pc");
  //Pour définir le nombre d'image à afficher par seconde
  //frameRate(60);
  
  //Initialisation des variables globales
  miseAZero();
}

//Initialisation des variables
void miseAZero() {
  //Dès la première évaluation, prendra cette valeur, puis d'autres si plus faible
  plusCourteDistance = Float.POSITIVE_INFINITY;
  //Pas encore de génération précédente
  distanceGenPrecedente = 0;
  niemeGen = 0;
  memeAptitude = 0;
  graph = new IntList();
  //Chromosome de base pour la génération de la population
  IntList chromosome = new IntList();
  //Dans l'ordre : Population des individus, Villes, Score des individus
  tableauDesChromosomes = new IntList[NOMBRE_D_INDIVIDUS];
  tableauDesCoordonnees = new PVector[NOMBRE_DE_VILLES];
  tableauDesAptitudes = new float[NOMBRE_D_INDIVIDUS];
  
  //Fixe l'aléatoire de la génération des villes
  randomSeed(GRAINE_ALEATOIRE);
  
  //Création d'un vecteur ayant deux valeurs comprises dans la zone prévue de la fenêtre et l'indice de création
  PVector vecteurVille = new PVector();
  //Génération manuelle ou d'après un JSON
  int indice;
  if(!BERLIN52) {
    //Initialisation des villes
    for(indice=0; indice<NOMBRE_DE_VILLES; indice++) {
      //Suivant MODE_DE_GENERATION, aléatoire ou circulaire
      switch(MODE_DE_GENERATION) {
        case 1:
          vecteurVille.x = floor(random(2*width/3 - 50)+25);
          vecteurVille.y = height/2-floor(random(height/2 - 70)+25);
          vecteurVille.z = indice;
          break;
        case 2:
          vecteurVille.x = 2*width/6 + sin(radians(360*NOMBRE_DE_BOUCLES*indice/360)) * 190;
          vecteurVille.y = height/4 + cos(radians(360*NOMBRE_DE_BOUCLES*indice/360)) * 190;
          vecteurVille.z = indice;
          break;
     }
     //Affectation du vecteur dans le tableau des coordonnées des villes
     tableauDesCoordonnees[indice] = vecteurVille.copy();
     //Ajout de l'indice de la ville dans le chromosone de génération
     chromosome.append(indice);
    }
  }
  else {
    //Nécessaire car nombreux parcours suivant cette valeur -> modif ?
    NOMBRE_DE_VILLES = 52;
    //Parcours du JSON
    for(indice=0; indice<json.size();indice++) {
      //Récupération des object contenu dans le JSON
      JSONObject point = json.getJSONObject(indice);
      //Affectation des valeurs dans le vecteur
      /*
       * Dans le cas où on souhaite afficher proprement dans la fenêtre, la valeur de la distance réduit, pas encore de compensation mathématiques
       * v.x = 20+point.getInt("X")/3;
       * v.y = 420-point.getInt("Y")/3;
       * v.z = h;
       */
      vecteurVille.x = point.getInt("X");
      vecteurVille.y = point.getInt("Y");
      vecteurVille.z = indice;
      //Affectation du vecteur dans les variables nécessaires
      tableauDesCoordonnees[indice] = vecteurVille.copy();
      chromosome.append(indice);
    }
  }
    
  //Initialisation de la population de chromosomes
  for (indice=0; indice<NOMBRE_D_INDIVIDUS; indice++) {
    //Mélange aléatoire de la position des valeurs du chromosome
    chromosome.shuffle();
    //Ajout du chromosome dans la population
    tableauDesChromosomes[indice] = chromosome.copy();
  }
}

//--------------------Gestion affichage--------------------
//Boucle de dessin, tourne TANTQUE(! noLoop() )
void draw() {
 //Couleur du fond
 background(0);
 //Réalisation d'une génération
 run();
 //Test de fin de simulation
 if(resultats.size() == NOMBRE_DE_BOUCLES) {
   //Effacement de la fenêtre
   background(0);
   //Retour en haut de l'écran
   translate(0, -height / 2 + 50);
   //Tri des résultats par ordre croissant
   resultats.sort();
   //Affichage des résultats successifs
   for(int t=0; t<NOMBRE_DE_BOUCLES; t++) {
     text(resultats.get(t), 20, 30*t);
   }
   //Ici, fin de programme
   noLoop();
 }
}

//Calcul l'aptitude, génère une nouvelle population, affiche l'interface
void run() {
   //Calcul des scores des solutions des individus
   calculAptitude(MODE_CALCUL_APTITUDE);
   //Création d'un nouvelle génération suivant les scores
   creerNouvelleGeneration();
   
   //Paramètres des dessins
   stroke(255);
   strokeWeight(3);
   textSize(20);
   
   //Affichage des informations
   float w = 2*width/3 + 5;
   float h = 20;
   int decalageTexte = 25;
   fill(255,255,0);
   text("Run n° " + resultats.size() + " / " + NOMBRE_DE_BOUCLES,                         w, h);
   fill(200,100,0);
   text("Nombre de villes : " + NOMBRE_DE_VILLES,                                         w, h + decalageTexte);
   text("Population : " + NOMBRE_D_INDIVIDUS,                                             w, h + 2*decalageTexte);
   text("Taux de mutation : " + TAUX_DE_MUTATION,                                         w, h + 3*decalageTexte);
   text("N meilleurs parents : " + NOMBRE_DE_MEILLEURS_PARENTS,                           w, h + 4*decalageTexte);
   text("Graine aléatoire : " + GRAINE_ALEATOIRE,                                         w, h + 5*decalageTexte);
   text("Elitisme ? " + UTILISATION_ELITISME,                                             w, h + 6*decalageTexte);
   text("Croisement simple ? " + CROISEMENT_SIMPLE,                                       w, h + 7*decalageTexte);
   text("Mode croisement : " + MODE_CROISEMENT,                                           w, h + 8*decalageTexte);
   text("Nb choisi élitisme : " + NOMBRE_ELITISME,                                        w, h + 9*decalageTexte);
   text("Mode mutation : " + MODE_MUTATION,                                               w, h + 10*decalageTexte);
   fill(0,255,0);
   text("Génération même score : " + memeAptitude + " / " + MAXIMUM_D_APTITUDE_IDENTIQUE, w, h + 13*decalageTexte);
   fill(0,255,255);
   text("Génération num : " + niemeGen + " / " + MAXIMUM_NOMBRE_GENERATION,               w, h + 14*decalageTexte);
   fill(255,255,0);
   text("Distance : " + calculerLaDistance(tableauDesCoordonnees,meilleureSolution),      w, h + 15*decalageTexte);
   
   noFill();
   //Afficher la meilleure solution trouvée jusqu'à maintenant
   beginShape();
   //Parcours de la solution
   int n;
   for(int i=0; i<meilleureSolution.size(); i++) {
     //Récupération des valeurs, indices, des villes de la solution
     n=meilleureSolution.get(i);
     //Récupération des valeurs x et y des vecteurs des villes pour dessiner
     vertex(tableauDesCoordonnees[n].x,tableauDesCoordonnees[n].y);
     ellipse(tableauDesCoordonnees[n].x,tableauDesCoordonnees[n].y, 16,16);
     //Couleur, rose et affichage de l'indice des villes
     fill(255,0,150);
     text(floor(tableauDesCoordonnees[n].z),tableauDesCoordonnees[n].x+15,tableauDesCoordonnees[n].y+15);
     noFill();
   }
   endShape();
   //Affiche un individu de la génération, en plus fin, aléatoirement choisi
   strokeWeight(0.5);
   IntList individu = new IntList();
   //Choix aléatoire de la solution à afficher parmi la population 
   individu = tableauDesChromosomes[floor(random(tableauDesChromosomes.length))];
   beginShape();
   for(int i=0; i<individu.size(); i++) {
     n=individu.get(i);
     vertex(tableauDesCoordonnees[n].x,tableauDesCoordonnees[n].y);
     //text("Distance individu : " + calculerLaDistance(tableauDesCoordonnees,individu), w, h + 11*decalageTexte);
   }
   endShape();
   
   //Déplacement à la deuxième partie de la fenêtre
   translate(0, height / 2 + 50);
   //Affiche le graphique des valeurs de plusCourteDistance
   graph.append(floor(plusCourteDistance));
   stroke(255);
   rect(50, 0, 800, 250);
   stroke(255, 255, 0);
   strokeWeight(2);
   for(int i=0; i<graph.size(); i++) {
     point(55+(792*(i)/(MAXIMUM_NOMBRE_GENERATION)),
           205-( 200*(graph.get(i)-300) / (graph.max()-300))
           );
   }
   text(graph.max(), 5, 10);
   text("0", 25, 250);
   text("Gen : 0", 5, 270);
   text(MAXIMUM_NOMBRE_GENERATION, 850, 270);
   text("Valeurs de plusCourteDistance suivant la génération", 55, 300);
   
   //Arrête la recherche si on atteint MAXIMUM_NOMBRE_GENERATION
   fill(255,0,0);
   if(niemeGen == MAXIMUM_NOMBRE_GENERATION) {
     text("Nombre maximum de génération atteint.", 250, h - 50);
     resultats.append(plusCourteDistance);
     miseAZero();
   }
   //Arrête la recherche si l'aptitude reste identique pendant MAXIMUM_D_APTITUDE_IDENTIQUE
   if(floor(plusCourteDistance) == floor(distanceGenPrecedente)) memeAptitude++;
   else memeAptitude = 0;
   distanceGenPrecedente = plusCourteDistance;
   if(memeAptitude > MAXIMUM_D_APTITUDE_IDENTIQUE) {
     text("Nombre maximum de génération sans meilleure aptitude atteint.", 250, h - 50);
     resultats.append(plusCourteDistance);
     miseAZero();
   }
}
//--------------------Calcul de l'aptitude--------------------
void calculAptitude(int mode) {
  //Parcours de la population
  float distanceTestee;
  for(int i=0; i<tableauDesChromosomes.length ; i++) {
    //Calcul de la distance du trajet, de la première ville à la dernière
    distanceTestee = calculerLaDistance(tableauDesCoordonnees, tableauDesChromosomes[i]);
    //Si la distance qu'on observe est plus courte (meilleure solution a priori)
    if(distanceTestee < plusCourteDistance) {
      //Remplacement de la meilleure solution
      plusCourteDistance = distanceTestee;
      meilleureSolution = tableauDesChromosomes[i];
    }
    /*
     * Différentes fonctions de calcul de l'aptitude
     * 1 : distance
     * 2 : 1/distance + normalisé NON FONCTIONNEL
     * 3 : 
     */
    switch(mode){
    case 1:
      tableauDesAptitudes[i] = distanceTestee;
      break;
    /*
    case 2:
      tableauDesAptitudes[i] = 1/(distanceTestee+1);
      float total = 0;
      for (int g=0; g<tableauDesAptitudes.length; g++) {
        total += tableauDesAptitudes[g];
      }
      for (int h=0; h<tableauDesAptitudes.length; h++) {
        tableauDesAptitudes[h] = tableauDesAptitudes[h] / total;
      }
      break;
    case 3:
      break;
      */
    }
  }
}

//Calcul effectif de la distance d'une solution
float calculerLaDistance(PVector[] villes, IntList solution) {
 float distance = 0;
 //Parcours de la solution et caclul de la distance entre une ville et celle suivante
 for(int i=0; i<solution.size()-1; i++) {
   distance += dist(villes[solution.get(i)].x
                   ,villes[solution.get(i)].y
                   ,villes[solution.get(i+1)].x
                   ,villes[solution.get(i+1)].y
                   );
 }
 return distance;
}

//--------------------Création de la nouvelle génération--------------------
void creerNouvelleGeneration() {
  //Création du tableau de la nouvelle génération
  IntList[] nouvGen = new IntList[NOMBRE_D_INDIVIDUS];
  //Indice qui sert lorsque l'élitisme est utilisé pour permettre de commencer après les individus conservés
  int indiceDeDepart=0;
  //Si on utilise l'élitisme, les N NOMBRE_ELITISME sont affectés directement
  if(UTILISATION_ELITISME) {
    int i;
    for(i=0; i<NOMBRE_ELITISME; i++)
     nouvGen[i] = selectionnerMeilleurParent(NOMBRE_ELITISME)[i];
    indiceDeDepart = i;
  }
  
  /*
   * Détermine le MODE_CROISEMENT
   * 1: Croisement de chaque individus avec un des NOMBRE_DE_MEILLEURS_PARENTS
   * 2: Eugénisme
   * 3: Clonage
   * 4: CrossOver ordonné
   */
  switch(MODE_CROISEMENT) {
    case 1:
      croisementDeIAvecUnDesMeilleurs(nouvGen, indiceDeDepart);
      break;
    case 2:
      eugenisme(nouvGen);
      break;
    case 3:
      clonage(nouvGen);
      break;
    case 4:
      orderedCrossOver(nouvGen);
      break;
  }
  //Parcours de la population et affectation des nouveaux individus
  for(int i=0; i<tableauDesChromosomes.length; i++) {
    tableauDesChromosomes[i] = nouvGen[i].copy();
    //afficher(tableauDesChromosomes[i]);
  }
  //Incrémentation du compteur de génération
  niemeGen++;
}

//Pour chaque individu, le croise avec un des NOMBRE_DE_MEILLEURS_PARENTS
void croisementDeIAvecUnDesMeilleurs(IntList[] nouvGen, int depart) {
  boolean variation;
  int lequelDesNParents;
  IntList[] tableauDesNMeilleursParents;
  //Parcours de la génération actuelle
  for(int i=depart; i<tableauDesChromosomes.length; i++) {
    //Pour changer quel parent est le début de l'enfant et lequel est la fin lors du croisement
    variation = (floor(random(2))==1? true:false);
    //Parent A et B, l'un sera l'individu à l'indice et l'autre un aléatoirement choisi parmi les N meilleurs
    IntList parentA = new IntList();
    IntList parentB = new IntList();
    lequelDesNParents = floor(random(NOMBRE_DE_MEILLEURS_PARENTS));
    //Création du tableau des N meilleurs parents pour le choix
    tableauDesNMeilleursParents = selectionnerMeilleurParent(NOMBRE_DE_MEILLEURS_PARENTS);
    /*
     * Suivant l'aléatoire l'un ou l'autre
     * Les deux font la même chose, simple inversion des parents
     * Parent 1 = l'individu de l'indice
     * Parent 2 = l'individu choisi parmi les meilleurs de sa génération
     */
    if(variation) {
      parentA = tableauDesChromosomes[i];
      parentB = tableauDesNMeilleursParents[lequelDesNParents];
    }
    else {
      parentB = tableauDesChromosomes[i];
      parentA = tableauDesNMeilleursParents[lequelDesNParents];
    }
    //Création de l'enfant, croisement des parents
    IntList enfant;
    //Détermine si le croisement sera a un point ou deux
    if(CROISEMENT_SIMPLE) enfant = croisementSimple(parentA, parentB);
    else enfant = croisementDouble(parentA, parentB);
    //Affectation de l'enfant muté à la nouvelle génération suivant la mutation
    if(MODE_MUTATION==1) nouvGen[i] = mutation(enfant);
    else nouvGen[i] = demiMutation(enfant);
  }
}

//Selectionne les 4 meilleurs individus pour les croiser entre eux
void eugenisme(IntList[] nouvGen) {
  IntList[] tableauDesNMeilleursParents = selectionnerMeilleurParent(4);
  IntList parentA = new IntList();
  IntList parentB = new IntList();
  for(int i=0; i<tableauDesChromosomes.length; i++) {
    if(random(1) < 0.5) {
      parentA=tableauDesNMeilleursParents[0];
      parentB=tableauDesNMeilleursParents[3];
    }
    else {
      parentA=tableauDesNMeilleursParents[2];
      parentB=tableauDesNMeilleursParents[1];
    }
    IntList enfant;
    if(CROISEMENT_SIMPLE) enfant = croisementSimple(parentA, parentB);
    else enfant = croisementDouble(parentA, parentB);
    if(MODE_MUTATION==1) nouvGen[i] = mutation(enfant);
    else nouvGen[i] = demiMutation(enfant);
  }
}

//Selectionne les 2 meilleurs individus, 50% chacun de devenir un nouvel indivdu pour NOMBRE_D_INDIVIDUS itération, sans croisement
void clonage(IntList[] nouvGen) {
  IntList[] tableauDesNMeilleursParents = selectionnerMeilleurParent(2);
  IntList clone = new IntList();
  for(int i=0; i<tableauDesChromosomes.length; i++) {
    if(random(1) < 0.5) {
      clone=tableauDesNMeilleursParents[0];
    }/*
    else if(random(1) < 0.5) {
      o=tableauDesNMeilleursParents[3];
    }
    else if(random(1) < 0.75) {
      o=tableauDesNMeilleursParents[2];
    }*/
    else {
      clone=tableauDesNMeilleursParents[1];
    }
    if(MODE_MUTATION==1) nouvGen[i] = mutation(clone);
    else nouvGen[i] = demiMutation(clone);
  }
}

//Place deux points de croisement, e1 et e2, partie e1 -> e2 du parent A et e2 -> fin + 0 -> e1 du parent B, dans l'ordre d'apparition
void orderedCrossOver(IntList[] nouvGen) {
  IntList[] tableauDesNMeilleursParents = selectionnerMeilleurParent(2);
  IntList nouvelIndividu;
  for(int ss=0; ss<tableauDesChromosomes.length; ss++) {
    nouvelIndividu = new IntList();
    //IntList b = new IntList();
    int emplacementAléatoire1 = floor(random(tableauDesNMeilleursParents[0].size()-4))+2;
    int emplacementAléatoire2 = floor(random(tableauDesNMeilleursParents[0].size()-4))+2;
    int e1, e2;
    if(emplacementAléatoire1 >= emplacementAléatoire2) {
      e1 = emplacementAléatoire2;
      e2 = emplacementAléatoire1;
    }
    else {
      e1 = emplacementAléatoire1;
      e2 = emplacementAléatoire2;
    }
    IntList temp = new IntList();
    int i;
    for(i=e1;i<e2;i++) {
      temp.append(tableauDesNMeilleursParents[0].get(i));
    }
    for(i=e2;i<tableauDesNMeilleursParents[1].size();i++) {
      if(!temp.hasValue(tableauDesNMeilleursParents[1].get(i))) {
        temp.append(tableauDesNMeilleursParents[1].get(i));
      }
    }
    int compteur = temp.size();
    for(i=0;i<tableauDesNMeilleursParents[1].size() && compteur<tableauDesNMeilleursParents[1].size();i++){
      if(!temp.hasValue(tableauDesNMeilleursParents[1].get(i))) {
        temp.append(tableauDesNMeilleursParents[1].get(i));
      }
    }
    compteur=0;
    for(i=0;i<tableauDesNMeilleursParents[1].size() && compteur<e1;i++) {
      if(!temp.hasValue(tableauDesNMeilleursParents[1].get(i))) {
        nouvelIndividu.append(tableauDesNMeilleursParents[1].get(i));
        compteur++;
      }
    }
    for(i=0;i<temp.size();i++) {
      nouvelIndividu.append(temp.get(i));
    }
    //afficher(tableauDesNMeilleursParents);afficher(a);println(e1+" "+e2);delay(555);
    if(MODE_MUTATION==1) nouvGen[ss] = mutation(nouvelIndividu);
    else nouvGen[ss] = demiMutation(nouvelIndividu);
  }
}

//Selectionne les nombreMeilleursParents de la génération actuelle
IntList[] selectionnerMeilleurParent (int nombreMeilleursParents) {
  //Création du tableau des meilleurs parents
  IntList[] nMeilleurs = new IntList[nombreMeilleursParents];
  //Pour N boucles, parcours des aptitudes
  int p=0;
  while(p<nMeilleurs.length) {
    for(int i=0; i<tableauDesAptitudes.length && p<nMeilleurs.length; i++) {
      //Si la valeur indice est inférieur au minimum des aptitudes (meilleure solution)
      if(tableauDesAptitudes[i] <= min(tableauDesAptitudes)) {
        //Affectation de l'individu dans le tableau des meilleurs
        nMeilleurs[p] = tableauDesChromosomes[i].copy();
        //Remplacement de l'ancienne aptitude par l'infini (plus la valeur est petite mieux c'est)
        tableauDesAptitudes[i] = Float.POSITIVE_INFINITY;
        //Incrémentation de p, car un meilleur a été trouvé
        p++;
      }
    }
  }
  //afficher(nMeilleurs);
  return nMeilleurs;
}

//Renvoie le début d'une liste avec la fin de l'autre, séparées aléatoirement une fois
IntList croisementSimple(IntList a, IntList b) {
  //L'emplacement où couper les listes est choisi aléatoirement
  int emplacementDeCroisement = floor(random(a.size()+1));
  //Nouvelle liste croisée
  IntList croisee = new IntList();
  //Parcours de la liste a et affectation de ses valeurs dans croisee jusqu'à l'emplacement
  for(int i=0; i<emplacementDeCroisement; i++) {
    croisee.append(a.get(i));
  }
  //Parcours de la liste b depuis emplacementDeCroisement et affectation de ses valeurs SI elles ne sont pas déjà dans croisee
  for(int i=emplacementDeCroisement; i<b.size(); i++) {
    if(!croisee.hasValue(b.get(i))) {
      croisee.append(b.get(i));
    }
    else {
      for(int j=0; j<emplacementDeCroisement; j++) {
        if(!croisee.hasValue(b.get(j))) {
          croisee.append(b.get(j));
          j=emplacementDeCroisement;
        }
      }
    }
  }
  return croisee;
}

//Renvoie le début d'une liste avec la fin de l'autre, séparées aléatoirement deux fois
IntList croisementDouble(IntList a, IntList b) {
  //L'emplacement où couper les listes est choisi aléatoirement
  int emplacementAléatoire1 = floor(random(a.size()+1));
  int emplacementAléatoire2 = floor(random(a.size()+1));
  int e1, e2;
  if(emplacementAléatoire1 >= emplacementAléatoire2) {
    e1 = emplacementAléatoire2;
    e2 = emplacementAléatoire1;
  }
  else {
    e1 = emplacementAléatoire1;
    e2 = emplacementAléatoire2;
  }
  //Nouvelle liste croisée
  IntList croisee = new IntList();
  
  //Parcours de la liste a et affectation de ses valeurs dans croisee jusqu'à l'emplacement
  for(int i=0; i<e1; i++)
    croisee.append(a.get(i));
    
  //Parcours de la liste b depuis e1 jusqu'à e2 et affectation de ses valeurs SI elles ne sont pas déjà dans croisee
  for(int i=e1; i<e2; i++) {
    if(!croisee.hasValue(b.get(i))) {
      croisee.append(b.get(i));
    }
    else {
      for(int j=0; j<e1; j++) {
        if(!croisee.hasValue(b.get(j))) {
          croisee.append(b.get(j));
          j=e1;
        }
      }
    }
  }
  //Parcours du début à emplacementDeCroisement et affectation des valeurs SI elles ne sont pas déjà présentes
  for(int i=e2; i<a.size(); i++) {
    if(!croisee.hasValue(a.get(i))) {
      croisee.append(a.get(i));
    }
    else {
      for(int j=e1; j<e2; j++) {
        if(!croisee.hasValue(a.get(j))) {
          croisee.append(a.get(j));
          j=e2;
        }
      }
    }
  }
  return croisee;
}

//Suivant un taux défini, fait un échange des valeurs entre deux indices, un étant celui parcouru, l'autre aléatoire
IntList mutation(IntList enfantNormal) {
  //Copie de la liste
  IntList enfantMute = enfantNormal.copy();
  
  int j, temp;
  //Parcours des villes (les listes des chromosomes sont de même taille que celle des villes)
  for(int i=0; i<NOMBRE_DE_VILLES; i++) {
    //Si l'aléatoire est < au taux, échange de la valeur à l'indice avec une autre aléatoirement choisie
    if(random(1) < TAUX_DE_MUTATION) {
      j = floor(random(enfantMute.size()));
      temp = enfantMute.get(i);
      enfantMute.set(i, enfantMute.get(j));
      enfantMute.set(j, temp);
    }
  }
  return enfantMute;
}

//Suivant un taux défini, coupe en deux aléatoirement et échange le début et la fin
IntList demiMutation(IntList e) {
  IntList temp = new IntList();
  int j;
  if(true){//random(1) < TAUX_DE_MUTATION) {
    j = floor(random(e.size()));
    for(int y=j;y<NOMBRE_DE_VILLES;y++) {
      temp.append(e.get(y));
    }
    for(int y=0;y<j;y++) {
      temp.append(e.get(y));
    }
  }//afficher(e);afficher(temp);println(j);
  return temp;
}

//Affiche dans la console, la IntList {1, 2, 3, 2} -> 1232
void afficher(IntList list) {
  for(int t=0;t<list.size();t++){
    print(list.get(t) + " ");
 }println();
}

//Affiche dans la console, le tableau de IntList, {{1, 1}, {2, 1}} -> 11\n21
void afficher(IntList[] list) {
  for(int t=0;t<list.length;t++){
   afficher(list[t]);
 }println();
}

//////////////////////////////Calcul de selection/////////////////////////////////////////////////
//renvoie la proba d'être choisie comme parent
int calculerProbaParentParRang(int rang){
  return NOMBRE_D_INDIVIDUS/rang;
}

//renvoie
int calculerSommeTab (float[] tableauAptitude){
  int res=0;
  float somme=0;
  for( int i=0;i<tableauAptitude.length;i++) {
          somme += tableauAptitude[ i];
      }
      res=floor(somme);
  return res;
}
