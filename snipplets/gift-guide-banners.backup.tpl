
<section class="gift-guide-section pb-5" style="background: #fff;">
    
    {# Hero Section #}
    <div class="gift-guide-hero d-flex align-items-center justify-content-center" style="min-height: 300px; background: #f9f9f9; text-align: center; margin-bottom: 50px;">
        <h1 class="display-4 text-uppercase" style="font-family: serif; letter-spacing: 3px; font-weight: 400;">Gifts for a Heavenly Holiday</h1>
    </div>

    {# Banners Grid #}
    <div class="container">
        <div class="row justify-content-center">
            
            {# Item 1 - TESTE #}
            <div class="col-6 col-md-3 mb-5">
                 <a href="/gift-guide/teste" class="text-decoration-none">
                    <div class="gift-card text-center">
                         <div class="gift-image-wrapper mb-3 position-relative" style="aspect-ratio: 1/1; overflow: hidden; background: #fff; border: 2px solid #000; display: flex; align-items: center; justify-content: center;">
                            <span style="font-size: 24px; color: #000; font-weight: bold; letter-spacing: 2px;">TESTE</span>
                         </div>
                         <h3 class="h6 text-uppercase font-weight-bold text-dark" style="letter-spacing: 2px;">Categoria Teste</h3>
                    </div>
                </a>
            </div>

            {# Item 2 - TESTE 2 #}
            <div class="col-6 col-md-3 mb-5">
                 <a href="/gift-guide/teste-2" class="text-decoration-none">
                    <div class="gift-card text-center">
                         <div class="gift-image-wrapper mb-3 position-relative" style="aspect-ratio: 1/1; overflow: hidden; background: #fff; border: 2px solid #000; display: flex; align-items: center; justify-content: center;">
                             <span style="font-size: 24px; color: #000; font-weight: bold; letter-spacing: 2px;">TESTE 2</span>
                         </div>
                         <h3 class="h6 text-uppercase font-weight-bold text-dark" style="letter-spacing: 2px;">Categoria Teste 2</h3>
                    </div>
                </a>
            </div>

        </div>
    </div>
    
    <style>
        .gift-image-wrapper {
            transition: transform 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }
        .gift-card:hover .gift-image-wrapper {
            transform: scale(1.05);
        }
        .gift-card h3 {
            font-size: 0.85rem;
            margin-top: 15px;
        }
    </style>
</section>
