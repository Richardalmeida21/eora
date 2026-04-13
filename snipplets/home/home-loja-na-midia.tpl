<h3>loja_media_show {{ settings.loja_media_show |json_encode}}</h3>

<div class="kings-na-midia container-fluid">
    <div class="row">
        {% if settings.loja_media_title %}
            <div class="col-6 align-items-center d-flex">
                <h2 class="section-title-products-home">{{ settings.loja_media_title }}</h2>
            </div>
        {% endif %}
        {% if settings.loja_media_link %}
            <div class="col-6 d-flex justify-content-end">
                <a href="{{ settings.loja_media_link }}" class="btn-link">VER TUDO</a>
            </div>
        {% endif %}
        <div class="col-12">
            <div class="kings-na-midia__content">
                <div class="kings-na-midia__content__item">
                    <div class="kings-na-midia__content__item__image">
                        <figure class="image -square">
                            <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "loja_media_01.jpg" | static_url | settings_image_url('large') }} 480w, {{ "loja_media_01.jpg" | static_url | settings_image_url('huge') }} 640w, {{ "loja_media_01.jpg" | static_url | settings_image_url('original') }} 1024w, {{ "loja_media_01.jpg" | static_url | settings_image_url('1080p') }} 1920w' class='lazyload'/>
                        </figure>
                    </div>
                    <div class="kings-na-midia__content__item__text">
                        <h4 class="kings-na-midia__content__item__text__title">
                            {{ settings.loja_media_01_title }}
                        </h4>

                        <p class="kings-na-midia__content__item__text__description line-clamp-3">
                            {{ settings.loja_media_01_text }}
                        </p>
                    </div>
                </div>
                <div class="kings-na-midia__content__item">
                    <div class="kings-na-midia__content__item__image">
                        <figure class="image -square">
                            <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "loja_media_02.jpg" | static_url | settings_image_url('large') }} 480w, {{ "loja_media_02.jpg" | static_url | settings_image_url('huge') }} 640w, {{ "loja_media_02.jpg" | static_url | settings_image_url('original') }} 1024w, {{ "loja_media_02.jpg" | static_url | settings_image_url('1080p') }} 1920w' class='lazyload'/>
                        </figure>
                    </div>
                    <div class="kings-na-midia__content__item__text">
                        <h4 class="kings-na-midia__content__item__text__title">
                            {{ settings.loja_media_02_title }}
                        </h4>
                        <p class="kings-na-midia__content__item__text__description line-clamp-3">
                            {{ settings.loja_media_02_text }}
                        </p>
                    </div>
                </div>
                <div class="kings-na-midia__content__item">
                    <div class="kings-na-midia__content__item__image">
                        <figure class="image -square">
                            <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "loja_media_03.jpg" | static_url | settings_image_url('large') }} 480w, {{ "loja_media_03.jpg" | static_url | settings_image_url('huge') }} 640w, {{ "loja_media_03.jpg" | static_url | settings_image_url('original') }} 1024w, {{ "loja_media_03.jpg" | static_url | settings_image_url('1080p') }} 1920w' class='lazyload'/>
                        </figure>
                    </div>
                    <div class="kings-na-midia__content__item__text">
                        <h4 class="kings-na-midia__content__item__text__title">
                            {{ settings.loja_media_03_title }}
                        </h4>
                        <p class="kings-na-midia__content__item__text__description line-clamp-3">                            
                            {{ settings.loja_media_03_text }}
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>