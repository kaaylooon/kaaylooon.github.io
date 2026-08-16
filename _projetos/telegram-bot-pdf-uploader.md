---
layout: projeto
title: "Telegram PDF Uploader Bot"
stack: "Python · python-telegram-bot"
status: "Concluído"
home: true
image: "/assets/telegram-bot-pdf-2.png"
images:
  - "/assets/telegram-bot-pdf-2.png"
  - "/assets/telegram-bot-pdf-1.png"
repo: "https://github.com/kaaylooon/telegram-bot-pdf-uploader"
description: "Bot do Telegram em Python para indexar, buscar e enviar arquivos PDF de grandes coleções locais de forma simples e eficiente."
---

O Telegram PDF Uploader Bot é um bot escrito em Python com a biblioteca `python-telegram-bot`. Ele indexa uma coleção local de PDFs, permite buscar por nome e envia o arquivo diretamente no chat.

O índice (`pdf_index.json`) é gerado automaticamente pela ferramenta `tools/index_pdfs.py` e não deve ser editado manualmente. A configuração é feita por variáveis de ambiente: `TELEGRAM_BOT_TOKEN` para o token do bot e `PDF_BASE_DIR` para o diretório com os PDFs.