# Cómo usar RodosUIToolset en otros proyectos

## Para que la librería sea importable remotamente:

1. **Tag de versión creado** ✅
   - Tag `1.0.0` ya está creado y pusheado
   - Swift Package Manager usa tags para versionar

2. **Repositorio público** (necesario verificar)
   - Ve a: https://github.com/King5upah/RodosUIToolset
   - Asegúrate de que el repositorio sea público (Settings → General → Danger Zone → Change visibility)

3. **Crear Release en GitHub** (recomendado pero opcional)
   - Ve a: https://github.com/King5upah/RodosUIToolset/releases
   - Click en "Draft a new release"
   - Selecciona tag: `1.0.0`
   - Título: `v1.0.0 - Initial Release`
   - Descripción: Usa el mensaje del tag
   - Publicar release

## Cómo otros pueden importar tu librería:

### En Xcode:

1. File → Add Package Dependencies...
2. URL: `https://github.com/King5upah/RodosUIToolset.git`
3. Version: `Up to Next Major Version` from `1.0.0`
4. Add Package

### En Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/King5upah/RodosUIToolset.git", from: "1.0.0")
]
```

### Uso en código:

```swift
import RodosUIToolset

// Usar componentes
PrecisableInput(...)
FMSetter(...)
PrecisableUnit.kilograms
```

## Para futuras versiones:

```bash
# 1. Hacer cambios
git add -A
git commit -m "feat: Nueva funcionalidad"
git push

# 2. Crear nuevo tag
git tag -a "1.1.0" -m "v1.1.0: Nueva funcionalidad"
git push origin 1.1.0

# 3. Crear release en GitHub (opcional)
```

## Verificar que funciona:

Puedes probar la importación en un proyecto nuevo:

```bash
swift package init --name TestPackage
# Editar Package.swift para agregar dependencia
swift package update
swift build
```

