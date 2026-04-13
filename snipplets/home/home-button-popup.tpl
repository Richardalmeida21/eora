<style>
  #reabrir-popup {
    display: none;
    position: fixed;
    bottom: 20px;
    left: 20px;
    z-index: 9999;
    background-color: #000;
    color: #fff;
    padding: 12px 16px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
  }
</style>

<div id="reabrir-popup">📩 Reabrir pop-up</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
    const botaoReabrir = document.getElementById('reabrir-popup');

    function encontrarPopup() {
        return document.querySelector('.p-layer');
    }

    function mostrarBotao() {
        botaoReabrir.style.display = 'block';
    }

    function esconderBotao() {
        botaoReabrir.style.display = 'none';
    }

    // Monitora alterações no DOM (inclusive se popup for removido)
    const observer = new MutationObserver(() => {
        const popup = encontrarPopup();

        if (!popup) {
            // Popup sumiu do DOM
            mostrarBotao();
            return;
        }

        // Verifica se tem a classe "p-closed"
        if (popup.classList.contains('p-closed')) {
            mostrarBotao();
        } else {
            esconderBotao();
        }
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ['class']
    });

    // Reabrir o popup ao clicar no botão
    botaoReabrir.addEventListener('click', function () {
        const popup = encontrarPopup();

        if (popup) {
            popup.classList.remove('p-closed');
            popup.classList.add('p-opened');
            esconderBotao();
        } else {
            // Se o popup foi removido do DOM, tenta recarregá-lo via reload (alternativa)
            location.reload();
        }
    });
});
</script>
