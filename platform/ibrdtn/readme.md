
# Note
Pour des besoins de traitement de logs, deux lignes ont été modifiées dans le fichier `core/BundleCore.cpp`.
Ces modifications permettent d'ajouter au log le destinateur d'un message.

# Installation de ibrDNT
- Suivre les étapes décrites dans le fichier `guide_installation_ibrdtn` pour télécharge les outils necessaires
- remplacer le fichier `ibrdtn-for-lepton/ibrdtn-adapter/bin/util/ibrdtn_functions` par le fichier `ibrdtn-adapter/bin/util/ibrdtn_functions`
- Ensuite avant d'installer remplacer le fichier `ibrdtn-for-lepton/ibrdtn/deamon/src/core/BundleCore.cpp` par le fichier `ibrdtn/deamon/src/core/BundleCore.cpp`
- `cd ibrdtn-for-lepton/ibrdtn`
- `make`
- `make install`
