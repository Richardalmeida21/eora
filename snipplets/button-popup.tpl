{% set popup_bg = settings.home_popup_background_color 
  ? settings.home_popup_background_color ~ '30' 
  : '#2F1A8330' %}{% set popup_title_color = settings.home_popup_text_title_color | default('#ffffff') %}
{% set popup_subtitle_color = settings.home_popup_text_subtitle_color | default('#ffffff') %}
{% set popup_error_color = settings.home_popup_mensagem_error_color | default('#ff5555') %}

<style>
  div#optin-IIw6HlBv > #p-open {
    display: none;
  }

  .p-layer.p-opened {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;   /* Centraliza verticalmente */
  justify-content: center; /* Centraliza horizontalmente */
  background: rgba(0, 0, 0, 0.5); /* opcional, fundo escurecido */
  z-index: 9999; /* garante que fique acima de tudo */
  }

  .notification-cart-reopen-container {
    position: fixed;
    bottom: 20px;
    left: 20px;
    z-index: 100;
    background-color: {{ popup_bg }};
    color: {{ popup_title_color }};
    padding: 7px 10px;
    border-radius: 10px;
    font-size: 14px;
    box-shadow: 0 4px 10px #00000041;
  }

  .notification-cart-reopen-container button {
    background: none;
    border: none;
    color: {{ popup_title_color }};
    cursor: pointer;
    font-size: 13px;
    font-weight: bold;
    text-align: left;
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .popup-btn-img {
    width: 35px;
    height: 35px;
    flex-shrink: 0;
  }

  .popup-btn-texts {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
  }

  .popup-btn-title {
    font-size: 13px;
    line-height: 1.1;
    color: {{ popup_title_color }};
  }

  .popup-btn-subtitle {
    font-size: 15px;
    font-weight: bold;
    line-height: 1.1;
    color: {{ popup_subtitle_color }};
  }

  .popup-error-message {
    margin-top: 8px;
    font-size: 12px;
    color: {{ popup_error_color }};
    display: none;
  }

  .p-closed {
    display: none !important;
  }
</style>

{% if settings.home_popup_button_show %}
<div class="notification-cart-reopen-container" id="notification-cart-reopen-container">
  <button>
    {% if 'home_popup_button_image.jpg' | has_custom_image %}
      <img src="{{ 'home_popup_button_image.jpg' | static_url }}" alt="Botão" class="popup-btn-img">
    {% endif %}
    <span class="popup-btn-texts">
      <span class="popup-btn-title">{{ settings.home_popup_button_title }}</span>
      <span class="popup-btn-subtitle">{{ settings.home_popup_button_subtitle }}</span>
    </span>
  </button>
  <div class="popup-error-message" id="popup-error">Erro, recarregue a página.</div>
</div>
{% endif %}

{# <script>
  document.addEventListener("DOMContentLoaded", function () {
    const container = document.getElementById('reabrir-container');
    const botaoReabrir = document.getElementById('reabrir-popup');
    const mensagemErro = document.getElementById('popup-error');

    const POPUP_KEY = 'PerfitOptinRulesExecInfo';

    const encontrarPopup = () => document.querySelector('.p-layer');
    const mostrarBotao = () => container.style.display = 'block';
    const esconderBotao = () => container.style.display = 'none';

    const mostrarErro = () => {
      mensagemErro.style.display = 'block';
      setTimeout(() => {
        mensagemErro.style.display = 'none';
      }, 3000);
    };

    const removerEstadoDoPopup = () => {
      if (localStorage.getItem(POPUP_KEY)) {
        localStorage.removeItem(POPUP_KEY);
        console.log(`LocalStorage "${POPUP_KEY}" removido.`);
      }
    };

    const observer = new MutationObserver(() => {
      const popup = encontrarPopup();
      if (!popup || popup.classList.contains('p-closed') || popup.style.display === 'none') {
        mostrarBotao();
      } else {
        esconderBotao();
      }
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ['class', 'style']
    });

    botaoReabrir.addEventListener('click', () => {
      removerEstadoDoPopup();

      // Espera um pouco para que o app da Nuvem possa reavaliar e reexibir o popup
      setTimeout(() => {
        const popup = encontrarPopup();

        if (popup) {
          popup.style.display = 'block';
          popup.classList.remove('p-closed');
          popup.classList.add('p-opened');
          esconderBotao();
        } else {
          mostrarErro();
        }
      }, 500);
    });
  });
</script> #}

<!-- Optin - Inicio -->
<div id="optin-IIw6HlBv" data-type="button"></div>
<link rel="stylesheet" type="text/css" href="https://optin.myperfit.com/res/css/eoraeyewear/IIw6HlBv.css"/>
<script type="text/javascript" src="https://optin.myperfit.com/res/js/eoraeyewear/IIw6HlBv.js" charset="UTF-8"></script>
<!-- Optin - Fin -->

<script>
  window.onload = () => {
    const button = document.querySelector("#notification-cart-reopen-container");

    function showPopup() {
      const buttonHide = document.querySelector("#p-open");
      buttonHide.click()
    }

    button.addEventListener("click", showPopup);
  }
</script>