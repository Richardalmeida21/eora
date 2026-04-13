/* Garantia Eora Custom Styles */

/* Scroll suave para navegação interna */
html {
    scroll-behavior: smooth;
    scroll-padding-top: 100px; /* Offset para não ficar colado no topo */
}

.garantia-eora-page {
    width: 100%;
    overflow-x: hidden;
}

.ge-container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 20px;
    width: 100%;
}

/* 1. Banner */
.ge-banner {
    height: 80vh;
    min-height: 500px;
    background-size: cover;
    background-position: center;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    text-align: center;
}

.ge-banner-content h1 {
    font-size: 4rem;
    margin-bottom: 1rem;
    text-transform: uppercase;
    letter-spacing: 2px;
    color: #fff;
}

.ge-banner-content p {
    font-size: 1.2rem;
    max-width: 600px;
    margin: 0 auto;
    line-height: 1.6;
}

.ge-repair-banner {
    min-height: 400px;
    background-size: cover;
    background-position: center;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    text-align: center;
    padding: 60px 20px;
}

.ge-repair-content h2 {
    font-size: 3rem;
    margin-bottom: 20px;
    text-transform: uppercase;
    letter-spacing: 2px;
    word-wrap: break-word;
    overflow-wrap: break-word;
}

.ge-repair-content p {
    font-size: 1.1rem;
    line-height: 1.8;
    margin-bottom: 30px;
    word-wrap: break-word;
    overflow-wrap: break-word;
}

/* Mobile adjustments for repair banner */
@media screen and (max-width: 768px) {
    .ge-repair-banner {
        min-height: 350px;
        padding: 40px 15px;
    }
    
    .ge-repair-content h2 {
        font-size: 1.5rem;
        line-height: 1.2;
        margin-bottom: 15px;
    }
    
    .ge-repair-content p {
        font-size: 0.9rem;
        line-height: 1.5;
        margin-bottom: 20px;
    }
}

/* 2. Texto Introdutório */
.ge-intro-text {
    padding: 80px 20px;
    background: #fff;
}

.ge-intro-text p {
    font-size: 0.95rem;
    line-height: 1.7;
    max-width: 900px;
    margin: 0 auto;
    color: #333;
    text-align: justify;
    font-weight: 400;
    letter-spacing: 0.3px;
}

/* 3. Banner Secundário */
.ge-second-banner {
    width: 100%;
    margin: 0 0 60px 0;
    position: relative;
    overflow: hidden;
}

.ge-second-banner-wrapper {
    position: relative;
    width: 100%;
}

.ge-second-banner img {
    width: 100%;
    height: auto;
    display: block;
}

.ge-second-banner-overlay {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    text-align: center;
    color: #fff;
    z-index: 2;
    width: 90%;
    max-width: 900px;
    padding: 20px;
    box-sizing: border-box;
}

.ge-second-banner-overlay h2 {
    font-size: 3rem;
    font-weight: 700;
    text-transform: uppercase;
    margin-bottom: 15px;
    letter-spacing: 2px;
    text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    word-wrap: break-word;
    overflow-wrap: break-word;
    white-space: normal;
    hyphens: auto;
}

.ge-second-banner-overlay p {
    font-size: 1rem;
    line-height: 1.6;
    text-shadow: 1px 1px 3px rgba(0,0,0,0.3);
    word-wrap: break-word;
    overflow-wrap: break-word;
    white-space: normal;
    hyphens: auto;
}

/* Mobile adjustments for BOTH banners */
@media screen and (max-width: 768px) {
    /* --- 1. Banner Garantia Eora (Imagem + Overlay) --- */
    .ge-second-banner {
        height: auto !important;
        min-height: auto !important;
    }

    .ge-second-banner-wrapper {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        position: relative;
        overflow: hidden;
        min-height: 600px !important; /* Aumentado para 600px */
        height: auto;
        background-color: #000; 
        padding: 80px 40px !important; /* Mais padding para conteúdo não sair */
    }
    
    /* Imagem de fundo absoluta */
    .ge-second-banner-wrapper img {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        object-fit: cover;
        z-index: 0;
        opacity: 0.6; /* Escurecer imagem para garantir leitura */
    }
    
    /* Conteúdo relativo para empurrar o container */
    .ge-second-banner-overlay {
        position: relative;
        width: 100%;
        max-width: 100%;
        padding: 0;
        z-index: 1;
        background: transparent;
        height: auto;
        top: auto;
        left: auto;
        transform: none;
    }
    
    .ge-second-banner-overlay h2 {
        font-size: 1.8rem !important; /* Aumentado */
        font-weight: 700;
        line-height: 1.3 !important;
        margin-bottom: 25px !important;
        color: #fff;
        text-transform: uppercase;
        text-shadow: 2px 2px 6px rgba(0,0,0,0.9);
    }
    
    .ge-second-banner-overlay p {
        font-size: 1rem !important; /* Aumentado */
        line-height: 1.6 !important;
        margin: 0 0 30px 0 !important;
        color: #fff;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.9);
    }
    
    .ge-second-banner-overlay .ge-btn {
        margin-top: 20px !important;
        padding: 15px 35px !important;
        font-size: 1rem !important;
    }

    /* --- 2. Banner Reparos (Background Image Inline) --- */
    .ge-repair-banner {
        min-height: 600px !important; /* Aumentado para 600px */
        height: auto !important;
        padding: 80px 40px !important; /* Mais padding */
        background-size: cover !important;
        background-position: center !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
    }

    .ge-repair-content {
        width: 100% !important;
        max-width: 100% !important;
        padding: 0 !important;
        text-align: center !important;
    }

    .ge-repair-content h2 {
        font-size: 1.8rem !important; /* Aumentado */
        line-height: 1.3 !important;
        margin-bottom: 25px !important;
        color: #fff;
        text-shadow: 2px 2px 6px rgba(0,0,0,0.9);
    }
    
    .ge-repair-content p {
        font-size: 1rem !important; /* Aumentado */
        line-height: 1.6 !important;
        margin-bottom: 30px !important;
        color: #fff;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.9);
    }

    .ge-buttons {
        display: flex;
        flex-direction: column;
        gap: 15px;
        width: 100%;
        max-width: 300px; /* Limitar largura dos botões */
        margin: 0 auto;
    }

    .ge-btn {
        width: 100%;
        display: block;
        text-align: center;
        padding: 15px 30px !important;
        font-size: 1rem !important;
    }
}

.ge-img-responsive {
    width: 100%;
    height: auto;
    display: block;
}

/* 2. Photo Sequence */
.ge-photo-sequence {
    display: flex;
    width: 100%;
    margin: 0;
}

.ge-photo-item {
    width: 25%;
    height: 400px; /* Adjust height as needed */
    overflow: hidden;
}

.ge-photo-item img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
}

/* 3. Care Accordion */
.ge-care-section {
    padding: 80px 20px;
    background: #fff;
}

.ge-care-section h2 {
    font-size: 1.5rem;
    margin-bottom: 20px;
    text-align: center;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-weight: 600;
}

.ge-care-intro {
    font-size: 0.85rem;
    line-height: 1.6;
    max-width: 600px;
    margin: 0 auto 50px;
    text-align: center;
    color: #333;
}

.ge-accordion {
    max-width: 600px;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    gap: 15px;
}

.ge-accordion-item {
    border: 2px solid #000;
    background: #fff;
}

.ge-accordion-header {
    padding: 18px 20px;
    cursor: pointer;
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-weight: 600;
    text-transform: uppercase;
    font-size: 0.85rem;
    letter-spacing: 0.5px;
    transition: background 0.2s;
    background: #f5f5f5;
}

.ge-accordion-header:hover {
    background: #e8e8e8;
}

.ge-icon {
    transition: transform 0.3s ease;
}

.ge-accordion-body {
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease-out;
    background: #fff;
}

.ge-accordion-item.active .ge-accordion-body {
    max-height: 2000px;
    padding: 20px;
    border-top: 1px solid #ddd;
}

.ge-care-description {
    margin-bottom: 20px;
    font-size: 0.9rem;
    line-height: 1.6;
    color: #555;
}

/* 3. Mini Banners - Cuidados com a Peça */
.ge-mini-banners {
    display: flex;
    flex-direction: column;
    gap: 15px;
    margin: 0;
    padding: 20px 0;
}

/* Estado padrão: Imagem esquerda + Título direita */
.ge-mini-banner-item {
    position: relative;
    width: 100%;
    background: #f5f5f5;
    border-radius: 8px;
    padding: 30px;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    min-height: 150px;
    cursor: pointer;
    transition: all 0.3s ease;
}

.ge-banner-content {
    display: flex;
    align-items: center;
    justify-content: flex-start;
    gap: 15px;
    flex: 0 0 auto;
    order: 1;
}

.ge-banner-image {
    width: 120px;
    height: 120px;
    object-fit: contain;
    flex-shrink: 0;
    display: block !important;
}

.ge-banner-description {
    font-size: 14px;
    line-height: 1.8;
    color: #333;
    text-align: left;
    padding: 0;
    margin: 0;
    display: none !important;
    width: 100%;
}

.ge-banner-title {
    font-size: 16px;
    font-weight: 700;
    margin: 0;
    text-align: right;
    color: #333;
    width: auto;
    text-transform: uppercase;
    display: block;
    order: 2;
}

/* HOVER Desktop: Título em cima + Descrição embaixo */
.ge-mini-banner-item:hover {
    background: #ececec !important;
    flex-direction: column !important;
    align-items: flex-start !important;
}

.ge-mini-banner-item:hover .ge-banner-title {
    order: -1 !important;
    width: 100% !important;
    text-align: left !important;
    margin-bottom: 15px !important;
}

.ge-mini-banner-item:hover .ge-banner-content {
    order: 1 !important;
    width: 100% !important;
    display: block !important;
}

.ge-mini-banner-item:hover .ge-banner-image {
    display: none !important;
}

.ge-mini-banner-item:hover .ge-banner-description {
    display: block !important;
}

/* Mobile */
@media screen and (max-width: 768px) {
    .ge-mini-banner-item {
        padding: 15px !important;
        min-height: auto !important;
        flex-direction: column !important;
        align-items: flex-start !important;
    }
    
    .ge-banner-title {
        font-size: 16px !important;
        text-align: left !important;
        margin-bottom: 12px !important;
        width: 100% !important;
        order: 1 !important;
    }
    
    .ge-banner-content {
        flex-direction: column !important;
        width: 100% !important;
        order: 2 !important;
        gap: 0 !important;
    }
    
    .ge-banner-image {
        width: 80px !important;
        height: 80px !important;
        display: none !important;
    }
    
    .ge-banner-description {
        font-size: 13px !important;
        line-height: 1.5 !important;
        width: 100% !important;
        display: block !important;
        text-align: left !important;
    }
}

/* Accordion Active State - Fundo preto e texto branco */
.ge-accordion-item.active .ge-accordion-header {
    background-color: #000 !important;
    color: #fff !important;
}

.ge-accordion-item.active .ge-accordion-header .ge-icon svg path {
    stroke: #fff !important;
}

.ge-accordion-item.active .ge-icon svg {
    transform: rotate(180deg);
}

/* 4. Video Carousel */
.ge-videos-section {
    padding: 80px 0;
    background: #f9f9f9;
    position: relative;
}

.ge-videos-section h2 {
    font-size: 3rem;
    margin-bottom: 40px;
    text-transform: uppercase;
    text-align: left;
}

.ge-video-carousel-container {
    position: relative;
    padding: 0 60px;
}

.ge-video-carousel-wrapper {
    overflow: hidden;
    width: 100%;
}

.ge-video-track {
    display: flex;
    gap: 20px; /* Gap entre vídeos */
    transition: transform 0.5s ease;
}

.ge-video-card {
    min-width: calc((100% - 60px) / 4);
    flex-shrink: 0;
}

.ge-video-frame {
    width: 100%;
    height: 0;
    padding-bottom: 177.78%; /* 9:16 aspect ratio (16/9 * 100) */
    position: relative;
    margin-bottom: 10px;
    border-radius: 8px;
    overflow: hidden;
    background: #f0f0f0;
}

.ge-video-frame video,
.ge-video-frame iframe {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    object-fit: contain;
}

.ge-video-frame iframe {
    border: none;
}

.ge-video-card p {
    font-size: 13px;
    line-height: 1.5;
    color: #333;
    text-align: center;
    padding: 10px 0 0 0;
    word-wrap: break-word;
    overflow-wrap: break-word;
    width: 100%; /* Ocupar largura do card */
    max-width: 100%; /* Remover limite fixo */
    margin: 0 auto;
    display: block;
}

/* Navigation Buttons */
.ge-carousel-btn {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    background: rgba(255, 255, 255, 0.9);
    border: none;
    width: 50px;
    height: 50px;
    border-radius: 50%;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 10;
    transition: all 0.3s ease;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.ge-carousel-btn:hover {
    background: #fff;
    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
}

.ge-carousel-btn:disabled {
    opacity: 0.3;
    cursor: not-allowed;
}

.ge-carousel-btn-prev {
    left: 0;
}

.ge-carousel-btn-next {
    right: 0;
}

.ge-carousel-btn svg {
    width: 24px;
    height: 24px;
    fill: #333;
}

/* Mobile Responsive - Vídeos */
@media screen and (max-width: 768px) {
    .ge-video-carousel-container {
        padding: 0 10px;
        position: relative;
    }
    
    .ge-video-carousel-wrapper {
        overflow-x: scroll !important; /* Forçar scroll horizontal */
        overflow-y: hidden;
        -webkit-overflow-scrolling: touch; /* Smooth scrolling no iOS */
        scroll-snap-type: x mandatory; /* Snap nos vídeos */
        scrollbar-width: thin; /* Mostrar scrollbar fino no Firefox */
        -ms-overflow-style: auto; /* Mostrar scrollbar no IE/Edge */
        cursor: grab;
        touch-action: pan-x; /* Permitir scroll horizontal no touch */
        user-select: none;
    }
    
    .ge-video-carousel-wrapper:active {
        cursor: grabbing;
    }
    
    /* Mostrar scrollbar no Chrome/Safari para indicar que é scrollável */
    .ge-video-carousel-wrapper::-webkit-scrollbar {
        height: 4px;
        display: block;
    }
    
    .ge-video-carousel-wrapper::-webkit-scrollbar-track {
        background: #f1f1f1;
        border-radius: 10px;
    }
    
    .ge-video-carousel-wrapper::-webkit-scrollbar-thumb {
        background: #888;
        border-radius: 10px;
    }
    
    .ge-video-carousel-wrapper::-webkit-scrollbar-thumb:hover {
        background: #555;
    }
    
    .ge-video-track {
        gap: 10px; /* Reduzido de 15px */
        padding: 0 5px 10px 5px;
    }
    
    .ge-video-card {
        min-width: 60%; /* Reduzido de 85% para não ficar muito alto no formato 9:16 */
        scroll-snap-align: center;
        flex-shrink: 0;
    }
    
    /* Esconder botões de navegação no mobile */
    .ge-carousel-btn {
        display: none;
    }
}

/* 5. Repair Banner */
.ge-repair-banner {
    height: 60vh;
    min-height: 400px;
    background-size: cover;
    background-position: center;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center; /* Centered content */
    color: #fff;
    position: relative;
    margin-bottom: 80px; /* Added spacing from footer */
}

.ge-repair-content {
    max-width: 600px;
    margin: 0 auto;
}

.ge-repair-content h2 {
    font-size: 3rem;
    margin-bottom: 20px;
    color: #fff;
    text-transform: uppercase;
}

.ge-repair-content p {
    margin-bottom: 40px;
    color: #fff;
    font-size: 1.1rem;
}

.ge-buttons {
    display: flex;
    gap: 20px;
    justify-content: center;
}

.ge-btn {
    padding: 15px 30px;
    background: #fff;
    color: #000;
    text-decoration: none;
    font-weight: bold;
    text-transform: uppercase;
    transition: all 0.3s;
    border: 1px solid #fff;
}

.ge-btn:hover {
    background: #000;
    color: #fff;
    border-color: #000;
}

.ge-btn-outline {
    background: transparent;
    color: #fff;
    border: 1px solid #fff;
}

.ge-btn-outline:hover {
    background: #fff;
    color: #000;
}

/* Mobile Responsiveness */
@media (max-width: 768px) {
    /* Banner Principal */
    .ge-banner {
        height: 60vh;
        min-height: 400px;
    }
    
    .ge-banner-content h1 {
        font-size: 2rem;
        letter-spacing: 1px;
        padding: 0 15px;
        word-wrap: break-word;
        overflow-wrap: break-word;
        max-width: 100%;
    }
    
    .ge-banner-content p {
        font-size: 0.95rem;
        padding: 0 20px;
        word-wrap: break-word;
        overflow-wrap: break-word;
        max-width: 100%;
    }
    
    /* Texto Introdutório */
    .ge-intro-text {
        padding: 40px 20px;
    }
    
    .ge-intro-text p {
        font-size: 0.9rem;
        text-align: left;
        word-wrap: break-word;
        overflow-wrap: break-word;
        max-width: 100%;
    }
    
    /* Banner Secundário - FIX PRINCIPAL */
    .ge-second-banner-overlay {
        width: 90%;
        padding: 0 15px;
        max-width: 100%;
        box-sizing: border-box;
    }
    
    .ge-second-banner-overlay h2 {
        font-size: 1.5rem !important;
        letter-spacing: 0.5px;
        margin-bottom: 10px;
        line-height: 1.3;
        word-wrap: break-word;
        overflow-wrap: break-word;
        white-space: normal;
        hyphens: auto;
        max-width: 100%;
    }
    
    .ge-second-banner-overlay p {
        font-size: 0.75rem !important;
        line-height: 1.4;
        word-wrap: break-word;
        overflow-wrap: break-word;
        white-space: normal;
        hyphens: auto;
        max-width: 100%;
    }
    
    /* Cuidados com a Peça */
    .ge-care-section {
        padding: 40px 0;
    }
    
    .ge-care-section h2 {
        font-size: 2rem;
        margin-bottom: 20px;
    }
    
    .ge-care-intro {
        font-size: 0.9rem;
        padding: 0 10px;
    }
    
    /* Banner de Reparos - Mobile */
    .ge-repair-content {
        padding: 0 20px;
    }
    
    .ge-repair-content h2 {
        font-size: 1.5rem !important;
        letter-spacing: 0.5px;
        margin-bottom: 15px;
        word-wrap: break-word;
        overflow-wrap: break-word;
        white-space: normal;
        hyphens: auto;
        max-width: 100%;
    }
    
    .ge-repair-content p {
        font-size: 0.75rem !important;
        line-height: 1.4;
        margin-bottom: 20px;
        word-wrap: break-word;
        overflow-wrap: break-word;
        white-space: normal;
        hyphens: auto;
        max-width: 100%;
    }
    
    .ge-care-layout {
        flex-direction: column-reverse;
    }
    
    .ge-care-image {
        min-height: 300px;
    }
    
    /* Accordion */
    .ge-accordion-header {
        font-size: 0.95rem;
        padding: 15px;
    }
    
    .ge-accordion-body {
        padding: 15px;
    }
    
    /* Mini Banners */
    .ge-mini-banners {
        gap: 15px;
    }
    
    .ge-mini-banner-item {
        padding: 15px;
    }
    
    .ge-banner-title {
        font-size: 0.85rem;
        margin-top: 10px;
    }
    
    .ge-banner-description {
        font-size: 0.85rem;
        line-height: 1.5;
    }
    
    /* Sequência de Fotos */
    .ge-photo-sequence {
        flex-wrap: wrap;
    }
    
    .ge-photo-item {
        width: 50%;
        height: 250px;
    }
    
    /* Vídeos */
    .ge-videos-section {
        padding: 40px 0;
    }
    
    .ge-videos-section h2 {
        font-size: 1.8rem;
        margin-bottom: 30px;
    }
    
    .ge-video-frame {
        height: 250px;
        max-width: 280px;
        margin: 0 auto;
    }
    
    .ge-video-card p {
        font-size: 12px;
        max-width: 280px;
    }
    
    
    /* Banner de Reparos */
    .ge-repair-banner {
        height: 50vh;
        min-height: 350px;
        margin-bottom: 40px;
    }
    
    .ge-repair-content {
        padding: 0 20px;
    }
    
    .ge-repair-content h2 {
        font-size: 1.8rem;
        margin-bottom: 15px;
    }
    
    .ge-repair-content p {
        font-size: 0.9rem;
        margin-bottom: 30px;
    }
    
    /* Botões */
    .ge-buttons {
        flex-direction: column;
        gap: 15px;
    }
    
    .ge-btn {
        padding: 12px 25px;
        font-size: 0.85rem;
        width: 100%;
        text-align: center;
    }
}

/* Tablets e telas médias */
@media (min-width: 769px) and (max-width: 1024px) {
    .ge-banner-content h1 {
        font-size: 3rem;
    }
    
    .ge-second-banner-overlay h2 {
        font-size: 2.5rem;
    }
    
    .ge-video-card {
        min-width: calc((100% - 40px) / 2);
    }
    
    .ge-photo-item {
        width: 33.333%;
    }
}
