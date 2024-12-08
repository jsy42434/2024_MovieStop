let currentSlide = 0;  // slide-container 슬라이드 인덱스
let currentIndex1 = 0;  // movie-slider2 슬라이드 인덱스

const slideContainer = document.querySelector('.slide');
const slideImages = document.querySelectorAll('.slide img');
const dots = document.querySelectorAll('.dot');  // dot 요소

// 슬라이드 이동 함수 (slide-container)
function moveSlide(direction) {
    const totalSlides = slideImages.length;
    const slideWidth = slideImages[0].offsetWidth; 
    
    if (direction === 'left') {
        currentSlide = (currentSlide > 0) ? currentSlide - 1 : totalSlides - 1;
    } else if (direction === 'right') {
        currentSlide = (currentSlide < totalSlides - 1) ? currentSlide + 1 : 0;
    }

    slideContainer.style.transform = `translateX(-${currentSlide * slideWidth}px)`;
    updateDots(currentSlide);  // 점 업데이트
}

// 점 활성화 업데이트
function updateDots(index) {
    dots.forEach((dot, dotIndex) => {
        dot.classList.toggle('active', dotIndex === index);
    });
}

// 페이지가 로드되면 초기 dot 설정
document.addEventListener('DOMContentLoaded', () => {
    updateDots(currentSlide);

    // dot 클릭 시 슬라이드로 이동
    dots.forEach(dot => {
        dot.addEventListener('click', () => {
            const index = parseInt(dot.getAttribute('data-slide'), 10);
            moveSlideToIndex(index);  // 해당 인덱스로 이동
        });
    });
});

// 슬라이드 변경 함수
function moveSlideToIndex(index) {
    const slideWidth =  slideImages[0].offsetWidth;
    slideContainer.style.transform = `translateX(-${index * slideWidth}px)`;  // 해당 인덱스 슬라이드로 이동
    currentSlide = index;
    updateDots(currentSlide);
}

// 이전 버튼 클릭 (slide-container)
document.querySelector('.left-btn').addEventListener('click', () => {
    moveSlide('left');
});

// 다음 버튼 클릭 (slide-container)
document.querySelector('.right-btn').addEventListener('click', () => {
    moveSlide('right');
});

// movieSlider2 슬라이드 이동 함수
function moveSlider(direction, sliderId) {
    const slider = document.getElementById(sliderId);
    const items = slider.children;
    const itemWidth = items[0].offsetWidth;
    const itemCount = items.length;

    if (slider.dataset.currentIndex === undefined) {
        slider.dataset.currentIndex = 0;
    }

    let currentIndex = parseInt(slider.dataset.currentIndex);

    if (direction === 'left') {
        if (currentIndex === 0) {
            currentIndex = itemCount - 1; // 마지막으로 이동
            slider.style.transition = 'none';
            slider.style.transform = `translateX(-${currentIndex * itemWidth}px)`;
            setTimeout(() => {
                currentIndex--;
                slider.style.transition = 'transform 0.3s ease-in-out';
                slider.style.transform = `translateX(-${currentIndex * itemWidth}px)`;
            }, 0);
        } else {
            currentIndex--;
            slider.style.transform = `translateX(-${currentIndex * itemWidth}px)`;
        }
    } else if (direction === 'right') {
        if (currentIndex === itemCount - 1) {
            currentIndex = 0; // 첫 번째로 이동
            slider.style.transition = 'none';
            slider.style.transform = `translateX(0px)`;
            setTimeout(() => {
                currentIndex++;
                slider.style.transition = 'transform 0.3s ease-in-out';
                slider.style.transform = `translateX(-${currentIndex * itemWidth}px)`;
            }, 0);
        } else {
            currentIndex++;
            slider.style.transform = `translateX(-${currentIndex * itemWidth}px)`;
        }
    }

    slider.dataset.currentIndex = currentIndex;
}


// movieSlider2의 이전/다음 버튼 클릭 이벤트
document.querySelector('.arrow-left').addEventListener('click', () => {
    moveSlider('left', 'movieSlider2');
});

document.querySelector('.arrow-right').addEventListener('click', () => {
    moveSlider('right', 'movieSlider2');
});

// 초기 슬라이드 설정 (slide-container, movieSlider2)
moveSlideToIndex(currentSlide);
moveSlider('right', 'movieSlider2');  // movieSlider2의 초기 위치 설정
