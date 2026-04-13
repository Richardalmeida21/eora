{# Banner inferior 2 #}
{% if settings.behind_lens_page_banner_bottom_segundo and settings.behind_lens_page_banner_bottom_img_segundo %}
    <section class="section-home banner-inferior-section">
        <div class="container-fluid">
            {% for banner in settings.behind_lens_page_banner_bottom_img_segundo %}
                <div class="banner-inferior-item">
                    <div class="banner-header">
                        <div class="header-dots">
                            <span class="dot dot-red"></span>
                            <span class="dot dot-yellow"></span>
                            <span class="dot dot-green"></span>
                        </div>
                        <h2 class="header-title">EORA.jpg</h2>
                        <div class="header-spacer"></div>
                    </div>
                    {% if banner.link %}
                        <a href="{{ banner.link | setting_url }}" title="{{ banner.title | default(store.name) }}" aria-label="{{ banner.title | default(store.name) }}">
                    {% endif %}
                        <img src="{{ banner.image | static_url | settings_image_url('1080p') }}" 
                             class="banner-inferior-img" 
                             alt="{{ banner.title | default('Banner ' ~ loop.index) }}">
                        {% if banner.title and banner.title != '' %}
                            <div class="banner-inferior-content">
                                <h3 class="banner-inferior-title">{{ banner.title }}</h3>
                                {% if banner.description and banner.description != '' %}
                                    <p class="banner-inferior-description">{{ banner.description }}</p>
                                {% endif %}
                            </div>
                        {% endif %}
                    {% if banner.link %}
                        </a>
                    {% endif %}
                </div>
            {% endfor %}
        </div>
    </section>
{% endif %}