# Insulano: Integracao com hypridle (T-502)

O hypridle e o daemon de inactividade do Hyprland. Detecta quando o rato
e o teclado ficam parados durante N segundos e executa comandos automaticamente.

## Como funciona

```
[utilizador inactivo 5min] --> hypridle lanca o Insulano em fullscreen
[utilizador move o rato]   --> hypridle termina o Insulano e restaura o ecra
```

## Bloco a adicionar em ~/.config/hypr/hypridle.conf

Cria o ficheiro se nao existir, ou adiciona ao existente:

```conf
# Insulano screensaver -- 5 minutos de inactividade
listener {
    timeout = 300
    on-timeout = /home/rodolfoc/Programacao/Kaeto/Insulano/dist/linux/insulano.x86_64 -- --screensaver
    on-resume = pkill -f insulano.x86_64
}
```

Notas:
- `timeout = 300` significa 300 segundos (5 minutos). Muda para 600 (10min) se preferires.
- `on-timeout` lanca o Insulano em modo screensaver (fullscreen, cursor oculto, fecha ao input).
- `on-resume` termina o processo quando mexes no rato ou teclado.
- O bloqueio de ecra (hyprlock) e a suspensao (systemd) nao sao afectados -- podes adicionar
  os teus listeners de lock/suspend normalmente no mesmo ficheiro.

## Exemplo completo com lock + screensaver

```conf
# Insulano screensaver -- 5 minutos
listener {
    timeout = 300
    on-timeout = /home/rodolfoc/Programacao/Kaeto/Insulano/dist/linux/insulano.x86_64 -- --screensaver
    on-resume = pkill -f insulano.x86_64
}

# Bloquear ecra -- 10 minutos
listener {
    timeout = 600
    on-timeout = hyprlock
}

# Suspender -- 30 minutos
listener {
    timeout = 1800
    on-timeout = systemctl suspend
}
```

## Activar o hypridle

```bash
# Iniciar agora (esta sessao)
systemctl --user start hypridle

# Activar no arranque (todas as sessoes)
systemctl --user enable hypridle

# Ver o estado
systemctl --user status hypridle

# Ver o log (util para depurar)
journalctl --user -u hypridle -f
```

## Testar sem esperar 5 minutos

```bash
# Forca o timeout manualmente para testar
hypridle --test-timeout 300
```

## Reverter (desligar o screensaver)

```bash
systemctl --user stop hypridle
# ou remover o bloco listener do hypridle.conf e reiniciar o servico
```

## Localizar o binario exportado

```bash
ls -lh ~/Programacao/Kaeto/Insulano/dist/linux/insulano.x86_64
```
