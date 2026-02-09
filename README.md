# 🚗 BlaBlaCar Clone (Flutter & Python)

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) ![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

> **Un clon funcional de Bla Bla Car desarrollado con el framework FLUTTER.**

## 📖 Sobre el Proyecto

Esta aplicación facilita la **movilidad compartida**, permitiendo a los usuarios conectar para realizar viajes en coche conjuntos. Es una solución ideal tanto para personas viajeras que buscan economizar, como para quienes disfrutan de socializar y tener conversaciones profundas durante sus trayectos.

**Funcionalidades Clave:**
* 🚘 **Publicar Viajes:** Los conductores pueden ofrecer asientos libres.
* 🔍 **Buscar Trayectos:** Los pasajeros pueden encontrar viajes que se ajusten a su ruta.
* 🤝 **Social:** Fomenta la comunidad y el viaje compartido.

---

## 🏗️ Arquitectura del Sistema

La aplicación está construida sobre una arquitectura **robusta**, diseñada específicamente para soportar **escalabilidad** y garantizar un **alto rendimiento**.

### 📱 Frontend (Cliente)
* **Framework:** Desarrollado en **Flutter (Dart)** para una experiencia nativa fluida.
* **Arquitectura:** Implementación de **Clean Architecture**, garantizando la separación de responsabilidades, testabilidad y fácil mantenimiento.
* **UI/UX:** Estilización ágil y consistente mediante **Tailwind Flutter**.

### 🔌 Backend (Servidor)
* **Core:** Impulsado por **Python 3.11+** y **FastAPI**, asegurando respuestas rápidas y manejo asíncrono eficiente.
* **Contenerización:** Todo el entorno está orquestado con **Docker Compose** 🐳 y asegurando consistencia entre desarrollo y producción.
* **Geo-servicios:** Integración completa con **Google Maps Platform** 🗺️ para geolocalización y rutas precisas.

### ☁️ Datos e Infraestructura
Utilizamos un enfoque híbrido y moderno:
* **Base de Datos Relacional:** **PostgreSQL** 🐘 como motor principal.
* **Datos Espaciales:** Motor **PostGIS** 🌍 para el manejo avanzado de coordenadas y rutas.
* **Caché:** Implementación de **Redis** ⚡ para un rendimiento muy rápido y manejo de caché.
* **Cloud:** Despliegue en estrategia multi-nube utilizando **AWS** y **Oracle Cloud (OCI)**.
