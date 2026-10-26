{# Raw filenames preserve the uploaded JPG/PNG; product_image_url('original') is a 1024 px derivative. #}
{# JSON_HEX_TAG | JSON_HEX_AMP preserves text inside the template without HTML/entity parsing. #}
{# A template also survives legacy navigation that reexecutes every script without its type. #}
<template data-eora-product-image-sources>
{
    "product_id": {{ product.id | json_encode | raw }},
    "tags": [{% for tag in product.tags %}{{ tag.tag | default(tag) | json_encode(3) | raw }}{% if not loop.last %},{% endif %}{% endfor %}],
    "images": [
        {% for image in product.images %}
        {
            "filename": {{ image.image | json_encode(3) | raw }},
            "resized_url": {{ (image | product_image_url('original')) | json_encode(3) | raw }},
            "width": {{ image.dimensions.width | default(0) | json_encode | raw }},
            "height": {{ image.dimensions.height | default(0) | json_encode | raw }}
        }{% if not loop.last %},{% endif %}
        {% endfor %}
    ]
}
</template>
