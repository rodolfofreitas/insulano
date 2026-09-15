# Insulano Gauntlet Loop -- Playbook

## Quando usar o Gauntlet vs o loop de backlog

| Situacao | Loop | Porque |
|---|---|---|
| Nova feature (T-114, T-115...) | Backlog loop | Criterios binarios claros, verify.sh |
| Polimento de sprites existentes | Gauntlet | Qualidade subjectiva, barra visual |
| Melhorar comportamento do naufrago | Gauntlet | Variedade/surprise, barra de gameplay |
| Afinar frases PT-PT | Gauntlet | Naturalidade, barra narrativa |
| Bug fix | Backlog loop | Criterio objectivo: nao crashar |
| Screensaver feel geral | Gauntlet | Experiencia holistica, barra JC |

## Modo A -- Hermes compoe, Claude Code executa (recomendado)

1. Dizer ao Hermes: 'Gauntlet: [dimensao] -- [peca especifica]'
2. O Hermes propoe 2-3 barras fetchable. Tu escolhes.
3. O Hermes escreve o prompt (~150 palavras) e grava em docs/gauntlet/PROMPT-YYYYMMDD.md
4. Tu abres uma sessao Claude Code fresca: `cd ~/Programacao/Kaeto/Insulano && claude`
5. Colas o conteudo de PROMPT-YYYYMMDD.md
6. Deixas correr. Tu es o travao.
7. O gauntlet-status.html atualiza a cada ronda. Ver no browser: `file:///...gauntlet-status.html`

## Modo B -- Hermes executa com subagentes isolados

Viavel porque delegate_task da contexto fresco a cada subagente.
Critico recebe APENAS: path do artefacto + path da referencia. Nada mais.

1. Dizer: 'Corre o gauntlet [peca] contra [barra]'
2. O Hermes faz fan-out: builder-subagente (implementa) + critic-subagente (avalia)
3. O critico recebe: screenshot do resultado + screenshot da barra + instrucao: 'pick um'
4. Se o critico escolhe a referencia: devolve o maior gap, ronda seguinte
5. Se o critico escolhe o nosso: a peca passou. Proximo item.
6. Tu podes parar a qualquer momento.

## Template de ronda

```
Gauntlet: [PECA] vs Johnny Castaway [BARRA]
Ronda [N] | Candidato: [hash/descricao] | Referencia: [barra]
Veredicto do critico: [JC ganhou | Insulano ganhou]
Gap devolvido: [descricao especifica ou PASSOU]
```

## O que invalida uma ronda (e tem de ser reiniciada)

- O critico viu o source ou o log de build
- O critico e o mesmo agente que construiu (mesmo contexto)
- O critico deu score em vez de pick
- A barra nao era fetchable e o critico inventou a comparacao
- O builder viu o veredicto do critico antes de comecar a proxima ronda

## Ratchet

So substitui o artefacto atual se o challenger ganhar o pick cego.
Um 'empate' e uma vitoria da referencia -- continua.
Nunca apagar rondas do status -- o historico mostra a curva de qualidade.

## Tu es o travao

O loop nao para sozinho. Para quando:
- O status deixar de mostrar gaps que te importam
- Ficares satisfeito com o pick do critico
- O custo/tempo nao justificar mais uma ronda

O Johnny Castaway ainda melhorava quando o Shumer matou o run.
