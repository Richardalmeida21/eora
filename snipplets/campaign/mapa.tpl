<section class="section-banner-mapa mb-5 py-5">
    <div class="shadow-map"></div>
    <div class="container-fluid">
        <div class="row">
            <div class="col-12 col-md-6 d-flex align-items-center order-2 order-md-1">
                <div class="content-text pt-5 pt-md-0">
                    <h6 class="uppertitle-campaign">
                        <svg width="28" height="29" viewBox="0 0 28 29" fill="none" xmlns="http://www.w3.org/2000/svg"><rect y="0.860352" width="28" height="28" rx="14" fill="#249F58"/><path fill-rule="evenodd" clip-rule="evenodd" d="M13.9998 6.64697L25.1998 14.8603L13.9998 23.0736L2.7998 14.8603" fill="#FFDA2C"/><path d="M14.0001 20.0871C16.8867 20.0871 19.2268 17.7471 19.2268 14.8605C19.2268 11.9738 16.8867 9.63379 14.0001 9.63379C11.1135 9.63379 8.77344 11.9738 8.77344 14.8605C8.77344 17.7471 11.1135 20.0871 14.0001 20.0871Z" fill="#1A47B8"/><path fill-rule="evenodd" clip-rule="evenodd" d="M11.7598 17.1006V18.5939H13.2531V17.1006H11.7598ZM14.7464 17.1006V18.5939H16.2398V17.1006H14.7464Z" fill="white"/><path fill-rule="evenodd" clip-rule="evenodd" d="M9.33301 12.9937C9.33301 12.9937 13.6472 13.2177 16.0844 14.2601L19.2263 15.607" fill="white"/><path d="M9.33301 12.9937C9.33301 12.9937 13.6472 13.2177 16.0844 14.2601L19.2263 15.607" stroke="white"/></svg>
                        <span>{{settings.franqueados_mapa_uppertitle}}</span>
                    </h6>
                    <h2 class="title-campaign">{{settings.franqueados_mapa_title}}</h2>
                    <p class="text-campaign">{{settings.franqueados_mapa_text}}</p>
                    <a href="{{settings.franqueados_mapa_url}}" class="btn-campaign btn-primary">
                        {{settings.franqueados_mapa_button}}
                    </a>
                </div>
            </div>
            <div class="col-12 col-md-6 order-1 order-md-2">
                <div class="content-image">
                    {% set image_url =  'franqueados_mapa.jpg' | static_url %}

                    <figure class='image -square'>
                        <img src="{% if image_url %}{{ image_url }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Banner Mapa">
                    </figure>
                </div>
            </div>
        </div>
    </div>
</section>
