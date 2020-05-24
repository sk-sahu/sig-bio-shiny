# SigBio 0.3.0

* UI changed to the shiny dashboard.
* Shiny isolated modular approach adopted.
* files and functions further streamlined.

# SigBio 0.2.4

* Zenodo integration for DOI generate. 

# SigBio 0.2.3

* Few dependency version bump. As a result memory footprint decreased.

# SigBio 0.2.2

* No drastic changes in app behaviour but much of code improvement.
* Function names streamlined to be behave more like API naming for improve readability.
* More core functions taken out of shiny script(app.R) to the package(SigBio).

# SigBio 0.2.1

### Bugs Fixed
* Some minor bugs fixed ea03beebb2949954db4ac9b1aa06076c3fce14b3

# SigBio 0.2.0

### Features Added
* Now support 2000+ organisms using AnnotationHub interface #7
* Pathway view for enriched KEGG pathways added #17 
* Tables download option is added. It will zip all the tables and download in a single go.
* APIs were created on SigBio so that app.R can be used as a standalone.

### Bugs Fixed
* Library missing in few situations are fixed. All the libraries now loaded from the namespace of SigBio package #16 

# SigBio 0.1

* Basic interface added.
* Able to do GO and KEGG Enrichment, plus related plots.
* Supports 19 organism from Biocondutor OrgDb list.
