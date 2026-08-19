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
  App Intents (`OpenQuickAddIntent`, `OpenQuickAddCashIntent`, `LogExpenseIntent`)
  pensados para colgar del botón de Acción, de un gesto Back Tap o de Siri.
- **Widget de pantalla de bloqueo**: en tamaño circular y rectangular es un botón que
  abre el formulario de alta al instante (y el rectangular enseña el gasto de hoy); en
  tamaño inline enseña el gasto de hoy y, al tocarlo, abre el mismo formulario.

## Por qué no hay "detección automática" del pago con tarjeta

Apple no da a las apps de terceros ninguna API para enterarse de que acabas de pagar
con Apple Pay o con el NFC del banco — ni el evento en sí, ni el importe, ni el
comercio. Ninguna app de terceros en el App Store lo hace porque no se puede.

Lo que sí es 100% viable, y es lo que monta esta app, es reducir el "voy a apuntar el
gasto" a un solo gesto tuyo justo después de pagar: botón de Acción, Back Tap, Siri o
el widget de pantalla de bloqueo. Todo dispara el mismo formulario que ves al pulsar
el "+" dentro de la app. Ver la sección 5.

---

## 0. No tienes Mac (solo Android/Windows/Linux) — cómo se resuelve esto

Xcode solo existe para macOS: eso no lo cambia nada de lo que hagamos. Pero **no hace
falta que tú tengas un Mac** para compilar, firmar ni publicar esta app: cada vez que
subes cambios a GitHub, un workflow de **GitHub Actions** arranca un Mac real (gratis,
lo pone GitHub) y compila el proyecto ahí. Es exactamente lo que haría Xcode en tu
mesa, solo que en la nube y sin que lo veas.

Lo que **sí** necesitas de forma inevitable, porque lo exige Apple y no hay vuelta que
darle, es:

- Un **iPhone físico** para instalar y usar la app de verdad (esto no es negociable:
  ni tu Android ni un simulador en la nube sustituyen "sentir" la app en tu mano, y
  cosas como Back Tap, el botón de Acción o el widget de bloqueo solo existen en un
  iPhone real).
- Una cuenta de **Apple Developer Program** (99 €/año) en cuanto quieras instalar la
  app en ese iPhone — no solo para publicarla en la tienda. Apple no deja instalar una
  app nativa en un iPhone sin pasar por Xcode con un Mac físico delante (gratis, 7
  días, requiere el Mac) **o** por TestFlight con una cuenta de pago. Como no tienes
  Mac, el camino es TestFlight, y TestFlight exige la cuenta de pago. Es una limitación
  de Apple, no de esta configuración.

Todo lo demás — escribir código, generar el proyecto Xcode, compilarlo, archivarlo,
firmarlo y subirlo a TestFlight — lo hace GitHub Actions por ti. Sigue leyendo.

## 1. Requisitos

- Una cuenta de **GitHub** (gratis) — ya la tienes, es donde vive este repo.
- Un **Apple ID** normal (gratis) — el mismo con el que usas el iPhone sirve.
- Un **iPhone físico** con iOS 17 o superior.
- Cuando quieras instalarla en el iPhone o publicarla: **Apple Developer Program**
  (99 €/año) — ver sección 3.
- Nada de Mac, nada de Xcode instalado en ningún sitio tuyo.

## 2. Compilar automáticamente (gratis, sin cuenta de pago, sin Mac)

Este paso ya está listo para funcionar en cuanto haya código en el repo: no tienes que
tocar nada. El workflow `.github/workflows/ios-build.yml`:

1. Arranca un Mac de GitHub Actions (`macos-14`).
2. Instala **XcodeGen** y genera el proyecto Xcode real (`FinanceTracker.xcodeproj`) a
   partir de `project.yml` — un archivo de texto que describe los dos targets (la app y
   la extensión del widget), sus fuentes, capacidades e Info.plist. Es el equivalente a
   que alguien haga clic en Xcode montando el proyecto, pero como configuración
   versionada: si algo cambia de estructura, se edita `project.yml` en vez de dar clics.
3. Compila la app para el simulador de iOS, sin firmar (`CODE_SIGNING_ALLOWED=NO`), lo
   cual no necesita ninguna cuenta de Apple Developer.

**Cómo verlo funcionar:** en GitHub, pestaña **Actions** del repositorio → verás una
entrada por cada push, con ✅ o ❌. Si falla, abre el log: te dirá la línea exacta y el
error del compilador, igual que si lo vieras en Xcode. Puedes pegarme ese log y lo
arreglamos.

Esto te da, sin gastar nada ni pedir nada a Apple, la confirmación de que "el código
compila" — el problema que tenías con el README anterior.

## 3. Instalarla en tu iPhone vía TestFlight (necesita cuenta de pago)

1. **Alta en Apple Developer Program**: https://developer.apple.com/programs/ con tu
   Apple ID (99 €/año, verificación de identidad, puede tardar hasta 48h). Todo desde
   el navegador, no hace falta Mac.
2. **Apunta tu Team ID**: developer.apple.com → **Account → Membership details** →
   copia el **Team ID** (una cadena de 10 caracteres).
3. **Crea una clave de App Store Connect API** (esto es lo que deja que GitHub Actions
   firme y suba builds en tu nombre, sin que tú toques ningún Mac):
   - https://appstoreconnect.apple.com → **Users and Access → Integrations → App Store
     Connect API → +**.
   - Nombre: el que quieras. Acceso: **App Manager**.
   - Descarga el archivo `AuthKey_XXXXXXXXXX.p8` **una sola vez** (Apple no te deja
     descargarlo de nuevo después) y apunta el **Key ID** y el **Issuer ID** que se ven
     en esa pantalla.
4. **Configura 4 secretos en GitHub**: en el repo → **Settings → Secrets and variables
   → Actions → New repository secret**, crea:
   - `ASC_API_KEY_ID` → el Key ID del paso anterior.
   - `ASC_API_ISSUER_ID` → el Issuer ID.
   - `ASC_API_KEY_P8_BASE64` → el contenido del `.p8` en base64. En tu ordenador
     (Windows/Linux, no hace falta Mac):
     - Windows (PowerShell): `[Convert]::ToBase64String([IO.File]::ReadAllBytes("AuthKey_XXXXXXXXXX.p8")) | Set-Clipboard`
     - Linux/Android (Termux): `base64 -w0 AuthKey_XXXXXXXXXX.p8`
   - `APPLE_TEAM_ID` → el Team ID del paso 2.
5. **Registra la app en App Store Connect**: **Mis Apps → + → Nueva App** — plataforma
   iOS, nombre, idioma principal, Bundle ID `com.tunombre.financetracker` (créalo antes
   en developer.apple.com → **Identifiers → +** si Xcode no lo ha hecho ya por ti), SKU
   a tu gusto. Cambia `com.tunombre` por tu propio identificador en `project.yml`
   (busca `PRODUCT_BUNDLE_IDENTIFIER` y `application-groups`) antes de este paso.
6. **Lanza el workflow de subida**: pestaña **Actions** del repo →
   **"Archivar y subir a TestFlight"** → **Run workflow**. Este workflow
   (`.github/workflows/testflight.yml`) archiva la app, la exporta y la sube a
   TestFlight usando la clave API — el equivalente exacto a **Product → Archive →
   Distribute App** en Xcode, pero automático.
7. **Instálala en tu iPhone**: descarga la app **TestFlight** de la App Store (esta sí
   la puedes instalar tú mismo, es de Apple), entra con el mismo Apple ID, y en unos
   minutos aparecerá FinanceTracker lista para instalar y probar de verdad — Back Tap,
   botón de Acción, widget de bloqueo y notificación de las 23:00 incluidos.

Si algún paso de este workflow falla la primera vez (es habitual con la firma
automática de Apple: a veces hay que relanzarlo una segunda vez tras crear el primer
perfil/certificado), copia el error del log de Actions y lo resolvemos juntos.

## 4. Capacidades e Info.plist

`project.yml` ya deja configurado todo esto automáticamente al generar el proyecto —
no hay que tocar nada a mano en Xcode:

- **Background Modes → Background fetch**, para que `BackgroundTaskManager` pueda
  refrescar el resumen aunque no abras la app ese día.
- **`BGTaskSchedulerPermittedIdentifiers`** con `com.financetracker.refreshSummary`
  (si cambias el identificador en `BackgroundTaskManager.swift`, cámbialo también en
  `project.yml`).
- **App Groups** (`group.com.tunombre.financetracker`) en la app y en el widget, para
  que compartan el gasto de hoy vía `SharedDataStore`.
- **URL Scheme `financetracker://`**, usada por el widget en tamaño inline.
- El **NSExtensionPointIdentifier** del widget (`com.apple.widgetkit-extension`).

Las notificaciones locales no necesitan ninguna entrada de Info.plist: se piden en
tiempo de ejecución (`NotificationManager.requestAuthorizationIfNeeded()`). Acepta el
permiso la primera vez que abras la app instalada desde TestFlight.

## 5. Configurar el gesto rápido (Atajos)

Esto se hace en el iPhone, ya con la app instalada vía TestFlight — no requiere Xcode
ni Mac en ningún momento.

1. Abre la app **Atajos** (Shortcuts) de Apple.
2. Pestaña **Atajos** → **+** → busca la acción **"Añadir gasto rápido"** (aparece
   porque `OpenQuickAddIntent` está expuesto vía `AppShortcutsProvider`). Añádela y
   guarda el atajo, p. ej. con el nombre "Apuntar gasto".
3. **Botón de Acción** (iPhone 15 Pro/16/17 Pro): Ajustes → Botón de Acción → desliza
   hasta **Atajo** → elige "Apuntar gasto".
4. **Back Tap** (cualquier iPhone con Touch/Face ID moderno): Ajustes →
   Accesibilidad → Tocar la parte trasera → elige **Doble toque** o **Triple toque** →
   selecciona el atajo "Apuntar gasto".
5. **Siri**: di "Oye Siri, apuntar gasto" (o el nombre que le pusieras), o usa
   directamente la frase integrada: "Oye Siri, añade un gasto en FinanceTracker".
6. Para el atajo por voz con datos ("Oye Siri, registra un gasto de 12 euros en
   comestibles con tarjeta"), la acción expuesta es **"Registrar gasto por voz"**
   (`LogExpenseIntent`) — Siri te irá preguntando los parámetros que falten.

## 6. Activar el widget de pantalla de bloqueo

El target del widget y su App Group ya vienen configurados en `project.yml` (sección
4) — no hace falta crear ningún target a mano. Solo dos cosas antes de compilar:

1. Cambia el App Group de ejemplo `group.com.tunombre.financetracker` por el tuyo
   propio en dos sitios: `project.yml` (dos apariciones, bajo `entitlements` de cada
   target) y `Services/SharedDataStore.swift` (constante `appGroupID`). Debes haberlo
   creado antes en developer.apple.com → **Identifiers → App Groups → +**.
2. Vuelve a lanzar el workflow correspondiente (sección 2 o 3) para que se recompile
   con el App Group correcto.

Para añadirlo en el iPhone: bloquea la pantalla → mantén pulsado → **Personalizar →
Bloqueo** → toca los widgets bajo la hora → **+** → busca "FinanceTracker" → elige el
tamaño (circular, rectangular o inline) → **Listo**. Tócalo: debe abrir la app
directamente sobre el formulario de añadir gasto.

## 7. Publicar en la App Store (la parte de aprender el proceso)

Una vez que ya has probado la app en TestFlight (sección 3) y estás contento con ella:

1. **Ficha de la App Store**: en App Store Connect, sobre la misma app que creaste en
   la sección 3, rellena descripción, capturas de pantalla (puedes generarlas desde
   TestFlight en tu iPhone con captura de pantalla normal), icono de 1024×1024,
   categoría (Finanzas), y la **App Privacy** (nutrition label): como todos los datos
   se quedan en el dispositivo (SwiftData local, sin backend ni analíticas), declaras
   que **no se recopilan datos**.
2. **Asocia la build**: en la sección "Preparar para envío", elige la build que ya
   subiste a TestFlight con el workflow.
3. **Enviar a revisión**: rellena información de contacto y notas para el revisor, y
   pulsa **Enviar para revisión**. Apple suele tardar entre 24h y unos pocos días.
4. **Motivos típicos de rechazo** a vigilar en una app así: capturas de pantalla que no
   reflejan la app real, metadatos incompletos, y — importante para esta app — no
   afirmes en la descripción nada tipo "detecta automáticamente tus pagos con
   tarjeta", porque no es cierto y Apple lo puede rechazar por publicidad engañosa;
   describe el gesto rápido tal cual es.

Cada nueva versión que quieras subir: cambia el `CFBundleShortVersionString` /
`CURRENT_PROJECT_VERSION` que quieras en `project.yml`, haz push, y vuelve a lanzar el
workflow "Archivar y subir a TestFlight" (sección 3, paso 6).

## 8. Si en algún momento consigues acceso a un Mac

Todo lo anterior sigue funcionando igual (GitHub Actions no deja de ser útil por tener
Mac), pero si quieres además abrir el proyecto en Xcode con interfaz gráfica —
depurar con breakpoints, usar el editor visual de SwiftUI, etc. — o alquilar un Mac por
horas (MacinCloud y similares, desde ~1 $/hora, te conectas por escritorio remoto
desde el propio Android):

1. Instala Xcode (gratis, App Store) y **XcodeGen** (`brew install xcodegen`).
2. Desde `FinanceTrackerApp/`, ejecuta `xcodegen generate` — genera
   `FinanceTracker.xcodeproj` localmente, idéntico al que genera CI.
3. Ábrelo con `open FinanceTracker.xcodeproj`.
4. En el target `FinanceTracker` → **Signing & Capabilities**, cambia el **Team** a tu
   Apple ID para poder ejecutar en un iPhone conectado por cable.

No hace falta crear el proyecto a mano ni arrastrar carpetas: `project.yml` es la
única fuente de verdad, tanto si lo genera CI como si lo generas tú en un Mac.

## 9. Ideas para ampliar más adelante

- **Widget en Control Center** (iOS 18+, `ControlWidget` en el mismo target de
  extensión) para añadir un gasto con un toque desde el Centro de Control.
- **Sincronización con iCloud** activando CloudKit en el `ModelContainer` de SwiftData,
  para tener los gastos en varios dispositivos.
- **Exportar a CSV/Excel** desde Historial.
- **Face ID / código** para bloquear la app si tiene datos sensibles.
- **Notification Service Extension** para que el resumen de las 23:00 recalcule los
  totales en el instante de entregarse la notificación (más robusto que el
  recálculo actual, que depende de que la app se haya abierto o de que el sistema
  ejecute la tarea en segundo plano ese día).
