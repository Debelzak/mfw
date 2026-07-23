# MFW — Minimal Forwarding Wrapper

`mfw` é um utilitário minimalista para **encaminhamento de portas TCP/UDP** usando `iptables`. Ele foi projetado para expor serviços em um destino privado a partir de um host público, especialmente quando a máquina de destino está atrás de **CGNAT**, **VPN** ou em uma **rede privada**.

## Por que usar o MFW

- interface simples de linha de comando
- regras persistentes em `/etc/mfw/rules.conf`
- configuração e reload automáticos de regras
- atualização segura com verificação GPG
- proteção de gravação de configuração com `flock`

## Casos de uso comuns

- expor servidores de jogo (Minecraft, Valheim, Project Zomboid)
- redirecionar portas de serviços internos
- conectar um host privado a um ponto de entrada público
- publicar portas TCP/UDP sem depender apenas de proxies HTTP

## Requisitos

- Linux
- `bash`
- `iptables` (legacy ou nft backend)
- kernel com `netfilter`
- acesso root

### Requisitos opcionais para atualização

- `curl`
- `gpg`

## Instalação

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Debelzak/mfw/main/install.sh)"
```

O instalador:

1. cria `/etc/mfw`
2. instala o binário em `/usr/local/bin/mfw`
3. cria `mfw.service` no systemd
4. executa o assistente de configuração interativa
5. habilita e inicia o serviço

## Configuração

Use:

```bash
sudo mfw configure
```

O assistente pergunta por:

- interface pública (ex: `enp4s0`, `eth0`)
- interface de destino ou túnel (ex: `wg0`, `tun0`)

O `mfw` salva a configuração em `/etc/mfw/config.conf` e aplica ajustes de sysctl para:

- habilitar `net.ipv4.ip_forward`
- desabilitar `net.ipv4.conf.all.rp_filter`
- desabilitar `net.ipv4.conf.$PUBLIC_IF.rp_filter`

## Comandos

- `mfw version` — mostra a versão instalada
- `mfw add <tcp|udp> <port|start-end> [dest_ip/cidr]` — adiciona regra de redirecionamento com destino por regra
- `mfw del <tcp|udp> <port|start-end> [dest_ip/cidr]` — remove regra existente
- `mfw status` — exibe configuração e estado atual
- `mfw reload` — reaplica todas as regras
- `mfw configure` — reexecuta o assistente de configuração
- `mfw update` — verifica release no GitHub e atualiza com assinatura GPG
- `mfw help [command]` — mostra ajuda específica

## Uso básico

### Adicionar uma porta com destino específico

```bash
sudo mfw add tcp 25565 10.226.10.2/24
sudo mfw add udp 16261 10.226.10.3/24
```

### Adicionar um intervalo

```bash
sudo mfw add tcp 12621-12631 10.226.10.4/24
```

### Compatibilidade com regras antigas

Se um cliente antigo ainda tiver `DEST_IP` e `DEST_CIDR_BITS` em `config.conf`, o novo `mfw` continua aceitando `mfw add tcp 25565` como fallback legado. O novo formato também migra automaticamente regras antigas para o formato com destino por regra apenas quando necessário.

### Remover uma porta

```bash
sudo mfw del udp 16261
```

### Remover um intervalo

```bash
sudo mfw del tcp 12621-12631
```

### Verificar estado

```bash
sudo mfw status
```

### Recarregar regras

```bash
sudo mfw reload
```

### Ajuda

```bash
mfw help
mfw help add
mfw help configure
```

## Segurança

O `mfw` não faz controle de acesso. Ele apenas expõe as portas configuradas.

- qualquer IP pode acessar as portas expostas
- filtragem adicional deve ser feita em firewall de borda ou no destino

## Arquivos gerados

```text
/etc/mfw/
├── config.conf    # configuração principal
└── rules.conf     # lista de portas gerenciadas
```

Além disso, o instalador cria:

- `/etc/systemd/system/mfw.service`
- `/etc/sysctl.d/99-mfw.conf`

## Desinstalação

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Debelzak/mfw/main/uninstall.sh)"
```

## Testado em

- Debian/Ubuntu
- Fedora
- Arch Linux
