# DressDiary

> Manager digital de garderobă pentru iOS: adaugă hainele tale, compune ținute și primește inspirație zilnică în funcție de sezon.

## Prezentare
DressDiary este o aplicație iOS construită în SwiftUI care îți organizează garderoba și îți propune ținute adaptate anotimpului curent. Persistența se face local, cu Core Data, iar logica de domeniu (gestionează utilizatori, articole, outfit-uri) este scrisă în C++ și expusă în Swift prin Objective-C++.

## Funcționalități
- creare cont, login și streak zilnic
- catalog de articole cu fotografie, materiale, culori, măsuri și categorii
- filtrare avansată (culoare, material, categorie)
- editor vizual pentru outfit-uri cu drag & drop și asociere sezon
- recomandare zilnică în funcție de sezon și ținutele salvate
- profil cu statistici personale și setări pentru temă light/dark/sistem
- persistarea imaginilor în Core Data și sincronizarea preferințelor prin AppStorage

## Detalii tehnice
- **Interfață:** SwiftUI 
- **Persistență:** Core Data (`DressDiary.xcdatamodeld`, `NSManagedObject`, fetch requests)
- **Logică domeniu:** C++ (`DataManager`, `ItemFactory`, `Utilities`)
- **Bridge:** Objective-C++ (`CppBridge`, `CoreAdapter`) pentru comunicarea Swift ↔ C++
- **Gestionare media:** stocare imagini ca `Binary Data` în Core Data și încărcare în SwiftUI
- **Preferințe:** `UserDefaults` și `ThemeManager`

## Integrare

- `DataManager` orchestrează utilizatori, articole și ținute în memorie.
- `CoreAdapter` traduce operațiile CRUD către Core Data.
- `CppBridge` expune API-ul C++ către Swift și gestionează conversiile de tip.
- `ThemeManager` și `AppStorage` sincronizează preferințele UI.

## Structură proiect
```
DressDiary/
├─ Views/         # Ecrane SwiftUI și componente UI
├─ Cpp/           # Modele, servicii și utilitare C++
├─ Wrappers/      # Bridge Objective-C++ (Swift <-> C++)
└─ Resources/     # Assets și modelul Core Data
```
Repere rapide:
- `HomeView.swift`, `ClosetView.swift`, `OutfitsView.swift`, `ProfileView.swift`, `SettingsView.swift` pentru tab-urile principale;
- `AddItemView.swift`, `AddOutfitView.swift` pentru fluxurile de creare;
- `FilterPageView.swift`, `FilteredClothesView.swift` pentru filtrare;
- `DataManager.cpp`, `ItemFactory.hpp`, `Outfit.hpp` pentru logica de domeniu;
- `CppBridge.mm`, `CoreAdapter.mm` pentru bridging.

## Persistență și date
Modelul `DressDiary.xcdatamodeld` include:
- **CDUser:** email, parolă, streak, ultima logare;
- **CDClothingItem:** metadate articol (categorie, materiale, culoare, măsuri, imagine);
- **CDOutfit:** nume, sezon, timestamp și legături către articolele asociate.

Sincronizarea se face prin conversii către structuri Swift (`ClothingItem`, `SavedOutfit`) astfel încât SwiftUI să observe modificări. Identificatorii din C++ se mapează pe `UUID` pentru a evita conflictele la salvare.

## Pornire rapidă
### Cerințe
- macOS cu Xcode 16+ și SDK iOS 18;
- simulator sau dispozitiv cu iOS 18.5 (deployment target `18.5`).

### Instalare
```bash
git clone https://github.com/antonia225/DressDiary.git
cd DressDiary
open DressDiary.xcodeproj
```
1. Selectează schema `DressDiary`.
2. Alege un simulator/dispozitiv iOS 18.5+.
3. Rulează cu `Cmd + R`.
4. Creează un cont nou din ecranul de Sign Up pentru a popula datele locale.

## Flux aplicație
1. **Autentificare:** Launch screen -> Login/Sign Up (creezi cont în câteva câmpuri).
2. **Home:** salut personalizat, sugestie de outfit pentru ziua respectivă.
3. **Closet:** listă filtrabilă de articole cu acces rapid la formularul de adăugare.
4. **Outfits:** grid cu ținutele salvate și editorul vizual pentru outfit-uri noi.
5. **Profile:** statistici personale și opțiune de logout.
6. **Settings:** control asupra temei aplicației și sincronizare cu sistemul.

## Obiective viitoare
- validare avansată pentru formulare (dimensiuni, extensii foto, mesaje dedicate)
- marcarea ținutelor favorite și opțiuni de partajare (PDF / social)
- sincronizare iCloud sau export/import de garderobă
- notificări push pentru menținerea streak-ului zilnic
- remove background pentru imagini
- îmbunătățirea afișării cardurilor pentru outfituri 

## Note 
- Bridging-ul Objective-C++ ↔ Swift (fișierele din `Wrappers/`) a fost realizat cu suport AI.
- O parte din componentele SwiftUI (de ex. `ImagePicker.swift`, rezolvarea erorilor `OutfitsView.swift`) au folosit sugestii AI.
- Toate contribuțiile generate au fost revizuite și testate manual înainte de integrare.
