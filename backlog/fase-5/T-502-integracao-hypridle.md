---
id: T-502
titulo: Ligar o Insulano ao hypridle do Omarchy
fase: 5
estado: humano
tipo: infra
depende_de: [T-501]
---

## Objectivo
Depois de N minutos sem actividade, o Omarchy lança o Insulano em modo protector e termina-o quando o utilizador volta. A configuração em `~/.config/hypr/` é do Rodolfo: o agente propõe, o Rodolfo aplica.

## Ler antes
- ~/.claude/CLAUDE.md (regras da máquina: não mexer em ~/.config/hypr sem pedido)
- a skill `omarchy` antes de escrever qualquer bloco de configuração
- ~/.config/hypr/hypridle.conf (só leitura, para propor um bloco compatível)

## Critérios de aceitação
- [ ] Existe `docs/integracao-hypridle.md` com o bloco `listener` proposto (timeout, `on-timeout` que lança `dist/linux/insulano.x86_64 -- --screensaver`, `on-resume` que termina o processo), a interacção com o bloqueio de ecrã existente e como reverter (prova: o ficheiro, escrito pelo agente).
- [ ] O Rodolfo aplicou o bloco e confirmou que o protector arranca após o timeout e fecha ao mexer o rato (prova: confirmação do Rodolfo registada no Relatório).
- [ ] O bloqueio de ecrã e a suspensão continuam a funcionar como antes (prova: confirmação do Rodolfo).

## Fora de âmbito
- Editar `~/.config/hypr/` por agente.
- Instalar o Insulano no sistema (pacote AUR, /usr/bin).

## Prova exigida
- `docs/integracao-hypridle.md` e a confirmação do Rodolfo.

## Relatório
(preenchido pelo executor)
