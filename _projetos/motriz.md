---
layout: projeto
title: "Motriz"
stack: "TypeScript · Expo · React Native"
status: "Em progresso"
repo: "https://github.com/kaaylooon/motriz"
description: "Aplicativo mobile para organizar ciclos de estudo e tarefas, combinando distribuição ponderada de disciplinas com uma lista de tarefas inspirada em todo.txt."
---

Motriz é um aplicativo construído com Expo e React Native para organizar estudos de forma prática. O projeto combina dois eixos principais: geração de ciclos de estudo e gerenciamento de tarefas.

Entre os recursos atuais, o app oferece:

- Cadastro de disciplinas com peso de dificuldade e tópicos em texto livre
- Geração de ciclos com dias e blocos configuráveis
- Distribuição ponderada de blocos com intercalação para evitar repetições próximas
- Criação automática de tarefas datadas com sintaxe inspirada em `todo.txt`
- Persistência local com `AsyncStorage` para disciplinas, ciclo, tarefas e configurações

Na implementação, o foco está em previsibilidade do motor de ciclo, tipagem estrita com TypeScript e uma interface baseada em componentes internos para manter consistência visual e evolução incremental.
