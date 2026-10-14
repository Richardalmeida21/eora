{# Local fallback. Production data is generated privately by the title workflow. #}
{%- macro get(product_id, fallback, current_language, languages) -%}{{- fallback | raw -}}{%- endmacro -%}
