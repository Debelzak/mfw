# MFW — Minimal Forwarding Wrapper

`mfw` é uma ferramenta simples e direta para **encaminhamento de portas TCP/UDP** usando `iptables`, pensada para cenários onde você possui **uma máquina com IP público** (cloud/VPS) e precisa expor serviços rodando em **outra máquina atrás de CGNAT**, VPN ou rede privada.

Ele foi criado para ser:
- uma ferramenta simples
- previsível
- fácil de auditar
- persistente
- simples de manter
- sem dependências externas


## 🔎 Casos de uso comuns

O `mfw` é útil principalmente quando:

- Você tem um **VPS/Cloud/Máquina com IP público**
- Sua máquina de destino está:
  - atrás de **CGNAT**
  - em **rede doméstica**
  - conectada via **VPN**, túnel L3 ou link privado
- Você quer expor **portas TCP/UDP deliberadas**, não se limitando apenas a HTTP/HTTPS, como um proxy reverso comum.

### Exemplos práticos
- Expor um servidor de jogo (Project Zomboid, Minecraft, Valheim, etc)
- Redirecionar portas de serviços internos
- Criar um “gateway” simples:

(Seu IP público) → (Máquina pública) → MFW → `192.168.1.100`

## 🧱 Arquitetura

O `mfw` gerencia:
- DNAT (PREROUTING)
- FORWARD
- SNAT (MASQUERADE)
- Chains próprias (`MFW_PREROUTING`, `MFW_FORWARD`)

Sem interferir com outras regras do sistema.

## 📦 Requisitos

- Linux
- `bash`
- `iptables` (legacy ou nft backend)
- Kernel com `netfilter`
- Acesso root
- Um túnel funcional (ex: WireGuard) entre a máquina pública e a de destino

## 🚀 Instalação

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Debelzak/mfw/main/install.sh)"
```

## ⚙️ Configuração

Após a instalação o serviço iniciará o guia de configuração automaticamente, após isso, se quiser modificar alguma configuração/refazer a configuração. Utilize:

```bash
sudo mfw configure
```

Você será guiado para definir:

* Interface pública (ex: `enp4s0`, `eth0`)
* Interface do túnel (ex: `wg0`, `tun0`)
* IP de destino (CIDR) (ex: `100.64.0.2/24`, `10.100.0.2/24`)

O script irá:

* habilitar `ip_forward`
* desabilitar `rp_filter` nas interfaces necessárias
* salvar a configuração em `/etc/mfw/config.conf`

## 🧪 Uso básico

### ➕ Adicionar uma porta

```bash
sudo mfw add tcp 25565
sudo mfw add udp 16261
```

### ➖ Remover uma porta

```bash
sudo mfw del udp 16261
```

### 📋 Verificar configuração/estado atual

```bash
sudo mfw status
```

Exemplo de saída:

```
PROTO  PORT
tcp    25565
udp    16261
```

### 🔄 Recarregar regras

```bash
sudo mfw reload
```

Útil após ajustes manuais ou para depuração.

### ❓ Ajuda

```bash
mfw help
mfw help add
mfw help del
```

Ou:
```bash
mfw add --help
```

## 🔐 Segurança

Por padrão:

* Qualquer IP da internet pode acessar as portas expostas
* O controle de acesso **não é feito pelo mfw**

## 📁 Arquivos criados

```text
/etc/mfw/
├── config.conf    # Configuração principal
└── rules.conf     # Lista de portas gerenciadas
```

## 🗑️ Remoção

Caso deseje remover o MFW do seu sistema, basta utilizar o comando abaixo.

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Debelzak/mfw/main/uninstall.sh)"
```

## 🧪 Testado em

* Debian/Ubuntu
* Fedora
* ArchLinux
