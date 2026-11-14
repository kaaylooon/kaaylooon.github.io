(function() {
    "use strict";

    var css = getComputedStyle(document.documentElement);
    function tok(name, fallback) {
        var v = css.getPropertyValue(name).trim();
        return v || fallback;
    }
    var C = {
        accent: tok("--accent", "#163d9a"),
        ink: tok("--text-main", "#1c1b19"),
        dim: tok("--text-dim", "#5f5b53"),
        line: tok("--border-color", "#cfcbc1"),
        bg: tok("--bg-card", "#ffffff")
    };
    var REDUCED = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    var DPR = Math.min(window.devicePixelRatio || 1, 3);

    function setupCanvas(canvas, vw, vh) {
        canvas.width = Math.round(vw * DPR);
        canvas.height = Math.round(vh * DPR);
        var ctx = canvas.getContext("2d");
        ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
        ctx.clearRect(0, 0, vw, vh);
        ctx.lineCap = "round";
        ctx.lineJoin = "round";
        return ctx;
    }
    function easeOut(t) { return 1 - Math.pow(1 - t, 3); }

    /* ============================================================
       Cena do hero — sistema orbital minimalista
       1 sol, 1 planeta, 2 luas. Sem estrelas, sem halo, rastros curtos.
       Tudo escala com (w, h), que são o tamanho real do canvas em CSS px.
       ============================================================ */
    function sceneHero(ctx, w, h, t) {
        var cx = w / 2, cy = h / 2;
        var R = Math.min(w, h) * 0.42;
        var clock = REDUCED ? 0 : t * 0.001;
        var cycle = 4.0;
        var phase = REDUCED ? 1 : (clock % cycle) / cycle;

        // 0..0.45 desenha K, 0.45..0.75 desenha S, 0.75..1.0 fade out
        var drawK = Math.min(1, phase / 0.45);
        var drawS = Math.min(1, Math.max(0, (phase - 0.45) / 0.30));
        var fade = phase > 0.75 ? 1 - (phase - 0.75) / 0.25 : 1;
        var alpha = 0.95 * fade;

        var scale = R * 1.1;

        ctx.globalAlpha = alpha;
        ctx.strokeStyle = C.accent;
        ctx.lineWidth = 4;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";

        /* ============================================================
           K — traço único e curvo, como caligrafia rápida.
           Ordem: topo da haste -> desce -> curva no meio ->
           sobe a diagonal superior com arco -> volta ao meio ->
           desce a diagonal inferior com arco oposto.
           ============================================================ */
        var kx = cx - scale * 0.35;
        var kyTop = cy - scale * 0.45;
        var kyBot = cy + scale * 0.45;
        var kyMid = cy;

        // controle dos arcos das diagonais (afasta o "mecânico")
        var bow = scale * 0.06;       // curvatura das diagonais
        var midBulge = scale * 0.04;  // leve saliência da haste no meio

        var kPath = new Path2D();
        // haste: começa no topo, desce com leve arco para a esquerda no meio
        kPath.moveTo(kx, kyTop);
        kPath.quadraticCurveTo(kx - midBulge, kyMid, kx, kyBot);

        // volta ao meio (sem levantar o "pincel": o dash revela na ordem)
        kPath.moveTo(kx, kyMid);

        // diagonal superior: sobe com arco para fora (para a direita)
        // o controle fica acima da linha reta -> curva "sorrindo para cima"
        kPath.quadraticCurveTo(
            kx + scale * 0.18 - bow, kyMid - scale * 0.12,
            kx + scale * 0.30, kyTop
        );

        // diagonal inferior: desce com arco para fora (oposto)
        kPath.moveTo(kx, kyMid);
        kPath.quadraticCurveTo(
            kx + scale * 0.18 - bow, kyMid + scale * 0.12,
            kx + scale * 0.30, kyBot
        );

        // desenha K progressivamente
        if (drawK > 0) {
            // comprimento aproximado do path (haste + 2 diagonais)
            var kLen = scale * 0.9 * 3; // ~3x a altura, grosseiro mas estável
            ctx.setLineDash([kLen, kLen]);
            ctx.lineDashOffset = kLen * (1 - drawK);
            ctx.stroke(kPath);
            ctx.setLineDash([]);
            ctx.lineDashOffset = 0;
        }

        /* ============================================================
           S — duas béziers contínuas (mantido igual ao original)
           ============================================================ */
        function sCurve(prog) {
            if (prog <= 0) return;
            var sx = cx + scale * 0.05;
            var syTop = cy - scale * 0.45;
            var syBot = cy + scale * 0.45;
            var sw = scale * 0.28;
            ctx.beginPath();
            ctx.moveTo(sx + sw, syTop);
            ctx.bezierCurveTo(sx - sw, syTop, sx - sw, cy, sx, cy);
            ctx.bezierCurveTo(sx + sw, cy, sx + sw, syBot, sx - sw, syBot);
            ctx.setLineDash([1e3, 1e3]);
            ctx.lineDashOffset = 1e3 * (1 - prog);
            ctx.stroke();
            ctx.setLineDash([]);
            ctx.lineDashOffset = 0;
        }
        sCurve(drawS);

        ctx.globalAlpha = 1;
    }
    /* ============================================================
       Bootstrap responsivo
       - usa o tamanho real do canvas em CSS px (clientWidth/Height)
       - ResizeObserver dispara redraw ao dar zoom / redimensionar
       - data-vb é IGNORADO se o canvas tiver tamanho CSS próprio
       ============================================================ */
    function initCanvas(canvas) {
        var start = null;
        var visible = true;
        var rafId = null;
        var ctx = null;
        var vw = 0, vh = 0;

        function measure() {
            // fallback: data-vb (útil se o canvas não tiver layout ainda)
            var rect = canvas.getBoundingClientRect();
            var w = Math.round(rect.width) || 0;
            var h = Math.round(rect.height) || 0;
            if (!w || !h) {
                var vb = (canvas.dataset.vb || "400 300").split(" ");
                w = parseFloat(vb[0]) || 400;
                h = parseFloat(vb[1]) || 300;
            }
            if (w === vw && h === vh) return false;
            vw = w;
            vh = h;
            ctx = setupCanvas(canvas, vw, vh);
            return true;
        }

        function draw(ts) {
            if (!visible) { rafId = null; return; }
            if (start === null) start = ts;
            ctx.save();
            ctx.setTransform(1, 0, 0, 1, 0, 0);
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.restore();
            ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
            sceneHero(ctx, vw, vh, ts - start);
            rafId = requestAnimationFrame(draw);
        }

        function kick() {
            if (REDUCED) {
                measure();
                sceneHero(ctx, vw, vh, 1200);
                return;
            }
            if (rafId === null) rafId = requestAnimationFrame(draw);
        }

        measure();

        if (REDUCED) {
            sceneHero(ctx, vw, vh, 1200);
        } else {
            kick();
        }

        // redimensionamento / zoom
        if (typeof ResizeObserver !== "undefined") {
            var ro = new ResizeObserver(function() {
                if (measure()) {
                    // se estava pausado por invisibilidade, não reinicia;
                    // se estava animando, o próximo frame já usa o novo tamanho
                    if (REDUCED) sceneHero(ctx, vw, vh, 1200);
                }
            });
            ro.observe(canvas);
        } else {
            window.addEventListener("resize", function() {
                if (measure() && REDUCED) sceneHero(ctx, vw, vh, 1200);
            });
        }

        // pausa quando fora da viewport
        var io = new IntersectionObserver(function(entries) {
            visible = entries[0].isIntersecting;
            if (visible) kick();
            else if (rafId !== null) { cancelAnimationFrame(rafId); rafId = null; }
        }, { threshold: 0.01 });
        io.observe(canvas);
    }

    document.querySelectorAll('canvas[data-fig="hero"], canvas[data-fig="stack"]').forEach(initCanvas);
})();
