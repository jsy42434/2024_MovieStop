document.addEventListener('DOMContentLoaded', function () {
    const hamburger = document.getElementById('hamburger');
    const menu = document.getElementById('menu');
    const genreToggle = document.getElementById('genreToggle');
    const genreSubmenu = document.querySelector('.genre-submenu');

    hamburger.addEventListener('click', function() {
        menu.classList.toggle('open');
    });

    genreToggle.addEventListener('click', function(event) {
        event.preventDefault(); // 기본 동작 방지
        genreSubmenu.style.display = genreSubmenu.style.display === 'block' ? 'none' : 'block';
    });
});