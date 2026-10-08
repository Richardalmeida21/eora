<button class="be-filter-button js-btn-fixed-bottom" type="button" data-bs-open-filters aria-haspopup="dialog" aria-controls="bs-filter-dialog">Filtros <svg aria-hidden="true" width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
				<path d="M0 14.875C0 14.418 0.351562 14.0312 0.84375 14.0312H2.91797C3.26953 12.9062 4.35938 12.0625 5.625 12.0625C6.85547 12.0625 7.94531 12.9062 8.29688 14.0312H17.1562C17.6133 14.0312 18 14.418 18 14.875C18 15.3672 17.6133 15.7188 17.1562 15.7188H8.29688C7.94531 16.8789 6.85547 17.6875 5.625 17.6875C4.35938 17.6875 3.26953 16.8789 2.91797 15.7188H0.84375C0.351562 15.7188 0 15.3672 0 14.875ZM4.5 14.875C4.5 15.5078 4.99219 16 5.625 16C6.22266 16 6.75 15.5078 6.75 14.875C6.75 14.2773 6.22266 13.75 5.625 13.75C4.99219 13.75 4.5 14.2773 4.5 14.875ZM11.25 9.25C11.25 9.88281 11.7422 10.375 12.375 10.375C12.9727 10.375 13.5 9.88281 13.5 9.25C13.5 8.65234 12.9727 8.125 12.375 8.125C11.7422 8.125 11.25 8.65234 11.25 9.25ZM12.375 6.4375C13.6055 6.4375 14.6953 7.28125 15.0469 8.40625H17.1562C17.6133 8.40625 18 8.79297 18 9.25C18 9.74219 17.6133 10.0938 17.1562 10.0938H15.0469C14.6953 11.2539 13.6055 12.0625 12.375 12.0625C11.1094 12.0625 10.0195 11.2539 9.66797 10.0938H0.84375C0.351562 10.0938 0 9.74219 0 9.25C0 8.79297 0.351562 8.40625 0.84375 8.40625H9.66797C10.0195 7.28125 11.1094 6.4375 12.375 6.4375ZM6.75 4.75C7.34766 4.75 7.875 4.25781 7.875 3.625C7.875 3.02734 7.34766 2.5 6.75 2.5C6.11719 2.5 5.625 3.02734 5.625 3.625C5.625 4.25781 6.11719 4.75 6.75 4.75ZM9.42188 2.78125H17.1562C17.6133 2.78125 18 3.16797 18 3.625C18 4.11719 17.6133 4.46875 17.1562 4.46875H9.42188C9.07031 5.62891 7.98047 6.4375 6.75 6.4375C5.48438 6.4375 4.39453 5.62891 4.04297 4.46875H0.84375C0.351562 4.46875 0 4.11719 0 3.625C0 3.16797 0.351562 2.78125 0.84375 2.78125H4.04297C4.39453 1.65625 5.48438 0.8125 6.75 0.8125C7.98047 0.8125 9.07031 1.65625 9.42188 2.78125Z" fill="white"/>
			</svg></button>
<dialog class="be-filter-dialog" id="bs-filter-dialog" aria-labelledby="bs-filter-title">
    <header><h2 id="bs-filter-title">Filtros</h2><button type="button" data-bs-close-filters aria-label="Fechar filtros"><svg aria-hidden="true"><use xlink:href="#times"/></svg></button></header>
    <form data-bs-filter-form>
        <div class="be-filter-dialog__body">
            <label class="be-model-select">Categoria<select name="bs_category"><option value="all">Todos os best sellers</option></select></label>
            <label class="be-model-select">Modelo<select name="bs_model"><option value="">Todos os modelos</option>
                {% for model in (settings.bolsas_eora_models | default([])) | merge(settings.oculos_eora_models | default([])) %}
                    {% if model.link %}<option value="{{ model.link | trim | escape }}">{{ model.title | default(model.link) | escape }}</option>{% endif %}
                {% endfor %}
            </select></label>
            <div data-be-facets></div>
            <fieldset class="be-facet"><legend>Preço</legend><div class="be-price-fields">
                <label>De R$ <input type="number" name="min_price" min="0" step="0.01" inputmode="decimal" placeholder="0,00"></label>
                <label>Até R$ <input type="number" name="max_price" min="0" step="0.01" inputmode="decimal" placeholder="0,00"></label>
            </div></fieldset>
        </div>
        <footer><button type="button" class="be-text-button" data-bs-clear-filters>Limpar filtros</button><button type="submit" class="be-button">Aplicar filtros</button></footer>
    </form>
</dialog>
