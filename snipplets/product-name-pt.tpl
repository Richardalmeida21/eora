{# Read complete current data, then the previous snapshot if an FTP switch is in progress. #}
{%- macro get(product_id, fallback, current_language, languages) -%}
    {%- set lookup = {oe_title_lookup: true, oe_title_product_id: product_id, oe_title_fallback: fallback, oe_title_current_language: current_language, oe_title_languages: languages} -%}
    {%- set rendered -%}{%- include "snipplets/product-name-pt-v2-data.tpl" ignore missing with lookup -%}{%- endset -%}
    {%- if not rendered -%}
        {%- set rendered -%}{%- include "snipplets/product-name-pt-v2-data.backup.tpl" ignore missing with lookup -%}{%- endset -%}
    {%- endif -%}
    {{- rendered | default(fallback) | raw -}}
{%- endmacro -%}
{%- macro full(product_id, base_name, full_name, current_language, languages) -%}
    {%- import _self as titles -%}
    {%- set base = titles.get(product_id, base_name, current_language, languages) ~ '' -%}
    {%- if base_name and full_name starts with base_name -%}{{- (base ~ (full_name | slice(base_name | length))) | raw -}}{%- else -%}{{- full_name | raw -}}{%- endif -%}
{%- endmacro -%}
