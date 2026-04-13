{# Banner inferior 1 #}
{% if settings.behind_lens_page_banner_bottom_primeiro and settings.behind_lens_page_banner_bottom_img_primeiro %}
    <section class="section-home banner-inferior-section">
        <div class="container-fluid">
            {% for banner in settings.behind_lens_page_banner_bottom_img_primeiro %}
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

<style>
.banner-inferior-section {
    margin: 40px 0;
}

.banner-header {
    display: flex;
    align-items: center;
    background: #d5d5d5;
    padding: 12px 20px;
}

.header-dots {
    display: flex;
    gap: 8px;
    margin-right: 20px;
}

.dot {
    width: 13px;
    height: 13px;
    border-radius: 50%;
}

.dot-red {
    background-color: #b6b6b6ff;
}

.dot-yellow {
    background-color: #b6b6b6ff;
}

.dot-green {
    background-color: #b6b6b6ff;
}

.header-title {
    color: #333;
    font-size: 16px;
    font-weight: 600;
    margin: 0;
    flex: 1;
    text-align: center;
    letter-spacing: 1px;
}

.header-spacer {
    width: 76px; /* Para balancear o espaço das bolinhas */
}

.banner-inferior-section .container-fluid {
    display: flex;
    gap: 20px;
    flex-wrap: wrap;
    justify-content: center;
    align-items: stretch;
}

.banner-inferior-item {
    position: relative;
    min-width: 350px;
    overflow: hidden;
    background: #fff;
    border-radius: 15px;
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
    border: 3px solid #d5d5d5;
    transition: all 0.3s ease;
    height: 450px;
    display: flex;
    flex-direction: column;
    flex: 1;
    max-width: 400px;
}

.banner-inferior-item a {
    display: block;
    text-decoration: none;
    color: inherit;
}

.banner-inferior-img {
    width: 100%;
    height: calc(100% - 44px); /* Altura total menos o header */
    object-fit: cover;
    object-position: center;
    display: block;
    transition: transform 0.3s ease;
    border-radius: 0 0 12px 12px;
    margin: 0;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.banner-inferior-item:hover {
    transform: translateY(-5px);
    box-shadow: 0 12px 35px rgba(0, 0, 0, 0.25);
}

.banner-inferior-content {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    background: linear-gradient(transparent, rgba(0,0,0,0.7));
    color: white;
    padding: 30px 20px 20px;
    text-align: center;
}

.banner-inferior-title {
    font-size: 24px;
    font-weight: bold;
    margin: 0 0 10px 0;
    line-height: 1.2;
}

.banner-inferior-description {
    font-size: 14px;
    margin: 0;
    opacity: 0.9;
    line-height: 1.4;
}

@media (max-width: 768px) {
    .banner-inferior-section {
        margin: 20px 0;
    }
    
    .banner-inferior-section .container-fluid {
        flex-direction: column;
        gap: 15px;
        justify-content: center;
        align-items: center;
    }
    
    .banner-inferior-item {
        min-width: auto;
        height: 380px;
    }
    
    .banner-inferior-content {
        padding: 20px 15px 15px;
    }
    
    .banner-inferior-title {
        font-size: 18px;
    }
    
    .banner-inferior-description {
        font-size: 12px;
    }
}
</style>