# Flint 依赖包问题解决方法

> 创建日期: 2026-11-07  
> 适用版本: Flint 0.0.59  
> 设备: CardputerZero (PatCZero)

---

## 问题描述

安装 Flint 后，应用提示缺少以下依赖包：
- mdk4
- bluez
- ettercap
- msfvenom
- reaver

---

## 解决方法

### 1. 安装基础依赖包

由于 apt 可能因为依赖问题卡住，使用 `apt download` + `dpkg -i` 逐个安装：

```bash
# 下载依赖包
cd /tmp
apt download python3-bleak python3-scapy python3-aiohttp mdk4 ettercap-text-only reaver

# 下载 Python 依赖
apt download python3-dbus-fast python3-async-timeout python3-yarl \
    python3-aiohappyeyeballs python3-aiosignal python3-frozenlist \
    python3-multidict python3-propcache

# 下载 ettercap 依赖
apt download ettercap-common geoip-database libgeoip1t64 libnet1

# 按顺序安装（先装依赖，再装主包）
sudo dpkg -i python3-async-timeout_*.deb
sudo dpkg -i python3-multidict_*.deb python3-propcache_*.deb
sudo dpkg -i python3-yarl_*.deb
sudo dpkg -i python3-aiohappyeyeballs_*.deb python3-aiosignal_*.deb python3-frozenlist_*.deb
sudo dpkg -i python3-aiohttp_*.deb
sudo dpkg -i python3-dbus-fast_*.deb
sudo dpkg -i python3-bleak_*.deb
sudo dpkg -i python3-scapy_*.deb
sudo dpkg -i mdk4_*.deb
sudo dpkg -i libgeoip1t64_*.deb geoip-database_*.deb libnet1_*.deb
sudo dpkg -i ettercap-common_*.deb
sudo dpkg -i ettercap-text-only_*.deb
sudo dpkg -i reaver_*.deb
```

### 2. 安装 Metasploit Framework (msfvenom)

Metasploit 不在 Debian 官方仓库，从 Kali 仓库下载：

```bash
# 下载 ARM64 版本
curl -L "http://http.kali.org/kali/pool/main/m/metasploit-framework/metasploit-framework_6.5.8-0kali1_arm64.deb" \
    -o /home/pi/metasploit-framework_arm64.deb

# 安装（会报依赖缺失，继续下一步）
sudo dpkg -i /home/pi/metasploit-framework_arm64.deb

# 强制配置（忽略依赖警告）
sudo dpkg --force-depends --configure metasploit-framework
```

### 3. 安装 Ruby 运行环境

msfvenom 需要 Ruby 3.3+：

```bash
# 下载 Ruby 相关包
cd /tmp
apt download ruby ruby3.3 libruby3.3 rubygems-integration ruby-rubygems rake ruby-json
apt download libyaml-0-2 ruby-csv ruby-did-you-mean ruby-net-telnet \
    ruby-ruby2-keywords ruby-xmlrpc ruby-webrick

# 按顺序安装
sudo dpkg -i libyaml-0-2_*.deb
sudo dpkg -i ruby-csv_*.deb ruby-did-you-mean_*.deb ruby-net-telnet_*.deb \
    ruby-ruby2-keywords_*.deb ruby-xmlrpc_*.deb ruby-webrick_*.deb
sudo dpkg -i rubygems-integration_*.deb
sudo dpkg -i libruby3.3_*.deb
sudo dpkg -i ruby3.3_*.deb
sudo dpkg -i ruby_*.deb

# 强制配置
sudo dpkg --force-depends --configure libruby3.3 ruby3.3 rake ruby
```

### 4. 修复 Flint 的 bluez 依赖检查

Flint 代码中错误地检查 `bluez`（包名），应该检查 `bluetoothctl`（可执行文件）：

```bash
# 修复所有位置的依赖检查
sudo sed -i 's/Dependency(name="bluez"/Dependency(name="bluetoothctl"/' \
    /opt/flint/tools/ble/ble_spam.py

sudo sed -i 's/Dependency(name="bluez"/Dependency(name="bluetoothctl"/' \
    /opt/flint/.venv/lib/python*/site-packages/tools/ble/ble_spam.py

sudo sed -i 's/Dependency(name="bluez"/Dependency(name="bluetoothctl"/' \
    /opt/flint/build/lib/tools/ble/ble_spam.py
```

---

## 验证安装

```bash
# 检查各工具是否可用
which bluetoothctl && bluetoothctl --version
which hcitool && hcitool dev
which msfvenom && msfvenom --version
which ruby && ruby --version

# 检查 flint 状态
dpkg -s flint | grep -E '^(Package|Status|Version):'

# 测试蓝牙扫描
sudo hcitool -i hci0 lescan --passive
```

---

## 注意事项

1. **apt 卡住问题**：如果 apt 下载卡住，可以 `Ctrl+C` 中断后重试，已下载的文件会保留在 `/tmp`

2. **依赖循环**：Ruby 包之间存在依赖循环，使用 `--force-depends` 强制配置

3. **磁盘空间**：Metasploit 占用约 651MB，确保有足够空间

4. **内存影响**：安装后内存使用增加约 56MB，但 Swap 充裕（4GB+）

5. **bluez 检查**：Flint 的依赖检查逻辑有问题，需要手动修复代码

---

## 相关资源

- [Flint 官方仓库](https://github.com/marivaaldo/flint)
- [Metasploit Framework](https://docs.metasploit.com/)
- [Kali Linux 包仓库](http://http.kali.org/kali/pool/main/)

---

*文档维护: CardputerZero 项目团队*
