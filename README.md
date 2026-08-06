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

Docelowo raw.githubusercontent + `PreLaunchCommand` z `packwiz-installer-bootstrap`
w instancji Prisma — świadomie nie GitHub Pages (buildy Jekyll bywały wolne i zawodne).

**Do ustalenia przed wypchnięciem:** konto/organizacja GitHub i czy repo ma być publiczne.
Prywatne wymaga tokenu w komendzie uruchomienia instancji, co psuje instalację u kogokolwiek innego.
Do tego czasu pack działa lokalnie — `install-prism.sh` realizuje go bez hostingu.
