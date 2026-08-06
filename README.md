# EstateWise per iOS e iPadOS

Client nativo offline-first del gestionale EstateWise, ottimizzato per il lavoro sul campo dei supervisor.

## Prima milestone

- interfaccia universale SwiftUI per iPad e iPhone;
- archivio locale SwiftData;
- dashboard supervisor;
- immobili disponibili offline;
- bozze di verbali e sopralluoghi;
- allegati fotografici conservati sul dispositivo;
- coda di sincronizzazione visibile all'utente.

## Requisiti

- Xcode 16 o successivo;
- iOS/iPadOS 17 o successivo.

Aprire `EstateWise.xcodeproj` e avviare lo scheme `EstateWise`.

`project.yml` permette di rigenerare il progetto con XcodeGen quando necessario.

## Configurazione API

L'endpoint del backend sarà configurabile per ambiente. La prima versione usa dati dimostrativi locali mentre viene definito il contratto di sincronizzazione con il backend esistente.

EstateWise native iOS and iPadOS app — offline-first property operations
