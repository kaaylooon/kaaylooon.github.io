(function () {
  document.querySelectorAll("[data-carousel]").forEach(function (root) {
    var track = root.querySelector("[data-carousel-track]");
    var prev = root.querySelector("[data-carousel-prev]");
    var next = root.querySelector("[data-carousel-next]");
    if (!track || !prev || !next) return;

    function step() {
      var card = track.querySelector(".project-card");
      if (!card) return track.clientWidth * 0.8;
      var gap = parseFloat(getComputedStyle(track).columnGap || "16") || 16;
      return card.getBoundingClientRect().width + gap;
    }

    function update() {
      var max = track.scrollWidth - track.clientWidth - 1;
      var x = track.scrollLeft;
      prev.disabled = x <= 0;
      next.disabled = x >= max;
    }

    prev.addEventListener("click", function () {
      track.scrollBy({ left: -step(), behavior: "smooth" });
    });

    next.addEventListener("click", function () {
      track.scrollBy({ left: step(), behavior: "smooth" });
    });

    track.addEventListener("scroll", update, { passive: true });
    window.addEventListener("resize", update);
    update();
  });
})();
