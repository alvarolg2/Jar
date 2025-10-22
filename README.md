# JAR - Gestión de Almacén y Palets

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-%2307405E.svg?style=for-the-badge&logo=sqlite&logoColor=white)
![Stacked](https://img.shields.io/badge/Stacked-%231C2834.svg?style=for-the-badge)

Aplicación móvil desarrollada con Flutter para la gestión eficiente de inventario en almacenes, enfocada en el seguimiento de palets por lote y producto.

## ✨ Características

* **Gestión de Almacenes**:
    * Crear, editar y eliminar almacenes.
    * Visualización del número total de palets por almacén en pestañas.
* **Gestión de Palets**:
    * **Recepción**: Registrar la entrada de nuevos lotes de productos escaneando documentos (códigos de barras, texto) o manualmente.
    * **Seguimiento**: Visualizar palets por almacén, lote y producto.
    * **Salida**: Registrar la salida de palets (individualmente o por camión completo - 26 palets).
    * **Palets Defectuosos**: Marcar y visualizar palets defectuosos de forma separada.
    * **Entrada Adicional**: Añadir más palets a un lote existente.
* **Gestión de Productos y Lotes**:
    * Creación automática o manual de productos y lotes durante la recepción.
    * Asociación de palets a lotes y productos específicos.
    * Filtrado de la vista de almacén por producto.
* **Base de Datos Local (SQLite)**: Almacenamiento persistente de toda la información.
* **Importación/Exportación de Datos**:
    * Exportar la base de datos completa para backups.
    * Importar una base de datos existente (reemplaza la actual).
* **Generación de Informes**: Crear y compartir informes en PDF del estado del inventario por almacén (estándar y defectuoso).
* **Escaneo de Documentos**: Utiliza la cámara para escanear etiquetas o documentos y extraer información (Producto, Lote, Cantidad) mediante OCR (Reconocimiento Óptico de Caracteres) para agilizar la entrada de datos.
* **Actualizaciones en la App (Android)**: Comprueba e instala actualizaciones automáticamente.

## 🚀 Tecnologías Utilizadas

* **Flutter**: Framework principal para el desarrollo de la interfaz de usuario multiplataforma.
* **Dart**: Lenguaje de programación.
* **Stacked**: Arquitectura MVVM para una estructura organizada (servicios, vistas, viewmodels).
* **stacked\_services**: Para navegación, diálogos y bottom sheets.
* **SQLite (sqflite)**: Base de datos local para almacenamiento persistente.
* **path\_provider**: Para obtener rutas del sistema de archivos (ubicación de la BD).
* **cunning\_document\_scanner**: Para escanear documentos usando la cámara.
* **google\_mlkit\_text\_recognition**: Para el reconocimiento de texto (OCR) en imágenes escaneadas.
* **share\_plus**: Para compartir archivos (exportar BD, informes PDF).
* **file\_picker**: Para seleccionar archivos (importar BD).
* **pdf**: Para generar documentos PDF (informes).
* **package\_info\_plus**: Para obtener información de la versión de la app.
* **in\_app\_update**: Para gestionar actualizaciones dentro de la aplicación (Android).

## ⚙️ Instalación y Ejecución

1.  **Clona el repositorio:**
    ```bash
    git clone [https://github.com/tu_usuario/jar.git](https://github.com/tu_usuario/jar.git)
    cd jar
    ```
2.  **Asegúrate de tener Flutter instalado.** Si no, sigue la [guía oficial de instalación de Flutter](https://flutter.dev/docs/get-started/install).
3.  **Obtén las dependencias:**
    ```bash
    flutter pub get
    ```
4.  **Genera los archivos necesarios (si aplica, para `stacked_generator`):**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
5.  **Ejecuta la aplicación** en el dispositivo o emulador deseado:
    ```bash
    flutter run
    ```

## 💾 Gestión de la Base de Datos

* La aplicación utiliza una base de datos SQLite llamada `warehouse_transport.db` almacenada localmente en el dispositivo.
* **Exportar**: Puedes exportar la base de datos actual desde el menú de opciones en la pantalla principal. Esto es útil para realizar copias de seguridad.
* **Importar**: Puedes importar un archivo `.db` previamente exportado. **¡Atención!** Esta acción reemplazará completamente la base de datos actual.
* **Informes**: Genera un resumen en PDF del inventario actual, detallado por almacén y separando palets estándar y defectuosos.

---

## 🤝 Contribuciones

Las contribuciones, issues y peticiones de características son bienvenidas. Siéntete libre de revisar los [issues](https://github.com/alvarolg2/jar/issues) existentes o abrir uno nuevo.

---

## 📄 Licencia
