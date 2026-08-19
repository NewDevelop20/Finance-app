# FinanceTracker — seguimiento de gastos diarios para iPhone

App SwiftUI + SwiftData para llevar el control de en qué te gastas el dinero cada día,
comparar contra un presupuesto semanal (lunes a domingo) y recibir un resumen cada
noche a las 23:00.

## Qué incluye

- **Alta rápida de movimientos**: importe, método (tarjeta / efectivo / bizum /
  transferencia), categoría (comestibles, restaurantes, ropa, alquiler, gasolina,
  transporte, coche, seguros, salud, ocio, suscripciones, hogar, educación, viajes,
  regalos, mascotas, otros) y tipo (gasto, ahorro, inversión, reembolso).
- **Reembolsos** (p. ej. un Bizum que te devuelven): se registran como tipo `reembolso`
  y restan del gasto neto del día/semana en vez de sumar.
- **Ahorro / inversión**: se registran y se ven en Estadísticas, pero no cuentan contra
  el presupuesto de gasto semanal (ese dinero no lo "gastas", lo apartas).
- **Home**: gasto de hoy, barra de progreso de la semana contra el presupuesto semanal,
  cuánto queda o cuánto te has pasado.
- **Historial**: agrupado por día, con filtros por tipo/método, edición y borrado.
- **Estadísticas**: gasto por categoría (gráfico de barras con Swift Charts) y totales
  de gasto/ahorro/inversión/reembolso por semana o mes.
- **Resumen automático a las 23:00**: notificación local con el gasto de hoy, el total
  de la semana (lunes-domingo) y si vas dentro o fuera de presupuesto, y cuánto te
  queda. Se recalcula cada vez que añades un movimiento y cada vez que abres la app.
- **Acceso rápido por gesto** (en vez de detección automática de pagos — ver más abajo):
  dos App Intents (`OpenQuickAddIntent`, `LogExpenseIntent`) pensados para colgar del
  botón de Acción, de un gesto Back Tap, de Siri o de la pantalla de bloqueo.

## Por qué no hay "detección automática" del pago con tarjeta

Apple no da a las apps de terceros ninguna API para enterarse de que acabas de pagar
con Apple Pay o con el NFC del banco — ni el evento en sí, ni el importe, ni el
comercio. Ninguna app de terceros en el App Store lo hace porque no se puede.

Lo que sí es 100% viable, y es lo que monta esta app, es reducir el "voy a apuntar el
gasto" a un solo gesto tuyo justo después de pagar:

- **Botón de Acción** (iPhone 15 Pro o superior).
- **Back Tap** (doble o triple toque en la parte trasera del iPhone).
- **Atajo de Siri** por voz.
- Todo dispara el mismo formulario (`AddExpenseSheet`) que ves al pulsar el "+" dentro
  de la app.

Ver la sección "Configurar el gesto rápido" más abajo.

---

## 1. Requisitos

- Un **Mac** con **Xcode 15 o superior** (Xcode es gratis, se instala desde la Mac App
  Store). No se puede compilar ni ejecutar esta app desde Linux/Windows.
- Un **Apple ID** normal para probar en el simulador y firmar la app en tu propio
  iPhone (gratis).
- Para publicar en la App Store de verdad: una cuenta de **Apple Developer Program**
  (99 €/año) — más detalles en la sección 4.
- Un iPhone físico con iOS 17+ si quieres probar Back Tap, botón de Acción o
  notificaciones exactamente como las verá el usuario final (el simulador no tiene
  Back Tap ni botón de Acción, y las notificaciones en simulador son limitadas).

## 2. Crear el proyecto en Xcode e importar el código

1. Abre Xcode → **File → New → Project**.
2. Elige **iOS → App** → Next.
3. Rellena:
   - Product Name: `FinanceTracker`
   - Team: tu Apple ID (Xcode → Settings → Accounts para añadirlo si no está)
   - Organization Identifier: algo tuyo, p. ej. `com.tunombre`
   - Interface: **SwiftUI**
   - Storage: **SwiftData**
   - Language: Swift
   - Desmarca "Include Tests" si no lo quieres de momento (puedes añadirlo luego).
4. Guarda el proyecto en una carpeta a tu elección.
5. Xcode te crea un `FinanceTrackerApp.swift` y un `ContentView.swift` de plantilla.
   **Bórralos** (Move to Trash) — los sustituimos por los de este repo.
6. En el Finder, arrastra dentro del navegador de proyecto de Xcode (panel izquierdo,
   dentro del grupo azul `FinanceTracker`) las carpetas de este repo:
   `App/`, `Models/`, `Services/`, `Intents/`, `Views/`.
   Al soltarlas, marca **"Copy items if needed"** y **"Create groups"**, con el target
   `FinanceTracker` marcado como destino.
7. Deployment target: selecciona el proyecto en el navegador → target `FinanceTracker`
   → pestaña **General** → **Minimum Deployments** → **iOS 17.0**.

## 3. Capacidades e Info.plist

### Background Modes (para que el resumen de las 23:00 se recalcule aunque no abras la app)

1. Target `FinanceTracker` → pestaña **Signing & Capabilities** → **+ Capability** →
   **Background Modes**.
2. Marca **Background fetch** (o "Background processing" según tu versión de Xcode;
   `BGAppRefreshTaskRequest` usa "Background fetch").

### Registrar el identificador de la tarea en segundo plano

En `Info.plist` (o en la pestaña **Info** del target) añade:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.financetracker.refreshSummary</string>
</array>
```

Si cambias el identificador en `BackgroundTaskManager.swift`, actualiza también este
valor para que coincida.

### Notificaciones

No hace falta ninguna entrada especial en Info.plist para notificaciones locales; la
app las pide en tiempo de ejecución (`NotificationManager.requestAuthorizationIfNeeded()`,
ya está llamado desde `FinanceTrackerApp.init()`). La primera vez que abras la app en
el dispositivo, acepta el permiso cuando te lo pida.

## 4. Ejecutar y probar

1. Conecta tu iPhone por cable o Wi-Fi, o usa un simulador.
2. Selecciona el destino (tu iPhone o un simulador) en la barra superior de Xcode.
3. Cmd+R para compilar y ejecutar.
4. La primera vez en un iPhone físico, ve a **Ajustes → General → VPN y gestión de
   dispositivos** y confía en tu certificado de desarrollador si Xcode te lo pide.
5. Prueba: añade un gasto, cierra la app, ábrela de nuevo y comprueba que la barra de
   la semana se actualiza. Cambia la hora del resumen en Ajustes a un par de minutos
   en el futuro para verificar que llega la notificación.

## 5. Configurar el gesto rápido (Atajos)

1. Con la app instalada, abre la app **Atajos** (Shortcuts) de Apple.
2. Pestaña **Galería/Automatización** no hace falta; vamos directos a un atajo nuevo:
   pestaña **Atajos** → **+** → busca la acción **"Añadir gasto rápido"** (aparece
   porque `OpenQuickAddIntent` está expuesto vía `AppShortcutsProvider`). Añádela y
   guarda el atajo, p. ej. con el nombre "Apuntar gasto".
3. **Botón de Acción** (iPhone 15 Pro/16/17 Pro): Ajustes → Botón de Acción → desliza
   hasta **Atajo** → elige "Apuntar gasto".
4. **Back Tap** (cualquier iPhone con Touch/Face ID moderno): Ajustes →
   Accesibilidad → Tocar la parte trasera → elige **Doble toque** o **Triple toque** →
   selecciona el atajo "Apuntar gasto".
5. **Siri**: simplemente di "Oye Siri, apuntar gasto" (o el nombre que le pusieras),
   o usa directamente la frase integrada: "Oye Siri, añade un gasto en FinanceTracker".
6. Para el atajo por voz con datos ("Oye Siri, registra un gasto de 12 euros en
   comestibles con tarjeta"), la acción expuesta es **"Registrar gasto por voz"**
   (`LogExpenseIntent`) — Siri te irá preguntando los parámetros que falten.

Con esto, justo después de pagar: pulsas el botón de Acción o el Back Tap, se abre
FinanceTracker directamente sobre el formulario, rellenas importe y categoría en un
par de toques, y listo.

## 6. Publicar en la App Store (la parte de aprender el proceso)

1. **Apple Developer Program**: entra en https://developer.apple.com/programs/ con tu
   Apple ID y date de alta (99 €/año, requiere verificación de identidad y puede tardar
   hasta 48h).
2. **Bundle Identifier definitivo**: decide uno único, p. ej. `com.tunombre.financetracker`,
   y ponlo en el target → **Signing & Capabilities** → Bundle Identifier.
3. **App Store Connect** (https://appstoreconnect.apple.com):
   - **Mis Apps → +  → Nueva App**.
   - Plataforma iOS, nombre visible en la tienda, idioma principal, Bundle ID (el
     mismo de arriba — Xcode lo registra automáticamente la primera vez que archivas
     o puedes crearlo a mano en developer.apple.com → Certificates, IDs & Profiles).
   - SKU: un identificador interno tuyo, p. ej. `financetracker001`.
4. **Ficha de la App Store**: descripción, capturas de pantalla (puedes generarlas
   desde el simulador con Cmd+S), icono de 1024×1024, categoría (Finanzas), y la
   **App Privacy** (nutrition label): como todos los datos se quedan en el dispositivo
   (SwiftData local, sin backend ni analíticas), declaras que **no se recopilan datos**.
5. **Archivar y subir el binario**:
   - En Xcode, selecciona destino **Any iOS Device (arm64)**.
   - **Product → Archive**.
   - En el Organizer que se abre, **Distribute App → App Store Connect → Upload**.
   - Xcode gestiona la firma automática si tienes "Automatically manage signing"
     activado en Signing & Capabilities (recomendado para empezar).
6. **TestFlight**: en App Store Connect, la build subida aparece primero en
   TestFlight. Puedes probarla tú mismo instalando la app TestFlight en tu iPhone e
   invitándote como tester interno — así pruebas exactamente el binario que vas a
   enviar a revisión, con notificaciones y Atajos reales.
7. **Enviar a revisión**: en la ficha de la app, sección **Preparar para envío**,
   asocia la build de TestFlight, rellena información de contacto y revisión, y pulsa
   **Enviar para revisión**. Apple suele tardar entre 24h y unos pocos días.
8. **Motivos típicos de rechazo** a vigilar en una app así: capturas de pantalla que no
   reflejan la app real, metadatos incompletos, y — importante para esta app — no
   afirmes en la descripción nada tipo "detecta automáticamente tus pagos con
   tarjeta", porque no es cierto y Apple lo puede rechazar por publicidad engañosa;
   describe el gesto rápido tal cual es.

## 7. Ideas para ampliar más adelante

- **Widget de bloqueo / Control Center** (target de extensión WidgetKit) para añadir un
  gasto con un toque sin ni siquiera abrir Atajos.
- **Sincronización con iCloud** activando CloudKit en el `ModelContainer` de SwiftData,
  para tener los gastos en varios dispositivos.
- **Exportar a CSV/Excel** desde Historial.
- **Face ID / código** para bloquear la app si tiene datos sensibles.
- **Notification Service Extension** para que el resumen de las 23:00 recalcule los
  totales en el instante de entregarse la notificación (más robusto que el
  recálculo actual, que depende de que la app se haya abierto o de que el sistema
  ejecute la tarea en segundo plano ese día).
