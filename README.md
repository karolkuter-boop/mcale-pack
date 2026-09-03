# NeoFFTV Waterpark Tycoon

Pełna paczka Packwiz dla odcinka „Minecraft, ale to Park wodny”.

- Minecraft 1.21.1
- NeoForge 21.1.248
- NeoFFTV 1.42.50-rc225
- Flashback 0.39.7
- Iris 1.8.14 beta 1
- Sodium 0.8.13 beta 2
- WorldEdit, UILib i Architectury
- BBS, Distant Horizons oraz narzędzia nagraniowe klienta

Paczka nie zawiera Veila, Sable, Create Aeronautics ani Simulated Coasters. NeoFFTV rysuje własne efekty przez publiczne API Minecrafta i NeoForge, bez przejmowania framebufferów używanych przez Iris, Flashback i Sodium.

Photon 1.3b jest domyślnie włączony. Paczka wyłącza wyłącznie `shader_curves` w BBS, ponieważ ta funkcja zamienia stałe shaderpacka na uniformy i uniemożliwia kompilację Photona w Iris; edytor, modele, nagrywanie i pozostałe funkcje BBS pozostają aktywne.

## Adres aktualizacji

```text
https://raw.githubusercontent.com/karolkuter-boop/mcale-pack/main/pack.toml
```

Instancja Prism uruchamia przed startem:

```text
"$INST_JAVA" -jar packwiz-installer-bootstrap.jar -g --side client https://raw.githubusercontent.com/karolkuter-boop/mcale-pack/main/pack.toml
```

Po zmianie zawartości należy uruchomić `packwiz refresh`, zweryfikować manifest oraz próbnie uruchomić klienta.
