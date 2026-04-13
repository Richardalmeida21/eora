{# <h4>complementary_product_list =>{{complementary_product_list[0]|json_encode}}</h4> #}
<div class="js-product-variants 
    {% if quickshop %}js-product-quickshop-variants{% endif %} 
    form-row 
    {% if settings.bullet_variants %}mb-3{% else %}mb-3{% endif %}">
    
    {% if settings.product_by_reference_colors %}
        {% set product_bg_color = '' %}
        {% set product_bg_color_name = '' %}
        {% for item in product.tags %}
            {% set item_tag = item.tag %}
            {% if item_tag starts with 'produto-gradiente:' %}
                {% set parts = item_tag|split(':') %}
                {% set colors = parts[1]|split('-') %}
                {% set qtd_colors = colors|length %}
                {# gera um gradiente conforme a quantidade de colors #}
                {% if qtd_colors == 1 %}
                    {% set product_bg_color = colors[0] %}
                {% elseif qtd_colors == 2 %}
                    {% set product_bg_color = 'linear-gradient(180deg,' ~ colors[0] ~ ',' ~ colors[1] ~ ')' %}
                {% elseif qtd_colors >= 3 %}
                    {% set product_bg_color = 'linear-gradient(180deg,' ~ colors|join(',') ~ ')' %}
                {% endif %}
                {% set parts_2 = item_tag|split(';') %}
                {% set product_bg_color_name = parts_2[1] %}
                <p class="insta-variation-label">{{ product_bg_color_name }}</p>
            {% endif %}
        {% endfor %}
    {% endif %}

    {% if settings.product_by_reference %}
        <div class="js-product-variants-group js-color-variants-container col-12 mb-2">
            
            {# Criar uma nova lista incluindo o produto atual e os complementares #}
            {% set newList = [] %}
            
            {# Adicionar o produto atual à lista primeiro #}
            {% set current_product_colors = [] %}
            {% set current_first_color = '' %}
            {% for item in current_product.tags %}
                {% set item_tag = item.tag %}
                {% if item_tag starts with 'produto-gradiente:' %}
                    {% set parts = item_tag|split(':') %}
                    {% set colors = parts[1]|split('-') %}
                    {% set current_product_colors = colors %}
                    {% set current_first_color = colors[0] ?? '' %}
                {% endif %}
            {% endfor %}
            {% set newList = newList|merge([{
                'product': current_product,
                'colors': current_product_colors,
                'first_color': current_first_color,
                'is_current': true
            }]) %}
            
            {# Criar lista com produtos complementares e suas cores extraídas para ordenação #}
            {% for product in complementary_product_list %}
                {% set product_colors = [] %}
                {% set first_color = '' %}
                {% for item in product.tags %}
                    {% set item_tag = item.tag %}
                    {% if item_tag starts with 'produto-gradiente:' %}
                        {% set parts = item_tag|split(':') %}
                        {% set colors = parts[1]|split('-') %}
                        {% set product_colors = colors %}
                        {% set first_color = colors[0] ?? '' %}
                    {% endif %}
                {% endfor %}
                {% set newList = newList|merge([{
                    'product': product,
                    'colors': product_colors,
                    'first_color': first_color,
                    'is_current': false
                }]) %}
            {% endfor %}
            
            {# Ordenar a lista completa (produto atual + complementares) pela primeira cor #}
            {% set sortedList = newList|sort(item => item.first_color) %}
            
            {# Usar a lista ordenada para renderizar todos os produtos #}
            {% for item in sortedList %}
                {% set product_variant_var = item.product %}
                {% set is_current = item.is_current %}
                
                {% if settings.product_by_reference_colors %}
                    {% set product_bg_color_variant = '' %}
                    {% set product_bg_color_variant_name = '' %}
                    {% for product_tag in product_variant_var.tags %}
                        {% set item_tag = product_tag.tag %}
                        {% if item_tag starts with 'produto-gradiente:' %}
                            {% set parts = item_tag|split(':') %}
                            {% set colors = parts[1]|split('-') %}
                            {% set qtd_colors = colors|length %}
                            {# gera um gradiente conforme a quantidade de colors #}
                            {% if qtd_colors == 1 %}
                                {% set product_bg_color_variant = colors[0] %}
                            {% elseif qtd_colors == 2 %}
                                {% set product_bg_color_variant = 'linear-gradient(180deg,' ~ colors[0] ~ ',' ~ colors[1] ~ ')' %}
                            {% elseif qtd_colors >= 3 %}
                                {% set product_bg_color_variant = 'linear-gradient(180deg,' ~ colors|join(',') ~ ')' %}
                            {% endif %}
                        {% endif %}
                    {% endfor %}
                {% endif %}
                
                <a href="{{ product_variant_var.url }}" target="_top" class="btn btn-variant btn-variant-color{% if is_current %} selected{% endif %}" title="{{ product_variant_var.name }}">
                    {% set class_variant = settings.product_by_reference_colors ? 'btn-variant-content-color': 'btn-variant-content-square' %}
                    <span class="btn-variant-content {{ class_variant }}" data-name="{{ product_variant_var.name }}"
                        {% if settings.product_by_reference_colors %}
                            style="background: {{ product_bg_color_variant }};"
                        {% else %}
                            style="display:none;"
                        {% endif %}>
                        {% if not settings.product_by_reference_colors %}
                            {% for image in product_variant_var.images|slice(0, 1) %}
                                <img src="{{ 'images/empty-placeholder.png' | static_url }}"
                                    data-src="{{ image | product_image_url('thumb')}}"
                                    data-sizes="auto"
                                    class="lazyload img-absolute-centered-vertically"
                                    {% if image.alt %}alt="{{image.alt}}"{% endif %} />
                            {% endfor %}
                        {% endif %}
                    </span>
                </a>
            {% endfor %}
        </div>
    {% endif %}

    {% set has_size_variations = false %}
    {% if settings.bullet_variants %}
        {% set hidden_variant_select = ' d-none' %}
    {% endif %}

    {% for variation in product.variations %}
        {% if variation.name in ['Talle', 'Talla', 'Tamanho', 'Size'] %}
            {% set has_size_variations = true %}
        {% endif %}
        {% set is_hidden_select = false %}
        {% if settings.image_color_variants and not (settings.bullet_variants) %}
            {% if variation.name in ['Color', 'Cor'] %}
                {% set hidden_variant_select = ' d-none' %}
                {% set is_hidden_select = true %}
            {% else %}
                {% set hidden_variant_select = ' d-block' %}
            {% endif %}
        {% endif %}
        {% set is_button_variant = settings.bullet_variants or (settings.image_color_variants and variation.name in ['Color', 'Cor']) %}
        <div class="js-product-variants-group
            {% if variation.name in ['Color', 'Cor'] %}js-color-variants-container{% endif %}
            {% if settings.bullet_variants or settings.image_color_variants %}col-12 {% if is_hidden_select or settings.bullet_variants %}mb-0{% endif %}{% endif %}
            {% if is_button_variant and show_size_guide and settings.size_guide_url and has_size_variations and loop.last %}mb-0{% endif %}
            {% if not is_button_variant %}
                {% if loop.length == 1 or loop.length == 3 or settings.image_color_variants %}col-md-8{% else %}col-6{% endif %}
            {% endif %}"
            data-variation-id="{{ variation.id }}">
            
            {% if quickshop %}
                {% embed "snipplets/forms/form-select.tpl" with{
                    select_label: true,
                    select_label_name: '' ~ variation.name ~ '',
                    select_for: 'variation_' ~ loop.index,
                    select_id: 'variation_' ~ loop.index,
                    select_name: 'variation' ~ '[' ~ variation.id ~ ']',
                    select_group_custom_class: hidden_variant_select,
                    select_custom_class: 'js-variation-option js-refresh-installment-data'
                } %}
                    {% block select_options %}
                        {% for option in variation.options %}
                        {% set is_coach_layout = product.handle == 'mini-vertice-nova' %}
                            <option value="{{ option.id }}" {% if product.default_options[variation.id] is same as(option.id) %}selected="selected"{% endif %}>{{ option.name }}</option>
                        {% endfor %}
                    {% endblock select_options %}
                {% endembed %}
            {% else %}
                {% embed "snipplets/forms/form-select.tpl" with{
                    select_label: true,
                    select_label_name: '' ~ variation.name ~ '',
                    select_for: 'variation_' ~ loop.index,
                    select_id: 'variation_' ~ loop.index,
                    select_name: 'variation' ~ '[' ~ variation.id ~ ']',
                    select_custom_class: 'js-variation-option js-refresh-installment-data',
                    select_group_custom_class: hidden_variant_select
                } %}
                    {% block select_options %}
                        {% for option in variation.options %}
                            <option value="{{ option.id }}" {% if product.default_options[variation.id] is same as(option.id) %}selected="selected"{% endif %}>{{ option.name }}</option>
                        {% endfor %}
                    {% endblock select_options %}
                {% endembed %}
            {% endif %}

            {% if is_button_variant and not settings.use_only_variant_product_by_reference %}
                {% if settings.show_label_variant %}
                    <label class="form-label mb-2">
                        <strong class="js-insta-variation-label">{{ product.default_options[variation.id] }}</strong>
                    </label>
                {% endif %}
                {% set variants_size = variation.options | length %}
                <div class="variation-options-wrapper">
                    {% for option in variation.options %}
                        <a data-option="{{ option.id }}"
                           class="js-insta-variant btn btn-variant m-0
                                {% if variants_size == 1 %} d-none{% endif %}
                                {% if product.default_options[variation.id] is same as(option.id) %} selected{% endif %}
                                {% if variation.name in ['Color', 'Cor'] %}
                                    {% if option.custom_data or settings.image_color_variants %}btn-variant-color{% endif %} p-0
                                    {% if is_coach_layout %} coach-layout-swatch{% endif %}
                                {% endif %}"
                           title="{{ option.name }}"
                           data-option="{{ option.id }}"
                           data-variation-id="{{ variation.id }}">
                            <span class="btn-variant-content
                                {% if (settings.image_color_variants or is_coach_layout) and variation.name in ['Color', 'Cor'] %} btn-variant-content-square{% endif %}
                                {% if is_coach_layout and variation.name in ['Color', 'Cor'] %} js-coach-variant-square{% endif %}"
                                {% if option.custom_data and variation.name in ['Color', 'Cor'] and (settings.bullet_variants and not settings.image_color_variants) and not is_coach_layout %}
                                    style="background: {{ option.custom_data }}; border: 1px solid #eee"
                                {% endif %}
                                data-name="{{ option.name }}">
                                {% if settings.image_color_variants and variation.name in ['Color', 'Cor'] %}
                                    {% if product.default_options[variation.id] is same as(option.id) %}
                                        <img src="{{ 'images/empty-placeholder.png' | static_url }}"
                                             data-src="{{ product.featured_variant_image | product_image_url('thumb')}}"
                                             data-sizes="auto"
                                             class="lazyload img-absolute-centered-vertically"
                                             {% if image.alt %}alt="{{image.alt}}"{% endif %} />
                                    {% else %}
                                        {% for variant in product.variants if (variant.option1 == option.id) or (variant.option2 == option.id) or (variant.option3 == option.id) %}
                                            {% if loop.first %}
                                                <img src="{{ 'images/empty-placeholder.png' | static_url }}"
                                                     data-src="{{ variant.image | product_image_url('thumb') }}"
                                                     data-sizes="auto"
                                                     class="lazyload img-absolute-centered-vertically" />
                                            {% endif %}
                                        {% endfor %}
                                    {% endif %}
                                {% endif %}
                                {% if not(variation.name in ['Color', 'Cor']) or ((variation.name in ['Color', 'Cor']) and not option.custom_data and not settings.image_color_variants and not is_coach_layout) %}
                                    {{ option.name }}
                                {% endif %}
                            </span>
                        </a>
                    {% endfor %}
                </div>
            {% endif %}
        </div>
    {% endfor %}

    {% if show_size_guide and settings.size_guide_url and has_size_variations %}
        {% set has_size_guide_page_finded = false %}
        {% set size_guide_url_handle = settings.size_guide_url | trim('/') | split('/') | last %}
        {% for page in pages if page.handle == size_guide_url_handle and not has_size_guide_page_finded %}
            {% set has_size_guide_page_finded = true %}
            {% if has_size_guide_page_finded %}
                <a data-toggle="#size-guide-modal"
                   data-modal-url="modal-fullscreen-size-guide"
                   class="tabela-de-medidas js-modal-open js-fullscreen-modal-open col-12 pb-2
                        {% if settings.bullet_variants %}mt-0 mb-2{% endif %}">
                    <svg width="14" height="15" viewBox="0 0 14 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M1.3125 12.5C1.3125 12.7461 1.50391 12.9375 1.75 12.9375H12.1406L10.3086 11.1328L9.92578 11.5156C9.76172 11.6797 9.46094 11.6797 9.29688 11.5156C9.13281 11.3516 9.13281 11.0508 9.29688 10.8867L9.67969 10.5039L8.12109 8.94531L7.73828 9.32812C7.57422 9.49219 7.27344 9.49219 7.10938 9.32812C6.94531 9.16406 6.94531 8.86328 7.10938 8.69922L7.49219 8.31641L5.93359 6.75781L5.55078 7.14062C5.38672 7.30469 5.08594 7.30469 4.92188 7.14062C4.75781 6.97656 4.75781 6.67578 4.92188 6.51172L5.30469 6.12891L3.74609 4.57031L3.36328 4.95312C3.19922 5.11719 2.89844 5.11719 2.73438 4.95312C2.57031 4.78906 2.57031 4.48828 2.73438 4.32422L3.11719 3.94141L1.3125 2.10938V12.5ZM13.7266 12.6914C13.8906 12.8555 14 13.0742 14 13.3203V13.375C14 13.8672 13.5898 14.25 13.125 14.25H1.75C0.765625 14.25 0 13.4844 0 12.5V1.125C0 0.660156 0.382812 0.25 0.875 0.25H0.929688C1.17578 0.25 1.39453 0.359375 1.55859 0.523438L13.7266 12.6914ZM3.5 7.25L7 10.75H3.5V7.25Z" fill="black"/>
                    </svg>
                    <span class="btn-link font-small">{{ 'Guía de talles' | translate }}</span>
                </a>
                {% embed "snipplets/modal.tpl" with{
                    modal_id: 'size-guide-modal',
                    modal_class: 'bottom-md',
                    modal_position: 'right modal-centered-md',
                    modal_transition: 'slide',
                    modal_header_title: true,
                    modal_width: 'centered',
                    modal_mobile_full_screen: 'true'
                } %}
                    {% block modal_head %}
                        {{ 'Guía de talles' | translate }}
                    {% endblock %}
                    {% block modal_body %}
                        <div class="user-content">
                            {{ page.content }}
                        </div>
                    {% endblock %}
                {% endembed %}
            {% endif %}
        {% endfor %}
    {% endif %}
</div>