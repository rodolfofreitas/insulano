# Insulano

Protetor de ecrã inspirado no Johnny Castaway (Sierra, 1992) — um náufrago numa ilha
com comportamento autónomo dirigido por IA (LLM local via Ollama).

## Conceito

Um personagem pixel art vive numa ilha tropical. Tem necessidades reais (fome, cansaço,
tédio) e um LLM local decide o que ele faz em cada momento: pesca, dorme, observa o
oceano, reage ao tempo lá fora, comenta a hora do dia — tudo gerado dinamicamente,
nunca repetido da mesma forma.

Sem copyright de terceiros. Sem cloud. Sem API keys. Corre 100% local.

## Estado

PROTÓTIPO INICIAL — em definição de arquitectura

## Stack

- Motor: Godot 4 (GDScript)
- IA de comportamento: Ollama (local, modelos leves como gemma3:4b ou llama3.2:3b)
- Behavior trees: Beehave (plugin Godot)
- Assets tileset: Tiny Islands por Majadroid (CC0)
- Assets personagem: 16x18 Character Base por Antifarea & Clint Bellanger (CC-BY)

## Base de código

Fork do Guy on Island (MIT) por Doubi:
- Repositório original: https://codeberg.org/Doubi/guy-on-island
- Clonado em: base-guy-on-island/

## Legal

- Código: MIT (herdado do Guy on Island, compatível com Kaeto)
- Tileset Tiny Islands: CC0 (domínio público — sem restrições)
- Personagem base: CC-BY (crédito obrigatório: Antifarea & Clint Bellanger / OpenGameArt.org)
- SEM assets Sierra/Activision — projecto original e legalmente limpo

## Inspirações documentadas

- Johnny Castaway (Sierra, 1992) — conceito e espírito
- Guy on Island (Doubi, 2025) — base de código Godot 4
- Hunter Davis PS1 Port (2026) — abordagem de feriados e VLM
- Mochi LLM Pet (NatBrian, 2026) — arquitectura LLM para comportamento

## Créditos

- Rodolfo (Kaeto) — desenvolvimento
- Antifarea & Clint Bellanger — base sprite do personagem (CC-BY)
- Majadroid — tileset Tiny Islands (CC0)
- Doubi — código base Guy on Island (MIT)
