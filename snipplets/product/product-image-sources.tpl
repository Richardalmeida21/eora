{# Raw filenames preserve the uploaded JPG/PNG; product_image_url('original') is a 1024 px derivative. #}
{# json_encode(1) uses PHP JSON_HEX_TAG so uploaded text cannot close this inert script. #}
<script type="application/json" data-eora-product-image-sources>
{
    "product_id": {{ product.id | json_encode | raw }},
    "tags": [{% for tag in product.tags %}{{ tag.tag | default(tag) | json_encode(1) | raw }}{% if not loop.last %},{% endif %}{% endfor %}],
    "images": [
        {% for image in product.images %}
        {
            "filename": {{ image.image | json_encode(1) | raw }},
            "resized_url": {{ (image | product_image_url('original')) | json_encode(1) | raw }},
            "width": {{ image.dimensions.width | default(0) | json_encode | raw }},
            "height": {{ image.dimensions.height | default(0) | json_encode | raw }}
        }{% if not loop.last %},{% endif %}
        {% endfor %}
    ]
}
</script>
