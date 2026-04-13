{# Garantia Eora Page - Simplified #}

<style>
    /* Video Cards - Sem Carrossel Desktop */
    @media screen and (min-width: 769px) {
        .ge-video-carousel-container {
            padding: 0 !important;
        }
        
        .ge-carousel-btn {
            display: none !important;
        }
        
        .ge-video-carousel-wrapper {
            overflow: visible !important;
        }
        
        .ge-video-track {
            display: flex !important;
            gap: 20px !important;
            transform: none !important;
        }
        
        .ge-video-card {
            flex: 1 !important;
            min-width: 0 !important;
            max-width: calc(25% - 15px) !important;
        }
        
        .ge-video-frame {
            width: 100% !important;
            height: 0 !important;
            padding-bottom: 177.78% !important; /* 9:16 aspect ratio */
            position: relative !important;
            background: transparent !important;
            overflow: hidden !important;
        }
        
        .ge-video-frame iframe,
        .ge-video-frame video {
            position: absolute !important;
            top: 0 !important;
            left: 0 !important;
            width: 100% !important;
            height: 100% !important;
            object-fit: contain !important;
            border: none !important;
            transform: none !important;
            transform-origin: center center !important;
        }
    }
    
    /* Video Cards - Mobile: Formato Vertical */
    @media screen and (max-width: 768px) {
        .ge-video-carousel-wrapper {
            overflow-x: auto !important;
            -webkit-overflow-scrolling: touch !important;
        }
        
        .ge-video-track {
            display: flex !important;
            gap: 15px !important;
        }
        
        .ge-video-card {
            flex: 0 0 73vw !important;
            min-width: 73vw !important;
            max-width: 75vw !important;
        }
        
        .ge-video-frame {
            width: 100% !important;
            height: 0 !important;
            padding-bottom: 177.78% !important; /* 9:16 aspect ratio */
            position: relative !important;
            overflow: hidden !important;
            background: transparent !important;
        }
        
        .ge-video-frame iframe,
        .ge-video-frame video {
            position: absolute !important;
            top: 0 !important;
            left: 0 !important;
            width: 100% !important;
            height: 100% !important;
            object-fit: contain !important;
            border: none !important;
            transform: none !important;
            transform-origin: center center !important;
        }
    }
            object-fit: cover !important;
            border: none !important;
        }
    }
    
    /* Accordion Active State */
    .ge-accordion-header {
        background: #f5f5f5 !important;
        color: #000 !important;
        transition: all 0.3s ease !important;
    }
    
    .ge-accordion-item.active .ge-accordion-header {
        background: #000 !important;
        color: #fff !important;
    }
    
    .ge-accordion-item.active .ge-accordion-header .ge-icon svg path {
        stroke: #fff !important;
    }
    
    /* Button Hover Fix */
    .ge-btn:hover {
        background: #000 !important;
        color: #fff !important;
        border: 2px solid #fff !important;
    }
    
    .ge-btn-outline:hover {
        background: #fff !important;
        color: #000 !important;
        border: 2px solid #fff !important;
    }
    
    /* Mini Banners - Estado Padrão: Título Esquerda + Imagem Direita */
    .ge-mini-banner-item {
        display: flex !important;
        flex-direction: row !important;
        align-items: center !important;
        justify-content: space-between !important;
        cursor: pointer !important;
        transition: all 0.3s ease !important;
        background: #f5f5f5 !important;
    }
    
    .ge-banner-title {
        display: block !important;
        order: 1 !important;
        color: #333 !important;
    }
    
    .ge-banner-content {
        display: flex !important;
        order: 2 !important;
    }
    
    .ge-banner-image {
        display: block !important;
    }
    
    .ge-banner-description {
        display: none !important;
        color: #333 !important;
    }
    
    /* Mini Banners - Hover/Active Desktop: Título em cima + Descrição embaixo */
    @media screen and (min-width: 769px) {
        .ge-mini-banner-item:hover,
        .ge-mini-banner-item.active {
            flex-direction: column !important;
            align-items: flex-start !important;
            background: #f5f5f5 !important;
        }
        
        .ge-mini-banner-item:hover .ge-banner-title,
        .ge-mini-banner-item.active .ge-banner-title {
            order: 1 !important;
            width: 100% !important;
            text-align: left !important;
            margin-bottom: 15px !important;
            color: #333 !important;
        }
        
        .ge-mini-banner-item:hover .ge-banner-content,
        .ge-mini-banner-item.active .ge-banner-content {
            order: 2 !important;
            width: 100% !important;
        }
        
        .ge-mini-banner-item:hover .ge-banner-image,
        .ge-mini-banner-item.active .ge-banner-image {
            display: none !important;
        }
        
        .ge-mini-banner-item:hover .ge-banner-description,
        .ge-mini-banner-item.active .ge-banner-description {
            display: block !important;
            color: #333 !important;
        }
    }
    
    /* Mini Banners - Mobile */
    @media screen and (max-width: 768px) {
        /* Contêiner geral */
        .ge-mini-banners {
            width: 100% !important;
            box-sizing: border-box !important;
        }

        /* Card: flex row igual ao desktop, mas contido na largura da tela */
        .ge-mini-banner-item {
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            justify-content: space-between !important;
            position: static !important;
            width: 100% !important;
            max-width: 100% !important;
            box-sizing: border-box !important;
            overflow: hidden !important;
            padding-right: 0 !important;
            min-height: unset !important;
        }

        /* Título: ocupa todo o espaço à esquerda */
        .ge-mini-banner-item .ge-banner-title {
            display: block !important;
            order: 1 !important;
            flex: 1 1 0% !important;
            min-width: 0 !important;
            color: #333 !important;
            position: static !important;
            min-height: unset !important;
        }

        /* Container da imagem: tamanho fixo, não encolhe, vai para direita */
        .ge-mini-banner-item .ge-banner-content {
            display: flex !important;
            order: 2 !important;
            flex: 0 0 90px !important;
            position: static !important;
            transform: none !important;
            margin-left: 8px !important;
        }

        /* Imagem com tamanho fixo e contida */
        .ge-mini-banner-item .ge-banner-image {
            display: block !important;
            width: 90px !important;
            height: 90px !important;
            max-width: 90px !important;
            max-height: 90px !important;
            object-fit: cover !important;
            flex-shrink: 0 !important;
        }

        /* === Estado ATIVO (clique no mobile): coluna, título em cima, descrição embaixo === */
        .ge-mini-banner-item.active {
            flex-direction: column !important;
            align-items: flex-start !important;
            min-height: unset !important;
        }

        .ge-mini-banner-item.active .ge-banner-title {
            order: 1 !important;
            flex: none !important;
            width: 100% !important;
            margin-bottom: 10px !important;
        }

        .ge-mini-banner-item.active .ge-banner-content {
            order: 2 !important;
            flex: none !important;
            width: 100% !important;
            position: static !important;
            transform: none !important;
            margin-left: 0 !important;
        }

        .ge-mini-banner-item.active .ge-banner-image {
            display: none !important;
        }

        .ge-mini-banner-item.active .ge-banner-description {
            display: block !important;
            color: #333 !important;
        }
    }
    
    /* MOBILE - Banners com altura aumentada */
    @media screen and (max-width: 768px) {
        /* Banner Garantia Eora (Secundário) */
        .ge-second-banner {
            height: auto !important;
            min-height: auto !important;
        }
        
        .ge-second-banner-wrapper {
            display: flex !important;
            flex-direction: column !important;
            align-items: center !important;
            justify-content: center !important;
            position: relative !important;
            overflow: hidden !important;
            min-height: 600px !important;
            height: auto !important;
            background-color: #000 !important;
            padding: 80px 40px !important;
        }
        
        .ge-second-banner-wrapper img {
            position: absolute !important;
            top: 0 !important;
            left: 0 !important;
            width: 100% !important;
            height: 100% !important;
            object-fit: cover !important;
            z-index: 0 !important;
            opacity: 0.6 !important;
        }
        
        .ge-second-banner-overlay {
            position: relative !important;
            width: 100% !important;
            max-width: 100% !important;
            padding: 0 !important;
            z-index: 1 !important;
            background: transparent !important;
            height: auto !important;
            top: auto !important;
            left: auto !important;
            transform: none !important;
        }
        
        .ge-second-banner-overlay h2 {
            font-size: 1.8rem !important;
            font-weight: 700 !important;
            line-height: 1.3 !important;
            margin-bottom: 25px !important;
            color: #fff !important;
            text-transform: uppercase !important;
            text-shadow: 2px 2px 6px rgba(0,0,0,0.9) !important;
        }
        
        .ge-second-banner-overlay p {
            font-size: 1rem !important;
            line-height: 1.6 !important;
            margin: 0 0 30px 0 !important;
            color: #fff !important;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.9) !important;
        }
        
        /* Banner Reparos (antes do footer) */
        .ge-repair-banner {
            min-height: 600px !important;
            height: auto !important;
            padding: 80px 40px !important;
            background-size: cover !important;
            background-position: center !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
        }
        
        .ge-repair-content {
            width: 100% !important;
            max-width: 100% !important;
            padding: 0 !important;
            text-align: center !important;
        }
        
        .ge-repair-content h2 {
            font-size: 1.8rem !important;
            line-height: 1.3 !important;
            margin-bottom: 25px !important;
            color: #fff !important;
            text-shadow: 2px 2px 6px rgba(0,0,0,0.9) !important;
        }
        
        .ge-repair-content p {
            font-size: 1rem !important;
            line-height: 1.6 !important;
            margin-bottom: 30px !important;
            color: #fff !important;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.9) !important;
        }
        
        .ge-buttons {
            display: flex !important;
            flex-direction: column !important;
            gap: 15px !important;
            width: 100% !important;
            max-width: 300px !important;
            margin: 0 auto !important;
        }
        
        .ge-btn {
            width: 100% !important;
            display: block !important;
            text-align: center !important;
            padding: 15px 30px !important;
            font-size: 1rem !important;
        }
    }
</style>

<div class="garantia-eora-page">

    {# 1. Banner Principal #}
    {% if settings.garantia_banner_show %}
        <section class="ge-banner" style="background-image: url('{{ "garantia_banner.jpg" | static_url }}');">
        </section>
    {% endif %}

    {# 2. Texto Introdutório #}
    {% if settings.garantia_intro_show %}
        <section class="ge-intro-text">
            <div class="ge-container">
                {% if settings.garantia_intro_text %}
                    <p>{{ settings.garantia_intro_text | nl2br }}</p>
                {% endif %}
            </div>
        </section>
    {% endif %}

    {# 3. Banner Secundário (Garantia Eora) #}
    {% if settings.garantia_second_banner_show %}
        <section class="ge-second-banner">
            <div class="ge-second-banner-wrapper">
                <img src="{{ "garantia_second_banner_img.jpg" | static_url }}" class="ge-img-responsive" alt="Garantia Eora">
                <div class="ge-second-banner-overlay">
                    {% if settings.garantia_second_banner_title %}
                        <h2>{{ settings.garantia_second_banner_title }}</h2>
                    {% endif %}
                    {% if settings.garantia_second_banner_text %}
                        <p>{{ settings.garantia_second_banner_text | nl2br }}</p>
                    {% endif %}
                    {% if settings.garantia_second_banner_btn_text %}
                        <div style="margin-top: 40px;">
                            <a href="{{ settings.garantia_second_banner_btn_url }}" class="ge-btn">{{ settings.garantia_second_banner_btn_text }}</a>
                        </div>
                    {% endif %}
                </div>
            </div>
        </section>
    {% endif %}

    {# 2. Sequência de 4 Fotos #}
    {% if settings.garantia_photos_show %}
        <section class="ge-photo-sequence">
            <div class="ge-photo-item">
                <img src="{{ "garantia_photo_1.jpg" | static_url }}" alt="Photo 1">
            </div>
            <div class="ge-photo-item">
                <img src="{{ "garantia_photo_2.jpg" | static_url }}" alt="Photo 2">
            </div>
            <div class="ge-photo-item">
                <img src="{{ "garantia_photo_3.jpg" | static_url }}" alt="Photo 3">
            </div>
            <div class="ge-photo-item">
                <img src="{{ "garantia_photo_4.jpg" | static_url }}" alt="Photo 4">
            </div>
        </section>
    {% endif %}

    {# 3. Cuidados com a Peça (Accordion) #}
    <section class="ge-care-section" id="cuidados-com-a-peca">
        <div class="ge-container">
            <h2>{{ settings.garantia_care_section_title | default('CUIDADOS COM A PEÇA') }}</h2>
            {% if settings.garantia_care_section_intro %}
                <p class="ge-care-intro">{{ settings.garantia_care_section_intro | nl2br }}</p>
            {% endif %}
            
            <div class="ge-accordion">
                
                {# ITEM 1 #}
                <div class="ge-accordion-item" data-index="1">
                    <div class="ge-accordion-header">
                        <span>{{ settings.garantia_care_title_1 | default('ÓCULOS') }}</span>
                        <span class="ge-icon">
                            <svg width="14" height="8" viewBox="0 0 14 8" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L7 7L13 1" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                        </span>
                    </div>
                    <div class="ge-accordion-body">
                        <div class="ge-mini-banners">
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_1_banner_1.jpg" | static_url }}" alt="Banner 1" class="ge-banner-image">
                                    {% if settings.garantia_care_1_banner_1_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_1_banner_1_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_1_banner_1_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_1_banner_1_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_1_banner_2.jpg" | static_url }}" alt="Banner 2" class="ge-banner-image">
                                    {% if settings.garantia_care_1_banner_2_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_1_banner_2_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_1_banner_2_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_1_banner_2_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_1_banner_3.jpg" | static_url }}" alt="Banner 3" class="ge-banner-image">
                                    {% if settings.garantia_care_1_banner_3_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_1_banner_3_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_1_banner_3_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_1_banner_3_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_1_banner_4.jpg" | static_url }}" alt="Banner 4" class="ge-banner-image">
                                    {% if settings.garantia_care_1_banner_4_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_1_banner_4_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_1_banner_4_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_1_banner_4_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_1_banner_5.jpg" | static_url }}" alt="Banner 5" class="ge-banner-image">
                                    {% if settings.garantia_care_1_banner_5_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_1_banner_5_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_1_banner_5_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_1_banner_5_title }}</div>
                                {% endif %}
                            </div>
                        </div>
                    </div>
                </div>

                {# ITEM 2 #}
                <div class="ge-accordion-item" data-index="2">
                    <div class="ge-accordion-header">
                        <span>{{ settings.garantia_care_title_2 | default('BOLSAS') }}</span>
                        <span class="ge-icon">
                            <svg width="14" height="8" viewBox="0 0 14 8" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L7 7L13 1" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                        </span>
                    </div>
                    <div class="ge-accordion-body">
                        <div class="ge-mini-banners">
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_2_banner_1.jpg" | static_url }}" alt="Banner 1" class="ge-banner-image">
                                    {% if settings.garantia_care_2_banner_1_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_2_banner_1_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_2_banner_1_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_2_banner_1_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_2_banner_2.jpg" | static_url }}" alt="Banner 2" class="ge-banner-image">
                                    {% if settings.garantia_care_2_banner_2_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_2_banner_2_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_2_banner_2_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_2_banner_2_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_2_banner_3.jpg" | static_url }}" alt="Banner 3" class="ge-banner-image">
                                    {% if settings.garantia_care_2_banner_3_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_2_banner_3_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_2_banner_3_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_2_banner_3_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_2_banner_4.jpg" | static_url }}" alt="Banner 4" class="ge-banner-image">
                                    {% if settings.garantia_care_2_banner_4_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_2_banner_4_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_2_banner_4_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_2_banner_4_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_2_banner_5.jpg" | static_url }}" alt="Banner 5" class="ge-banner-image">
                                    {% if settings.garantia_care_2_banner_5_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_2_banner_5_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_2_banner_5_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_2_banner_5_title }}</div>
                                {% endif %}
                            </div>
                        </div>
                    </div>
                </div>

                {# ITEM 3 #}
                <div class="ge-accordion-item" data-index="3">
                    <div class="ge-accordion-header">
                        <span>{{ settings.garantia_care_title_3 | default('LEATHER GOODS') }}</span>
                        <span class="ge-icon">
                            <svg width="14" height="8" viewBox="0 0 14 8" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L7 7L13 1" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                        </span>
                    </div>
                    <div class="ge-accordion-body">
                        <div class="ge-mini-banners">
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_3_banner_1.jpg" | static_url }}" alt="Banner 1" class="ge-banner-image">
                                    {% if settings.garantia_care_3_banner_1_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_3_banner_1_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_3_banner_1_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_3_banner_1_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_3_banner_2.jpg" | static_url }}" alt="Banner 2" class="ge-banner-image">
                                    {% if settings.garantia_care_3_banner_2_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_3_banner_2_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_3_banner_2_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_3_banner_2_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_3_banner_3.jpg" | static_url }}" alt="Banner 3" class="ge-banner-image">
                                    {% if settings.garantia_care_3_banner_3_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_3_banner_3_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_3_banner_3_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_3_banner_3_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_3_banner_4.jpg" | static_url }}" alt="Banner 4" class="ge-banner-image">
                                    {% if settings.garantia_care_3_banner_4_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_3_banner_4_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_3_banner_4_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_3_banner_4_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_3_banner_5.jpg" | static_url }}" alt="Banner 5" class="ge-banner-image">
                                    {% if settings.garantia_care_3_banner_5_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_3_banner_5_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_3_banner_5_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_3_banner_5_title }}</div>
                                {% endif %}
                            </div>
                        </div>
                    </div>
                </div>

                {# ITEM 4 #}
                <div class="ge-accordion-item" data-index="4">
                    <div class="ge-accordion-header">
                        <span>{{ settings.garantia_care_title_4 | default('METAL GOODS') }}</span>
                        <span class="ge-icon">
                            <svg width="14" height="8" viewBox="0 0 14 8" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M1 1L7 7L13 1" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                        </span>
                    </div>
                    <div class="ge-accordion-body">
                        <div class="ge-mini-banners">
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_4_banner_1.jpg" | static_url }}" alt="Banner 1" class="ge-banner-image">
                                    {% if settings.garantia_care_4_banner_1_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_4_banner_1_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_4_banner_1_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_4_banner_1_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_4_banner_2.jpg" | static_url }}" alt="Banner 2" class="ge-banner-image">
                                    {% if settings.garantia_care_4_banner_2_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_4_banner_2_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_4_banner_2_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_4_banner_2_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_4_banner_3.jpg" | static_url }}" alt="Banner 3" class="ge-banner-image">
                                    {% if settings.garantia_care_4_banner_3_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_4_banner_3_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_4_banner_3_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_4_banner_3_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_4_banner_4.jpg" | static_url }}" alt="Banner 4" class="ge-banner-image">
                                    {% if settings.garantia_care_4_banner_4_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_4_banner_4_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_4_banner_4_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_4_banner_4_title }}</div>
                                {% endif %}
                            </div>
                            <div class="ge-mini-banner-item">
                                <div class="ge-banner-content">
                                    <img src="{{ "garantia_care_4_banner_5.jpg" | static_url }}" alt="Banner 5" class="ge-banner-image">
                                    {% if settings.garantia_care_4_banner_5_desc %}
                                        <div class="ge-banner-description">{{ settings.garantia_care_4_banner_5_desc | nl2br }}</div>
                                    {% endif %}
                                </div>
                                {% if settings.garantia_care_4_banner_5_title %}
                                    <div class="ge-banner-title">{{ settings.garantia_care_4_banner_5_title }}</div>
                                {% endif %}
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </section>

    {# 4. Carrossel de Vídeos #}
    {% if settings.garantia_videos_show %}
        <section class="ge-videos-section">
            <div class="ge-container">
                <h2 style="text-align: center; font-size: 1.5rem; font-weight: 500; letter-spacing: 0.1em; margin-bottom: 30px;">{{ settings.garantia_videos_title | default('AJUSTES RÁPIDOS') }}</h2>


                <div class="ge-video-carousel-container">
                    <button class="ge-carousel-btn ge-carousel-btn-prev" onclick="scrollCarousel(-1)" aria-label="Previous">
                        <svg viewBox="0 0 24 24"><path d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"/></svg>
                    </button>
                    
                    <div class="ge-video-carousel-wrapper">
                        <div class="ge-video-track" id="videoTrack">
                         {% if settings.garantia_video_url_1 %}
                            <div class="ge-video-card">
                                <div class="ge-video-frame">
                                    {% if 'vimeo.com' in settings.garantia_video_url_1 %}
                                        <iframe src="https://player.vimeo.com/video/{{ settings.garantia_video_url_1 | replace('https://vimeo.com/', '') | replace('http://vimeo.com/', '') | replace('vimeo.com/', '') }}?autoplay=1&loop=1&muted=1&background=1&playsinline=1&title=0&byline=0&portrait=0&controls=0&sidedock=0&autopause=0" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>
                                    {% else %}
                                        <iframe src="https://www.youtube.com/embed/{{ settings.garantia_video_url_1 | replace('https://www.youtube.com/watch?v=', '') | replace('https://youtu.be/', '') | replace('https://youtube.com/shorts/', '') | replace('youtube.com/watch?v=', '') | replace('youtu.be/', '') }}?autoplay=1&mute=1&playsinline=1&loop=1&playlist={{ settings.garantia_video_url_1 | replace('https://www.youtube.com/watch?v=', '') | replace('https://youtu.be/', '') | replace('https://youtube.com/shorts/', '') | replace('youtube.com/watch?v=', '') | replace('youtu.be/', '') }}&controls=0&showinfo=0&rel=0&modestbranding=1" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
                                    {% endif %}
                                </div>
                                <p>{{ settings.garantia_video_desc_1 }}</p>
                            </div>
                         {% endif %}
                         
                         {% if settings.garantia_video_url_2 %}
                            <div class="ge-video-card">
                                <div class="ge-video-frame">
                                    {% if 'vimeo.com' in settings.garantia_video_url_2 %}
                                        <iframe src="https://player.vimeo.com/video/{{ settings.garantia_video_url_2 | replace('https://vimeo.com/', '') | replace('http://vimeo.com/', '') | replace('vimeo.com/', '') }}?autoplay=1&loop=1&muted=1&background=1&playsinline=1&title=0&byline=0&portrait=0&controls=0&sidedock=0&autopause=0" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>
                                    {% else %}
                                        <iframe src="https://www.youtube.com/embed/{{ settings.garantia_video_url_2 | replace('https://www.youtube.com/watch?v=', '') | replace('https://youtu.be/', '') | replace('https://youtube.com/shorts/', '') | replace('youtube.com/watch?v=', '') | replace('youtu.be/', '') }}?autoplay=1&mute=1&playsinline=1&loop=1&playlist={{ settings.garantia_video_url_2 | replace('https://www.youtube.com/watch?v=', '') | replace('https://youtu.be/', '') | replace('https://youtube.com/shorts/', '') | replace('youtube.com/watch?v=', '') | replace('youtu.be/', '') }}&controls=0&showinfo=0&rel=0&modestbranding=1" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
                                    {% endif %}
                                </div>
                                <p>{{ settings.garantia_video_desc_2 }}</p>
                            </div>
                         {% endif %}

                         {% if settings.garantia_video_url_3 %}
                            <div class="ge-video-card">
                                <div class="ge-video-frame">
                                    {% if 'vimeo.com' in settings.garantia_video_url_3 %}
                                        <iframe src="https://player.vimeo.com/video/{{ settings.garantia_video_url_3 | replace('https://vimeo.com/', '') | replace('http://vimeo.com/', '') | replace('vimeo.com/', '') }}?autoplay=1&loop=1&muted=1&background=1&playsinline=1&title=0&byline=0&portrait=0&controls=0&sidedock=0&autopause=0" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>
                                    {% else %}
                                        <iframe src="https://www.youtube.com/embed/{{ settings.garantia_video_url_3 | replace('https://www.youtube.com/watch?v=', '') | replace('https://youtu.be/', '') | replace('https://youtube.com/shorts/', '') | replace('youtube.com/watch?v=', '') | replace('youtu.be/', '') }}?autoplay=1&mute=1&playsinline=1&loop=1&playlist={{ settings.garantia_video_url_3 | replace('https://www.youtube.com/watch?v=', '') | replace('https://youtu.be/', '') | replace('https://youtube.com/shorts/', '') | replace('youtube.com/watch?v=', '') | replace('youtu.be/', '') }}&controls=0&showinfo=0&rel=0&modestbranding=1" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
                                    {% endif %}
                                </div>
                                <p>{{ settings.garantia_video_desc_3 }}</p>
                            </div>
                         {% endif %}

                         {% if settings.garantia_video_url_4 %}
                            <div class="ge-video-card">
                                <div class="ge-video-frame">
                                    {% if 'vimeo.com' in settings.garantia_video_url_4 %}
                                        <iframe src="https://player.vimeo.com/video/{{ settings.garantia_video_url_4 | replace('https://vimeo.com/', '') | replace('http://vimeo.com/', '') | replace('vimeo.com/', '') }}?autoplay=1&loop=1&muted=1&background=1&playsinline=1&title=0&byline=0&portrait=0&controls=0&sidedock=0&autopause=0" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>
                                    {% else %}
                                        <iframe src="https://www.youtube.com/embed/{{ settings.garantia_video_url_4 | replace('https://www.youtube.com/watch?v=', '') | replace('https://youtu.be/', '') | replace('https://youtube.com/shorts/', '') | replace('youtube.com/watch?v=', '') | replace('youtu.be/', '') }}?autoplay=1&mute=1&playsinline=1&loop=1&playlist={{ settings.garantia_video_url_4 | replace('https://www.youtube.com/watch?v=', '') | replace('https://youtu.be/', '') | replace('https://youtube.com/shorts/', '') | replace('youtube.com/watch?v=', '') | replace('youtu.be/', '') }}&controls=0&showinfo=0&rel=0&modestbranding=1" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
                                    {% endif %}
                                </div>
                                <p>{{ settings.garantia_video_desc_4 }}</p>
                            </div>
                         {% endif %}
                        </div>
                    </div>
                    
                    <button class="ge-carousel-btn ge-carousel-btn-next" onclick="scrollCarousel(1)" aria-label="Next">
                        <svg viewBox="0 0 24 24"><path d="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z"/></svg>
                    </button>
                </div>
            </div>
        </section>
    {% endif %}

    {# 5. Banner Reparos #}
    {% if settings.garantia_repair_show %}
        <section class="ge-repair-banner" style="background-image: url('{{ "garantia_repair_img.jpg" | static_url }}');">
            <div class="ge-container">
                <div class="ge-repair-content" style="max-width: 560px;">
                    <h2 style="font-size: 1.4rem; margin-bottom: 12px;">{{ settings.garantia_repair_title | default('REPAROS E CONSERTOS') }}</h2>
                    <p style="font-size: 0.85rem; line-height: 1.5; margin-bottom: 20px;">{{ settings.garantia_repair_text | default('Your LOEWE item will maintain its qualities...') }}</p>
                    <div class="ge-buttons" style="gap: 10px;">
                        <a href="https://api.whatsapp.com/send/?phone=5519999285508&text=Ol%C3%A1%2C+gostaria+de+falar+sobre+reparos+e+consertos+da+EORA.&type=phone_number&app_absent=0" class="ge-btn" target="_blank" style="padding: 11px 24px; font-size: 0.85rem;">{{ settings.garantia_repair_btn1_text | default('FALAR NO WHATSAPP') }}</a>
                        <a href="#cuidados-com-a-peca" class="ge-btn ge-btn-outline" style="padding: 11px 24px; font-size: 0.85rem;">{{ settings.garantia_repair_btn2_text | default('DICAS DE USO') }}</a>
                    </div>
                </div>
            </div>
        </section>
    {% endif %}


</div>

<script>
    // Video Carousel Navigation (Force Gap Update)
    let currentIndex = 0;
    
    function scrollCarousel(direction) {
        const track = document.getElementById('videoTrack');
        const cards = track.querySelectorAll('.ge-video-card');
        const totalCards = cards.length;
        
        if (totalCards === 0) return;
        
        // Determine how many cards to show based on screen size
        const isMobile = window.innerWidth <= 768;
        const cardsToShow = isMobile ? 1 : 4;
        const maxIndex = Math.max(0, totalCards - cardsToShow);
        
        // Update current index
        currentIndex += direction;
        currentIndex = Math.max(0, Math.min(currentIndex, maxIndex));
        
        // No mobile, usar scroll nativo
        if (isMobile) {
            const cardWidth = cards[0].offsetWidth;
            const gap = 15;
            const scrollPosition = currentIndex * (cardWidth + gap);
            track.parentElement.scrollTo({ left: scrollPosition, behavior: 'smooth' });
        } else {
            // Desktop: usar transform com novo gap
            const cardWidth = cards[0].offsetWidth;
            const gap = 20; // NOVO GAP DESKTOP
            const offset = -(currentIndex * (cardWidth + gap));
            track.style.transform = `translateX(${offset}px)`;
        }
        
        // Update button states
        updateCarouselButtons(currentIndex, maxIndex);
    }
    
    function updateCarouselButtons(current, max) {
        const prevBtn = document.querySelector('.ge-carousel-btn-prev');
        const nextBtn = document.querySelector('.ge-carousel-btn-next');
        
        if (prevBtn) prevBtn.disabled = current === 0;
        if (nextBtn) nextBtn.disabled = current === max;
    }
    
    // Initialize on load
    document.addEventListener('DOMContentLoaded', function() {
        const track = document.getElementById('videoTrack');
        if (track) {
            const cards = track.querySelectorAll('.ge-video-card');
            const isMobile = window.innerWidth <= 768;
            const cardsToShow = isMobile ? 1 : 4;
            const maxIndex = Math.max(0, cards.length - cardsToShow);
            updateCarouselButtons(0, maxIndex);
        }
        
        // Accordion functionality
        const items = document.querySelectorAll('.ge-accordion-item');

        if(items.length > 0) {
            items.forEach(item => {
                const header = item.querySelector('.ge-accordion-header');
                if(header){
                    header.addEventListener('click', () => {
                        // Apenas toggle o item clicado, sem fechar os outros
                        item.classList.toggle('active');
                    });
                }
            });
        }
    });

    // Hover behavior for mini-banners
    document.addEventListener('DOMContentLoaded', function() {
        const miniBanners = document.querySelectorAll('.ge-mini-banner-item');
        
        // Desktop e Mobile: toggle com clique
        miniBanners.forEach(function(banner) {
            const description = banner.querySelector('.ge-banner-description');
            
            if (description) {
                banner.addEventListener('click', function(e) {
                    e.preventDefault();
                    
                    // Fechar outros banners abertos
                    miniBanners.forEach(function(otherBanner) {
                        if (otherBanner !== banner) {
                            otherBanner.classList.remove('active');
                        }
                    });
                    
                    // Toggle do banner atual
                    banner.classList.toggle('active');
                });
            }
        });
    });

</script>
