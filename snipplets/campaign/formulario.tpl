<section class="section-banner-formulario my-5 py-5" id="formulario-franqueado">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12 col-md-6">
                <div class="content-text">
                    <h2>{{settings.franqueados_formulario_title}}</h2>
                    <p>{{settings.franqueados_formulario_text}}</p>
                </div>
            </div>
            <div class="col-12 col-md-6">
                <div class="content-form">
                    {{ settings.custom_html_franqueados_formulario | raw }}
                </div>
            </div>
        </div>
    </div>
</section>
