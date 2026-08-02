(function() {
  const toggleBtn = document.getElementById('langToggle');
  const textNodes = Array.from(document.querySelectorAll('[data-en][data-pt]'));
  const contentBlocks = Array.from(document.querySelectorAll('[data-language-block]'));
  let currentLang = document.documentElement.lang === 'en' ? 'en' : 'pt';

  function setTextLanguage(lang) {
    textNodes.forEach((el) => {
      const text = el.getAttribute(`data-${lang}`);
      if (text !== null) {
        el.textContent = text;
      }
    });
  }

  function setBlockLanguage(lang) {
    contentBlocks.forEach((block) => {
      const isActive = block.getAttribute('data-language-block') === lang;
      block.hidden = !isActive;
      block.setAttribute('aria-hidden', isActive ? 'false' : 'true');
    });
  }

  function setLanguage(lang) {
    setTextLanguage(lang);
    setBlockLanguage(lang);
    currentLang = lang;
    document.documentElement.lang = lang;

    if (toggleBtn) {
      toggleBtn.setAttribute('aria-label', lang === 'en' ? 'Mudar para português' : 'Switch to English');
      toggleBtn.setAttribute('title', lang === 'en' ? 'Mudar para português' : 'Switch to English');
    }
  }

  if (!toggleBtn) {
    return;
  }

  toggleBtn.addEventListener('click', () => {
    setLanguage(currentLang === 'en' ? 'pt' : 'en');
  });

  setLanguage(currentLang);
})();
