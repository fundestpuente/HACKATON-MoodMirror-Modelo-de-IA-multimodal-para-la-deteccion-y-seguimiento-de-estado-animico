# MoodMirror

MoodMirror es un prototipo de aplicación móvil que analiza emociones a partir de texto e imágenes. La idea es sencilla: ayudar a las personas a entender cómo se sienten día a día sin necesidad de acudir a herramientas complejas o costosas. No pretende reemplazar a un profesional, pero sí ofrecer un espacio accesible para reflexionar y recibir recomendaciones básicas.

Los problemas emocionales y el estrés van en aumento, y conseguir atención psicológica oportuna no siempre es posible: falta de tiempo, costos altos o sistemas de salud saturados. Mucha gente termina ignorando su propio bienestar emocional. MoodMirror nace como una respuesta a esa brecha.

La aplicación combina dos análisis:
- lo que escribes,
- y lo que muestra tu expresión facial.

Con eso obtiene una lectura general de tu estado emocional y te da sugerencias simples para ayudarte a manejarlo mejor, cabe recalcar que esta herramienta no es clínica.

## Componentes del proyecto

MoodMirror está compuesto por tres módulos principales::

1. Un modelo para detección de emociones en texto.
2. Un modelo CNN para detección de emociones en imágenes.
3. Integración móvil


### 1. Modelo de análisis emocional en texto (emotion_detection_text.ipynb)
Modelo basado en XLM-RoBERTa entrenado con datasets públicos. Procesa frases en español y devuelve una emoción entre varias categorías como alegría, ira, tristeza, disgusto, miedo, neutral o sorpresa.

Incluye:
- carga y unión de datasets (se pueden encontrar los datasets usados en los enlaces al inicio del código)
- tokenización
- entrenamiento con HuggingFace
- guardado del modelo (importante para el uso de la aplicación)
- ejemplo de inferencia

### 2. Modelo de análisis emocional en imágenes (emotion_detection_image.ipynb)
Una CNN desarrollada con Keras para clasificar expresiones faciales en diferentes emociones.

Incluye:
- preparación del dataset (el dataset usado se incluye en la carpeta )
- aumentación de datos
- entrenamiento y validación
- matriz de confusión
- guardado del modelo en formato  (importante para el uso de la aplicación)
- ejemplo de predicción con una imagen real


### 3. Aplicación móvil

## Backend FAST API

El backend de MoodMirror implementa un sistema de análisis emocional multimodal combinando tres modelos de inteligencia artificial:

1. Un modelo CNN entrenado para reconocimiento de emociones faciales.
2. Un modelo Transformer tipo RoBERTa (RoBERTuito) para el análisis de sentimiento del texto.
3. Un modelo LLM de OpenAI para refinar la interpretación emocional y generar un consejo personalizado.

Toda la lógica está implementada en FastAPI, mientras que los datos se almacenan de forma local en SQLite.

--------------------------------------------------------
4.1 Arquitectura general del backend
--------------------------------------------------------

Cuando el usuario envía una entrada desde la app (una foto y una nota escrita), el backend realiza:

1. Procesamiento de la imagen → predicción emocional con la CNN.
2. Procesamiento del texto → sentimiento mediante el Transformer RoBERTuito.
3. Refinamiento emocional y generación de consejo → LLM de OpenAI.
4. Fusión de resultados → una única emoción dominante.
5. Almacenamiento en SQLite.

Esto permite un análisis emocional más completo, ya que combina señales visuales + textuales + razonamiento contextual.

--------------------------------------------------------
4.2 Ejecución del backend

Para iniciar el servicio:

uvicorn main:app --host 0.0.0.0 --port 8000 --reload

- Permite el acceso desde otros dispositivos en la red.
- Habilita recarga automática al modificar el código.

--------------------------------------------------------
4.3 Modelos utilizados
--------------------------------------------------------

(1) CNN para emociones en imagen
--------------------------------
Se carga el modelo: model/cnn_moodmirror_64px_50dataset.h5

Este modelo clasifica la expresión facial en:
Angry, Happy, Neutral, Sad, Surprise.

(2) Transformer RoBERTuito
---------------------------
Se usa un modelo tipo RoBERTa en español para analizar el sentimiento del texto escrito por el usuario.  
Este modelo ofrece una predicción mucho más precisa del estado emocional textual que un clasificador tradicional.

Detecta sentimientos como:
- alegría
- neutralidad
- tristeza
- enojo
- sorpresa

(3) Modelo de OpenAI (LLM)
---------------------------
El LLM cumple dos funciones:
1. Refinar y normalizar las salidas de ambos modelos.
2. Generar un consejo emocional basado en:
   - 70% emoción textual (RoBERTuito)
   - 30% emoción visual (CNN)

La respuesta final se adapta a la situación emocional del usuario.

--------------------------------------------------------
4.4 Endpoints principales
--------------------------------------------------------

(1) POST /add_entry
-------------------

Recibe:
- Una imagen (UploadFile)
- Una nota escrita (texto)

El backend ejecuta la siguiente secuencia:

1. La imagen se procesa y la CNN predice una emoción facial.
2. El texto se envía al modelo Transformer RoBERTuito, que devuelve su propia etiqueta emocional.
3. Ambas emociones se fusionan y se envían a OpenAI.
4. El LLM interpreta la situación emocional, contextualiza y genera un consejo breve.
5. La entrada completa se guarda en SQLite.

Devuelve un JSON con:
- Fecha y hora
- Nota original
- Emoción detectada por imagen
- Emoción detectada por texto (Transformer)
- Consejo generado por OpenAI

(2) GET /entries
-----------------

Obtiene todas las entradas almacenadas en la base de datos, ordenadas por fecha.  
Es usado por la app para mostrar el diario del usuario.

(3) DELETE /delete_entry/{id}
------------------------------

Elimina una entrada específica por su ID.  
Se usa para limpiar o actualizar el diario.

--------------------------------------------------------
4.5 Flujo emocional multimodal
--------------------------------------------------------

El backend combina tres fuentes:

- La “señal visual” (CNN)
- La “señal lingüística” (Transformer RoBERTuito)
- La “señal interpretativa” (LLM de OpenAI)

Esto genera un análisis emocional más robusto que usar solo uno de los modelos.

La ponderación final:
- 70% emoción textual (lenguaje)
- 30% emoción visual (rostro)

OpenAI se encarga de interpretar ambas señales y convertirlas en un consejo personalizado.

--------------------------------------------------------
4.6 Almacenamiento
--------------------------------------------------------

Cada entrada queda registrada en SQLite con:
- Fecha
- Texto original
- Emoción de imagen
- Emoción del Transformer
- Consejo generado

Esto permite construir funciones como:
- Resumen semanal
- Análisis mensual
- Detección de patrones emocionales
- Alertas en caso de emociones negativas repetidas



La aplicación móvil de MoodMirror fue desarrollada en **Flutter**, utilizando un diseño minimalista con tonos pastel y navegación sencilla.  
Para ejecutar el proyecto en cualquier entorno, se deben seguir los siguientes pasos:

---

### Frontend Flutter

La aplicación móvil de MoodMirror fue desarrollada en Flutter, con una interfaz minimalista y temática pastel. Para ejecutar el frontend en cualquier entorno, se deben seguir los siguientes pasos.

------------------------------------------
3.1 Crear un nuevo proyecto Flutter
------------------------------------------

En una terminal:

flutter create moodmirror_app
cd moodmirror_app

Esto genera la estructura base del proyecto.

------------------------------------------
3.2 Instalar las dependencias necesarias
------------------------------------------

Reemplazar el archivo pubspec.yaml creado por Flutter con el archivo pubspec.yaml proporcionado en este repositorio. Este archivo contiene todas las librerías necesarias:

- http (comunicación con backend)
- image_picker (cámara y galería)
- shared_preferences (guardar la IP del servidor)
- flutter_svg (manejo de imágenes SVG)
- Declaración de assets

Después de reemplazarlo, instalar dependencias con:

flutter pub get

------------------------------------------
3.3 Integrar los archivos del frontend
------------------------------------------

Copiar al proyecto Flutter las siguientes carpetas y archivos provenientes del repositorio:

- lib/      (contiene todas las pantallas, widgets y lógica)
- assets/   (imágenes, íconos y recursos gráficos)
- pubspec.yaml (definición de dependencias y assets)

Asegurarse de que en pubspec.yaml esté incluida la declaración:

assets:
  - assets/

------------------------------------------
3.4 Ejecutar la aplicación
------------------------------------------

Para correr la app en un dispositivo físico o emulador:

flutter run

Para generar el APK:

flutter build apk --release

El archivo resultante estará en:

build/app/outputs/flutter-apk/app-release.apk

------------------------------------------
3.5 Conexión con el backend
------------------------------------------

La app requiere la IP del servidor backend. Esto se configura desde la aplicación:

1. Abrir Menú → Configuración
2. Ingresar la IP del backend (solo la IP, sin http:// ni puerto)
3. Guardar cambios y reiniciar la app

Ejemplo:

192.168.1.50

El backend debe ser accesible desde el navegador del celular:

http://IP:8000/entries

------------------------------------------
3.6 Funcionalidades principales
------------------------------------------

- Pantalla de inicio (LoginPage):
  Presenta el logo e ingresa al demo.

- Pantalla principal (HomePage):
  Acceso a Añadir Feeling, Revisar Diario, Análisis de Progreso, Configuración y Nosotros.

- Añadir Feeling:
  Toma una foto, recoge una nota del usuario y envía datos al backend.

- Revisar Diario:
  Muestra todas las entradas almacenadas y permite eliminarlas.

- Análisis de Progreso:
  Resume emociones por día, semana y mes. Detecta patrones repetitivos.

- Configuración:
  Permite guardar la IP del backend utilizando SharedPreferences.

Esta estructura permite instalar, correr y extender el frontend sin dependencias externas adicionales.

