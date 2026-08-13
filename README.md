# mcale-pack

Publiczna paczka Packwiz dla odcinka **Minecraft, ale to Rollercoaster Tycoon**.

- Minecraft 1.21.1
- NeoForge 21.1.248
- NeoFFTV 1.42.49-rc42
- Create 6.0.10
- Create: Coasters Simulated 0.1.4
- Sable 2.0.3
- WorldEdit 7.3.8
- BBS, Flashback i narzędzia nagraniowe po stronie klienta

Packwiz pobiera 27 publicznych plików bezpośrednio z Modrinth. Cztery własne pliki FFTV są
przechowywane w tym repozytorium. `index.toml` i hash w `pack.toml` są generowane przez
`packwiz refresh`.

Paczka nie zawiera Yuushya, FancyMenu ani ich dodatkow. Zawiera BBS i Flashback
dla ekipy nagraniowej oraz wspolne waypointy Xaero dla `mcale.csrv.gg`.

## Adres aktualizacji

```text
https://raw.githubusercontent.com/karolkuter-boop/mcale-pack/main/pack.toml
```

Instancja Prism uruchamia przed startem:

```text
"$INST_JAVA" -jar packwiz-installer-bootstrap.jar -g --side client https://raw.githubusercontent.com/karolkuter-boop/mcale-pack/main/pack.toml
```

## Aktualizacja

Generator znajduje się w repo NeoFFTV:

```powershell
python tools/package/build-rollercoaster-packwiz.py `
  --source "$env:LOCALAPPDATA/Temp/neofftv-rollercoaster-pack-1.42.48/minecraft" `
  --target "C:/AI/worktrees/mcale-pack-rollercoaster" `
  --version 1.42.48 `
  --export "$env:USERPROFILE/Downloads/NeoFFTV-Rollercoaster-Tycoon-1.42.48/NeoFFTV-Rollercoaster-Tycoon-1.42.48-Packwiz.mrpack"
```

Po zmianie zawartości zawsze uruchom `packwiz refresh` i sprawdź eksport `.mrpack` przed
publikacją.
