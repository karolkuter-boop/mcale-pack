# mcale-pack

Paczka modów dla serii **„Minecraft, ale …"** — Minecraft 1.21.1, Fabric loader 0.19.3.

To repo jest **jedynym źródłem prawdy o tym, co ma być w instancji i na serwerze**. Wersje modów
zmienia się tutaj, nie w instancji Prisma.

## Zawartość

| Mod | side | po co |
|---|---|---|
| `mcale` | both | mod serii: panel odcinków, presety, świat odcinka |
| Fabric API | both | wersja zgodna z tą, którą kompilowany jest mcale |
| Sodium | client | wydajność renderowania przy nagrywaniu |
| Flashback | client | nagrywanie i odtwarzanie ujęć |

Jar `mcale-<wersja>.jar` leży w repo jako **surowy plik**, nie metaplik `.pw.toml` — zmienia się
z każdym buildem, więc nie ma dla niego stabilnego URL-a z hashem. Reszta modów jedzie z Modrinth
przez `.pw.toml`.

## Praca z packiem

```bash
packwiz refresh                       # przelicz index po każdej zmianie w mods/
packwiz modrinth add sodium           # dołóż mod z Modrinth
packwiz update --all                  # sprawdź aktualizacje
```

Wgranie zawartości packa do instancji Prisma (z repo moda):

```bash
bash scripts/install-prism.sh
```

## Hosting

Pack jest **publiczny** i serwowany przez raw.githubusercontent — świadomie nie GitHub Pages
(buildy Jekyll bywały wolne i zawodne). Publiczność jest wymogiem technicznym: prywatne repo
zmuszałoby do wpisania tokenu w komendę uruchomienia instancji, co psuje instalację na każdej
innej maszynie.

```
https://raw.githubusercontent.com/karolkuter-boop/mcale-pack/main/pack.toml
```

Instancja PrismLauncher `mcale` ma to w `PreLaunchCommand`, więc synchronizuje się sama przy
każdym starcie gry.

> **Repo moda (`karolkuter-boop/mcale`) jest prywatne — ten pack jest publiczny.**
> Kod źródłowy nie jest ujawniony, ale skompilowany `mcale-<wersja>.jar` jest tu publicznie
> pobieralny. Tak działa każdy modpack; jar pozostaje objęty licencją ARR z repo moda.

**Kolejność ma znaczenie:** pack musi być wypchnięty **zanim** odpalisz grę. Installer przy starcie
przywraca stan zgodny ze zdalnym repo, więc niewypchnięty świeży jar zostałby po cichu nadpisany
poprzednim. `install-prism.sh` robi ten push automatycznie.
