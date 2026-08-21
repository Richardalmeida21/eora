{% if store.allows_checkout_styling %}

{#/*============================================================================
checkout.scss.tpl

    -This file contains all the theme styles related to the checkout based on settings defined by user from config/settings.txt
    -Rest of styling can be found in:
        -static/css/style-async.css --> For non critical styles witch will be loaded asynchronously
        -static/css/style-critical.css --> For critical CSS rendered inline before the rest of the site

==============================================================================*/#}

{#/*============================================================================
  Global
==============================================================================*/#}

{# /* // Colors */ #}

:root {

  {#/*============================================================================
    #Colors
  ==============================================================================*/#}

  {#### Colors settings #}

  {# Main colors #}

  {% set main_background = settings.background_color %}
  {% set main_foreground = settings.text_color %}
  {% set accent_color = settings.accent_color %}

  {% set button_background = settings.button_background_color %}
  {% set button_foreground = settings.button_foreground_color %}
  
  {% set label_background = settings.label_background_color %}
  {% set label_foreground = settings.label_foreground_color %}

  {% set header_background = settings.header_colors ? settings.header_background_color : main_background %}
  {% set header_foreground = settings.header_colors ? settings.header_foreground_color : main_foreground %}

  --main-background: {{ settings.background_color | default('rgb(252, 252, 252)' | raw ) }};
  --main-foreground: {{ settings.text_color | default('rgb(102, 102, 102)' | raw ) }};
  --accent-color: {{ settings.accent_color | default('rgb(77, 190, 207)' | raw ) }};;

  --button-background: {{ button_background }};
  --button-foreground: {{ button_foreground }};

  --label-background: {{ label_background }};
  --label-foreground: {{ label_foreground }};

  {# Optional colors #}

  --header-background: {{ header_background }};
  --header-foreground: {{ header_foreground }};

  {# Color shades #}

  {# Opacity hex levels #}

  {% set opacity_05 = '0D' %}
  {% set opacity_10 = '1A' %}
  {% set opacity_15 = '26' %}
  {% set opacity_20 = '33' %}
  {% set opacity_30 = '4D' %}
  {% set opacity_50 = '80' %}
  {% set opacity_60 = '99' %}
  {% set opacity_80 = 'CC' %}

  --main-foreground-opacity-05: {{ main_foreground }}{{ opacity_05 }};
  --main-foreground-opacity-10: {{ main_foreground }}{{ opacity_10 }};
  --main-foreground-opacity-15: {{ main_foreground }}{{ opacity_15 }};
  --main-foreground-opacity-20: {{ main_foreground }}{{ opacity_20 }};
  --main-foreground-opacity-30: {{ main_foreground }}{{ opacity_30 }};
  --main-foreground-opacity-50: {{ main_foreground }}{{ opacity_50 }};
  --main-foreground-opacity-60: {{ main_foreground }}{{ opacity_60 }};
  --main-foreground-opacity-80: {{ main_foreground }}{{ opacity_80 }};

  --main-background-opacity-10: {{ main_background }}{{ opacity_10 }};
  --main-background-opacity-50: {{ main_background }}{{ opacity_50 }};

  --accent-color-opacity-10: {{ accent_color }}{{ opacity_10 }};
  --accent-color-opacity-15: {{ accent_color }}{{ opacity_15 }};
  --accent-color-opacity-20: {{ accent_color }}{{ opacity_20 }};
  --accent-color-opacity-50: {{ accent_color }}{{ opacity_50 }};
  --accent-color-opacity-80: {{ accent_color }}{{ opacity_80 }};

  {# Alert colors CSS #}

  --danger: #c13a3a;

  {#/*============================================================================
    #Fonts
  ==============================================================================*/#}

  {# Font families #}

  --heading-font: {{ settings.font_headings | default('Lexend') | raw }};
  --body-font: {{ settings.font_rest | default('Lexend') | raw }};

  {#/*============================================================================
    #Misc
  ==============================================================================*/#}

  {# Borders #}

  --border-radius: 0;
  --border-color: var(--main-foreground-opacity-50);

  {# Box #}

  --box-background: var(--main-background-opacity-10);
  --box-shadow: 0 0 5px var(--main-foreground-opacity-20);

}

{# /* // Mixins */ #}

@mixin prefix($property, $value, $prefixes: ()) {
	@each $prefix in $prefixes {
    	#{'-' + $prefix + '-' + $property}: $value;
	}
   	#{$property}: $value;
}

{#/*============================================================================
  React
==============================================================================*/#}


$xs: 0;
$sm: 576px;
$md: 768px;
$lg: 992px;
$xl: 1200px;

body {
  font-family: var(--body-font);
  color: var(--main-foreground);
  background-color: var(--main-background);
  font-size: 14px;
}
a {
  color: var(--main-foreground);
  text-decoration: none;
  &:hover, &:focus {
    color: var(--main-foreground-opacity-60);
    
    svg {
      fill: var(--main-foreground);
    }
  }

  svg {
    fill: var(--accent-color);
  }
}

{# /* // Text */ #}

.title {
  color: var(--main-foreground);
}

.heading-small {
  font-size: 18px;
  font-weight: normal;
}

.text-small {
  font-size: 12px;
}

{# /* // Header */ #}

.header { 
  background-color: var(--main-background);
  border-color: var(--accent-color);
}

.security-seal {
  color: var(--header-foreground);
}

{# /* // Headbar */ #}

.headbar {
  padding: 0;
  background: var(--header-background);
  box-shadow: none;

  .container {
    max-width: 100%;
    width: 100%;
    padding: 0 15px;
    border: 0;

    .row {
      -ms-flex-align: center;
      align-items: center;

      {% if settings.logo_position_desktop == 'center' %}
        -ms-flex-pack: center!important;
        justify-content: center!important;

        > .text-left {
          text-align: center !important;
          -ms-flex: 0 0 50%;
          flex: 0 0 50%;
          max-width: 50%;
          margin-left: 25%;
        }
      {% endif %}
    }
  }
}

.headbar-logo-img {
  max-width: 100%;
  max-height: 40px;
}

.headbar-logo-text {
  float: none;
  color: var(--header-foreground);
  font-weight: 700;

  &:hover {
    color: var(--header-foreground);
    opacity: .8;
  }

  &:focus {
    color: var(--main-background);
  }
}

.headbar-continue {
  margin: 0 !important;
  font-weight: 400;
  color: var(--header-foreground);
  &:hover,
  &:focus {
    color: var(--header-foreground);
    opacity: .8;

    .headbar-continue-icon {
      fill: var(--header-foreground);
    }
  }
  &-icon {
    margin-left: 5px;
    fill: var(--header-foreground);
  }
}

{# /* // Form */ #}

.form-group {
  margin-bottom: 15px;
}
.form-control {
  background: var(--main-background);
  border-color: var(--border-color);
  color: var(--main-foreground);
  font-family: var(--body-font);
  border-radius: var(--border-radius);

  &:focus {
    border-color: var(--main-foreground);
    outline: none;    
  }
}
.form-group.form-group-error .form-control {
  border-radius: var(--border-radius);
}
.form-options-content {
  font-size: 12px;
  line-height: 16px;
  color: var(--main-foreground-opacity-60);
  border: 0;
}
.form-group input[type="radio"] + .form-options-content .unchecked {
  fill: var(--main-foreground-opacity-10);
}
.form-group input[type="radio"] + .form-options-content .checked {
  fill: var(--accent-color);
}
.form-group input[type="radio"]:checked + .form-options-content {
  border: 1px solid var(--accent-color);
  border-color: var(--main-foreground-opacity-10);
  
  + .form-options-accordion {
    border-color: var(--main-foreground-opacity-10);
  }
  
  .checked {
    fill: var(--accent-color);
  }
}
.form-group input[type="checkbox"]:checked + .form-options-content .checked {
  fill: var(--main-foreground);
}
.form-group input[disabled] + .form-options-content {
  border-color: var(--main-foreground-opacity-10) !important;
  
  .form-options-label {
    color: var(--main-foreground) !important;
  }
  .checked {
    fill: var(--main-foreground) !important;
  }
}
.form-group input[type="checkbox"] + .form-options-content .form-group-icon {
  border-radius: 2px;
  overflow: hidden;
}
.form-group input[type="checkbox"] + .form-options-content svg {
  width: 13px;
  height: 13px;
}
.form-group input[type="checkbox"] + .form-options-content .unchecked {
  width: 13px;
  fill: var(--main-foreground);
}

{# /* // Input */ #}

.has-float-label>span,
.has-float-label label {
  padding: 1px 0 0 7px;
  font-weight: 400;
}

.has-float-label .form-control-help {
  z-index: 1;
}

.input-label {
  color: var(--main-foreground);
}

.select-icon {
  fill: var(--main-foreground);
  svg {
    width: 10px;
  }
}

{# /* // Buttons */ #}

.btn {
  border-radius: var(--border-radius);
}
.btn-primary {
  padding: 15px;
  color: var(--button-foreground);
  background: var(--button-background);
  border-radius: var(--border-radius);
  font-size: 14px;
  line-height: 18px;
  text-transform: none !important;

  &:hover,
  &:focus,
  &:active {
    color: var(--button-foreground);
    background: var(--button-background);
    opacity: 0.9;
  }
}
.btn-secondary {
  min-width: auto;
  padding: 0;
  color: var(--button-background);
  font-size: 12px;
  line-height: 10px;
  border: 0;
  border-radius: var(--border-radius);
  background: var(--main-background);
  text-decoration: underline;

  &:hover,
  &:focus,
  &:active,
  &:active:focus {
    background: var(--main-background);
    color: var(--button-background);
    border-color: var(--button-background);
    opacity: .8;

    .btn-icon-right {
      fill: var(--button-background);
    }
  }
  .btn-icon-right {
    fill: var(--accent-color);
  }
}
.btn-transparent {
  color: var(--main-foreground);

  &:hover {
    color: var(--main-foreground);
    opacity: .6;
    
    .btn-icon-right {
      fill: var(--main-foreground);
    }
  }

  .btn-icon-right {
    width: 10px;
    fill: var(--main-foreground);
  }
}

.btn-link {
  color: var(--main-foreground);
  font-size: 12px;
  font-weight: normal;
  text-transform: initial;
  &:hover {
    color: var(--main-foreground-opacity-60);

    svg {
      fill: var(--main-foreground-opacity-60);
    }
  }
}

.btn:active {
  box-shadow: none;
}

.btn-picker {
  border-color: var(--border-color);
  border-radius: var(--border-radius);
}

.login-info {
  margin: 10px 0 0;
  font-size: 12px;
  text-align: left;
}

{# /* // Breadcrumb */ #}

.breadcrumb {
  max-width: 100%;
  margin: 0;
  li .breadcrumb-step {
    margin: 0;
    font-size: 12px;
    color: var(--main-foreground-opacity-60);
    background: none;
    text-transform: none;

    &.active {
      color: var(--main-foreground);
      background: none;

      &:before,
      &:after {
        position: relative;
        margin: 0 5px;
        border: 0;
        content: "|";
        opacity: .6;
      }
    }

    &.visited {
      color: var(--main-foreground-opacity-60);
      background: none;
    }
  }
  li:first-child .breadcrumb-step,
  li:last-child .breadcrumb-step {
    padding: 0;
  }
}

{# /* // Accordion */ #}

.accordion {
  color: var(--main-foreground);
  background-color: var(--main-background);
  border-radius: var(--border-radius);
  box-shadow: 0 1px 3px -1px var(--main-foreground-opacity-10);
  border-color: var(--main-foreground-opacity-15); 
}

.accordion-section-header-icon {
  fill: var(--main-foreground);
}

.accordion-rotate-icon {
  fill: var(--main-foreground);
}

{# /* // Summary */ #}

.summary {
  top: 0;
}
.summary-img {
  &-thumb {
    left: 0;
    border-radius: 0;
    background: none;
  }
  img {
    max-height: fit-content;
  }
}

.mobile-discount-coupon_btn {
  border-radius: var(--border-radius);
  border-color: var(--main-foreground-opacity-10);
  color: var(--main-foreground-opacity-80);
  
  .icon {
    color: var(--main-foreground-opacity-80);
  }
}

.panel.summary-details {
  background: var(--main-background);
  overflow: hidden;
}
.summary-container {
  padding: 10px 15px;
  background: var(--main-background);
  border-top: 1px solid var(--main-foreground-opacity-20);
  border-bottom: 1px solid var(--main-foreground-opacity-20);
  box-shadow: none;
}
.summary-total {
  font-size: 16px;
  font-weight: 700;
  color: var(--main-foreground);
  background: none;
}

.summary-arrow-rounded {
  width: auto;
  background: none;
  .summary-arrow-icon {
    fill: var(--main-foreground);
  }
}

.summary-title {
  color: var(--main-foreground);
  font-size: 12px;
  text-decoration: underline;
}

.summary-coupon {
  padding: 0;
  &+.breadcrumb {
    margin: 0;
  }
}

{# /* // Radio */ #}

.radio-group {

  &.radio-group-accordion {
    border: none;
    overflow: hidden;

    .radio {
      padding: 10px 0;
      border: 0;
      &.active {
        .description {
          color: var(--main-background);
        }
        .payment-item-discount {
          color: var(--main-background);
        }
      }
      .description {
        width: calc(100% - 35px);
        margin-left: 35px;
        font-weight: 400;
      }
    }
  }
}

.radio input:checked + .selector:before {
  background-image: none;
  border-color: var(--main-foreground);
}
.radio input:disabled:checked + .selector:before {
  background-image: radial-gradient(circle, rgba(0, 0, 0, 0.5) 0%, rgba(0, 0, 0, 0.5) 50%, transparent 50%, transparent 100%);
}
.radio input:checked + .selector:after {
  position: absolute;
  left: 4px;
  bottom: 4px;
  width: 8px;
  height: 8px;
  background: var(--main-foreground);
  content: '';
}
.radio .selector {
  position: relative;

  &:before {
    width: 16px;
    height: 16px;
    margin: 1px 15px 0 0;
    background-color: var(--main-background);
    border-color: var(--main-foreground);
    border-radius: 0;
  }
}

.radio-content {
  margin-bottom: 20px;
  padding: 10px 0 0;
  background: var(--main-background);
  border: 0;
  box-shadow: none;

  .text-center {
    text-align: left !important;
  }
  .p-all {
    padding-top: 0 !important;
  }
}

.shipping-option {
  position: relative;
  margin-bottom: -1px;
  padding: 15px;
  border: 1px solid var(--main-foreground);
  border-radius: var(--border-radius);

  &.active {
    border-color: var(--main-foreground);
  }

  .selector {
    position: absolute;
    top: 5px;
    left: 15px;
    width: 15px;
    margin: 0;
    text-align: center;
    &:before {
      margin: 10px 0 0 0;
    }
  }
}

{# /* // Panel */ #}

.panel {
  padding: 0;
  color: var(--main-foreground);
  background-color: var(--main-background);
  box-shadow: none;
  border: 0;
  border-radius: var(--border-radius);
  &.panel-with-header {
    padding-top: 5px;
    p {
      margin-top: 0;
    }
  }
  &.text-center {
    text-align: left !important;
  }
  .shipping-address-container .panel-subheader:before {
    display: none;
  }
}
.panel-header {
  margin: 0 !important;
  font-size: 14px;
  font-weight: bold;
  color: var(--main-foreground);
  text-align: left;
  border: 0;
  text-shadow: none;
  text-transform: uppercase;
}
.panel-header-tooltip {
  padding: 0 5px;
}
.panel-header-sticky {
  background-color: var(--main-background);
}
.panel-header-button {
  position: absolute;
  top: 13px;
  right: 0;
  z-index: 2;
  width: auto;
}
.panel-subheader {
  margin: 5px 0 10px 0;
  font-size: 12px;
  font-weight: normal;
}
.panel-footer {
  background: var(--main-foreground-opacity-05);
  &-wa {
    border-color: var(--main-foreground-opacity-05);
  }
}
.panel-footer-form {
  input {
    border-color: var(--main-foreground);
  }
  .input-group-addon {
    background: var(--main-background);
    border-color: var(--main-foreground);
  }
  .disabled {
    background: var(--main-foreground-opacity-10) !important;
  }
}

{# /* // Table */ #}

.table-footer {
  font-size: 18px;
  font-weight: bold;
  color: var(--main-foreground);
  border: 0;
}

.table-subtotal {
  margin: 0;
  padding: 10px 0;
  border: 0;
  td {
    padding: 5px 15px;
  }
}

.table .table-discount-coupon,
.table .table-discount-promotion {
  color: var(--accent-color);
  border: 0;
}

{# /* // Shipping Options */ #}

.shipping-options {
  color: var(--main-foreground-opacity-80);

  .radio-group {
    border-radius: var(--border-radius);
    box-shadow: 0 1px 3px -1px var(--main-foreground-opacity-10);
    overflow: hidden;
  }

  .btn {
    margin: 0;
    background: var(--main-background);
  }

}

.new-shipping-flow .shipping-options .radio-group {
  box-shadow: none;
  overflow: inherit;
}

.new-shipping-flow .shipping-options .btn {
  padding-top: 15px;
  border: 0;
}

.new-shipping-flow .shipping-options .btn span {
  text-decoration: underline;
}

.new-shipping-flow .shipping-options .btn .btn-icon-right {
  display: none;
}

.shipping-method-item {
  margin-left: 25px;
  > span {
    width: 100%;
  }
}

.shipping-method-item-desc,
.shipping-method-item-name {
  max-width: 70%;
  color: var(--main-foreground);
  font-size: 12px;
  font-weight: normal;
}

.shipping-method-item-desc {
  opacity: .6 !important;
}

{# /* // EORA: logos das transportadoras nas opcoes de entrega */ #}

/* O checkout remove "table_" do codigo do Sedex Expresso Gratis. */
.shipping-option[id^="radio-option-sedex"] .shipping-method-item-name,
.shipping-option[id^="radio-option-pac"] .shipping-method-item-name,
.shipping-option[id^="radio-option-7580263"] .shipping-method-item-name,
.shipping-option[id^="radio-option-loggi"] .shipping-method-item-name {
  display: flex;
  align-items: center;
  gap: 8px;
  max-width: calc(100% - 110px);
  min-height: 20px;
}

.shipping-option[id^="radio-option-sedex"] .shipping-method-item-name:after,
.shipping-option[id^="radio-option-pac"] .shipping-method-item-name:after,
.shipping-option[id^="radio-option-7580263"] .shipping-method-item-name:after,
.shipping-option[id^="radio-option-loggi"] .shipping-method-item-name:after {
  content: "";
  display: inline-block;
  flex: 0 0 auto;
  pointer-events: none;
  background-position: center;
  background-repeat: no-repeat;
  background-size: contain;
}

.shipping-option[id^="radio-option-sedex"] .shipping-method-item-name:after,
.shipping-option[id^="radio-option-pac"] .shipping-method-item-name:after,
.shipping-option[id^="radio-option-7580263"] .shipping-method-item-name:after {
  width: 78px;
  height: 18px;
  background-image: url("data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPCEtLSBHZW5lcmF0b3I6IEFkb2JlIElsbHVzdHJhdG9yIDIwLjAuMCwgU1ZHIEV4cG9ydCBQbHVnLUluIC4gU1ZHIFZlcnNpb246IDYuMDAgQnVpbGQgMCkgIC0tPgo8c3ZnIHZlcnNpb249IjEuMSIgaWQ9IkxheWVyXzEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaWRZTWluIHNsaWNlIgoJICBzdHlsZT0iIHdpZHRoOiAxMDAlOyBvdmVyZmxvdzogdmlzaWJsZSIgdmlld0JveD0iMCAwIDQ0NS4zIDkxLjIiIG92ZXJmbG93PSJzY3JvbGwiIHhtbDpzcGFjZT0icHJlc2VydmUiID4KPHN0eWxlIHR5cGU9InRleHQvY3NzIj4KCS5zdDB7ZmlsbC1ydWxlOmV2ZW5vZGQ7Y2xpcC1ydWxlOmV2ZW5vZGQ7ZmlsbDp1cmwoI1NWR0lEXzFfKTt9Cgkuc3Qxe2ZpbGwtcnVsZTpldmVub2RkO2NsaXAtcnVsZTpldmVub2RkO2ZpbGw6dXJsKCNTVkdJRF8yXyk7fQoJLnN0MntmaWxsLXJ1bGU6ZXZlbm9kZDtjbGlwLXJ1bGU6ZXZlbm9kZDtmaWxsOnVybCgjU1ZHSURfM18pO30KCS5zdDN7ZmlsbC1ydWxlOmV2ZW5vZGQ7Y2xpcC1ydWxlOmV2ZW5vZGQ7ZmlsbDp1cmwoI1NWR0lEXzRfKTt9Cgkuc3Q0e2ZpbGw6IzBCQkJFRjt9Cgkuc3Q1e2ZpbGw6I0ZGRDUwMDt9Cgkuc3Q2e2ZpbGw6IzA2NDE2QTt9Cjwvc3R5bGU+CjxsaW5lYXJHcmFkaWVudCBpZD0iU1ZHSURfMV8iIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIiB4MT0iNjguODQxOCIgeTE9IjI4Ljg5MzgiIHgyPSIxMC4wNTM4IiB5Mj0iNzQuODI0Ij4KCTxzdG9wICBvZmZzZXQ9IjAiIHN0eWxlPSJzdG9wLWNvbG9yOiNGRkREMDAiLz4KCTxzdG9wICBvZmZzZXQ9IjAuOSIgc3R5bGU9InN0b3AtY29sb3I6I0Q0OUYwMCIvPgoJPHN0b3AgIG9mZnNldD0iMSIgc3R5bGU9InN0b3AtY29sb3I6I0ZGREQwMCIvPgo8L2xpbmVhckdyYWRpZW50Pgo8cGF0aCBjbGFzcz0ic3QwIiBkPSJNMzEuNyw5MS4yaC00Yy0zLjIsMC02LjEtMS41LTgtMy45TDAuNyw2Mi45QzAuMyw2Mi4zLDAsNjEuNiwwLDYwLjhjMC0wLjgsMC4zLTEuNSwwLjctMi4xbDE5LjEtMjQuNAoJYzEuOS0yLjQsNC43LTMuOSw4LTMuOUg3MGwtMjQsMzAuMUwyOC41LDgyLjZMMzEuNyw5MS4yeiIvPgo8bGluZWFyR3JhZGllbnQgaWQ9IlNWR0lEXzJfIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjcwLjAxNjEiIHkxPSI3NS44NjAzIiB4Mj0iMjcuMjE3NyIgeTI9Ijc1Ljg2MDMiPgoJPHN0b3AgIG9mZnNldD0iMCIgc3R5bGU9InN0b3AtY29sb3I6I0Q0OUYwMCIvPgoJPHN0b3AgIG9mZnNldD0iMSIgc3R5bGU9InN0b3AtY29sb3I6I0FCNTgwOCIvPgo8L2xpbmVhckdyYWRpZW50Pgo8cGF0aCBjbGFzcz0ic3QxIiBkPSJNNDYuMyw2MC44bC0wLjItMC4zTDI4LjUsODIuNmMtMC43LDAuOS0xLjMsMi4xLTEuMyw0LjFjMCwyLDEuOSw0LjUsNS43LDQuNUg3MEw0Ni4zLDYwLjh6Ii8+CjxsaW5lYXJHcmFkaWVudCBpZD0iU1ZHSURfM18iIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIiB4MT0iNTUuOTI3OCIgeTE9IjYyLjIxODMiIHgyPSIxMTQuODE5MyIgeTI9IjE2LjM3MjUiPgoJPHN0b3AgIG9mZnNldD0iMCIgc3R5bGU9InN0b3AtY29sb3I6IzAwNTM3RSIvPgoJPHN0b3AgIG9mZnNldD0iMC45IiBzdHlsZT0ic3RvcC1jb2xvcjojMThBQUUyIi8+Cgk8c3RvcCAgb2Zmc2V0PSIxIiBzdHlsZT0ic3RvcC1jb2xvcjojMTA3QkMwIi8+CjwvbGluZWFyR3JhZGllbnQ+CjxwYXRoIGNsYXNzPSJzdDIiIGQ9Ik05Ni4zLDguNkw5My4xLDBoNGMzLjIsMCw2LjEsMS41LDgsMy45bDE5LjEsMjQuNGMwLjQsMC42LDAuNywxLjMsMC43LDIuMWMwLDAuOC0wLjMsMS41LTAuNywyLjFMMTA1LDU2LjkKCWMtMS45LDIuNC00LjcsMy45LTgsMy45SDU0LjhsMjQtMzAuMUw5Ni4zLDguNnoiLz4KPGxpbmVhckdyYWRpZW50IGlkPSJTVkdJRF80XyIgZ3JhZGllbnRVbml0cz0idXNlclNwYWNlT25Vc2UiIHgxPSI5MS44MDM3IiB5MT0iLTQuMjExIiB4Mj0iNjYuNzkzNiIgeTI9IjE1LjMyOSI+Cgk8c3RvcCAgb2Zmc2V0PSIwIiBzdHlsZT0ic3RvcC1jb2xvcjojMDAyNTQyIi8+Cgk8c3RvcCAgb2Zmc2V0PSIxIiBzdHlsZT0ic3RvcC1jb2xvcjojMDA0MTY5Ii8+CjwvbGluZWFyR3JhZGllbnQ+CjxwYXRoIGNsYXNzPSJzdDMiIGQ9Ik03OC42LDMwLjRsMC4yLDAuM0w5Ni4zLDguNmMwLjctMC45LDEuMy0yLjEsMS4zLTQuMWMwLTItMS45LTQuNS01LjctNC41SDU0LjhMNzguNiwzMC40eiIvPgo8cGF0aCBjbGFzcz0ic3Q0IiBkPSJNOTcuMyw4LjJjMC43LTAuOSwxLjEtMS45LDEuMS0zLjFjMC0yLjgtMi4zLTUuMS01LjEtNS4xSDkyQzk0LjgsMCw5NywyLjMsOTcsNS4xYzAsMS4yLTAuNCwyLjMtMS4xLDMuMQoJTDc4LjYsMzAuNEw1NC45LDYwLjdMOTcuMyw4LjJ6Ii8+CjxwYXRoIGNsYXNzPSJzdDUiIGQ9Ik0yNy42LDgzYy0wLjcsMC45LTEuMSwxLjktMS4xLDMuMWMwLDIuOCwyLjMsNS4xLDUuMSw1LjFoMS4zYy0yLjgsMC01LjEtMi4zLTUuMS01LjFjMC0xLjIsMC40LTIuMywxLjEtMy4xCglsMTcuNC0yMi4yTDcwLDMwLjVMMjcuNiw4M3oiLz4KPHBhdGggY2xhc3M9InN0NiIgZD0iTTI4My4yLDQyLjhjLTIuNCwwLTQuMywwLjMtNi4zLDAuOWMtMy4yLDEtNS42LDIuNy03LjQsNS4xYy0zLjEsNC0zLDguOC0zLDguOHYzMy40aDguOWMwLjYsMCwxLTAuNSwxLTFWNTguMwoJYzAtMC42LDAuMS0yLjgsMS4zLTMuOWMxLTAuOSwyLjMtMS4zLDMuNi0xLjVjMS40LTAuMiwyLjgtMC4xLDMuNSwwYzAsMCwwLjEsMCwwLjIsMGMwLjcsMCwxLjItMC40LDEuNS0wLjlsNC42LTcuOQoJQzI4OC43LDQzLjIsMjg2LjEsNDIuNywyODMuMiw0Mi44Ii8+CjxwYXRoIGNsYXNzPSJzdDYiIGQ9Ik0yNTcsNDIuOGMtMi40LDAtNC40LDAuMy02LjMsMC45Yy0zLjIsMS01LjYsMi43LTcuNCw1LjFjLTMuMSw0LTMsOC44LTMsOC44djMzLjRoOC45YzAuNiwwLDEtMC41LDEtMVY1OC4zCgljMC0wLjYsMC4xLTIuOCwxLjMtMy45YzEtMC45LDIuMy0xLjMsMy42LTEuNWMxLjQtMC4yLDIuOC0wLjEsMy41LDBjMCwwLDAuMSwwLDAuMiwwYzAuNiwwLDEuMi0wLjQsMS41LTAuOUwyNjUsNDQKCUMyNjIuNCw0My4yLDI1OS45LDQyLjcsMjU3LDQyLjgiLz4KPHBhdGggY2xhc3M9InN0NiIgZD0iTTE3OS4yLDc4LjdjLTAuMy0wLjQtMC45LTAuNy0xLjUtMC43Yy0wLjMsMC0wLjcsMC4xLTAuOSwwLjNsMCwwYy0zLDEuOC02LjYsMi45LTEwLjQsMi45CgljLTExLjIsMC0yMC4zLTkuMS0yMC4zLTIwLjRjMC0xMS4yLDkuMS0yMC4zLDIwLjMtMjAuM2MzLjgsMCw3LjQsMSwxMC40LDIuOWMwLjMsMC4yLDAuNiwwLjMsMSwwLjNjMC42LDAsMS4xLTAuMywxLjUtMC43bDUuMS02LjYKCWMtNS0zLjctMTEuMi01LjktMTgtNS45Yy0xNi44LDAtMzAuNCwxMy42LTMwLjQsMzAuNGMwLDE2LjgsMTMuNiwzMC40LDMwLjQsMzAuNGM2LjcsMCwxMi45LTIuMiwxOC01LjlMMTc5LjIsNzguN3oiLz4KPHBhdGggY2xhc3M9InN0NiIgZD0iTTMxNC4zLDUxLjdMMzE0LjMsNTEuN2M2LjYsMCwxMi4yLDQuMywxNC4yLDEwLjJoLTI4LjNDMzAyLjIsNTYsMzA3LjgsNTEuNywzMTQuMyw1MS43IE0zMTQuMyw0Mi4xCgljLTEzLjUsMC0yNC41LDExLTI0LjUsMjQuNWMwLDEzLjQsMTEsMjQuNCwyNC41LDI0LjVjMC4yLDAsMC43LDAsMC43LDBjNS4zLDAsOS42LTAuNywxNS4zLTQuNGwwLjktMC42YzAsMC01LTYuNS01LjEtNi42CgljLTAuMy0wLjQtMC45LTAuNy0xLjQtMC43Yy0wLjMsMC0wLjYsMC4xLTAuOSwwLjJjLTEuMywwLjctNS4yLDIuNC05LjUsMi40Yy02LjUsMC0xMi00LjEtMTQuMS05LjloMzMuNmwzLjksMGMwLjYsMCwxLTAuNSwxLTEKCWwwLjEtMi44YzAtMC40LDAtMC43LDAtMS4xQzMzOC45LDUzLjEsMzI3LjksNDIuMSwzMTQuMyw0Mi4xeiIvPgo8cGF0aCBjbGFzcz0ic3Q2IiBkPSJNMzQ1LjYsOTEuMmMtMC42LDAtMS0wLjQtMS0xVjQ0LjdjMC0wLjUsMC40LTEsMS0xaDcuOWMwLjYsMCwxLDAuNSwxLDF2NDUuNWMwLDAuNi0wLjUsMS0xLDFIMzQ1LjZ6Ii8+CjxwYXRoIGNsYXNzPSJzdDYiIGQ9Ik0yMTAuNyw1MS41TDIxMC43LDUxLjVjLTguMiwwLTE0LjgsNi42LTE0LjgsMTQuOHM2LjYsMTQuOCwxNC44LDE0LjhjOC4yLDAsMTQuOC02LjYsMTQuOC0xNC44CglTMjE4LjksNTEuNSwyMTAuNyw1MS41IE0yMTAuNyw5MS4yYy0xMy43LDAtMjQuOC0xMS4xLTI0LjgtMjQuOGMwLTEzLjcsMTEuMS0yNC44LDI0LjgtMjQuOGMxMy43LDAsMjQuOCwxMS4xLDI0LjgsMjQuOAoJQzIzNS41LDgwLDIyNC40LDkxLjIsMjEwLjcsOTEuMnoiLz4KPHBhdGggY2xhc3M9InN0NiIgZD0iTTM4NC4xLDUxLjlMMzg0LjEsNTEuOWMtOC4xLDAtMTQuNyw2LjYtMTQuNywxNC43YzAsOC4xLDYuNiwxNC42LDE0LjcsMTQuNmM4LjEsMCwxNC43LTYuNiwxNC43LTE0LjYKCUMzOTguOCw1OC41LDM5Mi4yLDUxLjksMzg0LjEsNTEuOSBNMzg0LjEsOTEuMWMtMTMuNiwwLTI0LjYtMTEtMjQuNi0yNC42YzAtMTMuNiwxMS0yNC42LDI0LjYtMjQuNmMxMy42LDAsMjQuNiwxMSwyNC42LDI0LjYKCUM0MDguNyw4MC4xLDM5Ny43LDkxLjEsMzg0LjEsOTEuMXoiLz4KPHBhdGggY2xhc3M9InN0NiIgZD0iTTQzNi42LDYyLjhjLTEuNy0wLjgtMy45LTEuMy02LjMtMS45Yy0zLjUtMC45LTYuOC0xLjEtOC0zYy0xLjEtMS44LTAuNS0zLjgsMS00LjljMy41LTIuNCw4LjItMS40LDEwLjgtMC4yCgljMC41LDAuMiwyLjQsMS4zLDIuNCwxLjNjMC4zLDAuMiwwLjYsMC4zLDAuOSwwLjNjMC42LDAsMS4xLTAuMywxLjUtMC44YzAsMCw1LTYuNCw1LTYuNGwtMC44LTAuN2MtMC41LTAuNC0xLjItMC44LTEuOS0xLjIKCWMtMS41LTAuOC02LTMuNC0xMi41LTMuNGMtMC4yLDAtMC40LDAtMC42LDBjLTE0LjMsMC4zLTE2LjMsMTAuNC0xNi4zLDE0YzAsNS40LDIuOCw5LjMsNywxMS43YzMuNCwxLjksOS43LDMsMTIuOSw0CgljMS43LDAuNSwyLjksMS43LDMuNCwyLjhjMC4yLDAuNSwwLjMsMSwwLjMsMS42YzAuMSwxLjktMC45LDQtMy43LDQuOWMtMy4xLDAuOS03LjksMC41LTEyLjMtMi45Yy0wLjEtMC4xLTAuNi0wLjUtMC44LTAuNgoJYy0wLjItMC4xLTAuNC0wLjEtMC43LTAuMWMtMC42LDAtMS4xLDAuMy0xLjUsMC44Yy0wLjEsMC4xLTQuOSw2LjMtNC45LDYuM3MxLjcsMS40LDIuMywxLjhjMi44LDIuMSw3LjgsNC45LDE0LjMsNC45aDAuMgoJYzEzLjgsMCwxNy05LjgsMTctMTUuMkM0NDUuMyw3MC41LDQ0Miw2NS4yLDQzNi42LDYyLjgiLz4KPC9zdmc+Cg==");
}

.shipping-option[id^="radio-option-loggi"] .shipping-method-item-name:after {
  width: 52px;
  height: 22px;
  background-image: url("data:image/png;base64,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");
}

/* Compensa as margens transparentes do arquivo original da Loggi. */
.shipping-option[id^="radio-option-loggi"] .shipping-method-item-name:after {
  background-size: 73px 36px;
}

.shipping-method-item-price {
  float: right;
  font-weight: normal;
  color: var(--main-foreground);
  text-align: right;
}

.price-striked {
  display: block;
  margin: 5px 0 0 !important;
  font-size: 10px;
  color: var(--main-foreground-opacity-60);
}

{# /* // Discount Coupon */ #}

.box-discount-coupon {
  margin-top: -1px;
  button {
    color: var(--main-foreground);
    background: none;

    &:hover {
      opacity: .6;
      background: none;
    }
    svg {
      fill: var(--main-foreground);
    }
  }
}
.box-discount-coupon-applied {
  padding: 10px 15px;
  color: var(--main-foreground);
  background: none;
  border-radius: 0;
  font-size: 8px;
  line-height: 20px;
  letter-spacing: 1px;
  text-transform: uppercase;

  .btn-link {
    padding-top: 3px;
    color: var(--main-foreground);
    &:hover {
      color: var(--main-foreground-opacity-60);
    }
  }
  .coupon-icon {
    display: none;
  }
}


{# /* // Support */ #}

.support {
  margin: 0;
  padding: 20px 15px;
  svg {
    width: 14px;
    vertical-align: middle;
    fill: var(--main-foreground);
  }
  .btn-secondary {
    margin: 0 0 15px 0 !important;
  }
}

{# /* // User Detail */ #}

.user-detail {
  margin: 0 !important;
  padding: 15px 15px 15px 0;
  background: var(--main-background);
  border-radius: var(--border-radius);
  &-icon {
    width: 20px;
    margin-right: 10px;
    svg {
      left: initial;
      width: 15px;
      height: 16px;
      fill: var(--main-foreground);
    }
  }
  &-content {
    width: calc(100% - 30px);
    .text-semi-bold {
      font-size: 10px;
      font-weight: 400;
      letter-spacing: 1px;
    }
  }
}
  

{# /* // History */ #}

.history-item-done .history-item-title {
  color: var(--accent-color);
}
.history-item-failure .history-item-title {
  color: var(--danger);
}
.history-item-progress-icon svg {
  width: 20px;
  fill: var(--main-foreground-opacity-30);
}
.history-item-progress-icon:after {
  top: 20px;
  margin-left: -11px;
  fill: var(--main-foreground-opacity-30);
  border-left: 2px solid var(--main-foreground-opacity-30);
}
.history-item-progress-icon-failure svg {
  fill: var(--danger);
}
.history-item-progress-icon-success svg {
  fill: var(--accent-color);
}
.history-item-progress-icon-success:after {
  border-color: var(--main-foreground);
}

{# /* // History Canceled */ #}

.history-canceled {
  border-top-right-radius: var(--border-radius);
  border-top-left-radius: var(--border-radius);
}
.history-canceled-header {
  border-color: var(--border-color);
  border-top-left-radius: var(--border-radius);
  border-top-right-radius: var(--border-radius);
}
.history-canceled-icon svg {
  fill: var(--main-foreground-opacity-50);
}

{# /* // Offline Payment */ #}

.ticket-coupon {
  background: var(--main-foreground-opacity-05);
  border-color: var(--border-color);
}

{# /* // Buy fast */ #}
.panel-buy-fast {
  color: var(--main-foreground);
  fill: var(--main-foreground);
  background: var(--main-background);
  border: 1px solid var(--main-foreground-opacity-15);
  border-radius: var(--border-radius);
  box-shadow: none;
}

{# /* // Status, Destination & Sign Up */ #}

.success-order-id {
  padding-top: 52px;
  font-size: 12px;
  text-transform: uppercase;
  .opacity-50 {
    opacity: 1 !important;
  }
}

.status,
.destination,
.signup {
  padding: 10px 0 !important;
  &-icon {
    width: 10px;
    margin: 0;
    svg {
      left: initial;
      width: 15px;
      fill: var(--main-foreground);
    }
  }
  &-content {
    width: calc(100% - 80px);
    margin: 4px 0 0 20px;
  }
}

.signup {
  padding: 10px 15px !important;
  border: 1px solid var(--main-foreground);
  .signup-icon {
    display: none;
  }
}

.status,
.orderstatus {
  margin: 0;
  background: var(--main-background);
}

.destination {
  align-items: initial;
}

.destination-content .heading-small {
  margin-top: 2px!important;
}

.orderstatus.destination {
  padding: 10px 0 0;
  border: 0;
}

.fulfillments {
  border-bottom: none;
  &-thumb {
    margin-left: 0;
    img {
      border-radius: var(--border-radius);
    }
  }
}

.signup .icon-inside-input.align-right-password {
  right: 15px;
}

{# /* // Tracking */ #}

.history-item-progress {
  width: 70px;
  margin: -2px 0 0 0;
}

.history-item-content {
  width: calc(100% - 80px);
  max-width: 100%;
}

.history-item-message {
  max-width: 100%;
  font-size: 10px;
}

.tracking-item-time {
  color: var(--main-foreground);
}

{# /* // WhatsApp Opt-in */ #}

.whatsapp-form input, 
.whatsapp-form .input-group-addon {
  border-color: var(--accent-color);
}

{# /* // Helpers */ #}

.border-top {
  border-color: var(--border-color);
}

{# /* // Errors */ #}

.alert-danger-bagged {
  margin-top: 5px;
  border-radius: var(--border-radius);
  float: left;
  background: none;
  color: #cc4845;
}

.general-error {
  background: var(--danger);
  border-color: var(--danger);
}

{# /* // Badge */ #}

.badge {
  border: 0;
}

{# /* // Payment */ #}

.payment-category-label {
  font-size: 8px;
  text-transform: uppercase;
  letter-spacing: 1px;

  &.text-semi-bold {
    font-weight: normal;
  }
}

.payment-item-discount {
  display: inline-block;
  float: left;
  clear: initial;
  margin: -1px 0 0 10px;
  padding: 4px 6px;
  color: var(--label-foreground);
  background: var(--label-background);
  font-size: 10px;
  text-transform: uppercase;
}

.payment-option {
  margin-bottom: -1px;
  border-radius: var(--border-radius);
  color: var(--main-foreground);
  border: 1px solid var(--main-foreground);
}

.radio-content.payment-option-content {
  background: var(--main-background);
  border: 1px solid var(--main-foreground);
  border-top: 0;
  border-radius: var(--border-radius);
}


{# /* // Overlay */ #}

.overlay {
  background: var(--main-foreground-opacity-15);
}
.overlay-title {
  color: var(--main-foreground-opacity-60);
}

{# /* // List Picker */ #}

.list-picker .unchecked {
  fill: var(--main-foreground);
}
.list-picker li {
  border-color: var(--border-color);
  background: var(--main-background);

  &:hover {
    color: var(--accent-color);
  }

  &.active {
    background: var(--main-background);
    color: var(--accent-color);

    .checked {
      fill: var(--accent-color);
    }
  }
}

.list-picker-content {
  background: var(--main-background);
  border-color: var(--border-color);
}

{# /* // Loading */ #}

.loading {
  background: var(--main-background-opacity-50);
  color: var(--accent-color);
}
.loading-spinner {
  color: var(--accent-color);
}
.loading-skeleton-radio {
  margin: 0 0 10px 0;
  padding: 15px;
  border-color: var(--main-foreground-opacity-15);
  border-radius: var(--border-radius);
}

{# /* // Spinner */ #}

.round-spinner {
  border-color: var(--accent-color);
  border-left-color: var(--accent-color-opacity-50);
  
  &:after {
    border-color: var(--accent-color);
    border-left-color: var(--accent-color-opacity-50);
  }
}

.spinner > .spinner-elem {
  width: 6px;
  height: 6px;
}

.spinner-inverted > .spinner-elem {
  background: var(--button-foreground);
}

{# /* // Modal */ #}

.modal-dialog,
.modal .modal-dialog {
  background: var(--main-background);
  fill: var(--main-foreground);
}

.modal .modal-header .modal-close {
  color: var(--main-foreground);
  text-shadow: none;
}

{# /* // List */ #}

.list-group-item {
  border-color: var(--main-foreground-opacity-15);
}

{# /* // Announcement */ #}

.announcement {
  color: var(--accent-color-opacity-80);

  &-bg {
    background: var(--accent-color);
    box-shadow: 0px 3px 5px -1px var(--accent-color-opacity-10);
    border-radius: var(--border-radius);
  }

  &-close {
    color: var(--accent-color);
  }
}

{# /* // Alert */ #}

.alert {
  border-radius: var(--border-radius);
  &-info {
    background-color: var(--accent-color-opacity-15);
    border-color: var(--accent-color-opacity-20);
    color: var(--accent-color);
    .alert-icon {
      fill: var(--accent-color);
    }
  }
  .alert-icon {
    width: 12px;
    min-width: auto;
  }
}

{# /* // Chip */ #}

.chip {
  background-color: var(--accent-color-opacity-15);
  color: var(--accent-color);
  border-radius: 5px;
}

{# /* // Review Block Detailed  */ #}
.price--display__free {
  color: var(--accent-color);
}

.review-block-detailed {
  margin: 0 !important;
  background: var(--main-background);
  border: 1px solid var(--main-foreground);
  border-radius: var(--border-radius);
  &-item {
    width: 100%;
    padding: 0 15px;
    background: transparent;
    border-radius: 0;
    border-bottom: 1px solid var(--main-foreground);
  }
}

.review-block-detailed-item .icon-area {
  flex-basis: 30px;
}

{# /* // Tooltip */ #}

.tooltip-icon {
  fill: var(--main-foreground);
}

{# /* // Tabs */ #}

.tabs-wrapper {
  border-top-right-radius: var(--border-radius);
  border-top-left-radius: var(--border-radius);
  background: var(--main-foreground-opacity-05);
  border-bottom-color: var(--main-foreground-opacity-10);
}

.tab-item.active {
  color: var(--accent-color);
  font-weight: bold;
}

.tab-indicator {
  background-color: var(--accent-color);
}

{#/*============================================================================
  #Media queries
==============================================================================*/ #}

{# /* // Max width 576px */ #}

@media (max-width: $sm) {

  .headbar .container .row .col {
    flex-basis: auto;
    &.text-left {
      flex: 0 0 100%;
      max-width: 100%;
      order: 2;
      margin: 0;
      padding: 10px 15px;
      {% if settings.logo_position_mobile == 'center' %}
        text-align: center !important;
      {% else %}
        text-align: left !important;
      {% endif %}
    }
    &.text-right {
      background: #aac67b;
      text-align: center !important;
    }
  }

  .headbar-logo-text {
    display: inline-block;
    margin: 8px 0;
  }

  .security-seal {
    color: #000000;

    .d-inline-block:first-child {
      position: absolute;
      top: 1px;
      left: 50%;
      margin-left: -13px;
    }
    p {
      display: inline-block;
      &.text-semi-bold {
        margin-right: 50px !important;
      }
    }
    &-badge {
      margin: 0;
    }
  }

  .box-discount-coupon-applied {
    border: none;
  }
  .box-discount-coupon .form-control {
    border: 1px solid var(--main-foreground-opacity-20);
    border-radius: var(--border-radius);
  }
  .summary .panel {
    border: 0;
  }
  .summary-container .container {
    padding: 0;
  }
  .summary-coupon {
    padding-top: 65px;
  }

  .btn-primary {
    margin: 0 !important;
  }

  .panel.summary-details {
    border: 0;
  }

  .payment-list-item .accordion-section-header-label {
    flex-direction: column;
  }

  .accordion-section-header-label {
    align-items: start;
    align-content: start;
  }

  .payment-item-discount {
    margin: 8px 0 0;
  }

  .orderstatus-footer {
    background: var(--main-background);
  }

}

{# /* // Min width 768px */ #}

@media (min-width: $md) {

  .container {
    max-width: 1000px;
  }

  .headbar {
    padding: 8px 0;
  }

  .success-order-id {
    padding-top: 0;
  }

  .table.table-scrollable {
    padding: 0;
  }
  .table-subtotal td {
    padding: 5px 0;
  }

}

{# /* // Max width 0px */ #}

@media (max-width: $xs) {

  .modal-xs {
    background: var(--main-background);
  }

}

{% endif %}
