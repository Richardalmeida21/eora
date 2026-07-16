{#
    Martz Tag Manager (variante compatível com GA4/GTM).
    Este snippet deve permanecer depois de head_content, pois a Martz precisa ser
    inicializada depois do container do Google Tag Manager.
#}
<script src="https://mtm.martzapis.com.br/datalayer/v1/MTZY8ZSR0QQR-gtm.js" async></script>

{% if customer %}
    <script>
        window.dataLayer = window.dataLayer || [];
        window.dataLayer.push({
            event: 'martz_identity',
            user_id: '{{ customer.id | escape("js") }}',
            email: '{{ customer.email | escape("js") }}'
        });
    </script>
{% endif %}
