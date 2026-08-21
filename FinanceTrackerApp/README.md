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
  abre el formulario de alta al instante; en tamaño inline, tocarlo abre el mismo
  formulario. Con cuenta de Apple Developer de pago, el rectangular y el inline
  enseñan además el gasto de hoy (ver sección 7 sobre por qué no en la vía gratuita).

## Por qué no hay "detección automática" del pago con tarjeta

Apple no da a las apps de terceros ninguna API para enterarse de que acabas de pagar
con Apple Pay o con el NFC del banco — ni el evento en sí, ni el importe, ni el
comercio. Ninguna app de terceros en el App Store lo hace porque no se puede.

Lo que sí es 100% viable, y es lo que monta esta app, es reducir el "voy a apuntar el
gasto" a un solo gesto tuyo justo después de pagar: botón de Acción, Back Tap, Siri o
el widget de pantalla de bloqueo. Todo dispara el mismo formulario que ves al pulsar
el "+" dentro de la app. Ver la sección 6.

---

## 0. No tienes Mac (solo Android/Windows/Linux) — cómo se resuelve esto

Xcode solo existe para macOS: eso no lo cambia nada de lo que hagamos. Pero **no hace
falta que tú tengas un Mac** para compilar, firmar ni instalar esta app: cada vez que
subes cambios a GitHub, un workflow de **GitHub Actions** arranca un Mac real (gratis,
lo pone GitHub) y compila el proyecto ahí. Es exactamente lo que haría Xcode en tu
mesa, solo que en la nube y sin que lo veas.

Lo único que sí necesitas de forma inevitable es un **iPhone físico** para instalar y
usar la app de verdad — ni tu Android ni un simulador en la nube sustituyen eso, y
cosas como Back Tap, el botón de Acción o el widget de bloqueo solo existen en un
iPhone real.

**¿Y la cuenta de pago de Apple (99 €/año)?** Aquí hay dos caminos distintos, según lo
que quieras hacer, y solo uno de ellos la exige:

| Quiero...                                                    | ¿Cuenta de pago? | Sección |
|---------------------------------------------------------------|:---:|:---:|
| Solo comprobar que el código compila                          | No  | 2 |
| Instalarla en mi iPhone para usarla yo (sideloading)           | **No** | 3 |
| Instalarla en mi iPhone vía TestFlight (más cómodo, sin caducar cada 7 días) | Sí | 4 |
| Publicarla de verdad en la App Store para que la baje cualquiera | Sí, sin excepción | 8 |

Es decir: puedes tener la app funcionando en tu iPhone, con notificaciones, widget y
gestos, **sin pagar nada a Apple**, usando sideloading (sección 3). Lo único que Apple
no deja hacer gratis bajo ningún concepto es meterla en la App Store para que la
descargue otra gente — eso, cuando llegue el momento, sí exige los 99 €/año.

## 1. Requisitos

- Una cuenta de **GitHub** (gratis) — ya la tienes, es donde vive este repo.
- Un **Apple ID** normal (gratis) — el mismo con el que usas el iPhone sirve.
- Un **iPhone físico** con iOS 17 o superior.
- Un ordenador (Windows, Linux o Mac, da igual) solo para ejecutar **AltServer**
  puntualmente si eliges la vía gratuita (sección 3) — no necesita ser tuyo ni potente,
  hasta un Windows viejo vale.
- Solo si más adelante quieres publicar en la App Store: **Apple Developer Program**
  (99 €/año) — ver sección 8.

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

## 3. Instalarla gratis en tu iPhone (sideloading, sin cuenta de pago)

Apple permite firmar apps para tu propio dispositivo con un Apple ID normal y gratis
— es el mecanismo que usa cualquier desarrollador para probar antes de pagar. Sin Mac
no puedes hacerlo con Xcode directamente, pero herramientas como
**[AltStore](https://altstore.io)** o **[SideStore](https://sidestore.io)** hacen esa
misma firma gratuita por ti, hablando con los servidores de Apple con las mismas APIs
que usaría Xcode, sin que haga falta Xcode ni Mac. Es legal y es exactamente para esto
para lo que Apple ofrece la firma gratuita.

Las contras, para que sepas dónde te metes: el certificado gratuito caduca cada **7
días** (AltServer/SideStore la vuelven a firmar solas si mantienes el proceso
disponible en tu red o activas el "refresco en segundo plano" de SideStore — si no, te
tocará reinstalar cada semana), y con un Apple ID gratis solo puedes tener **3 apps**
firmadas así a la vez. Para un proyecto personal en el que estás aprendiendo, es un
intercambio razonable.

### 3.1 Generar el `.ipa` sin firmar

1. En GitHub, pestaña **Actions** → workflow **"Generar .ipa para sideload"** → **Run
   workflow** (lo lanzas tú manualmente, no hace falta cada vez que subas un cambio).
2. Cuando termine (✅), entra en esa ejecución y baja hasta **Artifacts** →
   descarga `FinanceTracker-sin-firmar` (es un .zip que contiene el `.ipa`).

### 3.2 Instalar AltStore/SideStore

1. En tu ordenador (Windows o Linux, no hace falta que sea potente ni tuyo): instala
   **AltServer** desde https://altstore.io. Necesita que instales también iTunes en
   Windows (o `usbmuxd` en Linux) para que reconozca el iPhone por cable/wifi.
2. Conecta el iPhone, abre AltServer, inicia sesión con tu Apple ID (gratis, no hace
   falta Developer Program), y desde el icono de AltServer en la bandeja del sistema:
   **Install AltStore → (tu iPhone)**.
3. En el iPhone: **Ajustes → General → VPN y gestión de dispositivos** → confía en tu
   Apple ID como desarrollador (una vez).
4. Abre la app **AltStore** ya instalada en el iPhone → pestaña **My Apps** → **+** →
   elige el `FinanceTracker.ipa` que descargaste en 3.1 (pásalo al iPhone por AirDrop,
   cable, o ábrelo directamente desde el Finder/explorador si AltServer sigue activo en
   el ordenador). AltStore lo firma con tu Apple ID gratis y lo instala.

Si prefieres no depender de un ordenador cada semana, una vez tengas AltStore
instalado puedes migrar a **SideStore**, que puede refrescar la firma sola sin volver a
conectar por cable (usa una VPN local en el propio iPhone) — su web trae la guía
actualizada, cambia con cada versión de iOS.

> Nota si estás en la Unión Europea: desde iOS 17.4, Apple está obligada a permitir
> "mercados alternativos" en la UE, y AltStore ya tiene una versión (**AltStore PAL**)
> instalable directamente desde Safari en el iPhone sin pasar por un ordenador en
> absoluto. Es más nuevo y cambia rápido — mira altstore.io por si ya te sirve
> directamente esa vía, aún más simple que lo de arriba.

## 4. Instalarla en tu iPhone vía TestFlight (con cuenta de pago)

Alternativa más cómoda al sideloading: no caduca cada 7 días, no necesitas un
ordenador con AltServer, y es el mismo mecanismo que usan las apps reales en fase de
pruebas. A cambio, exige la cuenta de pago.

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
7. **Instálala en tu iPhone**: descarga la app **TestFlight** de la App Store, entra
   con el mismo Apple ID, y en unos minutos aparecerá FinanceTracker lista para
   instalar y probar de verdad.

Si algún paso de este workflow falla la primera vez (es habitual con la firma
automática de Apple: a veces hay que relanzarlo una segunda vez tras crear el primer
perfil/certificado), copia el error del log de Actions y lo resolvemos juntos.

## 5. Capacidades e Info.plist

`project.yml` ya deja configurado todo esto automáticamente al generar el proyecto —
no hay que tocar nada a mano en Xcode:

- **Background Modes → Background fetch**, para que `BackgroundTaskManager` pueda
  refrescar el resumen aunque no abras la app ese día.
- **`BGTaskSchedulerPermittedIdentifiers`** con `com.financetracker.refreshSummary`
  (si cambias el identificador en `BackgroundTaskManager.swift`, cámbialo también en
  `project.yml`).
- **URL Scheme `financetracker://`**, usada por el widget en tamaño inline.
- El **NSExtensionPointIdentifier** del widget (`com.apple.widgetkit-extension`).

A propósito **no** se declara la capacidad App Groups: las cuentas gratuitas de Apple
(la que usa el sideloading, sección 3) no la admiten, y sin ella la firma fallaría.
Ver sección 7 para qué implica esto en el widget y cómo activarla si algún día pagas
la cuenta de Developer.

Las notificaciones locales no necesitan ninguna entrada de Info.plist: se piden en
tiempo de ejecución (`NotificationManager.requestAuthorizationIfNeeded()`). Acepta el
permiso la primera vez que abras la app instalada.

## 6. Configurar el gesto rápido (Atajos)

Esto se hace en el iPhone, ya con la app instalada (por sideloading o TestFlight) — no
requiere Xcode ni Mac en ningún momento.

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

## 7. Activar el widget de pantalla de bloqueo

El target del widget ya viene configurado en `project.yml` — no hace falta crear
ningún target a mano ni tocar nada antes de compilar.

**Con la vía gratuita (sideloading), el widget funciona como botón de acceso
rápido pero sin enseñar "hoy has gastado X€":** las cuentas de Apple gratuitas
(Personal Team, la que usan AltStore/SideStore) no admiten la capacidad "App Groups",
que es la que necesitaría el widget para leer ese dato de la app. Por eso
`project.yml` no la declara — así la firma gratuita funciona sin errores — y el
widget (`Widgets/QuickAddWidget.swift`) está hecho para no enseñar un "0,00 €" falso
en ese caso: simplemente muestra "Añadir gasto" / "FinanceTracker". Sigue abriendo el
formulario al instante, que era el objetivo; solo pierdes ese dato extra en pantalla.

Si en algún momento das el paso a Apple Developer Program (sección 8), puedes
recuperarlo: añade de vuelta el bloque `entitlements` con
`com.apple.security.application-groups: [group.tu-id]` en ambos targets de
`project.yml`, pon el mismo identificador en `Services/SharedDataStore.swift`
(constante `appGroupID`), créalo en developer.apple.com → **Identifiers → App Groups
→ +**, y volverá a mostrar el total solo, sin tocar el resto del código.

Para añadirlo en el iPhone: bloquea la pantalla → mantén pulsado → **Personalizar →
Bloqueo** → toca los widgets bajo la hora → **+** → busca "FinanceTracker" → elige el
tamaño (circular, rectangular o inline) → **Listo**. Tócalo: debe abrir la app
directamente sobre el formulario de añadir gasto.

## 8. Publicar en la App Store (aquí sí hace falta la cuenta de pago, sin excepción)

Esta es la única parte del proyecto que Apple no permite hacer gratis bajo ningún
concepto: para que la app aparezca en la App Store y cualquiera pueda descargarla,
exige sí o sí estar dado de alta en el Apple Developer Program (99 €/año). Ni
sideloading ni ningún otro atajo la sustituyen aquí — es la revisión y distribución
pública de Apple, no un problema técnico que se pueda rodear.

Una vez que ya has probado la app (sideloading o TestFlight, secciones 3-4) y estás
contento con ella:

1. **Ficha de la App Store**: en App Store Connect, sobre la misma app que creaste en
   la sección 4, rellena descripción, capturas de pantalla (puedes generarlas
   directamente desde el iPhone con captura de pantalla normal), icono de 1024×1024,
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
workflow "Archivar y subir a TestFlight" (sección 4, paso 6).

## 9. Si en algún momento consigues acceso a un Mac

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
   Apple ID para poder ejecutar en un iPhone conectado por cable (con un Apple ID
   gratis basta para esto, sin Developer Program, igual que el sideloading).

No hace falta crear el proyecto a mano ni arrastrar carpetas: `project.yml` es la
única fuente de verdad, tanto si lo genera CI como si lo generas tú en un Mac.

## 10. Ideas para ampliar más adelante

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
