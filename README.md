# Kuroneko Nyx - pagina web

Pagina estatica para un portafolio de fotografia cosplay colaborativa.

## Cambiar fotos del portafolio

1. Guarda tus fotos dentro de la carpeta `assets/`.
2. Abre `index.html`.
3. Busca la seccion `portfolio`.
4. En cada bloque de galeria cambia:
   - `src="assets/tu-foto.jpg"`
   - `data-lightbox="assets/tu-foto.jpg"`
   - `alt="Descripcion breve de la foto"`
5. Elige la clase de proporcion:
   - `ratio-landscape` para fotos 16:9.
   - `ratio-portrait` para fotos 4:5.
   - `ratio-square` para fotos 1:1.

Ejemplo:

```html
<button class="gallery-item ratio-portrait" data-lightbox="assets/mi-cosplay.jpg">
  <img src="assets/mi-cosplay.jpg" alt="Retrato cosplay de mi personaje" />
  <span>Nombre o formato</span>
</button>
```

## Cambiar textos del acuerdo

La seccion `acuerdo` en `index.html` usa bloques `<details>`. Cada bloque funciona como un menu desplegable:

```html
<details>
  <summary>Titulo del punto</summary>
  <p>Texto del punto.</p>
</details>
```

Puedes agregar, quitar o reordenar puntos sin modificar `styles.css`.
