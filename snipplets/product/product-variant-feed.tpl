{# Internal metadata response. Reuse the native reference list and selected variant;
   no description, players, scripts, applications or store layout are needed. #}
<div id="single-product" data-variants="{{ product.variants_object | json_encode | escape }}" data-product-tags="{{ product.tags | json_encode | escape }}">
    <span class="js-product-name">{{ product.name | escape }}</span>
    <form id="product_form" class="js-product-form">
        <input type="hidden" name="add_to_cart" value="{{ product.id }}">
        <input type="hidden" name="variant_id" value="{{ product.selected_or_first_available_variant.id }}">
        {% include 'snipplets/product/product-variants.tpl' with {current_product: product, show_size_guide: false} %}
    </form>
</div>
