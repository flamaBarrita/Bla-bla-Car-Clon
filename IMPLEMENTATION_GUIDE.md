# 🛠️ GUÍA DE IMPLEMENTACIÓN PASO A PASO
## Refactorización BlaBlaCar → Anáhuac Light Professional

---

## ⚡ QUICK START (30 minutos)

Si solo quieres versión rápida:\

### 1. Integra el nuevo tema en main.dart
```dart
import 'themes/app_theme.dart';

class MyApp extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildAnáhuacTheme(),  // ← Aquí
      home: Auth(),
    );
  }
}
```

### 2. Reemplaza la definición de thema anterior
```dart
// BORRAR ESTA PARTE:
theme: ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF191919),
  primaryColor: const Color(0xFF00AFF5),
),

// REEMPLAZAR CON:
import 'themes/app_theme.dart';
theme: buildAnáhuacTheme(),
```

### 3. Exporta los colores en un lugar accesible
Crea un archivo `lib/themes/app_theme.dart` (ya incluido en la entrega)

---

## 📋 CHECKLIST COMPLETO DE PANTALLAS

### FASE 1: Pantallas de Autenticación
- [ ] **login.dart**
  - [ ] Reemplazar fondo de Color(0xFF191919) → Colors.white
  - [ ] AppBar: fondo blanco, iconos naranja
  - [ ] Botones: Color(0xFF00AFF5) → AnáhuacColors.PRIMARY_ORANGE
  - [ ] Inputs: fillColor gris claro, borde sutil
  - [ ] Textos: blanco → Color(0xFF2C2C2C)

- [ ] **signup_page.dart**
  - [ ] Mismo proceso que login.dart
  - [ ] Campos de entrada con validación (bordes rojo en error)

- [ ] **confirmar_email.dart**
  - [ ] UI limpia, mensaje centrado
  - [ ] Botón primario naranja

### FASE 2: Pantalla Principal y Navegación
- [ ] **home_page.dart** (ProfilePage)
  - [ ] backgroundColor: Color(0xFF191919) → Colors.white
  - [ ] AppBar: blanca con botón naranja
  - [ ] TabBar: indicador naranja (no azul)
  - [ ] Cards de información: white + borde sutil
  - [ ] Botones: naranja principal, rojo para logout
  - [ ] Textos: gris oscuro, etiquetas más claras

- [ ] **navegacion_button.dart** (BottomNavBar)
  - [ ] backgroundColor: blanco
  - [ ] selectedItemColor: AnáhuacColors.PRIMARY_ORANGE
  - [ ] unselectedItemColor: AnáhuacColors.TEXT_LIGHT

### FASE 3: Búsqueda y Filtros
- [ ] **buscar_viaje.dart**
  - [ ] Fondo: blanco
  - [ ] Cards de filtros: gris claro + borde naranja cuando activo
  - [ ] Botón buscar: naranja grande y prominente
  - [ ] Inputs de fecha/hora: píldora con fondo gris claro
  - [ ] Spinner loading: naranja (no azul)

- [ ] **buscar_ubicacion.dart**
  - [ ] Barra de búsqueda: píldora con fondo gris claro
  - [ ] Resultados: Cards limpias blancas
  - [ ] Icono de localización: naranja

### FASE 4: Publicación y Gestión de Viajes
- [ ] **publicar_ruta.dart**
  - [ ] Fondo blanco
  - [ ] Steps/Progress: naranja en los pasos completados
  - [ ] Inputs: gris claro + naranja en foco
  - [ ] Botón siguiente: naranja bold
  - [ ] Botón cancelar: outline naranja

- [ ] **fecha_hora_viaje.dart**
  - [ ] Picker de fecha/hora: tema claro
  - [ ] Botones de confirmación: naranja

- [ ] **precio_viaje.dart**
  - [ ] Display de precio: verde (éxito)
  - [ ] Campo de entrada: gris claro
  - [ ] Botón confirmar: naranja

- [ ] **seleccionar_ruta.dart**
  - [ ] Mapa con UI clara
  - [ ] Pins de origen/destino: naranja (no azul)
  - [ ] Cards de información: blancas

### FASE 5: Viajes y Pasajeros
- [ ] **resultados_busqueda_viaje.dart**
  - [ ] Cards de viajes refactorizadas (ver trip_card_refactored.dart)
  - [ ] Fondo: blanco
  - [ ] Precio: verde
  - [ ] Fecha: naranja
  - [ ] Rating: naranja

- [ ] **trip_card.dart**
  - [ ] Reemplazar con trip_card_refactored.dart como referencia
  - [ ] Card: white + borde sutil
  - [ ] Botón solicitar: naranja grande
  - [ ] Información conductor: texto gris oscuro, avatar con borde

- [ ] **viajes_aprobados.dart**
  - [ ] Tab bar: naranja
  - [ ] Cards de viajes: white + borde
  - [ ] Estado "Aprobado": green badge
  - [ ] Botones de acción: naranja

- [ ] **lista_pasajeros_page.dart**
  - [ ] Lista blanca de pasajeros
  - [ ] Avatar con borde sutil
  - [ ] Botones aprobar: verde
  - [ ] Botones rechazar: rojo
  - [ ] Información: texto oscuro

### FASE 6: Perfiles y Chat
- [ ] **perfil_pasagero.dart**
  - [ ] AppBar: blanca
  - [ ] Avatar: CircleAvatar con borde naranja
  - [ ] Información: Cards blancas
  - [ ] Rating: naranja
  - [ ] Botón contactar: naranja
  - [ ] Botón bloquear: rojo outline

- [ ] **chat.dart** / **mensajes_screen.dart**
  - [ ] Reemplazar con chat_refactored.dart como referencia
  - [ ] Fondo: blanco
  - [ ] AppBar: blanca
  - [ ] Mis mensajes: naranja
  - [ ] Mensajes otros: gris claro
  - [ ] Campo input: píldora gris claro
  - [ ] Botón envío: naranja circular

### FASE 7: Widgets Reutilizables
- [ ] **boton_principal.dart**
  - [ ] Reemplazar o refactorizar con boton_principal_refactored
  - [ ] Color: AnáhuacColors.PRIMARY_ORANGE
  - [ ] BorderRadius: 16
  - [ ] Height: 56

- [ ] **entrada_datos.dart**
  - [ ] Reemplazar con entrada_datos_refactored
  - [ ] fillColor: AnáhuacColors.NEUTRAL_LIGHT_BG
  - [ ] Border focus: naranja
  - [ ] Etiqueta: gris oscuro

- [ ] **formatear_fecha.dart**
  - [ ] Estilos de texto: gris oscuro
  - [ ] Sin cambios de lógica requeridos

---

## 🔄 PATRÓN DE REEMPLAZO DETALLADO

### Para cada pantalla, seguir este orden:

#### 1. **Importar tema**
```dart
import '../themes/app_theme.dart';
```

#### 2. **Reemplazar Scaffold**
```dart
// ANTES
Scaffold(
  backgroundColor: const Color(0xFF191919),
)

// DESPUÉS
Scaffold(
  backgroundColor: AnáhuacColors.BACKGROUND_WHITE,
)
```

#### 3. **Reemplazar AppBar**
```dart
// ANTES
AppBar(
  backgroundColor: const Color(0xFF191919),
  elevation: 0,
  toolbarHeight: 10,
  bottom: TabBar(
    indicatorColor: Colors.white,
    labelColor: Colors.white,
  )
)

// DESPUÉS
AppBar(
  backgroundColor: AnáhuacColors.BACKGROUND_WHITE,
  elevation: 0,
  title: const Text('Tu Título'),
  titleTextStyle: const TextStyle(
    color: AnáhuacColors.TEXT_DARK,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
  iconThemeData: const IconThemeData(
    color: AnáhuacColors.PRIMARY_ORANGE,
  ),
  bottom: TabBar(
    indicatorColor: AnáhuacColors.PRIMARY_ORANGE,
    labelColor: AnáhuacColors.TEXT_DARK,
    unselectedLabelColor: AnáhuacColors.TEXT_LIGHT,
  )
)
```

#### 4. **Reemplazar Colors.white**
```dart
// Buscar y reemplazar todos:
// Colors.white → AnáhuacColors.TEXT_DARK (si es texto)
// Colors.white → AnáhuacColors.BACKGROUND_WHITE (si es fondo)
```

#### 5. **Reemplazar Color(0xFF00AFF5) - Azul Cian**
```dart
// Buscar y reemplazar todos:
Color(0xFF00AFF5) → AnáhuacColors.PRIMARY_ORANGE
```

#### 6. **Reemplazar Color(0xFF191919) - Gris oscuro**
```dart
// Buscar y reemplazar todos:
Color(0xFF191919) → AnáhuacColors.BACKGROUND_WHITE
Color(0xFF2C2C2C) (grises oscuros) → Color(0xFF2C2C2C) (ya correcto)
```

#### 7. **Actualizar Cards**
```dart
// ANTES
Card(
  color: const Color(0xFF2C2C2C),
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
)

// DESPUÉS
Card(
  color: AnáhuacColors.BACKGROUND_WHITE,
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: const BorderSide(
      color: AnáhuacColors.NEUTRAL_BORDER,
      width: 0.5,
    ),
  ),
)
```

#### 8. **Actualizar Botones**
```dart
// ANTES
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF00AFF5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)

// DESPUÉS
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AnáhuacColors.PRIMARY_ORANGE,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 2,
    shadowColor: AnáhuacColors.PRIMARY_ORANGE.withOpacity(0.3),
  ),
)
```

#### 9. **Actualizar TextFields**
```dart
// ANTES
TextField(
  style: TextStyle(color: Colors.white),
  decoration: InputDecoration(
    hintText: "...",
    fillColor: const Color(0xFF2C2C2C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
)

// DESPUÉS
TextField(
  style: const TextStyle(color: AnáhuacColors.TEXT_DARK),
  decoration: InputDecoration(
    hintText: "...",
    hintStyle: const TextStyle(
      color: AnáhuacColors.TEXT_LIGHT,
    ),
    fillColor: AnáhuacColors.NEUTRAL_LIGHT_BG,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: AnáhuacColors.NEUTRAL_BORDER,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: AnáhuacColors.PRIMARY_ORANGE,
        width: 2,
      ),
    ),
  ),
)
```

#### 10. **Actualizar Textos**
```dart
// ANTES
Text(
  "Ejemplo",
  style: const TextStyle(color: Colors.white),
)

// DESPUÉS
Text(
  "Ejemplo",
  style: const TextStyle(color: AnáhuacColors.TEXT_DARK),
)

// Para textos secundarios:
Text(
  "Detalle",
  style: const TextStyle(color: AnáhuacColors.TEXT_SECONDARY),
)

// Para textos muy claros:
Text(
  "Hint",
  style: const TextStyle(color: AnáhuacColors.TEXT_LIGHT),
)
```

---

## 🔍 BÚSQUEDA Y REEMPLAZO GLOBAL (VS Code)

### Abrir Find and Replace
`Ctrl+H` (Windows/Linux) o `Cmd+Option+F` (Mac)

### Reemplazos recomendados (en orden):

```
1. Buscar: Color\(0xFF00AFF5\)
   Reemplazar: AnáhuacColors.PRIMARY_ORANGE
   Scope: lib/

2. Buscar: Color\(0xFF191919\)
   Reemplazar: AnáhuacColors.BACKGROUND_WHITE
   Scope: lib/screens/

3. Buscar: backgroundColor: const Color\(0xFF2C2C2C\)
   Reemplazar: backgroundColor: AnáhuacColors.NEUTRAL_LIGHT_BG
   Scope: lib/screens/

4. Buscar: Colors\.white
   Reemplazar: AnáhuacColors.TEXT_DARK (revisar contexto antes)
   Scope: lib/

5. Buscar: color: Colors\.grey,?
   Reemplazar: color: AnáhuacColors.NEUTRAL_BORDER,
   Scope: lib/
```

---

## 🗂️ ESTRUCTURA DE ARCHIVOS ENTREGADOS

```
lib/
├── themes/
│   └── app_theme.dart                    ← NUEVO (Tema completo)
│
├── screens/
│   ├── chat_refactored.dart              ← NUEVO (Ejemplo Chat)
│   ├── trip_card_refactored.dart         ← NUEVO (Ejemplo TripCard)
│   ├── home_page.dart                    ← REFACTORIZAR
│   ├── buscar_viaje.dart                 ← REFACTORIZAR
│   ├── chat.dart                         ← REFACTORIZAR
│   └── ...otros...
│
├── widgets/
│   ├── widgets_refactored.dart           ← NUEVO (Componentes refactorizados)
│   ├── boton_principal.dart              ← REFACTORIZAR
│   ├── entrada_datos.dart                ← REFACTORIZAR
│   └── navegacion_button.dart            ← REFACTORIZAR
│
├── main.dart                             ← ACTUALIZAR
└── main_refactored.dart                  ← NUEVO (Referencia)

Documentación:
├── DESIGN_REFACTORING_GUIDE.md           ← Guía de diseño (filosofía)
└── IMPLEMENTATION_GUIDE.md               ← Este archivo
```

---

## ✅ CHECKLIST POR FASE

### Semana 1: Fundación
- [ ] Copiar `lib/themes/app_theme.dart`
- [ ] Actualizar `main.dart` con nuevo tema
- [ ] Compilar sin errores
- [ ] Verificar que el tema se aplica globalmente

### Semana 2: Autenticación
- [ ] Refactorizar `login.dart`
- [ ] Refactorizar `signup_page.dart`
- [ ] Refactorizar `confirmar_email.dart`
- [ ] Testing en múltiples dispositivos
- [ ] Revisar accesibilidad (contraste, tamaño texto)

### Semana 3: Navegación y Principal
- [ ] Refactorizar `home_page.dart`
- [ ] Refactorizar `navegacion_button.dart`
- [ ] Actualizar widgets reutilizables
- [ ] Testing de transiciones
- [ ] Performance check

### Semana 4: Búsqueda y Viajes
- [ ] Refactorizar `buscar_viaje.dart`
- [ ] Refactorizar `resultados_busqueda_viaje.dart`
- [ ] Usar `trip_card_refactored.dart` como base
- [ ] Perfeccionar interacciones
- [ ] Testing con datos reales

### Semana 5: Chat y Mensajería
- [ ] Refactorizar `chat.dart`
- [ ] Refactorizar `mensajes_screen.dart`
- [ ] Usar `chat_refactored.dart` como referencia
- [ ] Testing de mensarería en tiempo real
- [ ] UX de notificaciones

### Semana 6: Perfiles y Detalles
- [ ] Refactorizar `perfil_pasagero.dart`
- [ ] Refactorizar `lista_pasajeros_page.dart`
- [ ] Refactorizar pantallas de detalle de viaje
- [ ] Completar refactorización menor
- [ ] QA completo

### Semana 7: Testing y Polish
- [ ] Testing en iOS
- [ ] Testing en Android
- [ ] Testing en web (si aplica)
- [ ] Refinamientos visuales menores
- [ ] Performance optimization

### Semana 8: Deployment
- [ ] Revisión final
- [ ] Build para production
- [ ] Beta testing con usuarios
- [ ] Feedback y ajustes
- [ ] Release

---

## 🎯 TIPS PRÁCTICOS DURANTE LA REFACTORIZACIÓN

### 1. **Usa la funcionalidad "Replace All" con cuidado**
```dart
// Buscar en directorios específicos:
// lib/screens/ para pantallas
// lib/widgets/ para widgets
// No reemplazar en lib/services/ o lib/models/
```

### 2. **Mantén copias de respaldo**
```bash
git commit -m "Before refactoring: keep backup"
git branch refactoring-backup
```

### 3. **Refactoriza pantalla por pantalla**
```
1. Abre pantalla
2. Importa app_theme.dart
3. Reemplaza colors específicamente
4. Revisa visualmente
5. Compilar y ver en emulador
6. Commit
7. Siguiente pantalla
```

### 4. **Utiliza el tema por defecto del Material**
```dart
// El tema aplica automáticamente a:
ElevatedButton()      // Color primario automático
OutlinedButton()      // Color primario automático
TextField()           // InputDecoration automática
AppBar()              // Colors automáticos
Card()                // Elevation automática (casi)

// Solo necesitas especificar si necesitas variantes
```

### 5. **Verifica en devices reales**
```
No confiar solo en emulador:
- Prueba en phone Android real
- Prueba en iPhone real (si es posible)
- Verifica tamaños de touch targets (48px)
- Verifica legibilidad en sunlight
```

---

## 🐛 TROUBLESHOOTING

### Problema: Los colores naranja no se ven bien
```
Solución:
1. Verifica que AnáhuacColors esté importado correctamente
2. Reconstruye la app: flutter clean && flutter pub get
3. Verifica que no hay override de tema en widgets específicos
```

### Problema: Los inputs se ven diferentes en iOS vs Android
```
Solución:
1. Usa TextFormField en lugar de TextField para iOS
2. Aplica explícitamente decoration a ambos
3. Prueba con `showCursorOnFocus: true`
```

### Problema: AppBar no se ve bien
```
Solución:
1. Asegurate que elevation: 0 está configurado
2. Añade Bottom Divider si se necesita separación
3. Verifica que iconThemeData está correctamente configurado
```

### Problema: Performance lenta después de refactorizar
```
Solución:
1. Verifica que no hay rebuilds innecesarios
2. Usa const para widgets que no cambian
3. Revisa Dart DevTools para Memory leaks
```

---

## 📞 CUANDO CONTACTAR AL DISEÑADOR

Si durante la refactorización encuentras:
- [ ] Pantalla con lógica compleja que necesita redesign
- [ ] Component que no existe en los ejemplos proporcionados
- [ ] Dudas sobre cómo aplicar el tema a cas específicos
- [ ] Performance issues no identificables
- [ ] Incompatibilidades con librerías de terceros

---

## 🎉 CHECKLIST FINAL DE ÉXITO

Una vez completada la refactorización, verifica:

```
VISUAL
 ✅ Todo el texto > 14px legible (no pequeño)
 ✅ Botones con altura mínima 48px
 ✅ Elementos clickeables con mínimo 8px de padding
 ✅ Sin negro puro (#000000) en ningún lugar
 ✅ Sin azul cian (#00AFF5) excepto en código antiguo marcado para eliminar
 ✅ AppBars blancas con iconos naranjas
 ✅ Cards con borde sutil y sombra
 ✅ Inputs con borde sutil y foco naranja
 ✅ Botones primarios naranjas
 ✅ Estados verde (éxito) y rojo (error)

FUNCIONALIDAD
 ✅ Tema se aplica globalmente
 ✅ No hay hard-coded colors en pantallas
 ✅ Todos los componentes usan AnáhuacColors
 ✅ Transiciones funcionan óptimamente
 ✅ No hay errores en consola

ACCESIBILIDAD
 ✅ Contraste texto/fondo ≥ 4.5:1 en todo
 ✅ Elementos interactivos > 48px
 ✅ Fuentes > 14px para cuerpo
 ✅ Colores no son la única forma de diferenciar (ej: + texto)

COMPATIBILIDAD
 ✅ Funciona en Android 6+
 ✅ Funciona en iOS 12+
 ✅ Sin memory leaks
 ✅ Performance > 60fps
```

---

**¡Listo para empezar la refactorización! 🚀**
