{% set megamenu = megamenu | default(false) %}
{% set hamburger = hamburger | default(false) %}
{% set subitem = subitem | default(false) %}

{% set hamburger_desktop_subpanels_position = settings.logo_position_desktop == 'center' ? 'nav-list-panel-left-md' : 'nav-list-panel-right-md' %}

{% for item in navigation %}

	{# LÓGICA DE DADOS (Injetada) #}
	{% set imagens_menu = [] %}
	
	{# 1. Galeria Padrao #}
	{% if not subitem and loop.first and settings.desktop_menu_images_show and settings.desktop_menu_images_first %}
		{% set imagens_menu = settings.desktop_menu_images_first %}
	{% endif %}

	{# 2. Menus Customizados (A, B, C, D) #}
	{% if not subitem and settings.desktop_menu_images_show and imagens_menu is empty %}
		{% set menu_item_name = item.name | upper | trim %}
		{% if menu_item_name == settings.custom_menu_name_a | upper | trim and settings.custom_menu_name_a is not empty %}
			{% for j in 1..4 %}
				{% set img_var = 'custom_menu_a_img_' ~ j ~ '.jpg' %}
				{% set link_var = 'custom_menu_a_link_' ~ j %}
				{% set title_var = 'custom_menu_a_title_' ~ j %}
				{% if img_var | has_custom_image %}
					{% set imagens_menu = imagens_menu | merge([{ 'image': img_var, 'link': attribute(settings, link_var), 'title': attribute(settings, title_var) }]) %}
				{% endif %}
			{% endfor %}
		{% elseif menu_item_name == settings.custom_menu_name_b | upper | trim and settings.custom_menu_name_b is not empty %}
			{% for j in 1..4 %}
				{% set img_var = 'custom_menu_b_img_' ~ j ~ '.jpg' %}
				{% set link_var = 'custom_menu_b_link_' ~ j %}
				{% set title_var = 'custom_menu_b_title_' ~ j %}
				{% if img_var | has_custom_image %}
					{% set imagens_menu = imagens_menu | merge([{ 'image': img_var, 'link': attribute(settings, link_var), 'title': attribute(settings, title_var) }]) %}
				{% endif %}
			{% endfor %}
		{% elseif menu_item_name == settings.custom_menu_name_c | upper | trim and settings.custom_menu_name_c is not empty %}
			{% for j in 1..4 %}
				{% set img_var = 'custom_menu_c_img_' ~ j ~ '.jpg' %}
				{% set link_var = 'custom_menu_c_link_' ~ j %}
				{% set title_var = 'custom_menu_c_title_' ~ j %}
				{% if img_var | has_custom_image %}
					{% set imagens_menu = imagens_menu | merge([{ 'image': img_var, 'link': attribute(settings, link_var), 'title': attribute(settings, title_var) }]) %}
				{% endif %}
			{% endfor %}
		{% elseif menu_item_name == settings.custom_menu_name_d | upper | trim and settings.custom_menu_name_d is not empty %}
			{% for j in 1..4 %}
				{% set img_var = 'custom_menu_d_img_' ~ j ~ '.jpg' %}
				{% set link_var = 'custom_menu_d_link_' ~ j %}
				{% set title_var = 'custom_menu_d_title_' ~ j %}
				{% if img_var | has_custom_image %}
					{% set imagens_menu = imagens_menu | merge([{ 'image': img_var, 'link': attribute(settings, link_var), 'title': attribute(settings, title_var) }]) %}
				{% endif %}
			{% endfor %}
		{% endif %}
	{% endif %}


	{% if item.subitems or (not subitem and imagens_menu | length > 0) %}
		<li class="{% if megamenu %}js-desktop-nav-item js-item-subitems-desktop nav-item-desktop {% if not subitem %}js-nav-main-item nav-dropdown nav-main-item {% endif %}{% endif %} nav-item item-with-subitems" data-component="menu.item">
			{% if megamenu %}
			<div class="nav-item-container">
			{% endif %}
				<a class="{% if hamburger and not subitem %}js-toggle-menu-panel align-items-center{% endif %} {% if (megamenu and subitem and item.subitems) or (hamburger and subitem and item.subitems) %}js-desktop-submenu-toggle{% endif %} nav-list-link position-relative {{ item.current ? 'selected' : '' }}" href="{% if megamenu and item.url %}{{ item.url }}{% else %}#{% endif %}">{{ item.name }}
					{% if hamburger %}
						{% if subitem and item.subitems %}
							<span class="nav-list-arrow ml-1 transition-toggle">
								<svg class="icon-inline icon-sm svg-icon-text"><use xlink:href="#chevron-down"/></svg>
							</span>
						{% else %}
							<span class="nav-list-arrow ml-1">
								<svg class="icon-inline icon-md svg-icon-text"><use xlink:href="#chevron"/></svg>
							</span>
						{% endif %}
					{% endif %}
					{% if megamenu and subitem and item.subitems %}
						<span class="nav-list-arrow ml-1 transition-toggle">
							<svg class="icon-inline icon-sm svg-icon-text"><use xlink:href="#chevron-down"/></svg>
						</span>
					{% endif %}
				</a>
			{% if megamenu %}
			</div>
			{% endif %}
			{% if megamenu and not subitem %}
				<div class="js-desktop-dropdown nav-dropdown-content desktop-dropdown">
					<div class="container-fluid desktop-dropdown-container">
			{% endif %}

				<ul class="{% if megamenu %}{% if not subitem %}desktop-list-subitems{% else %}desktop-submenu-list{% endif %} {% elseif hamburger and subitem %}desktop-submenu-list mobile-accordion-list{% else %}js-menu-panel nav-list-panel nav-list-panel-right {{ hamburger_desktop_subpanels_position }} {% endif %} list-subitems {% if imagens_menu | length > 0 %}col-xl-6 d-xl-inline-block align-top{% endif %}" {% if (hamburger and not subitem) or (megamenu and subitem) or (hamburger and subitem) %}style="display:none;"{% endif %}>
					{% if hamburger and not subitem %}
						<div class="modal-header">
							<div class="row no-gutters">
								<div class="col">
									<a class="js-toggle-menu-back" href="#">
										<div class="row no-gutters align-items-center">
											<div class="col-auto">
												<span class="modal-back pr-2 mr-1">
													<svg class="icon-inline icon-flip-horizontal svg-icon-text"><use xlink:href="#chevron"/></svg>
												</span>
											</div>
											<div class="col my-3 text-center">
												{{ item.name }}
											</div>
										</div>
									</a>
								</div>
								<div class="col-auto">
									<a class="js-toggle-menu-close js-modal-close modal-close">
										<svg class="icon-inline icon-lg modal-close-icon"><use xlink:href="#times"/></svg>
									</a>
								</div>
							</div>
						</div>
						<div class="modal-body p-0">
							{% if item.isCategory %}
								<li class="nav-item py-1">
									<a class="nav-list-link position-relative font-body py-3 {{ item.current ? 'selected' : '' }}" href="{{ item.url }}">
										{% if item.isRootCategory %}
											{{ 'Ver todos os produtos' | translate }}
										{% else %}
											{{ 'Ver todo em' | translate }} {{ item.name }}
										{% endif %}
									</a>
								</li>
							{% endif %}
					{% endif %}


					{# Logica: Link ver tudo (Desktop e Mobile) - Apenas para subitens (nao na principal/root) #}
					{% if (hamburger or megamenu) and subitem %}
						<li class="nav-item" style="margin-bottom: 5px;">
							<a class="nav-list-link" href="{{ item.url }}" style="text-decoration: underline; font-weight: bold; font-size: 14px;">
								{{ 'Ver tudo em' | translate }} {{ item.name }}
							</a>
						</li>
					{% endif %}



					{% include 'snipplets/navigation/navigation-nav-list.tpl' with { 'navigation' : item.subitems, 'subitem' : true, 'hamburger' : hamburger, 'megamenu': megamenu } %}
					
					{% if hamburger and imagens_menu | length > 0 %}
						<div class="menu-images-mobile mt-3 px-3">
							<div class="row no-gutters">
								{% for img in imagens_menu %}
									{% set img_src = img.image | static_url | settings_image_url('large') %}
									{% set img_title = img.title %}
									{% set img_link = img.link %}

									<div class="col-6 p-1">
										{% if img_link %}
											<a href="{{ img_link }}">
										{% endif %}
											<figure class="image position-relative" style="padding-bottom: 100%; overflow: hidden;">
												<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ img_src }}" class='lazyload navigation-banner image' style="object-fit: cover; width: 100%; height: 100%; position: absolute; top: 0; left: 0;" alt="{{ item.name }}"/>
												{% if img_title %}
													<div class="position-absolute d-flex align-items-end" style="bottom: 0; left: 0; right: 0; background: linear-gradient(transparent, rgba(0,0,0,0.7)); padding: 15px 10px 10px; z-index: 2;">
														<span class="font-weight-bold" style="color: #ffffff !important;">{{ img_title | upper }}</span>
													</div>
												{% endif %}
											</figure>
										{% if img_link %}
											</a>
										{% endif %}
									</div>
								{% endfor %}
							</div>
						</div>
					{% endif %}
					
					{% if hamburger and not subitem %}
						</div>
					{% endif %}
				</ul>

			{% if not hamburger and imagens_menu | length > 0 %}
				<div class="col-xl-6 d-none d-xl-inline-block menu-imagens-grid mt-3 align-top">
					<div class="row justify-content-center">
						{% for img in imagens_menu %}
							{% set img_src = img.image | static_url | settings_image_url('huge') %}
							{% set img_title = img.title %}
							{% set img_link = img.link %}

							<div class="col-6 mb-2 px-2">
								{% if img_link %}
									<a href="{{ img_link }}">
								{% endif %}
									<figure class="image position-relative" style="padding-bottom: 150%; overflow: hidden;">
										<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ img_src }}" class='lazyload navigation-banner image' style="object-fit: cover; width: 100%; height: 100%; position: absolute; top: 0; left: 0;" alt="{{ item.name }}"/>
										{% if img_title %}
											<div class="position-absolute d-flex align-items-end" style="bottom: 0; left: 0; right: 0; background: linear-gradient(transparent, rgba(0,0,0,0.7)); padding: 15px 10px 10px; z-index: 2; justify-content: center">
												<span class="font-weight-bold" style="color: #ffffff !important;">{{ img_title | upper }}</span>
											</div>
										{% endif %}
									</figure>
								{% if img_link %}
									</a>
								{% endif %}
							</div>
						{% endfor %}
					</div>
				</div>
			{% endif %}
			
			{% if megamenu and not subitem %}
					</div>
				</div>
			{% endif %}
		</li>
	{% else %}
		<li class="js-desktop-nav-item {% if megamenu %}{% if not subitem %}js-nav-main-item nav-main-item{% endif %} nav-item-desktop{% endif %} nav-item" data-component="menu.item">
			<a class="nav-list-link {{ item.current ? 'selected' : '' }}" href="{% if item.url %}{{ item.url | setting_url }}{% else %}#{% endif %}">{{ item.name }}</a>
		</li>
	{% endif %}
{% endfor %}
