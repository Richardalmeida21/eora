<section class="section-faq mb-5 mt-5">
    <div class="container-fluid">
        <div class="row justify-content-center">
            <div class="col-12 col-md-8">
                <h3 class="text-center mb-4" style="font-weight: bold; font-size: 2rem;">Dúvidas frequentes</h3>
                
                <div class="faq-accordion">
                    
                    <div class="faq-item">
                        <button class="faq-header">
                            Os produtos da EORA são realmente de alta qualidade?
                            <span class="faq-icon">+</span>
                        </button>
                        <div class="faq-content">
                            <p>Sim. Todas as nossas peças são produzidas artesanalmente em ateliês especializados.</p>
                            <ul style="list-style-type: disc; padding-left: 20px; margin-bottom: 1rem;">
                                <li><strong>Óculos:</strong> acetato Mazzucchelli italiano, lentes ZEISS com proteção UVA e UVB, adornos banhados a ouro japonês e polimento manual.</li>
                                <li><strong>Bolsas e leather goods:</strong> couro natural selecionado, estrutura reforçada e metais de alta qualidade.</li>
                                <li><strong>Joias e metais:</strong> acabamento premium, banho antialérgico e design exclusivo.</li>
                            </ul>
                            <p>Cada item passa por inspeções em várias etapas, garantindo durabilidade, estética e conforto.</p>
                        </div>
                    </div>

                    <div class="faq-item">
                        <button class="faq-header">
                            Os produtos da EORA servem para diferentes perfis e estilos?
                            <span class="faq-icon">+</span>
                        </button>
                        <div class="faq-content">
                            <p>Sim. Nossos óculos se adaptam a variados formatos de rosto, e nossos leather goods possuem tamanhos versáteis, da bolsa de festa ao porta-joias de viagem. Tudo é pensado para integrar funcionalidade real, elegância e longa vida útil.</p>
                        </div>
                    </div>

                    <div class="faq-item">
                        <button class="faq-header">
                            Posso colocar lentes de grau nos óculos da EORA?
                            <span class="faq-icon">+</span>
                        </button>
                        <div class="faq-content">
                            <p>Sim. Todos os nossos modelos aceitam lentes de grau, inclusive multifocais. Basta nos contatar para um orçamento ou levar ao seu óptico de confiança para aplicação das lentes sem alterar o design original.</p>
                        </div>
                    </div>

                    <div class="faq-item">
                        <button class="faq-header">
                            Como cuidar dos meus produtos EORA?
                            <span class="faq-icon">+</span>
                        </button>
                        <div class="faq-content">
                            <p>Recomendamos conservar suas peças na dust bag original, evitar exposição prolongada ao sol e umidade e manter seus óculos na case para evitar riscos.</p>
                            <p>Leather goods podem ser hidratados com produtos próprios para couro, e joias devem ser guardadas longe de perfumes e cremes.</p>
                        </div>
                    </div>

                    <div class="faq-item">
                        <button class="faq-header">
                            Os produtos da EORA têm garantia?
                            <span class="faq-icon">+</span>
                        </button>
                        <div class="faq-content">
                            <p>Sim. Todas as categorias óculos, bolsas, carteiras, porta-joias e joias, possuem garantia de 90 dias para defeitos de fabricação. Caso note algo fora do padrão, fale conosco pelo chat ou e-mail. Será um prazer ajudar.</p>
                        </div>
                    </div>

                    <div class="faq-item">
                        <button class="faq-header">
                            Como funciona a troca ou devolução?
                            <span class="faq-icon">+</span>
                        </button>
                        <div class="faq-content">
                            <p>Basta entrar em contato com nosso time dentro do prazo de 7 dias após o recebimento. Vamos abrir a reversa, acompanhar o processo e garantir que você receba seu novo produto ou reembolso com total transparência.</p>
                        </div>
                    </div>

                    <div class="faq-item">
                        <button class="faq-header">
                            Onde posso comprar os produtos da EORA?
                            <span class="faq-icon">+</span>
                        </button>
                        <div class="faq-content">
                            <p>Nossas peças são vendidas exclusivamente pelo site oficial. Trabalhamos com produção limitada, artesanal e com materiais premium, por isso, alguns itens podem esgotar rapidamente.</p>
                        </div>
                    </div>

                    <div class="text-center mt-4">
                        <p class="small">Tem mais perguntas? <strong>Entre em contato conosco via email ou chat e ficaremos felizes em responde-las!</strong></p>
                    </div>

                </div>
            </div>
        </div>
    </div>
</section>

<style>
    .faq-item {
        background-color: #f9f9f9;
        margin-bottom: 10px;
        border-radius: 4px;
    }
    .faq-header {
        width: 100%;
        text-align: left;
        padding: 15px 20px;
        background: none;
        border: none;
        font-weight: bold;
        font-size: 1rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: pointer;
        color: #333;
    }
    .faq-header:hover {
        background-color: #f0f0f0;
    }
    .faq-content {
        max-height: 0;
        overflow: hidden;
        transition: max-height 0.3s ease-out;
        padding: 0 20px;
    }
    .faq-item.active .faq-content {
        max-height: 500px; /* Adjust if content is longer */
        padding-top: 20px;
        padding-bottom: 20px;
    }
    .faq-icon {
        font-size: 1.2rem;
        font-weight: normal;
    }
    .faq-item.active .faq-icon {
        /* transform: rotate(45deg); */
    }
</style>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const faqHeaders = document.querySelectorAll('.faq-header');
        
        faqHeaders.forEach(header => {
            header.addEventListener('click', function() {
                const item = this.parentElement;
                const isActive = item.classList.contains('active');
                
                if (!isActive) {
                    item.classList.add('active');
                    this.querySelector('.faq-icon').textContent = '-';
                } else {
                    item.classList.remove('active');
                    this.querySelector('.faq-icon').textContent = '+';
                }
            });
        });
    });
</script>