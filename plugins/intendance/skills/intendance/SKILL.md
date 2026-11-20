---
name: intendance
description: Revue d'outillage obligatoire au démarrage d'un projet, d'une mission ou d'une session de travail, et à chaque tournant du projet. Inventorie les skills, plugins et connecteurs réellement disponibles, les croise avec la mission, propose ce qu'il faut activer, ajouter ou laisser de côté, et attend l'accord de l'humain avant tout. Utiliser systématiquement quand l'humain ouvre un projet, écrit ou relit un CLAUDE.md, demande « de quoi a-t-on besoin », « quels outils », « on a ce qu'il faut ? », change d'étape (recherche → construction → mise en ligne), ou quand un besoin apparaît qu'aucun outil chargé ne couvre. S'applique dans Claude Code, Cowork et l'app Claude. Oblige à réfléchir à l'outillage, jamais à tout utiliser.
---

# Intendance — réfléchir à l'outillage avant de travailler

## Pourquoi ce skill existe
Les outils ne s'activent pas tout seuls au bon moment. Un assistant voit la liste de ce qui est
installé, mais rien ne l'oblige à se demander, au début d'un projet, *lequel de ces outils cette
mission demande* ni *ce qui manque*. Résultat : on travaille avec ce qui est sous la main, on oublie
un connecteur déjà payé, ou on ajoute un dixième plugin alors que le troisième faisait l'affaire.
Et chaque outil chargé coûte du contexte à chaque tour : en avoir trop rend l'assistant plus bête,
pas plus capable.

Intendance impose un moment de réflexion, court, au bon endroit. Il ne décide rien : il propose, et
l'humain tranche. Il ne pousse pas à utiliser : il pousse à **choisir**.

## Quand il se déclenche
- À l'ouverture d'un projet ou d'une mission, avant la première action de fond.
- Quand l'humain écrit ou relit le fichier d'instructions du projet (CLAUDE.md ou équivalent).
- À chaque **tournant** : la recherche devient de la construction, la construction devient une mise
  en ligne, un sujet nouveau entre dans le projet.
- Quand un besoin apparaît que rien de chargé ne couvre (« il nous faudrait lire des PDF », « il
  faudrait des données de marché »).
- Sur demande : « intendance », « quels outils », « on a ce qu'il faut ? ».

Hors de ces moments, le skill se tait. Une revue d'outillage à chaque message serait du bruit.

## Ce qu'il fait, dans l'ordre
### 1. Inventaire de ce qui est réellement disponible
Lister ce que la session voit **maintenant**, pas ce qu'on croit installé :
- les skills (listing des skills disponibles dans le contexte),
- les connecteurs et serveurs MCP dont les outils sont chargés,
- les plugins actifs, quand l'environnement permet de les lister (dans l'app : outils de liste des
  plugins et connecteurs s'ils existent ; dans Claude Code : `/plugin` ou `claude plugin list`).

Écrire ce qui est **vu** et ce qui est **supposé**. Un connecteur dont les outils ne sont pas chargés
est à signaler comme « installé mais non chargé ici », pas comme disponible.

### 2. Lecture de la mission
Trois questions, en une ligne chacune :
- Que doit produire ce projet (fichiers, code, décisions, communications) ?
- Sur quelles données ou quels systèmes (dépôts, bases, mails, données publiques, documents) ?
- Quelles contraintes (sécurité, données personnelles, budget de jetons, validation humaine) ?

Si le CLAUDE.md du projet a une section **Outillage**, la lire d'abord : elle fait foi. S'il n'en a
pas, en proposer une à la fin (étape 5).

### 3. Croisement
Classer chaque outil disponible dans une de ces trois colonnes, avec une raison d'une ligne :
- **Requis** : la mission ne se fait pas sans (ex. le connecteur du dépôt pour un projet de code).
- **Utile à un moment** : pas maintenant, mais à un tournant prévisible (ex. l'audit de sécurité
  avant la mise en ligne). Dire lequel.
- **Hors sujet pour ce projet** : chargé, mais sans usage ici. Ne pas le désactiver soi-même ;
  signaler qu'il coûte du contexte et laisser l'humain décider.

Puis les **manques** : ce que la mission demande et que rien ne couvre. Pour chacun, dire où ça
existe (connecteur du répertoire, plugin connu, skill à écrire) et ce que ça implique (compte,
clé, coût, données qui sortent). Ne pas inventer un outil ; si on ne sait pas, écrire « à chercher ».

### 4. Proposition, puis attente
Présenter le résultat en un tableau court (voir format), terminer par **une question** : « on part
avec ça ? ». Ne rien activer, installer ni désactiver avant la réponse. Si l'humain n'est pas là,
travailler avec les outils « requis » déjà chargés et laisser la proposition en tête du travail.

### 5. Trace dans le projet
Quand l'humain a tranché, proposer d'écrire la section Outillage du CLAUDE.md du projet :

```markdown
## Outillage (revu le AAAA-MM-JJ)
Requis : <outil> — <pourquoi> ; <outil> — <pourquoi>
À un tournant : <outil> — <quand>
Règle : au premier message de chaque session, vérifier que les outils requis sont chargés, dire ce
qui manque, et proposer un ajout quand le projet change d'étape. Un nouvel outil = une question :
« pour quelle étape de ce projet ? ».
```

C'est cette section qui rend la réflexion durable : la session suivante la lira sans refaire
l'inventaire complet.

## Format de la revue
```
INTENDANCE — <projet>, <date>
Vu dans la session : N skills, N connecteurs chargés, N plugins (ou « non listable ici »)

| Outil | Colonne | Pourquoi / quand |
|---|---|---|
| … | Requis | … |
| … | À un tournant | … (étape) |
| … | Hors sujet ici | coûte du contexte, à vous de voir |

Manques : <besoin> → <où ça existe, ce que ça implique> / « à chercher »
Question : on part avec ça ?
```

Dix lignes suffisent pour la plupart des projets. Si le tableau dépasse vingt lignes, c'est que
trop d'outils sont chargés : le dire, c'est aussi le rôle du skill.

## Ce que le skill ne fait pas
- Il n'active, n'installe et ne désactive rien de lui-même. L'outillage d'un compte appartient à
  l'humain ; un assistant qui touche à la configuration sans accord perd la confiance.
- Il ne recommande pas d'utiliser un outil « parce qu'il est là ». La bonne liste est courte.
- Il ne refait pas la revue à chaque message. Une fois par projet, puis aux tournants.
- Il ne remplace pas les outils de diagnostic de l'environnement (dans Claude Code, `/skill-doctor`
  mesure le coût et l'usage des skills ; Intendance décide du *sens*, pas du *coût*).

## Exemple
Mission : « ouvrir le projet de refonte du site d'une petite société, Next.js sur Vercel, contenu à
récupérer de l'ancien site, mise en ligne dans trois semaines ».

```
INTENDANCE — Refonte site, 2026-11-18
Vu dans la session : 12 skills, 6 connecteurs chargés, plugins non listables ici

| Outil | Colonne | Pourquoi / quand |
|---|---|---|
| GitHub (connecteur) | Requis | le dépôt du site |
| Vercel (connecteur + skills) | Requis | hébergement, déploiements, variables |
| Exa (recherche) | Requis | relire l'ancien site et les concurrents |
| searchfit-seo | À un tournant | structure et balises, à l'étape maquette → pages |
| arriere-garde | À un tournant | avant la mise en ligne : secrets, en-têtes, formulaires |
| Canva | À un tournant | visuels, quand la charte est fixée |
| Supabase | Hors sujet ici | pas de base de données prévue ; coûte du contexte |
| Bigdata.com, Quiver | Hors sujet ici | données financières ; coûte du contexte |

Manques : analyse d'accessibilité → skill « design:accessibility-review » si installé, sinon à chercher
Question : on part avec ça ?
```
