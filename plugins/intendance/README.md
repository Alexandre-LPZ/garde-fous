# Intendance — réfléchir à l'outillage avant de travailler

*Français ci-dessous · [English](#intendance--think-about-your-tooling-before-you-work)*

**Intendance** est un skill Claude qui oblige l'assistant, au démarrage d'un projet et à chaque
tournant, à faire une **revue d'outillage** : inventorier les skills, plugins et connecteurs
réellement chargés dans la session, les croiser avec la mission, proposer ce qu'il faut garder,
ajouter ou laisser de côté, et **attendre l'accord de l'humain**. Il n'active, n'installe et ne
désactive rien de lui-même.

Pourquoi : les outils ne s'activent pas tout seuls au bon moment. Un assistant voit la liste de ce
qui est installé, mais rien ne l'oblige à se demander *lequel de ces outils cette mission demande*
ni *ce qui manque*. Et chaque outil chargé coûte du contexte à chaque tour : en avoir trop rend
l'assistant plus bête, pas plus capable. Intendance impose un moment de réflexion, court, au bon
endroit. Il ne pousse pas à utiliser : il pousse à **choisir**.

## Ce que ça donne

```
INTENDANCE — Refonte site, 2026-11-18
Vu dans la session : 12 skills, 6 connecteurs chargés, plugins non listables ici

| Outil | Colonne | Pourquoi / quand |
|---|---|---|
| GitHub (connecteur) | Requis | le dépôt du site |
| Vercel (connecteur + skills) | Requis | hébergement, déploiements, variables |
| searchfit-seo | À un tournant | structure et balises, à l'étape maquette → pages |
| arriere-garde | À un tournant | avant la mise en ligne : secrets, en-têtes, formulaires |
| Supabase | Hors sujet ici | pas de base de données prévue ; coûte du contexte |

Manques : analyse d'accessibilité → skill « design:accessibility-review » si installé, sinon à chercher
Question : on part avec ça ?
```

Puis, quand l'humain a tranché, le skill propose d'écrire une section **Outillage** dans le
CLAUDE.md du projet, pour que la session suivante la lise sans refaire l'inventaire.

## L'installer ne suffit pas : les trois couches

Un skill installé est un skill *disponible*. Pour qu'il soit *obligatoire*, l'assistant doit avoir
reçu l'ordre de le lancer, et cet ordre doit être lu dans chaque interface. Trois couches, testées
dans Claude Code, Cowork et l'app Claude (18/11/2026) :

### Couche 1 — les instructions personnalisées du compte (app Claude et Cowork)
Dans les réglages du compte, section des instructions personnalisées (ce que Claude lit dans toutes
les conversations), ajouter une règle (celle-ci est la règle en service sur le compte de l'auteur) :

```
# INTENDANCE (OBLIGATOIRE)
Au premier message de tout projet ou session de travail, et à chaque changement
d'étape (recherche → construction → mise en ligne), lancer le skill « intendance » :
inventaire des skills et connecteurs réellement chargés, croisement avec la mission,
proposition, attente de mon accord. Ne rien activer ni désactiver sans mon accord.
Un nouvel outil = une question : « pour quelle étape ? »
```

### Couche 2 — le CLAUDE.md global de Claude Code
Fichier `~/.claude/CLAUDE.md` (Windows : `C:\Users\<vous>\.claude\CLAUDE.md`), lu au démarrage de
chaque session de chaque projet. Y ajouter ce bloc (celui de l'auteur, prénom à remplacer) :

```markdown
## INTENDANCE (obligatoire, tous projets)
Au premier message de toute session, et à chaque changement d'étape du projet
(recherche → construction → mise en ligne), lancer le skill « intendance » :
inventaire des skills et connecteurs réellement chargés, croisement avec la mission,
proposition en tableau, attente de l'accord de <votre prénom>. Ne rien activer ni désactiver
sans son accord. Un nouvel outil = une question : « pour quelle étape ? ».
Si le projet a une section « Outillage » dans son CLAUDE.md, elle fait foi ; sinon,
proposer de l'écrire après la première revue.
```

Sous Windows, créer le fichier s'il n'existe pas (PowerShell, fenêtre normale) :

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude" | Out-Null
Add-Content -Path "$HOME\.claude\CLAUDE.md" -Encoding utf8 -Value @"

## INTENDANCE (obligatoire, tous projets)
Au premier message de toute session, et a chaque changement d'etape du projet
(recherche -> construction -> mise en ligne), lancer le skill "intendance" :
inventaire des skills et connecteurs reellement charges, croisement avec la mission,
proposition en tableau, attente de l'accord de <votre prenom>. Ne rien activer ni desactiver
sans son accord. Un nouvel outil = une question : "pour quelle etape ?".
Si le projet a une section "Outillage" dans son CLAUDE.md, elle fait foi ; sinon,
proposer de l'ecrire apres la premiere revue.
"@
```
(Sans accents dans la commande : Windows PowerShell 5.1 écrit les accents de travers dans ce
fichier ; Claude les lit très bien sans.)

### Couche 3 — le skill lui-même
C'est ce plugin. Il porte la méthode (inventaire, lecture de la mission, croisement, proposition,
trace), le format du tableau, et ce que le skill ne fait pas.

Sans la couche 1, l'app et Cowork ont le skill mais ne le lancent pas d'eux-mêmes. Sans la couche 2,
Claude Code non plus. Sans la couche 3, les deux premières demandent quelque chose qui n'existe pas.

## Installation

**App Claude et Cowork** : Plug-ins → Ajouter un marketplace → `Alexandre-LPZ/garde-fous` →
installer **intendance**. Puis la couche 1 ci-dessus, et une nouvelle conversation.

**Claude Code** :
```
/plugin marketplace add Alexandre-LPZ/garde-fous
/plugin install intendance@garde-fous
/reload-plugins
```
Puis la couche 2 ci-dessus. Commande : `/intendance:intendance <mission>`.

## Ce que le skill ne fait pas
- Il n'active, n'installe et ne désactive rien de lui-même.
- Il ne recommande pas un outil « parce qu'il est là ». La bonne liste est courte.
- Il ne refait pas la revue à chaque message : une fois par projet, puis aux tournants.
- Il ne remplace pas les outils de diagnostic (`/skill-doctor` dans Claude Code mesure le coût ;
  Intendance décide du *sens*).

Construit avec Claude, par un utilisateur qui en avait assez de découvrir après coup qu'un
connecteur déjà installé aurait fait le travail.

---

# Intendance — think about your tooling before you work

**Intendance** (French for "quartermaster's office") is a Claude skill that forces the assistant,
at the start of a project and at every turning point, to run a **tooling review**: list the skills,
plugins and connectors actually loaded in the session, match them against the mission, propose
what to keep, add or leave aside, and **wait for the human's go**. It never enables, installs or
disables anything by itself.

Why: tools don't switch themselves on at the right moment. An assistant sees what is installed,
but nothing makes it ask *which of these tools this mission needs* or *what is missing*. And every
loaded tool costs context on every turn: too many make the assistant dumber, not more capable.
Intendance forces a short moment of reflection, at the right place. It doesn't push to use: it
pushes to **choose**.

## Output
A short table, one line of reasoning per tool, in three columns: **Required / At a turning point /
Off-topic here (costs context, your call)**, then the gaps (where the missing tool exists and what
it implies), and one question: "shall we go with this?". Once the human decides, the skill offers
to write a **Tooling** section in the project's CLAUDE.md so the next session reads it instead of
redoing the inventory.

## Installing is not enough: the three layers
An installed skill is *available*. To make it *mandatory*, the assistant must be told to run it,
in every interface:

1. **Account custom instructions** (Claude app and Cowork): a rule saying that at the start of any
   project, mission or session, and at every change of stage, the `intendance` skill runs before
   any substantive action, and nothing is enabled or disabled without the human's go.
2. **Global `~/.claude/CLAUDE.md`** (Claude Code): the same block, read at the start of every
   session of every project.
3. **The skill itself**: this plugin.

The French section above gives the exact text for layers 1 and 2.

## Install
App / Cowork: Plug-ins → Add marketplace → `Alexandre-LPZ/garde-fous` → install **intendance**,
then layer 1, then a new conversation. Claude Code: `/plugin marketplace add Alexandre-LPZ/garde-fous`,
`/plugin install intendance@garde-fous`, `/reload-plugins`, then layer 2. Command:
`/intendance:intendance <mission>`.

MIT. Built with Claude.
