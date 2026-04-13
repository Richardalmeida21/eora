{% set video_link = settings.franqueados_gallery_video_embed %}
{% set video_link_mobile = settings.franqueados_gallery_video_embed_mobile %}

<div class="container-fluid my-5">
  <div class="section-franqueados" {% if not settings.franqueados_show %}style="display:none;"{% endif %}>
    <div class="row no-gutters align-items-center">
      <!-- VIDEO/IMAGE LEFT -->
      <div class="col-12 col-lg-6 p-0">
        <div class="franqueados-image-wrapper">
          {% if video_link or video_link_mobile %}
            <!-- Desktop Video -->
            <figure class="image -custom d-none d-md-block">
              {% if video_link %}
                <div class="js-video home-video embed-responsive embed-responsive-21by9 position-relative" data-video-type="desktop">
                  {% if settings.franqueados_gallery_video_type == 'sound' %}
                    <a href="javascript:void(0)" class="js-play-button video-player">
                      <div class="video-player-icon">
                        <svg class="icon-inline icon-3x svg-icon-text"><use xlink:href="#play"/></svg>
                      </div>
                    </a>
                  {% endif %}
                  
                  {# Video thumbnail #}
                  <div class="js-video-image">
                    {% set video_url = video_link %}
                    {% set video_id = '' %}
                    {% set video_platform = '' %}
                    
                    {# YouTube detection #}
                    {% if '/watch?v=' in video_link %}
                      {% set video_id = video_url|split('/watch?v=')|last|split('&')|first %}
                      {% set video_platform = 'youtube' %}
                    {% elseif '/youtu.be/' in video_link %}
                      {% set video_id = video_url|split('/youtu.be/')|last|split('?')|first %}
                      {% set video_platform = 'youtube' %}
                    {% elseif '/shorts/' in video_link %}
                      {% set video_id = video_url|split('/shorts/')|last|split('?')|first %}
                      {% set video_platform = 'youtube' %}
                    {# Vimeo detection #}
                    {% elseif 'vimeo.com/' in video_link %}
                      {% set video_id = video_url|split('vimeo.com/')|last|split('?')|first|split('/')[0] %}
                      {% set video_platform = 'vimeo' %}
                    {% endif %}
                    
                    {% if video_platform == 'youtube' %}
                      {% set video_image_src = 'https://img.youtube.com/vi/' ~ video_id ~ '/maxresdefault.jpg' %}
                    {% elseif video_platform == 'vimeo' %}
                      {% set video_image_src = 'https://vumbnail.com/' ~ video_id ~ '.jpg' %}
                    {% endif %}
                    
                    <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ video_image_src }}" class="lazyload video-image fade-in" alt="{{ 'Video de' | translate }} {{ store.name }}" />
                    <div class="placeholder-fade"></div>
                  </div>

                  {# Empty iframe component: will be filled with JS on play button click #}
                  <div class="js-video-iframe embed-responsive embed-responsive-21by9" style="display: none;" data-video-color="{{ settings.accent_color | trim('#') }}" data-video-url="{{ video_link }}">
                  </div>
                </div>
              {% endif %}
            </figure>

            <!-- Mobile Video -->
            <figure class="image -custom d-md-none">
              {% if video_link_mobile %}
                <div class="js-video home-video embed-responsive embed-responsive-21by9 position-relative" data-video-type="mobile">
                  {% if settings.franqueados_gallery_video_type == 'sound' %}
                    <a href="javascript:void(0)" class="js-play-button video-player">
                      <div class="video-player-icon">
                        <svg class="icon-inline icon-3x svg-icon-text"><use xlink:href="#play"/></svg>
                      </div>
                    </a>
                  {% endif %}
                  
                  {# Video thumbnail #}
                  <div class="js-video-image">
                    {% set video_url_mobile = video_link_mobile %}
                    {% set video_id_mobile = '' %}
                    {% set video_platform_mobile = '' %}
                    
                    {# YouTube detection #}
                    {% if '/watch?v=' in video_link_mobile %}
                      {% set video_id_mobile = video_url_mobile|split('/watch?v=')|last|split('&')|first %}
                      {% set video_platform_mobile = 'youtube' %}
                    {% elseif '/youtu.be/' in video_link_mobile %}
                      {% set video_id_mobile = video_url_mobile|split('/youtu.be/')|last|split('?')|first %}
                      {% set video_platform_mobile = 'youtube' %}
                    {% elseif '/shorts/' in video_link_mobile %}
                      {% set video_id_mobile = video_url_mobile|split('/shorts/')|last|split('?')|first %}
                      {% set video_platform_mobile = 'youtube' %}
                    {# Vimeo detection #}
                    {% elseif 'vimeo.com/' in video_link_mobile %}
                      {% set video_id_mobile = video_url_mobile|split('vimeo.com/')|last|split('?')|first|split('/')[0] %}
                      {% set video_platform_mobile = 'vimeo' %}
                    {% endif %}
                    
                    {% if video_platform_mobile == 'youtube' %}
                      {% set video_image_src_mobile = 'https://img.youtube.com/vi/' ~ video_id_mobile ~ '/maxresdefault.jpg' %}
                    {% elseif video_platform_mobile == 'vimeo' %}
                      {% set video_image_src_mobile = 'https://vumbnail.com/' ~ video_id_mobile ~ '.jpg' %}
                    {% endif %}
                    
                    <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ video_image_src_mobile }}" class="lazyload video-image fade-in" alt="{{ 'Video de' | translate }} {{ store.name }}" />
                    <div class="placeholder-fade"></div>
                  </div>

                  {# Empty iframe component: will be filled with JS on play button click #}
                  <div class="js-video-iframe embed-responsive embed-responsive-21by9" style="display: none;" data-video-color="{{ settings.accent_color | trim('#') }}" data-video-url="{{ video_link_mobile }}">
                  </div>
                </div>
              {% endif %}
            </figure>
          {% else %}
            <!-- Fallback for gallery images if no video -->
            {% for item in settings.franqueados_gallery %}
              {% if item.image %}
                <figure class="m-0 h-100">
                  <img 
                    src="{{ item.image | static_url }}" 
                    class="lazyload w-100 h-100"
                    alt="Imagem da seção dos franqueados"
                    style="width:100%;height:100%;object-fit:cover;display:block;"
                  />
                </figure>
              {% endif %}
            {% endfor %}
          {% endif %}
        </div>
      </div>

      <!-- CONTEÚDO À DIREITA -->
      <div class="col-12 col-lg-6">
        <div class="content-franqueados">
          <div class="franqueados-top-block">
            <p class="quote-franqueados">{{ settings.franqueados_title }}</p>
            <p class="author-franqueados">{{ settings.franqueados_description }}</p>
          </div>
          <div class="franqueados-bottom-block">
            <p class="subtitle-franqueados">{{ settings.franqueados_banner_title }}</p>
            <p class="description-franqueados-small">{{ settings.franqueados_banner_description }}</p>
            {% if settings.franqueados_banner_link %}
              <a href="{{ settings.franqueados_banner_link }}" class="btn-franqueados">
                {{ settings.franqueados_banner_nome }}
                <svg class="banner-floating-icon ml-3" viewBox="0 0 10 10" fill="none" style="transform: scaleX(-1)">
                  <use xlink:href="#chevron-diagonal"></use>
                </svg>
              </a>
            {% endif %}
          </div>
        </div>
      </div>

    </div>
  </div>
</div>

<script>
  document.addEventListener('DOMContentLoaded', function() {
    console.log('Franqueados video script iniciado');
    var videoContainers = document.querySelectorAll('.section-franqueados .js-video');
    var videoUrlDesktop = '{{ video_link }}';
    var videoUrlMobile = '{{ video_link_mobile }}';
    var videoType = '{{ settings.franqueados_gallery_video_type }}';
    
    console.log('Franqueados URLs:', { desktop: videoUrlDesktop, mobile: videoUrlMobile, type: videoType });
    
    if (videoContainers.length && (videoUrlDesktop || videoUrlMobile)) {
      videoContainers.forEach(function(videoContainer) {
        var iframeContainer = videoContainer.querySelector('.js-video-iframe');
        var videoImage = videoContainer.querySelector('.js-video-image');
        var playButton = videoContainer.querySelector('.js-play-button');
        var videoDevice = videoContainer.getAttribute('data-video-type');
        
        console.log('Processando container franqueados:', videoDevice, videoContainer);
        
        // Escolher URL baseado no dispositivo
        var currentVideoUrl = '';
        if (videoDevice === 'desktop' && videoUrlDesktop) {
          currentVideoUrl = videoUrlDesktop;
        } else if (videoDevice === 'mobile' && videoUrlMobile) {
          currentVideoUrl = videoUrlMobile;
        }
        
        console.log('URL escolhida para franqueados', videoDevice + ':', currentVideoUrl);
        
        if (!currentVideoUrl) {
          console.log('Nenhuma URL encontrada para franqueados', videoDevice);
          return;
        }
        
        // Detectar plataforma e extrair ID do vídeo
        var videoId = '';
        var videoPlatform = '';
        
        if (currentVideoUrl.includes('/watch?v=')) {
          videoId = currentVideoUrl.split('/watch?v=')[1].split('&')[0];
          videoPlatform = 'youtube';
        } else if (currentVideoUrl.includes('/youtu.be/')) {
          videoId = currentVideoUrl.split('/youtu.be/')[1].split('?')[0];
          videoPlatform = 'youtube';
        } else if (currentVideoUrl.includes('/shorts/')) {
          videoId = currentVideoUrl.split('/shorts/')[1].split('?')[0];
          videoPlatform = 'youtube';
        } else if (currentVideoUrl.includes('vimeo.com/')) {
          videoId = currentVideoUrl.split('vimeo.com/')[1].split('?')[0].split('/')[0];
          videoPlatform = 'vimeo';
        }
        
        console.log('Franqueados Video ID:', videoId, 'Platform:', videoPlatform);
        
        if (videoId && videoPlatform) {
          // Função para criar e carregar iframe
          function loadVideo(autoplay) {
            console.log('Carregando video franqueados:', { id: videoId, platform: videoPlatform, autoplay: autoplay });
            
            var iframe = document.createElement('iframe');
            var params = [];
            var embedUrl = '';
            
            if (videoPlatform === 'youtube') {
              embedUrl = 'https://www.youtube.com/embed/' + videoId;
              
              if (autoplay) {
                params.push('autoplay=1', 'mute=1');
              }
              
              if (videoType === 'autoplay') {
                params.push('controls=0', 'showinfo=0', 'rel=0', 'loop=1', 'playlist=' + videoId, 'modestbranding=1', 'playsinline=1', 'iv_load_policy=3', 'fs=0', 'disablekb=1', 'cc_load_policy=0');
              } else {
                params.push('rel=0', 'modestbranding=1', 'playsinline=1');
              }
            } else if (videoPlatform === 'vimeo') {
              embedUrl = 'https://player.vimeo.com/video/' + videoId;
              var accentColor = '{{ settings.accent_color | trim('#') }}';
              
              if (autoplay) {
                params.push('autoplay=1', 'muted=1');
              }
              
              if (videoType === 'autoplay') {
                params.push('background=1', 'loop=1', 'controls=0');
              } else {
                params.push('title=0', 'byline=0', 'portrait=0');
              }
              
              if (accentColor) {
                params.push('color=' + accentColor);
              }
              
              params.push('dnt=1', 'playsinline=1');
            }
            
            iframe.src = embedUrl + (params.length ? '?' + params.join('&') : '');
            iframe.width = '100%';
            iframe.height = '100%';
            iframe.frameBorder = '0';
            iframe.allowFullscreen = true;
            iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
            iframe.style.border = 'none';
            iframe.style.position = 'absolute';
            iframe.style.width = '100%';
            iframe.style.height = '100%';
            
            if (videoType === 'autoplay') {
              iframe.style.pointerEvents = 'none';
            }
            
            console.log('Iframe franqueados criado:', iframe.src);
            
            // Limpar container e adicionar iframe
            iframeContainer.innerHTML = '';
            iframeContainer.appendChild(iframe);
            
            // Mostrar iframe e esconder imagem
            iframeContainer.style.display = 'block';
            iframeContainer.style.position = 'absolute';
            iframeContainer.style.top = '0';
            iframeContainer.style.left = '0';
            iframeContainer.style.width = '100%';
            iframeContainer.style.height = '100%';
            
            // Aplicar estilo para preencher completamente como no slider
            iframe.style.position = 'absolute';
            iframe.style.top = '50%';
            iframe.style.left = '50%';
            iframe.style.width = '177.78vh'; // Para cobrir toda altura
            iframe.style.height = '100vh';
            iframe.style.minWidth = '100%';
            iframe.style.minHeight = '100%';
            iframe.style.transform = 'translate(-50%, -50%)';
            iframe.style.objectFit = 'cover';
            
            // Para telas mais largas que 16:9
            if (window.matchMedia('(min-aspect-ratio: 16/9)').matches) {
              iframe.style.width = '100vw';
              iframe.style.height = '56.25vw';
            }
            
            if (videoImage) {
              videoImage.style.display = 'none';
            }
            if (playButton) {
              playButton.style.display = 'none';
            }
            
            console.log('Video franqueados carregado com sucesso');
          }
          
          // Se for autoplay, carregar automaticamente
          if (videoType === 'autoplay') {
            setTimeout(function() {
              loadVideo(true);
            }, 500);
          }
          
          // Se for sound, carregar quando clicar no play
          if (playButton && videoType === 'sound') {
            playButton.addEventListener('click', function(e) {
              e.preventDefault();
              loadVideo(true);
            });
          }
        } else {
          console.log('Erro: não foi possível extrair ID do vídeo franqueados');
        }
      });
    }
  });
</script>
