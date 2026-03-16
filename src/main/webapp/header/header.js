/**
 * Header Module - Handles mobile navigation and UI effects
 */
document.addEventListener('DOMContentLoaded', () => {
    const menuToggle = document.getElementById('menuToggle');
    const navActions = document.getElementById('navActions');
    const body = document.body;

    if (menuToggle && navActions) {
        menuToggle.addEventListener('click', () => {
            // Toggle classes
            navActions.classList.toggle('open');
            
            // Change Icon
            const icon = menuToggle.querySelector('i');
            if (navActions.classList.contains('open')) {
                icon.classList.replace('fa-bars', 'fa-xmark');
                body.style.overflow = 'hidden'; // Prevent scrolling when menu open
            } else {
                icon.classList.replace('fa-xmark', 'fa-bars');
                body.style.overflow = 'auto';
            }
        });
    }

    // Close menu when clicking a link (mobile)
    const navLinks = document.querySelectorAll('.header-button');
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            navActions.classList.remove('open');
            body.style.overflow = 'auto';
        });
    });
});