# PRD — Insulano

Versão: 0.1 (protótipo)
Data: 2026-09-13
Autor: Rodolfo (Kaeto)

---

## 1. Problema

Os utilizadores que cresceram nos anos 90 têm nostalgia do Johnny Castaway (Sierra, 1992),
um protetor de ecrã com um náufrago animado. O original corre apenas em Windows 3.1 de
16-bit e o copyright pertence à Activision — não há continuação oficial há 34 anos.

Os remakes existentes (jc_reborn, Hunter Davis PS1, Guy on Island) focam-se em preservação
fiel ou são protótipos sem comportamento generativo real.

**Gap:** não existe um protetor de ecrã moderno, com assets originais e legalmente limpo,
onde o personagem use um LLM local para comportamento autónomo e imprevisível.

## 2. Proposta de valor

Insulano é um protetor de ecrã onde um náufrago numa ilha tropical:
- Faz coisas por iniciativa própria (pesca quando tem fome, dorme à noite, observa o oceano)
- Diz coisas geradas por IA local — nunca a mesma frase duas vezes
- Reage ao mundo real (hora do dia, estação do ano, clima lá fora, feriados)
- Corre 100% local, sem internet, sem API keys, sem custo recorrente

## 3. Utilizadores alvo

**Primário:** programadores e pessoas técnicas, 30-50 anos, nostalgia dos anos 90,
que deixam o computador inactivo durante longos períodos (compilações, renders, reuniões).

**Secundário:** qualquer utilizador Linux/Windows que queira um protetor de ecrã com
personalidade e não o habitual slide show de fotos.

## 4. Casos de uso

### UC-1: Protetor de ecrã inactivo
Utilizador deixa o computador. Ao fim de N minutos (configurável), o Insulano activa.
O náufrago está na ilha a fazer as suas coisas. O utilizador pode assistir sem interagir.
Qualquer movimento do rato ou tecla sai do protetor.

### UC-2: Modo janela (bonus)
Utilizador corre o Insulano como janela no canto do ecrã enquanto trabalha.
O náufrago coexiste com o trabalho sem ser intrusivo.

### UC-3: Reacção ao clima
Se está a chover na cidade do utilizador, a ilha também tem chuva.
O náufrago comenta o mau tempo com uma frase gerada pelo LLM.

### UC-4: Feriado especial
No Natal, a ilha tem neve e o náufrago tem gorro.
No Ano Novo, há fogos de artifício ao longe.

## 5. Fora de âmbito (v0.1)

- Interacção directa com o utilizador (clicar no personagem)
- Múltiplos personagens
- Editor de ilha
- Sons (Fase 5)
- Mobile

## 6. Critérios de sucesso (Fase 1)

- Corre no Omarchy (Linux/Wayland) sem crash
- Personagem faz pelo menos 3 acções diferentes (andar, pescar, sentar)
- LLM gera frase contextual em < 3 segundos
- Fallback sem LLM funciona (frases fixas)
- Export .x86_64 funcional

## 7. Riscos

Ver docs/threat_model.md para análise completa.

Principal: usar assets Sierra/Activision (copyright). Mitigado com assets CC0/CC-BY próprios.
Secundário: latência LLM quebrando a fluidez. Mitigado com chamadas assíncronas + fallback.
