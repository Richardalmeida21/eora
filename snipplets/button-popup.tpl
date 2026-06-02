{% set popup_bg = settings.home_popup_background_color 
  ? settings.home_popup_background_color ~ '30' 
  : '#2F1A8330' %}{% set popup_title_color = settings.home_popup_text_title_color | default('#ffffff') %}
{% set popup_subtitle_color = settings.home_popup_text_subtitle_color | default('#ffffff') %}
{% set popup_error_color = settings.home_popup_mensagem_error_color | default('#ff5555') %}

<style>
  div#optin-IIw6HlBv > #p-open {
    display: none;
  }

  .p-layer {
    position: fixed;
    inset: 0;
    overflow: auto;
    z-index: 20000;
    background: transparent;
  }

  .p-layer.p-opened {
    display: flex !important;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    padding: 16px;
    background: rgba(0, 0, 0, 0.5);
  }

  .p-layer .p-close-layer {
    position: absolute;
    inset: 0;
  }

  .p-layer .p-optin {
    position: relative;
    z-index: 1;
    width: calc(100vw - 32px);
    max-width: 560px;
    max-height: calc(100vh - 32px);
    margin: auto;
    overflow: auto;
    border-radius: 7px;
    background: #000;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.22);
  }

  #optin-form-IIw6HlBv {
    color: #fff;
  }

  #optin-form-IIw6HlBv > .p-close,
  #optin-form-IIw6HlBv .eora-perfit-fallback-close {
    position: absolute !important;
    top: 10px !important;
    right: 10px !important;
    z-index: 20 !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    width: 36px !important;
    height: 36px !important;
    padding: 0 !important;
    margin: 0 !important;
    border: 0 !important;
    border-radius: 999px !important;
    background: rgba(255, 255, 255, 0.92) !important;
    color: #000 !important;
    font-family: Arial, sans-serif !important;
    font-size: 26px !important;
    font-weight: 400 !important;
    line-height: 1 !important;
    cursor: pointer !important;
    box-shadow: 0 3px 12px rgba(0, 0, 0, 0.18) !important;
  }

  #optin-form-IIw6HlBv .p-body {
    background: #000;
    color: #fff;
  }

  #optin-form-IIw6HlBv.p-layout-topImage .p-grid {
    display: grid;
    grid-template-rows: minmax(140px, 220px) auto;
  }

  #optin-form-IIw6HlBv.p-layout-topImage .p-col-image {
    display: block !important;
    min-height: 140px;
    background-position: center;
    background-repeat: no-repeat;
    background-size: cover;
  }

  #optin-form-IIw6HlBv.p-layout-topImage .p-col-form {
    position: relative;
    padding: 24px 22px 30px;
  }

  #optin-form-IIw6HlBv .p-success {
    position: static !important;
    display: flex !important;
    align-items: center;
    justify-content: center;
    min-height: 120px;
    margin: 0 !important;
    color: #fff !important;
    text-align: center;
    font-size: 16px;
    font-weight: 600;
    line-height: 1.35;
  }

  .notification-cart-reopen-container {
    position: fixed;
    bottom: 20px !important;
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

  .p-closed,
  .p-layer.p-closed {
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
  (function () {
    var optinId = 'IIw6HlBv';
    var formId = 'optin-form-' + optinId;
    var reopenId = 'notification-cart-reopen-container';
    var dismissedKey = 'eora_perfit_optin_dismissed_' + optinId;
    var retryTimer = null;
    var retryAttempts = 0;

    function safeSessionGet(key) {
      try {
        return window.sessionStorage ? window.sessionStorage.getItem(key) : null;
      } catch (error) {
        return null;
      }
    }

    function safeSessionSet(key, value) {
      try {
        if (window.sessionStorage) window.sessionStorage.setItem(key, value);
      } catch (error) {}
    }

    function safeSessionRemove(key) {
      try {
        if (window.sessionStorage) window.sessionStorage.removeItem(key);
      } catch (error) {}
    }

    function isDismissed() {
      return safeSessionGet(dismissedKey) === '1';
    }

    function setDismissed(value) {
      if (value) safeSessionSet(dismissedKey, '1');
      else safeSessionRemove(dismissedKey);
    }

    function cancelRetries() {
      if (retryTimer) {
        clearTimeout(retryTimer);
        retryTimer = null;
      }
      retryAttempts = 0;
    }

    function getApi() {
      return window.PerfitOptIn && window.PerfitOptIn[optinId];
    }

    function getForm() {
      return document.getElementById(formId);
    }

    function getLayer() {
      var form = getForm();
      return form ? form.closest('.p-layer') : document.querySelector('.p-layer');
    }

    function showPopupError() {
      var error = document.getElementById('popup-error');
      if (!error) return;

      error.style.display = 'block';
      setTimeout(function () {
        error.style.display = 'none';
      }, 3000);
    }

    function ensureCloseButton() {
      var form = getForm();
      var layer = getLayer();

      if (!form) return;

      if (!form.querySelector('.p-close')) {
        var closeButton = document.createElement('button');
        closeButton.type = 'button';
        closeButton.className = 'p-close eora-perfit-fallback-close';
        closeButton.setAttribute('aria-label', 'Fechar popup');
        closeButton.textContent = '\u00d7';
        form.insertBefore(closeButton, form.firstChild);
      }

      if (layer) {
        layer.classList.add('eora-perfit-ready');
      }
    }

    function forceHidePopup() {
      var layer = getLayer();
      if (layer) {
        if (layer.classList.contains('p-opened')) {
          layer.classList.remove('p-opened');
        }
        if (!layer.classList.contains('p-closed')) {
          layer.classList.add('p-closed');
        }
        if (layer.style.display !== 'none') {
          layer.style.display = 'none';
        }
      }
      if (document.body.classList.contains('p-popup-open')) {
        document.body.classList.remove('p-popup-open');
      }
    }

    function closePopup(event) {
      if (event) {
        event.preventDefault();
        event.stopPropagation();
      }

      setDismissed(true);
      cancelRetries();

      var api = getApi();
      if (api && typeof api.close === 'function') {
        try {
          api.close(event || {});
        } catch (error) {}
      }

      forceHidePopup();
    }

    function openPopup(event) {
      if (event) {
        event.preventDefault();
        event.stopPropagation();
      }

      if (!event && isDismissed()) {
        cancelRetries();
        forceHidePopup();
        return;
      }

      var api = getApi();
      if (api && typeof api.open === 'function') {
        api.open(event || {});
        setTimeout(ensureCloseButton, 50);
        return;
      }

      var nativeButton = document.getElementById('p-open');
      if (nativeButton) {
        nativeButton.click();
        setTimeout(ensureCloseButton, 50);
        return;
      }

      var layer = getLayer();
      if (layer) {
        layer.style.display = 'flex';
        layer.classList.remove('p-closed');
        layer.classList.add('p-opened');
        document.body.classList.add('p-popup-open');
        ensureCloseButton();
        return;
      }

      if (retryAttempts < 10 && !retryTimer) {
        retryAttempts += 1;
        retryTimer = setTimeout(function () {
          retryTimer = null;
          openPopup();
        }, 300);
      } else {
        showPopupError();
      }
    }

    window.eoraAllowPerfitPopupOpen = function () {
      setDismissed(false);
      cancelRetries();
    };

    function bindPopupSafety() {
      ensureCloseButton();

      document.addEventListener('click', function (event) {
        if (!event.target || !event.target.closest) return;

        if (event.target.closest('#' + reopenId)) {
          setDismissed(false);
          cancelRetries();
          openPopup(event);
          return;
        }

        if (event.target.closest('.p-layer .p-close, .p-layer .p-close-layer')) {
          closePopup(event);
        }
      }, true);

      if (window.MutationObserver && document.body) {
        var observer = new MutationObserver(function () {
          ensureCloseButton();
          if (isDismissed()) forceHidePopup();
        });
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });
      }
    }

    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', bindPopupSafety);
    } else {
      bindPopupSafety();
    }
  })();
</script>
