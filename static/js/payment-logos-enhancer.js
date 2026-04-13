/**
 * Payment Logos Enhancer
 * Replaces default payment method images with enhanced versions
 * Uses alt attribute to identify and map to correct enhanced image
 */

(function() {
    'use strict';

    // Mapping of alt text to enhanced image filenames
    const paymentLogoMap = {
        // Cartões de Crédito
        'visa': 'visa-enhanced.png',
        'mastercard': 'mastercard-enhanced.png',
        'master card': 'mastercard-enhanced.png',
        'american express': 'amex-enhanced.png',
        'amex': 'amex-enhanced.png',
        'diners': 'diners-enhanced.png',
        'diners club': 'diners-enhanced.png',
        'elo': 'elo-enhanced.png',
        'hipercard': 'hipercard-enhanced.png',
        'hiper': 'hipercard-enhanced.png',
        'discover': 'discover-enhanced.png',
        'jcb': 'jcb-enhanced.png',
        
        // PIX e transferência
        'pix': 'pix-enhanced.png',
        'transferência bancária': 'transferencia-enhanced.png',
        'transferencia bancaria': 'transferencia-enhanced.png',
        'ted': 'transferencia-enhanced.png',
        'doc': 'transferencia-enhanced.png',
        
        // Boleto
        'boleto': 'boleto-enhanced.png',
        'boleto bancário': 'boleto-enhanced.png',
        'boleto bancario': 'boleto-enhanced.png',
        
        // Carteiras digitais
        'paypal': 'paypal-enhanced.png',
        'mercado pago': 'mercadopago-enhanced.png',
        'mercadopago': 'mercadopago-enhanced.png',
        'pagseguro': 'pagseguro-enhanced.png',
        'pag seguro': 'pagseguro-enhanced.png',
        'picpay': 'picpay-enhanced.png',
        'pic pay': 'picpay-enhanced.png',
        'google pay': 'googlepay-enhanced.png',
        'googlepay': 'googlepay-enhanced.png',
        'apple pay': 'applepay-enhanced.png',
        'applepay': 'applepay-enhanced.png',
        'samsung pay': 'samsungpay-enhanced.png',
        'samsungpay': 'samsungpay-enhanced.png',
        
        // Outros
        'cielo': 'cielo-enhanced.png',
        'rede': 'rede-enhanced.png',
        'stone': 'stone-enhanced.png',
        'getnet': 'getnet-enhanced.png',
        'safetypay': 'safetypay-enhanced.png',
        'pagamento digital': 'digital-enhanced.png'
    };

    // Base path for enhanced images
    const enhancedImagesPath = '/static/images/payment-logos/';

    /**
     * Normalizes alt text for comparison
     */
    function normalizeAltText(alt) {
        return alt.toLowerCase()
            .trim()
            .replace(/[^\w\s]/g, ' ')  // Replace special chars with space
            .replace(/\s+/g, ' ')      // Multiple spaces to single
            .trim();
    }

    /**
     * Finds enhanced image filename for given alt text
     */
    function getEnhancedImageFilename(alt) {
        const normalizedAlt = normalizeAltText(alt);
        
        // Direct match
        if (paymentLogoMap[normalizedAlt]) {
            return paymentLogoMap[normalizedAlt];
        }
        
        // Partial match - check if any key is contained in the alt text
        for (const [key, filename] of Object.entries(paymentLogoMap)) {
            if (normalizedAlt.includes(key) || key.includes(normalizedAlt)) {
                return filename;
            }
        }
        
        return null;
    }

    /**
     * Replaces payment logo with enhanced version
     */
    function replacePaymentLogo(img) {
        const alt = img.getAttribute('alt') || '';
        const enhancedFilename = getEnhancedImageFilename(alt);
        
        if (enhancedFilename) {
            const enhancedSrc = enhancedImagesPath + enhancedFilename;
            
            // Create new image to test if it exists
            const testImg = new Image();
            testImg.onload = function() {
                // Image exists, replace it
                img.src = enhancedSrc;
                img.setAttribute('data-enhanced', 'true');
                
                // Update data-src if using lazy loading
                if (img.hasAttribute('data-src')) {
                    img.setAttribute('data-src', enhancedSrc);
                }
                
                // Add class for styling if needed
                img.classList.add('payment-logo-enhanced');
                
                console.log(`Enhanced payment logo: ${alt} -> ${enhancedFilename}`);
            };
            testImg.onerror = function() {
                console.warn(`Enhanced payment logo not found: ${enhancedFilename} for alt: ${alt}`);
            };
            testImg.src = enhancedSrc;
        }
    }

    /**
     * Processes all payment images in the page
     */
    function enhancePaymentLogos() {
        // Common selectors for payment logos
        const selectors = [
            '.footer-payments-shipping-logos img',
            '.payment-logos img',
            '.payments-container img',
            '[data-store="footer"] img[alt]',
            '.card-img',
            '.payment-method img',
            '.checkout-payment img'
        ];

        const allImages = document.querySelectorAll(selectors.join(', '));
        
        allImages.forEach(img => {
            // Skip if already enhanced
            if (img.hasAttribute('data-enhanced')) {
                return;
            }
            
            const alt = img.getAttribute('alt') || '';
            
            // Only process images that seem to be payment related
            if (alt && (
                img.closest('.footer-payments-shipping-logos') ||
                img.closest('.payment-logos') ||
                img.closest('.payments-container') ||
                img.classList.contains('card-img') ||
                /payment|card|visa|master|pix|boleto|paypal/i.test(alt)
            )) {
                replacePaymentLogo(img);
            }
        });
    }

    /**
     * Observer for dynamically added content
     */
    function setupMutationObserver() {
        if (typeof MutationObserver === 'undefined') return;

        const observer = new MutationObserver(function(mutations) {
            let shouldProcess = false;
            
            mutations.forEach(function(mutation) {
                if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                    for (let node of mutation.addedNodes) {
                        if (node.nodeType === 1) { // Element node
                            if (node.tagName === 'IMG' || node.querySelector('img')) {
                                shouldProcess = true;
                                break;
                            }
                        }
                    }
                }
            });
            
            if (shouldProcess) {
                setTimeout(enhancePaymentLogos, 100);
            }
        });

        observer.observe(document.body, {
            childList: true,
            subtree: true
        });
    }

    /**
     * Initialize the enhancement process
     */
    function init() {
        // Initial enhancement
        enhancePaymentLogos();
        
        // Setup observer for dynamic content
        setupMutationObserver();
        
        // Re-enhance on lazy load events
        document.addEventListener('lazyload', enhancePaymentLogos);
        
        // Re-enhance periodically (in case of delayed loading)
        setTimeout(enhancePaymentLogos, 1000);
        setTimeout(enhancePaymentLogos, 3000);
    }

    // Start when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Expose function globally for manual triggering
    window.enhancePaymentLogos = enhancePaymentLogos;
})();