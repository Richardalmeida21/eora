{% if settings.social_fixed_show and settings.social_fixed_links and settings.social_fixed_links is not empty %}
    <div class="social-fixed-sidebar">
        {% for social in settings.social_fixed_links %}
            <div class="social-fixed-item">
                {% if social.link %}
                    <a href="{{ social.link | setting_url }}" target="_blank" rel="noopener noreferrer" class="social-fixed-link">
                {% else %}
                    <div class="social-fixed-link">
                {% endif %}
                        <img 
                            src="{{ 'images/empty-placeholder.png' | static_url }}" 
                            data-src="{{ social.image | static_url | settings_image_url('tiny') }}" 
                            class="lazyload social-fixed-icon" 
                            alt="Rede social"
                        >
                {% if social.link %}
                    </a>
                {% else %}
                    </div>
                {% endif %}
            </div>
        {% endfor %}
    </div>
{% endif %}