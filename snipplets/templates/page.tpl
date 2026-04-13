{# Institutional page  #}
{# pagina de Por trás das lentes #}
{% set behind_lens_page = settings.behind_lens_page_url %}
{% set is_behind_lens_page = page.handle == behind_lens_page %}

{# pagina de campanha #}
{% set gift_guide_page = settings.gift_guide_page_url %}
{% set is_gift_guide_page = page.handle == gift_guide_page %}

{% set page_current_01 = settings.campaign_page_01_url %}
{% set page_current_02 = settings.campaign_page_02_url %}
{% set page_current_03 = settings.campaign_page_03_url %}
{% set page_current_04 = settings.campaign_page_04_url %}
{% set page_current_05 = settings.campaign_page_05_url %}
{% set page_current_06 = settings.campaign_page_06_url %}
{% set page_current_07 = settings.campaign_page_07_url %}
{% set page_current_08 = settings.campaign_page_08_url %}
{% set page_current_09 = settings.campaign_page_09_url %}
{% set page_current_10 = settings.campaign_page_10_url %}

{% set is_campaign_01 = page.handle == page_current_01 %}
{% set is_campaign_02 = page.handle == page_current_02 %}
{% set is_campaign_03 = page.handle == page_current_03 %}
{% set is_campaign_04 = page.handle == page_current_04 %}
{% set is_campaign_05 = page.handle == page_current_05 %}
{% set is_campaign_06 = page.handle == page_current_06 %}
{% set is_campaign_07 = page.handle == page_current_07 %}
{% set is_campaign_08 = page.handle == page_current_08 %}
{% set is_campaign_09 = page.handle == page_current_09 %}
{% set is_campaign_10 = page.handle == page_current_10 %}

{% set is_on_page = is_campaign_01 or is_campaign_02 or is_campaign_03 or is_campaign_04 or is_campaign_05 or is_campaign_06 or is_campaign_07 or is_campaign_08 or is_campaign_09 or is_campaign_10 %}

{% set settings_name = '' %}
{% if is_campaign_01 %}
	{% set settings_name = 'campaign_page_01' %}
{% elseif is_campaign_02 %}
	{% set settings_name = 'campaign_page_02' %}
{% elseif is_campaign_03 %}
	{% set settings_name = 'campaign_page_03' %}
{% elseif is_campaign_04 %}
	{% set settings_name = 'campaign_page_04' %}
{% elseif is_campaign_05 %}
	{% set settings_name = 'campaign_page_05' %}
{% elseif is_campaign_06 %}
	{% set settings_name = 'campaign_page_06' %}
{% elseif is_campaign_07 %}
	{% set settings_name = 'campaign_page_07' %}
{% elseif is_campaign_08 %}
	{% set settings_name = 'campaign_page_08' %}
{% elseif is_campaign_09 %}
	{% set settings_name = 'campaign_page_09' %}
{% elseif is_campaign_10 %}
	{% set settings_name = 'campaign_page_10' %}
{% elseif is_behind_lens_page %}
	{% set settings_name = 'behind_lens_page' %}
{% endif %}

{% if is_gift_guide_page %}
    <main>
        {% include 'snipplets/gift-guide-banners.tpl' %}
    </main>
{% elseif is_on_page %}
	<main>
		{% include 'snipplets/campaign/index.tpl' with {current_settings_name: settings_name } %}
	</main>
{% elseif is_behind_lens_page %}
	<main>
		{% include 'snipplets/page-content/behind-the-lens-index.tpl' with {current_settings_name: settings_name } %}
	</main>
{% elseif page.handle == 'garantia-eora' %}
	<main>
		{% include 'snipplets/garantia-eora.tpl' %}
	</main>
{% else %}
	
	<section class="user-content pb-5 pagina-institucional">
		<div class="container-fluid">
			<div class="row">
				
				{% if settings.menu_institutional_1_show or settings.menu_institutional_2_show %}
				{# ————————— BOTÃO Menu Mobile————————— #}
				<div class="d-block d-md-none col-12">
					{# ————————— BOTÃO ————————— #}
					<button id="btn-menu-inst" class="d-flex align-items-center d-md-none">
						<svg width="18" height="16" viewBox="0 0 18 16" fill="none" xmlns="http://www.w3.org/2000/svg">
							<path d="M1.40625 0.9375H3.09375C3.55078 0.9375 3.9375 1.32422 3.9375 1.78125V3.46875C3.9375 3.96094 3.55078 4.3125 3.09375 4.3125H1.40625C0.914062 4.3125 0.5625 3.96094 0.5625 3.46875V1.78125C0.5625 1.32422 0.914062 0.9375 1.40625 0.9375ZM6.46875 1.78125H17.1562C17.6133 1.78125 18 2.16797 18 2.625C18 3.11719 17.6133 3.46875 17.1562 3.46875H6.46875C5.97656 3.46875 5.625 3.11719 5.625 2.625C5.625 2.16797 5.97656 1.78125 6.46875 1.78125ZM6.46875 7.40625H17.1562C17.6133 7.40625 18 7.79297 18 8.25C18 8.74219 17.6133 9.09375 17.1562 9.09375H6.46875C5.97656 9.09375 5.625 8.74219 5.625 8.25C5.625 7.79297 5.97656 7.40625 6.46875 7.40625ZM6.46875 13.0312H17.1562C17.6133 13.0312 18 13.418 18 13.875C18 14.3672 17.6133 14.7188 17.1562 14.7188H6.46875C5.97656 14.7188 5.625 14.3672 5.625 13.875C5.625 13.418 5.97656 13.0312 6.46875 13.0312ZM0.5625 7.40625C0.5625 6.94922 0.914062 6.5625 1.40625 6.5625H3.09375C3.55078 6.5625 3.9375 6.94922 3.9375 7.40625V9.09375C3.9375 9.58594 3.55078 9.9375 3.09375 9.9375H1.40625C0.914062 9.9375 0.5625 9.58594 0.5625 9.09375V7.40625ZM1.40625 12.1875H3.09375C3.55078 12.1875 3.9375 12.5742 3.9375 13.0312V14.7188C3.9375 15.2109 3.55078 15.5625 3.09375 15.5625H1.40625C0.914062 15.5625 0.5625 15.2109 0.5625 14.7188V13.0312C0.5625 12.5742 0.914062 12.1875 1.40625 12.1875Z" fill="black"/>
						</svg>

						MENU INSTITUCIONAL
					</button>

					{# ————————— OFF-CANVAS ————————— #}
					<div id="drawer-backdrop" class="drawer-backdrop"></div>

					<aside id="drawer-menu-inst" class="drawer-menu-inst">

						<div class="header-drawer">
							<h3 class="d-flex align-items-center d-md-none">
								<svg width="18" height="16" viewBox="0 0 18 16" fill="none" xmlns="http://www.w3.org/2000/svg">
									<path d="M1.40625 0.9375H3.09375C3.55078 0.9375 3.9375 1.32422 3.9375 1.78125V3.46875C3.9375 3.96094 3.55078 4.3125 3.09375 4.3125H1.40625C0.914062 4.3125 0.5625 3.96094 0.5625 3.46875V1.78125C0.5625 1.32422 0.914062 0.9375 1.40625 0.9375ZM6.46875 1.78125H17.1562C17.6133 1.78125 18 2.16797 18 2.625C18 3.11719 17.6133 3.46875 17.1562 3.46875H6.46875C5.97656 3.46875 5.625 3.11719 5.625 2.625C5.625 2.16797 5.97656 1.78125 6.46875 1.78125ZM6.46875 7.40625H17.1562C17.6133 7.40625 18 7.79297 18 8.25C18 8.74219 17.6133 9.09375 17.1562 9.09375H6.46875C5.97656 9.09375 5.625 8.74219 5.625 8.25C5.625 7.79297 5.97656 7.40625 6.46875 7.40625ZM6.46875 13.0312H17.1562C17.6133 13.0312 18 13.418 18 13.875C18 14.3672 17.6133 14.7188 17.1562 14.7188H6.46875C5.97656 14.7188 5.625 14.3672 5.625 13.875C5.625 13.418 5.97656 13.0312 6.46875 13.0312ZM0.5625 7.40625C0.5625 6.94922 0.914062 6.5625 1.40625 6.5625H3.09375C3.55078 6.5625 3.9375 6.94922 3.9375 7.40625V9.09375C3.9375 9.58594 3.55078 9.9375 3.09375 9.9375H1.40625C0.914062 9.9375 0.5625 9.58594 0.5625 9.09375V7.40625ZM1.40625 12.1875H3.09375C3.55078 12.1875 3.9375 12.5742 3.9375 13.0312V14.7188C3.9375 15.2109 3.55078 15.5625 3.09375 15.5625H1.40625C0.914062 15.5625 0.5625 15.2109 0.5625 14.7188V13.0312C0.5625 12.5742 0.914062 12.1875 1.40625 12.1875Z" fill="black"/>
								</svg>
								MENU INSTITUCIONAL
							</h3>
							<button class="drawer-close" aria-label="Fechar">×</button>
						</div>

						{# reutiliza exatamente as mesmas listas já existentes #}
						{% if settings.menu_institutional_1_show %}
							<nav class="menu-institucional">
								<ul class="list">
									<li class="menu-title">{{ settings.menu_institutional_title_one }}</li>
									{% for item in menus[settings.menu_institutional_1] %}
									<li class="menu-item">
										<a class="menu-link" href="{{ item.url }}" {% if item.url | is_external %}target="_blank"{% endif %}>{{ item.name }}</a>
									</li>
									{% endfor %}
								</ul>
							</nav>
						{% endif %}

						{% if settings.menu_institutional_2_show %}
							<nav class="menu-institucional">
								<ul class="list">
									<li class="menu-title">{{ settings.menu_institutional_title_two }}</li>
									{% for item in menus[settings.menu_institutional_2] %}
									<li class="menu-item">
										<a class="menu-link" href="{{ item.url }}" {% if item.url | is_external %}target="_blank"{% endif %}>{{ item.name }}</a>
									</li>
									{% endfor %}
								</ul>
							</nav>
						{% endif %}
					</aside>
				</div>
				{% endif %}

				{# ————————— MENUS ————————— #}
				{% if settings.menu_institutional_1_show or settings.menu_institutional_2_show %}
				<div class="d-none d-md-block col-md-3 offset-md-1">
					<div class="content-menu-institucional">
						{% if settings.menu_institutional_1_show  %}
						<nav class="menu-institucional mt-5">
							<ul class="list">
								{% if settings.menu_institutional_1 %}
									<li class="menu-title">
										{{ settings.menu_institutional_title_one }}
									</li>
								{% endif %}
								{% for item in menus[settings.menu_institutional_1] %}
									<li class="menu-item">
										<a class="menu-link" href="{{ item.url }}" {% if item.url | is_external %}target="_blank"{% endif %}>{{ item.name }}</a>
									</li>
								{% endfor %}
							</ul>
						</nav>
						{% endif %}
						{% if settings.menu_institutional_2_show %}
						<nav class="menu-institucional">
							<ul class="list">
								{% if settings.menu_institutional_2 %}
									<li class="menu-title">
										{{ settings.menu_institutional_title_two }}
									</li>
								{% endif %}
								{% for item in menus[settings.menu_institutional_2] %}
									<li class="menu-item">
										<a class="menu-link" href="{{ item.url }}" {% if item.url | is_external %}target="_blank"{% endif %}>{{ item.name }}</a>
									</li>
								{% endfor %}
							</ul>
						</nav>
						{% endif %}
					</div>
				</div>
				{% endif %}

				{# ————————— Texts and img ————————— #}
				<div class="{% if settings.menu_institutional_1_show or settings.menu_institutional_2_show %}col-12 col-md-7{% else %}col-12{% endif %}">
					<div class="page-text">
						<h2>{{ page.name }}</h2>

						{{ page.content }}
						{% include 'snipplets/page-content/who-uses.tpl'%}
						{% if page.handle == 'nossas-lojas' %}
							<!-- Start Stockist.co widget -->
							<stockist-store-locator data-stockist-widget-tag="u21114">
							Loading store locator from <a href="https://stockist.co">Stockist store locator</a>...
							</stockist-store-locator>
							<script async src="https://stockist.co/embed/v1/widget.min.js"></script>
							<!-- End Stockist.co widget -->
						{% endif %}
					</div>
				</div>

			</div>
		</div>
	</section>

{% endif %}

{# <h1>page_current_01 {{ page_current_01 }}</h1> #}
