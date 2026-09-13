# Project Brief: Insulano

Uma página. Se algo aqui contradisser outro documento, este ganha no "o quê e porquê" e o
[`tech_design.md`](tech_design.md) ganha no "como".

## Visão

Um protector de ecrã que dá vontade de ficar a ver: um náufrago com vida própria numa ilha,
que reage à hora, ao tempo e às datas do mundo real, e que fala como um português com humor seco.
O espírito do Johnny Castaway, sem nenhum dos seus assets, com IA local no lugar das cenas gravadas.

## Para quem

Pessoas técnicas entre os 30 e os 50 anos, com nostalgia dos anos 90, que deixam o computador parado
durante compilações, renders e reuniões. Primeiro o Rodolfo, no Omarchy; depois quem o descarregar no itch.io.

## Pilares (por ordem, em caso de conflito)

1. **Vivo sem rede.** Funciona completo sem Ollama e sem internet. A IA é tempero, não fundação.
2. **Legalmente limpo.** Nenhum asset de terceiros sem licença verificada. Nada da Sierra.
3. **Discreto.** Leve em CPU e GPU, nunca intrusivo, sai ao primeiro movimento.
4. **Com personalidade.** Frases curtas, em pt-PT, coerentes com o que o personagem está a fazer.
5. **Construído por agentes, verificável por humanos.** Cada funcionalidade tem prova automática.

## O que não é

- Não é um jogo: não há objectivos, pontuação nem interacção directa (v0.x).
- Não é uma recriação fiel do Johnny Castaway.
- Não é um produto cloud nem recolhe dados.

## Sucesso

- Fase 1: o náufrago fala português gerado localmente, com fallback provado, num binário Linux.
- Fase 5: o Rodolfo usa-o como protector de ecrã real no Omarchy durante uma semana sem o desligar
  por irritação, e está publicado no itch.io com os créditos correctos.

## Restrições

- Godot 4 e GDScript; Ollama local; Linux primeiro, Windows depois.
- Máquina de referência: Ryzen 7 5800H, 32 GB RAM, Ollama só em CPU.
- Orçamento de dinheiro: zero (assets CC0 ou criados pelo projecto, ferramentas livres).
