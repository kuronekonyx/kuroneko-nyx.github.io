const header = document.querySelector("[data-header]");
const lightbox = document.querySelector("[data-lightbox-dialog]");
const lightboxImage = document.querySelector("[data-lightbox-image]");
const closeLightbox = document.querySelector("[data-lightbox-close]");
const toast = document.querySelector("[data-toast]");
const copyButton = document.querySelector("[data-copy-message]");

const updateHeader = () => {
  header.classList.toggle("is-scrolled", window.scrollY > 18);
};

const showToast = (message) => {
  toast.textContent = message;
  toast.classList.add("is-visible");
  window.clearTimeout(showToast.timeout);
  showToast.timeout = window.setTimeout(() => {
    toast.classList.remove("is-visible");
  }, 2200);
};

document.querySelectorAll("[data-lightbox]").forEach((button) => {
  button.addEventListener("click", () => {
    const image = button.querySelector("img");
    lightboxImage.src = button.dataset.lightbox;
    lightboxImage.alt = image?.alt || "Fotografia cosplay ampliada";
    lightbox.showModal();
  });
});

closeLightbox.addEventListener("click", () => {
  lightbox.close();
});

lightbox.addEventListener("click", (event) => {
  if (event.target === lightbox) {
    lightbox.close();
  }
});

copyButton.addEventListener("click", async () => {
  const message =
    "Hola Kuroneko Nyx, me interesa proponer una colaboracion cosplay. Personaje: ____. Ciudad: ____. Fecha tentativa: ____. Idea o referencias: ____. Lei y acepto revisar el acuerdo de colaboracion antes de coordinar.";

  try {
    await navigator.clipboard.writeText(message);
    showToast("Mensaje guia copiado");
  } catch {
    showToast("No se pudo copiar automaticamente");
  }
});

window.addEventListener("scroll", updateHeader, { passive: true });
updateHeader();
