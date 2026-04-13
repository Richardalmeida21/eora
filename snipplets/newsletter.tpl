{% set newsletter_contact_error = contact.type == 'newsletter' and not contact.success %}
{% set show_footer_logo = "footer_logo.jpg" | has_custom_image %}


{% if settings.news_show %}
    <div class="js-newsletter newsletter ">
        <div class="d-flex flex-column w-100" style="max-width:600px;">
            {% if show_footer_logo %}
                <div class="logo-newsletter text-center mb-2">
                    <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ 'footer_logo.jpg' | static_url('original') }}" alt="{{ store.name }}" title="{{ store.name }}" class="img-fluid lazyload">
                </div>
            {% endif %}
            {% if settings.news_description %}
                <div class="title-newsletter mb-3">{{ settings.news_description }}</div>
            {% endif %}
            <form class="js-newsletter-form w-100" method="post" action="/winnie-pooh" onsubmit="this.setAttribute('action', '');" data-store="newsletter-form">
                <div class="newsletter-form input-append d-flex flex-column w-100" style="gap:16px;">
                        <div class="input-group w-100 position-relative">
                            {% embed "snipplets/forms/form-input.tpl" with{
                                input_for: 'email',
                                type_email: true,
                                input_name: 'email',
                                input_id: 'email',
                                input_placeholder: 'E-mail:',
                                input_group_custom_class: 'mb-0',
                                input_custom_class: 'form-control-line',
                                input_aria_label: 'Endereço de e-mail para newsletter'
                            } %}
                            {% endembed %}
                            <button type="submit" name="contact"
                                class="btn position-absolute"
                                style="background:none; border:none; color: #000; font-size:15px; font-weight:700; text-decoration:underline; right:15px; top:50%; transform:translateY(-50%); z-index:10; margin:0; cursor:pointer; min-width:48px; min-height:48px;">
                                Inscrever-se
                            </button>
                        </div>
                    <!-- Checkbox de política de privacidade removido conforme solicitado -->
                    <div class="winnie-pooh" style="display: none;>
                        <label for="winnie-pooh-newsletter">{{ "No completar este campo" | translate }}</label>
                        <input id="winnie-pooh-newsletter" type="text" name="winnie-pooh"/>
                    </div>
                    <input type="hidden" name="message" value="{{ "Pedido de inscripción a newsletter" | translate }}" />
                    <input type="hidden" name="type" value="newsletter" />
                </div>
            </form>
            {% if contact and contact.type == 'newsletter' %}
                {% if contact.success %}
                    <div class="alert alert-success mt-3">{{ "¡Gracias por suscribirte! A partir de ahora vas a recibir nuestras novedades en tu email" | translate }}</div>
                {% else %}
                    <div class="alert alert-danger mt-3">{{ "Necesitamos tu email para enviarte nossas novidades." | translate }}</div>
                {% endif %}
            {% endif %}
            {% if settings.news_description_confirmation %}
                <div class="title-newsletter mt-2">{{ settings.news_description_confirmation }}</div>
            {% endif %}
        </div>
    </div>
{% endif %}