# 📱 Flutter Posts App

Aplicación en **Flutter** que consume la API pública [JSONPlaceholder](https://jsonplaceholder.typicode.com/), permitiendo listar, filtrar, crear, editar y eliminar publicaciones de manera interactiva.  
Este proyecto está enfocado en el manejo de **Provider**, **consumo de APIs REST**, y **diseño de interfaces limpias** con Material 3.

---

## 🌐 API utilizada

La aplicación se conecta a la API gratuita **JSONPlaceholder**, que simula endpoints REST con datos falsos para pruebas y prototipado.  

Endpoints principales utilizados:

- `GET /posts` → Listar publicaciones (con paginación simulada).  
- `GET /posts/{id}` → Obtener detalle de una publicación.  
- `POST /posts` → Crear una publicación (no se guarda en el servidor, solo responde con lo enviado).  
- `PUT /posts/{id}` → Actualizar una publicación (simulado).  
- `DELETE /posts/{id}` → Eliminar una publicación (simulado, siempre responde `200 OK`).  

> ⚠️ Importante: JSONPlaceholder **no persiste cambios reales**. Los endpoints de creación/edición/eliminación solo devuelven respuestas simuladas.

---

## 🚀 Funcionalidades del proyecto

- 📋 **Listado de posts** con scroll infinito (paginación).  
- 🔍 **Filtros** por usuario y longitud del título.  
- ➕ **Crear posts** con validación de formularios.  
- ✏️ **Editar posts** existentes.  
- ❌ **Eliminar posts** con confirmación y SnackBars.  
- 🔄 **Pull-to-refresh** en la lista de publicaciones.  
- 🎨 **Tema visual moderno** con Material 3 y estilos personalizados.

---

## ▶️ Demostración en video

📽️ Aquí puedes ver un recorrido de la app en acción:  

👉 [Agrega aquí tu enlace de YouTube](https://youtube.com/)  

---


