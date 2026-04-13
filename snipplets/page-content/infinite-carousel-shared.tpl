<style>
/* Container principal do carrossel */
.infinite-carousel-container {
	overflow: hidden;
	width: 100%;
	position: relative;
	background: transparent;
	user-select: none;
	pointer-events: none;
}

/* Track que contém as imagens */
.infinite-carousel-track {
	display: flex;
	will-change: transform;
	padding: 16px 0;
	gap: 20px;
	width: max-content;
}

/* Item individual do carrossel */
.infinite-carousel-slide {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	transition: transform 0.3s ease;
	min-width: auto;
	/* Tamanhos responsivos */
	width: 280px;
	padding: 0 20px;
}

.infinite-carousel-slide:hover {
	transform: scale(1.1);
}

.infinite-carousel-slide img {
	max-height: 280px;
	max-width: 280px;
	width: auto;
	height: auto;
	object-fit: contain;
	padding: 8px;
	transition: all 0.3s ease;
	loading: lazy;
}

/* Responsividade para diferentes tamanhos de tela */
@media (max-width: 1024px) {
	.infinite-carousel-slide {
		width: 250px;
		padding: 0 16px;
	}
	.infinite-carousel-slide img {
		max-height: 200px;
		max-width: 200px;
		width: auto;
		height: auto;
		padding: 4px;
	}
}

@media (max-width: 768px) {
	.infinite-carousel-slide {
		width: 200px;
		padding: 0 10px;
	}
	.infinite-carousel-slide img {
		max-height: 170px;
		max-width: 170px;
		width: auto;
		height: auto;
		padding: 4px;
	}
	.infinite-carousel-track {
		gap: 25px;
	}
}

@media (max-width: 480px) {
	.infinite-carousel-slide {
		width: 170px;
		padding: 0 8px;
	}
	.infinite-carousel-slide img {
		max-height: 140px;
		max-width: 140px;
		width: auto;
		height: auto;
		padding: 4px;
	}
	.infinite-carousel-track {
		gap: 20px;
	}
}
</style>

<script>
function initInfiniteCarousel(trackId) {
	const track = document.getElementById(trackId);
	if (!track) return;
	
	const originalItems = Array.from(track.children);
	const originalCount = originalItems.length;
	
	if (originalCount === 0) return;
	
	// Duplicar os itens para criar o efeito infinito
	const clones = originalItems.map(item => item.cloneNode(true));
	clones.forEach(clone => track.appendChild(clone));
	
	// Duplicar mais uma vez para garantir fluidez
	const moreClones = [...originalItems, ...clones].map(item => item.cloneNode(true));
	moreClones.forEach(clone => track.appendChild(clone));
	
	// Configuração da animação - ajustar velocidade baseada no tamanho da tela
	const isMobile = window.innerWidth <= 768;
	const duration = isMobile ? 45 * 1000 : 30 * 1000; // Mais lento no mobile (45s vs 30s)
	let startTime = null;
	let animationId = null;
	
	const animate = (timestamp) => {
		if (!startTime) startTime = timestamp;
		const progress = (timestamp - startTime) / duration;
		
		if (progress >= 1) {
			// Reset suave para o início
			startTime = timestamp;
			track.style.transition = 'none';
			track.style.transform = 'translateX(0)';
			
			// Reativar transição no próximo frame
			requestAnimationFrame(() => {
				track.style.transition = 'transform 0.1s linear';
			});
		} else {
			// Calcular posição baseada no progresso - ajustar largura por tela
			const slideWidth = isMobile ? 225 : 300; // Largura ajustada no mobile (200px + 25px gap)
			const translateX = -progress * (originalCount * slideWidth);
			track.style.transform = `translateX(${translateX}px)`;
		}
		
		animationId = requestAnimationFrame(animate);
	};
	
	// Iniciar a animação
	animationId = requestAnimationFrame(animate);
	
	// Pausar animação ao passar o mouse (opcional)
	let isPaused = false;
	
	track.addEventListener('mouseenter', () => {
		if (!isPaused && animationId) {
			isPaused = true;
			cancelAnimationFrame(animationId);
		}
	});
	
	track.addEventListener('mouseleave', () => {
		if (isPaused) {
			isPaused = false;
			startTime = null; // Reset para evitar pulos
			animationId = requestAnimationFrame(animate);
		}
	});
	
	// Função de cleanup
	return () => {
		if (animationId) {
			cancelAnimationFrame(animationId);
		}
	};
}

// Armazenar referências para cleanup
const carouselCleanups = [];

// Inicializar quando o DOM estiver pronto
document.addEventListener('DOMContentLoaded', function() {
	// Aguardar um pouco para garantir que as imagens foram carregadas
	setTimeout(() => {
		carouselCleanups.push(initInfiniteCarousel('carousel-track-01'));
		carouselCleanups.push(initInfiniteCarousel('carousel-track-02'));
		carouselCleanups.push(initInfiniteCarousel('carousel-track-03'));
	}, 100);
});

// Cleanup quando sair da página
window.addEventListener('beforeunload', function() {
	carouselCleanups.forEach(cleanup => {
		if (cleanup) cleanup();
	});
});

// Reinicializar se a janela for redimensionada
let resizeTimeout;
window.addEventListener('resize', function() {
	clearTimeout(resizeTimeout);
	resizeTimeout = setTimeout(() => {
		// Parar animações atuais
		carouselCleanups.forEach(cleanup => {
			if (cleanup) cleanup();
		});
		carouselCleanups.length = 0;
		
		// Reinicializar carrosséis
		setTimeout(() => {
			carouselCleanups.push(initInfiniteCarousel('carousel-track-01'));
			carouselCleanups.push(initInfiniteCarousel('carousel-track-02'));
			carouselCleanups.push(initInfiniteCarousel('carousel-track-03'));
		}, 100);
	}, 250);
});
</script>