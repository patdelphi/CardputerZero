# CardputerZero 项目分析报告

> 生成日期: 2026-11-06  
> 项目版本: 0.2.1  
> 分析范围: Template 目录完整代码库 + Docs 文档

---

## 1. 项目概述

### 1.1 项目定位

**CardputerZero** 是 M5Stack 为 CardputerZero 硬件设备开发的嵌入式 Linux GUI 应用框架。项目提供了一个完整的 MVVM 架构模板，支持：

- 桌面端模拟器（SDL2 渲染）用于快速 UI 开发
- 设备端交叉编译（aarch64 Linux）用于实际部署
- 统一的 CMake 构建系统

### 1.2 核心特性

| 特性 | 说明 |
|------|------|
| GUI 框架 | LVGL v9.5.0 - 轻量级嵌入式图形库 |
| 架构模式 | MVVM (Model-View-ViewModel) |
| 响应式绑定 | 基于 LVGL observer 模式的自定义 Subject 系统 |
| 多平台支持 | Windows/Linux/macOS 桌面端 + ARM64 设备端 |
| 主题系统 | 明暗双主题，支持运行时切换和持久化 |
| 资源管理 | 多路径资源查找（CMake/源码/安装目录） |

### 1.3 项目统计

```
源代码统计:
├── 源文件数量: 52 (.cpp + .h)
├── 代码行数: 6,927
├── 资源文件:
│   ├── 字体: 3个 TTF (Phosphor-Fill, Kenney Keyboard)
│   ├── 图标: 7个 PNG (不同尺寸的应用图标)
│   └── 音频: 1个 WAV (click.wav)
└── 构建配置:
    ├── CMake Presets: 7个配置预设
    └── Skills: 4个 AI 辅助技能
```

---

## 2. 目录结构

```
CardputerZero/
├── Docs/
│   └── CardputerZero.pdf          # 硬件文档 (约30MB)
└── Template/
    ├── .agents/skills/            # AI 辅助技能定义
    │   ├── cardputerzero-ui-feature/
    │   ├── cardputerzero-peripherals/
    │   ├── cardputerzero-template-customization/
    │   └── cardputerzero-package-release/
    ├── assets/                    # 运行时资源
    │   ├── audio/                 # 音频文件
    │   ├── fonts/                 # 字体文件 (TTF)
    │   └── images/                # 图标和图片
    ├── cmake/                     # CMake 模块
    │   ├── cm0-package.cmake      # Debian 打包配置
    │   ├── templates/             # 打包模板
    │   └── toolchains/            # 交叉编译工具链
    ├── config/                    # 应用配置
    │   └── template-app.conf      # 主题配置文件
    ├── screenshot/                # 模拟器截图
    ├── src/                       # 源代码
    │   ├── app/                   # 应用层 (6个文件)
    │   ├── config/                # LVGL 配置 (3个文件)
    │   ├── logger/                # 日志系统 (2个文件)
    │   ├── model/                 # 数据模型 (2个文件)
    │   ├── platform/              # 平台抽象层 (6个文件)
    │   ├── reactive/              # 响应式绑定 (4个文件)
    │   ├── view/                  # UI 视图层
    │   │   ├── screens/           # 页面 (6个文件)
    │   │   └── widgets/           # 组件 (10个文件)
    │   ├── viewmodel/             # 视图模型 (2个文件)
    │   └── main.cpp               # 入口点
    ├── CMakeLists.txt             # 主构建文件 (634行)
    ├── CMakePresets.json          # 构建预设
    ├── vcpkg.json                 # Windows 依赖清单
    ├── app-builder.json           # 应用商店元数据
    ├── deploy.sh                  # 部署脚本
    └── README.md                  # 项目说明
```

---

## 3. 架构设计

### 3.1 分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   app.cpp   │  │screen_manager│  │   asset_manager     │ │
│  │ (生命周期)   │  │ (页面路由)    │  │   (资源管理)        │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                      ViewModel Layer                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              base_viewmodel.cpp                      │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │  Subjects   │  │   Actions   │  │  Commands   │ │   │
│  │  │ (响应式状态) │  │ (业务逻辑)   │  │ (用户交互)  │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                       Model Layer                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                base_model.cpp                        │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │  AppPage    │  │  dark_mode  │  │   counter   │ │   │
│  │  │  (页面枚举)  │  │  (主题状态)  │  │  (计数器)   │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                        View Layer                            │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐ │
│  │   BaseScreen   │  │    NavBar      │  │  IconButton  │ │
│  │   (页面基类)    │  │  (导航栏组件)   │  │  (按钮组件)   │ │
│  └────────────────┘  └────────────────┘  └──────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                    Reactive Layer                            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │  │
│  │  │  Subjects   │  │  Bindings   │  │  Observers  │  │  │
│  │  │ (状态容器)   │  │ (数据绑定)   │  │ (变化监听)   │  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    Platform Layer                            │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────┐   │
│  │ linux_input  │  │ device_status│  │screenshot_service│  │
│  │ (输入处理)    │  │ (设备状态)    │  │ (截图服务)      │  │
│  └──────────────┘  └──────────────┘  └────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 数据流

```
用户输入 (键盘/触摸)
    │
    ▼
┌─────────────────┐
│  Widget Callback │ ◄─── view/widgets/*.cpp
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ ViewModel Action │ ◄─── viewmodel/base_viewmodel.cpp
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Model Update   │ ◄─── model/base_model.cpp
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Subject.notify() │ ◄─── reactive/subjects.cpp
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ LVGL Observer  │ ◄─── reactive/bindings.cpp
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   UI Refresh    │ ◄─── LVGL 自动渲染
└─────────────────┘
```

### 3.3 核心模块详解

#### 3.3.1 Reactive 响应式系统

**subjects.h/cpp** - 类型安全的状态容器

| 类型 | 用途 | 示例 |
|------|------|------|
| `IntSubject` | 整数状态 | 页面索引、计数器 |
| `BoolSubject` | 布尔状态 | 主题模式、可见性 |
| `StringSubject<N>` | 字符串状态 | 标题、问候语 |
| `PointerSubject<T>` | 指针状态 | 图片资源 |
| `ColorSubject` | 颜色状态 | 主题色 |
| `GroupSubject<N>` | 组合状态 | 多字段聚合 |

**bindings.h/cpp** - 声明式数据绑定

```cpp
// 主题绑定
reactive::bind_theme(label, dark_mode_subject, ThemeRole::Text);

// 文本绑定
reactive::bind_label_text(label, string_subject, "格式: %s");

// 值绑定
reactive::bind_slider_value(slider, int_subject);

// 标志位绑定
reactive::bind_flag(obj, bool_subject, LV_OBJ_FLAG_HIDDEN, 0, Compare::Equal);
```

#### 3.3.2 Screen 页面系统

**BaseScreen** - 页面基类

```cpp
class BaseScreen {
    lv_obj_t* root_;        // 页面根对象
    lv_obj_t* content_;     // 内容区域
    TitleBar* title_bar_;   // 标题栏
    NavBar* nav_bar_;       // 导航栏
    
    virtual void build_content(lv_obj* content) = 0;  // 子类实现
};
```

**当前页面**:
- `AppleScreen`: 首页，显示问候语、主题切换、版本信息
- `ButterScreen`: 计数器页面，演示增减操作

#### 3.3.3 Platform 平台抽象

**输入系统** (`linux_input.h`)

```cpp
// 特殊键定义
constexpr uint32_t kKeyPrintScreen = 0x200000U | 18U;
constexpr uint32_t kKeyHelp = 0x200000U | 19U;

// 全局键盘监听器
using GlobalKeyListener = bool (*)(uint32_t key, const char* key_name, 
                                   bool long_pressed, void* user_data);
```

**快捷键映射**:

| 按键 | 功能 | 触发方式 |
|------|------|----------|
| `4` | 导航按钮 1 / 退出 | 短按/长按 |
| `5` | 导航按钮 2 | - |
| `6` | 导航按钮 3 (主题切换) | - |
| `7` | 导航按钮 4 | - |
| `8` | 导航按钮 5 | - |
| `ESC` | 退出/返回 | 短按返回，长按退出 |
| `H` | 帮助弹窗 | 短按 |
| `PrintScreen` | 截图保存 | 短按 |
| `Left/Right` | 计数器减/增 | 仅 Butter 页面 |

---

## 4. 构建系统

### 4.1 CMake 预设

| 预设名称 | 目标平台 | 说明 |
|----------|----------|------|
| `darwin-arm64` | macOS Apple Silicon | 桌面模拟器 |
| `darwin-x86-64` | macOS Intel | 桌面模拟器 |
| `linux-x86-64` | Linux x64 | 桌面模拟器 |
| `win32-msvc` | Windows MSVC | 桌面模拟器 |
| `win32-mingw64` | Windows MinGW | 桌面模拟器 |
| `cp0-native` | CardputerZero 原生 | 设备端构建 |
| `cp0-cross` | CardputerZero 交叉编译 | aarch64 设备 |

### 4.3 构建命令

```bash
# 桌面端 (以 Linux 为例)
cmake --preset linux-x86-64
cmake --build --preset linux-x86-64-dbg
./build/linux-x86-64/Debug/template_app

# 设备端交叉编译
cmake --preset cp0-cross
cmake --build --preset cp0-cross-rel

# 打包 Debian
cpack --preset cp0-cross-deb
# 或一键完成
cmake --workflow --preset cp0-cross-package
```

---

## 5. 部署架构

### 5.1 Debian 包结构

```
TemplateApp_0.2.1_rev1_arm64.deb
└── /usr/
    ├── bin/
    │   └── template_app              # 可执行文件
    ├── etc/
    │   └── template-app.conf         # 系统默认配置
    ├── share/
    │   ├── template_app/
    │   │   ├── audio/                # 音频资源
    │   │   ├── fonts/                # 字体资源
    │   │   └── images/               # 图片资源
    │   ├── APPLaunch/
    │   │   ├── applications/
    │   │   │   └── template_app.desktop  # 启动器入口
    │   │   └── share/images/
    │   │       └── template*.png     # 启动器图标
    │   └── doc/template_app/
    │       ├── README.md
    │       └── third-party-assets-license.txt
    └── lib/systemd/system/
        └── template_app.service      # systemd 服务
```

### 5.2 配置文件优先级

```
1. $XDG_CONFIG_HOME/template-app/template-app.conf  (用户配置)
2. ~/.config/template-app/template-app.conf         (用户配置备选)
3. /etc/template-app.conf                           (系统配置)
4. config/template-app.conf                         (开发配置)
```

### 5.3 资源查找顺序

```
1. APP_ASSETS_ROOT (CMake 指定)
2. 源码树 assets/ 目录
3. /usr/share/<APP_NAME>/ (安装目录)
```

---

## 6. Skills 系统

项目配置了 4 个 AI 辅助技能，用于指导开发者进行特定类型的修改：

### 6.1 cardputerzero-ui-feature

**用途**: 添加新的 UI 功能/页面

**指导内容**:
- 如何扩展 `AppPage` 枚举
- 如何创建新的 `BaseScreen` 子类
- 如何在 `ScreenManager` 中注册页面
- 如何更新 `NavBar` 图标和回调

### 6.2 cardputerzero-peripherals

**用途**: 集成硬件外设

**支持的外设**:

| 类别 | 外设 | 后端 |
|------|------|------|
| 媒体传感器 | 摄像头 | libcamera |
| 媒体传感器 | 音频录制/播放 | miniaudio |
| 媒体传感器 | IMU (BMI270/BMM150) | Linux IIO |
| 连接 | WiFi/以太网 | NetworkManager |
| 连接 | 蓝牙 | BlueZ |
| 硬件IO | GPIO | libgpiod |
| 硬件IO | I2C/SPI/UART | Linux sysfs |
| 显示 | HDMI | DRM/KMS |

### 6.3 cardputerzero-template-customization

**用途**: 定制应用身份（名称、图标等）

**关键文件映射**:

| 身份值 | 文件位置 |
|--------|----------|
| 显示名称 `TemplateApp` | CMakeLists.txt, cm0-package.cmake |
| 项目名 `template_app` | CMakeLists.txt, app-builder.json |
| 配置身份 `template-app` | config 文件路径 |
| 图标基础名 `template` | assets/images/ |

### 6.4 cardputerzero-package-release

**用途**: 打包和发布应用

**发布清单**:
1. 桌面端构建成功
2. `cp0-cross-package` 成功
3. 生成 ARM64 Debian 包
4. `app-builder.json` 元数据完整
5. 图标和截图更新

---

## 7. 代码质量评估

### 7.1 优点

| 方面 | 评价 |
|------|------|
| 架构设计 | ⭐⭐⭐⭐⭐ 分层清晰，MVVM 模式规范 |
| 代码风格 | ⭐⭐⭐⭐ 统一的命名规范，SPDX 许可证头 |
| 文档完善度 | ⭐⭐⭐⭐ README 详细，Skills 指导完整 |
| 构建系统 | ⭐⭐⭐⭐⭐ CMake Presets 多平台支持完善 |
| 可扩展性 | ⭐⭐⭐⭐⭐ BaseScreen/BaseWidget 易于扩展 |

### 7.2 待改进

| 方面 | 建议 |
|------|------|
| 自动化测试 | 添加单元测试和 UI 测试框架 |
| CI/CD | 配置 GitHub Actions 自动构建 |
| 代码格式 | 添加 .clang-format 配置文件 |
| 文档格式 | 将 PDF 转换为 Markdown 便于版本控制 |
| 错误处理 | 增加更详细的错误日志和异常处理 |

---

## 8. 开发指南

### 8.1 添加新页面

1. **扩展 Model**:
   ```cpp
   // src/model/base_model.h
   enum class AppPage {
       Apple = 0,
       Butter = 1,
       NewPage = 2,  // 添加新页面
   };
   ```

2. **扩展 ViewModel**:
   ```cpp
   // src/viewmodel/base_viewmodel.h
   void show_new_page();
   ```

3. **创建 Screen**:
   ```cpp
   // src/view/screens/new_screen.h
   class NewScreen : public BaseScreen {
       void build_content(lv_obj* content) override;
   };
   ```

4. **注册到 ScreenManager**:
   ```cpp
   // src/app/screen_manager.cpp
   void ScreenManager::show_new_screen() {
       load_screen(std::make_unique<screen::NewScreen>(view_model_, assets_));
   }
   ```

### 8.2 添加新组件

1. **继承 BaseWidget**:
   ```cpp
   class MyWidget : public BaseWidgets {
       void build() override;
   };
   ```

2. **使用响应式绑定**:
   ```cpp
   void MyWidget::build() {
       auto* label = lv_label_create(parent_);
       reactive::bind_label_text(label, view_model.some_subject());
       reactive::bind_theme(label, view_model.dark_mode_subject(), ThemeRole::Text);
   }
   ```

### 8.3 调试技巧

```bash
# 启用详细日志
export LOG_LEVEL=debug

# 桌面模拟器运行
./build/linux-x86-64/Debug/template_app

# 截图保存位置
ls -la ~/Pictures/Screenshots/  # 或当前目录

# 配置文件位置
cat ~/.config/template-app/template-app.conf
```

---

## 4. 开发技术栈

### 4.1 核心技术栈

| 层级 | 技术 | 版本/说明 |
|------|------|----------|
| **编程语言** | C++ | C++17 |
| **GUI 框架** | LVGL | v9.5.0 |
| **构建系统** | CMake | ≥ 3.31 |
| **桌面模拟** | SDL2 | 2.32.x |
| **字体渲染** | FreeType | 2.13.x |
| **图像解码** | libpng + libjpeg-turbo | 1.6.x / 3.1.x |
| **日志库** | fmt | 10.1.1 |
| **包管理** | vcpkg (Windows) / apt (Linux) | - |

### 4.2 架构模式

```
┌─────────────────────────────────────────┐
│           MVVM 架构模式                  │
├─────────────────────────────────────────┤
│  View (LVGL UI)                         │
│    ↓ 用户交互                            │
│  ViewModel (响应式状态 + 业务逻辑)        │
│    ↓ 数据绑定                            │
│  Model (纯数据模型)                      │
└─────────────────────────────────────────┘
```

**关键技术特点**:

1. **响应式数据绑定**
   ```cpp
   // 基于 LVGL observer 模式的自定义 Subject 系统
   reactive::IntSubject counter_subject_;
   reactive::BoolSubject dark_mode_subject_;
   reactive::StringSubject<32> title_subject_;
   
   // 声明式绑定
   reactive::bind_label_text(label, subject);
   reactive::bind_theme(obj, dark_mode_subject, ThemeRole::Text);
   ```

2. **双显示后端**
   - **Framebuffer** (`/dev/fb0`) - 传统 Linux 显示
   - **DRM/KMS** (`/dev/dri/card0`) - 现代 Linux 显示，支持 HDMI 输出

3. **资源管理**
   ```
   查找顺序:
   1. CMake 指定的 APP_ASSETS_ROOT
   2. 源码树 assets/ 目录
   3. 安装目录 /usr/share/<APP_NAME>/
   ```

4. **配置持久化**
   ```
   优先级:
   1. $XDG_CONFIG_HOME/template-app/template-app.conf
   2. ~/.config/template-app/template-app.conf
   3. /etc/template-app.conf
   ```

### 4.3 平台支持

| 平台 | 用途 | 工具链 |
|------|------|--------|
| **Linux x64** | 桌面开发/调试 | GCC + SDL2 |
| **macOS (ARM/Intel)** | 桌面开发/调试 | Clang + SDL2 |
| **Windows (MSVC/MinGW)** | 桌面开发/调试 | MSVC/MinGW + SDL2 + vcpkg |
| **aarch64 Linux** | 设备端部署 | 交叉编译 (ARM64) |

### 4.4 开发流程

```
1. 桌面开发 (快速迭代)
   cmake --preset linux-x86-64  # 或 darwin-arm64 / win32-msvc
   cmake --build --preset linux-x86-64-dbg
   ./build/linux-x86-64/Debug/template_app

2. 设备交叉编译
   cmake --preset cp0-cross
   cmake --build --preset cp0-cross-rel

3. 打包部署
   cpack --preset cp0-cross-deb
   # 生成 .deb 包，通过 deploy.sh 传输到设备
```

### 4.5 项目模板结构

```
Template/
├── src/
│   ├── app/           # 应用生命周期、资源管理
│   ├── model/         # 数据模型
│   ├── viewmodel/     # 视图模型 (响应式状态)
│   ├── view/          # UI 层
│   │   ├── screens/   # 页面 (继承 BaseScreen)
│   │   └── widgets/   # 组件 (继承 BaseWidget)
│   ├── reactive/      # 响应式绑定系统
│   ├── platform/      # 平台抽象 (输入、截图等)
│   └── logger/        # 日志
└── CMakeLists.txt     # 构建配置
```

### 4.6 开发约定

| 约定 | 说明 |
|------|------|
| 屏幕分辨率 | 320x170 (固定) |
| 导航键 | `4-8` 对应底部导航栏图标 |
| 快捷键 | `ESC` 退出/返回, `H` 帮助, `PrintScreen` 截图 |
| 主题 | 明暗双主题，通过 `6` 键切换 |
| 文件命名 | 小写 + 下划线 (snake_case) |
| 命名空间 | 按模块分层 (`app::`, `model::`, `view::`, `reactive::`) |

### 4.7 依赖管理

**桌面端依赖** (通过 vcpkg 或系统包管理器):

| 依赖 | 版本 | 用途 |
|------|------|------|
| LVGL | v9.5.0 | GUI 框架 |
| SDL2 | 2.32.x | 桌面显示和输入 |
| FreeType | 2.13.x | TTF 字体渲染 |
| libpng | 1.6.x | PNG 图片解码 |
| libjpeg-turbo | 3.1.x | JPEG 图片解码 |
| fmt | 10.1.1 | 日志格式化 |
| zlib | 1.3.x | 压缩支持 |

### 4.8 适用场景

CardputerZero 的 App 开发是一个**典型的嵌入式 Linux GUI 开发场景**，适合开发：

- 运维工具
- 物联网控制台
- 便携式测试设备
- 边缘计算终端
- 移动开发环境

---

## 9. 硬件规格

### 9.1 核心硬件

| 组件 | 规格 |
|------|------|
| **计算模块** | Raspberry Pi Compute Module 0 (CM0) |
| **CPU** | BCM2837, 四核 Cortex-A53 @ 1GHz, ARMv8-A (aarch64) |
| **内存** | 512MB LPDDR2 |
| **存储** | microSD (标准版 32GB, Lite 版不含) |

### 9.2 显示与视频输出

| 接口 | 规格 |
|------|------|
| **内置屏幕** | 1.9" LCD @ ST7789v3, 320x170, SPI 接口 |
| **视频输出** | 1x 高清数字音视频输出接口，支持 1080P 30fps |
| **视频编解码** | H.264/MPEG-4 1080P 30fps 解码, H.264 1080P 30fps 编码 |

### 9.3 连接与扩展

| 功能 | 规格 |
|------|------|
| **Wi-Fi** | 2.4GHz 802.11 b/g/n |
| **以太网** | 10/100M (SR9900A USB 转以太网) |
| **USB** | 1x USB-A 2.0, 2x USB Type-C 2.0 (支持 Host/Slave 切换, OTG) |
| **扩展接口** | EXT 2.54-14P (SPI/UART/I2C/USB/GPIO), HY2.0-4P (I2C/UART) |

### 9.4 音视频

| 功能 | 规格 |
|------|------|
| **音频编解码** | ES8389 |
| **麦克风** | 1x MEMS |
| **扬声器** | 1W @ 8Ω (AW8737A 功放) |
| **音频接口** | 3.5mm TRRS (支持 CTIA/OMTP 切换) |
| **摄像头** | IMX219 8MP CSI 4-Lane (3280x2464) |

### 9.5 传感器与其他

| 功能 | 规格 |
|------|------|
| **IMU** | BMI270 + BMM150 磁力计 |
| **RTC** | RX8130CE |
| **红外** | 发射 +接收 (GPIO 12/13) |
| **键盘** | 46 键矩阵键盘 (TCA8418RTWR 控制器) |
| **电池** | DC 3.7V 1750mAh (BQ27220YZFR 计量) |

### 9.6 物理规格

| 项目 | 数值 |
|------|------|
| **尺寸** | 84.0 x 54.0 x 23.1mm |
| **重量** | 95g |

### 9.7 管脚映射

#### Display (屏幕)

| CM0 | ST7789v3 |
|-----|----------|
| G10 | MOSI |
| G11 | SCLK |
| G25 | DC |
| G8 | CS |
| G5 | TE |

#### Audio (音频)

| CM0 | ES8389 |
|-----|--------|
| G20_I2S_DIN | DOUT |
| G19_I2S_LRCK | LRCK |
| G18_I2S_BLCK | BCLK |
| G21_I2S_DOUT | MCLK/DIN |
| G2_I2C1_SDA | SDA |
| G3_I2C1_SCL | SCL |

#### USB 2.0

- **Host 模式**: CM0 USB 连接至内部 USB Hub (GL852G-OHY60)，拓展出 4 路 USB
- **Slave 模式**: CM0 USB 直接连接至右侧 USB Type-C 接口

#### HMI (人机交互)

| 设备 | 控制器 | 接口 |
|------|--------|------|
| 键盘 | TCA8418RTWR (0x34) | I2C1 |
| IMU | BMI270 (0x68) | I2C1 |
| 磁力计 | BMM150 (0x10) | I2C1 |
| RTC | RX8130CE (0x32) | I2C1 |

#### IR (红外)

| CM0 | 功能 |
|-----|------|
| G12 | IR_TX |
| G13 | IR_RX |

#### HY2.0-4P 接口

| 颜色 | UART 模式 | I2C 模式 |
|------|-----------|----------|
| Black | GND | GND |
| Red | 5V | 5V |
| Yellow | G14_UART_TXD | G2_I2C1_SDA |
| White | G15_UART_RXD | G3_I2C1_SCL |

通过 CM0 的 G4_I2C/UART_SW 控制电子开关切换功能，默认为 UART。

#### EXT 2.54-14P 扩展总线

| 功能 | 引脚 | 左 | 右 | 引脚 | 功能 |
|------|------|----|----|------|------|
| USB4_D_P / G26 | HAT_P0 | 1 | 2 | 5VIN |
| USB4_D_N / G23 | HAT_P1 | 3 | 4 | GND |
| G22 | - | 5 | 6 | 5VOUT |
| SPI0_CLK / G11 | - | 7 | 8 | G2 / I2C1_SDA |
| SPI0_MOSI / G10 | - | 9 | 10 | G3 / I2C1_SCL |
| SPI0_MISO / G9 | - | 11 | 12 | G15 / UART_RXD |
| SPI0_CS1 / G7 | - | 13 | 14 | G14 / UART_TXD |

通过 M5IOE1 的 PYG1_HAT_SW 控制 HAT_P0/P1 引脚切换 USB/GPIO 功能，默认为 GPIO。

---

## 10. 硬件抽象层与驱动调用

### 10.1 架构分层

```
┌─────────────────────────────────────────────────────────────┐
│                    应用层 (Template App)                      │
│              src/app, src/view, src/viewmodel                │
├─────────────────────────────────────────────────────────────┤
│                  硬件抽象层 (需要补充)                         │
│              src/platform/*.cpp (待实现)                      │
│  ┌──────────┬──────────┬──────────┬──────────┬──────────┐  │
│  │ camera   │ audio    │ imu      │ gpio     │ i2c/spi  │  │
│  │ 摄像头    │ 音频     │ 传感器    │ IO控制   │ 总线通信  │  │
│  └──────────┴──────────┴──────────┴──────────┴──────────┘  │
├─────────────────────────────────────────────────────────────┤
│                  Linux 内核驱动层 (已有)                       │
│  ┌──────────┬──────────┬──────────┬──────────┬──────────┐  │
│  │ libcamera│ ALSA     │ IIO      │ libgpiod │ ioctl    │  │
│  │ V4L2     │ miniaudio│ sysfs    │          │          │  │
│  └──────────┴──────────┴──────────┴──────────┴──────────┘  │
├─────────────────────────────────────────────────────────────┤
│                  硬件设备层 (BCM2837 + 外设)                   │
│        IMX219摄像头, ES8389音频, BMI270 IMU, GPIO等           │
└─────────────────────────────────────────────────────────────┘
```

### 10.2 驱动现状

CardputerZero 基于 Raspberry Pi CM0 (BCM2837)，运行标准 Linux 系统，**所有硬件驱动已由 Linux 内核提供**：

| 硬件 | Linux 驱动/接口 | 设备节点 |
|------|----------------|----------|
| **摄像头** | libcamera / V4L2 | `/dev/video*` |
| **音频** | ALSA / miniaudio | `/dev/snd/*` |
| **IMU** | IIO sysfs | `/sys/bus/iio/devices/*` |
| **GPIO** | libgpiod | `/dev/gpiochip*` |
| **I2C** | Linux ioctl | `/dev/i2c-*` |
| **SPI** | Linux ioctl | `/dev/spidev*` |
| **UART** | libserialport | `/dev/ttyS*` |
| **红外** | LIRC | `/dev/lirc*` |
| **WiFi** | NetworkManager | D-Bus API |
| **蓝牙** | BlueZ | D-Bus API |
| **显示** | fbdev / DRM | `/dev/fb0`, `/dev/dri/card0` |

### 10.3 Template 已实现的硬件调用

当前 Template 只实现了**基础硬件调用**：

#### 1. 设备状态读取 (`src/platform/device_status.*`)

```cpp
// 读取电池、WiFi、以太网状态
namespace platform {
    struct DeviceStatus {
        bool wifi_present;
        bool wifi_connected;
        int32_t wifi_strength_percent;
        bool ethernet_present;
        bool ethernet_connected;
        bool battery_present;
        bool battery_charging;
        int32_t battery_percent;
    };
    
    DeviceStatus read_device_status();
}
```

**实现方式**: 读取 Linux sysfs
- 电池: `/sys/class/power_supply/`
- 网络: `/sys/class/net/`
- WiFi信号: `/proc/net/wireless`

#### 2. 键盘输入 (`src/platform/linux_input.*`)

```cpp
namespace platform {
    // 初始化键盘输入
    void init_key_input(lv_display_t* display);
    
    // 全局键盘监听器
    using GlobalKeyListener = bool (*)(uint32_t key, const char* key_name, 
                                       bool long_pressed, void* user_data);
    void set_global_key_listener(GlobalKeyListener listener, void* user_data);
    
    // 特殊键定义
    constexpr uint32_t kKeyPrintScreen = 0x200000U | 18U;
    constexpr uint32_t kKeyHelp = 0x200000U | 19U;
}
```

**实现方式**: Linux evdev (`/dev/input/event*`)

#### 3. 显示输出 (在 `src/app/app.cpp` 中)

```cpp
// Framebuffer 方式
auto* display = lv_linux_fbdev_create();
lv_linux_fbdev_set_file(display, "/dev/fb0");

// 或 DRM/KMS 方式
auto* display = lv_linux_drm_create();
lv_linux_drm_set_file(display, "/dev/dri/card0", connector_id);
```

#### 4. 截图服务 (`src/platform/screenshot_service.*`)

```cpp
namespace platform::screenshot {
    struct ScreenshotResult {
        bool success;
        std::string path;
        std::string error;
    };
    
    ScreenshotResult capture_active_screen();
}
```

### 10.4 待实现的硬件调用封装

以下硬件需要开发者在 `src/platform/` 下**自行实现 C++ 封装**：

#### 摄像头 (libcamera)

```cpp
// 建议文件: src/platform/camera.cpp
namespace platform::camera {
    struct CameraInfo {
        std::string name;
        int width{320};
        int height{240};
    };
    
    bool find_mipi_csi_camera(CameraInfo& camera, std::string& error);
    
    class PreviewSession {
    public:
        bool start(const CameraInfo& camera, std::string& error);
        bool copy_frame_rgb565(std::vector<uint16_t>& frame, int& width, int& height);
        bool running() const;
        void stop();
    };
}
```

**后端**: libcamera  
**设备**: IMX219 8MP CSI 4-Lane  
**用途**: 摄像头预览、拍照

---

#### 音频 (miniaudio)

```cpp
// 建议文件: src/platform/audio.cpp
namespace platform::audio {
    struct AudioDevice {
        std::string backend_name;
        std::string display_name;
        std::string playback_device;
        std::string capture_device;
    };
    
    bool find_audio_device(AudioDevice& device, std::string& error);
    bool record_wav(const AudioDevice& device, const std::string& path, int seconds);
    bool play_wav(const AudioDevice& device, const std::string& path);
    void set_volume_level(float level);
}
```

**后端**: miniaudio  
**设备**: ES8389 音频编解码 + MEMS 麦克风 + 1W 扬声器  
**用途**: 录音、播放音效、音量控制

---

#### IMU 传感器 (Linux IIO)

```cpp
// 建议文件: src/platform/imu.cpp
namespace platform::imu {
    struct ImuDevice {
        std::string i2c_path;
        std::string iio_path;
        std::string mag_iio_path;
        bool has_bmi270{false};
        bool has_bmm150{false};
    };
    
    struct NineAxisReading {
        double accel_x, accel_y, accel_z;
        double gyro_x, gyro_y, gyro_z;
        double magn_x, magn_y, magn_z;
    };
    
    bool find_bmi270_device(ImuDevice& device, std::string& error);
    bool read_nine_axis(const ImuDevice& device, NineAxisReading& reading, std::string& error);
}
```

**后端**: Linux IIO sysfs  
**设备**: BMI270 (IMU, 0x68) + BMM150 (磁力计, 0x10)  
**用途**: 姿态检测、运动感应

---

#### WiFi/以太网 (NetworkManager)

```cpp
// 建议文件: src/platform/network.cpp
namespace platform::network {
    struct WirelessScanItem {
        std::string name;
        std::string detail;
        int32_t strength_percent{-1};
        std::string bssid;
    };
    
    struct EthernetInfo {
        std::string interface_name;
        std::string state;
        std::string hw_address;
        std::string ip4_address;
        std::string connection_name;
        bool connected{false};
    };
    
    std::vector<WirelessScanItem> scan_wifi(std::string& error);
    EthernetInfo read_ethernet_info(std::string& error);
}
```

**后端**: NetworkManager (libnm) + GLib/GIO  
**用途**: WiFi扫描、网络连接状态

---

#### 蓝牙 (BlueZ)

```cpp
// 建议文件: src/platform/bluetooth.cpp
namespace platform::bluetooth {
    std::vector<WirelessScanItem> scan_bluetooth(std::string& error);
}
```

**后端**: BlueZ over D-Bus (GIO)  
**用途**: 蓝牙设备扫描

---

#### GPIO (libgpiod)

```cpp
// 建议文件: src/platform/gpio.cpp
namespace platform::gpio {
    struct OutputLineConfig {
        std::string chip_path;
        unsigned int line_offset;
        std::string consumer;
    };
    
    class OutputLine {
    public:
        explicit OutputLine(OutputLineConfig config);
        bool set_value(bool active, std::string& error);
        bool get_value(bool& active, std::string& error);
        void release();
    };
}
```

**后端**: libgpiod (`/dev/gpiochip*`)  
**用途**: 控制外部 GPIO 设备

---

#### I2C/SPI/UART 总线

```cpp
// 建议文件: src/platform/i2c.cpp, spi.cpp, uart.cpp
namespace platform::i2c {
    bool read_i2c_byte_data(int bus, uint8_t address, uint8_t command, uint8_t& value);
    std::vector<uint8_t> read_i2c_block(int bus, uint8_t address, uint8_t command, size_t length);
}

namespace platform::spi {
    struct DeviceConfig {
        std::string path;
        uint32_t speed_hz{1000000};
        uint8_t mode{0};
        uint8_t bits_per_word{8};
    };
    
    class Device {
    public:
        static std::unique_ptr<Device> open(const DeviceConfig&, std::string& error);
        bool transfer(const std::vector<uint8_t>& tx, std::vector<uint8_t>& rx);
    };
}

namespace platform::uart {
    class UartDebugSession {
    public:
        static std::unique_ptr<UartDebugSession> open(const std::string& path, int baud_rate);
        std::string read_available(std::string& error);
        bool write_text(const std::string& text, std::string& error);
    };
}
```

**后端**: Linux ioctl / libserialport  
**用途**: 与外部模块通信

---

#### 红外 (LIRC)

```cpp
// 建议文件: src/platform/ir.cpp
namespace platform::ir {
    struct IrDeviceInfo {
        std::string name;
        std::string path;
    };
    
    IrDeviceInfo read_receiver_info();
    IrDeviceInfo read_sender_info();
    
    struct IrSendResult {
        bool success;
        std::string error;
    };
    
    IrSendResult send_nec_packet(uint16_t address, uint16_t command);
    
    class IrReceiverSession {
    public:
        bool start(uint16_t expected_address, bool filter_address = true);
        void stop();
        struct IrReceiveSnapshot {
            uint16_t address;
            uint16_t command;
            bool valid;
        };
        IrReceiveSnapshot poll();
    };
}
```

**后端**: Linux LIRC  
**GPIO**: G12 (TX), G13 (RX)  
**用途**: 红外遥控

### 10.5 开发路线

#### 当前阶段 (Template v0.2.1)

- ✅ 基础 UI 框架 (MVVM + LVGL)
- ✅ 设备状态读取 (电池/网络)
- ✅ 键盘输入处理
- ✅ 显示输出 (fbdev/DRM)
- ✅ 截图功能

#### 下一步开发建议

1. **优先级高** (常用功能):
   - [ ] 摄像头预览 (`camera.cpp`)
   - [ ] 音频播放/录制 (`audio.cpp`)
   - [ ] WiFi 扫描显示 (`network.cpp`)

2. **优先级中** (扩展功能):
   - [ ] IMU 姿态检测 (`imu.cpp`)
   - [ ] 蓝牙扫描 (`bluetooth.cpp`)
   - [ ] GPIO 控制 (`gpio.cpp`)

3. **优先级低** (专业场景):
   - [ ] I2C/SPI/UART 通信
   - [ ] 红外收发 (`ir.cpp`)

### 10.6 总结

| 层级 | 状态 | 说明 |
|------|------|------|
| **Linux 内核驱动** | ✅ 完整 | BCM2837 标准 Linux 驱动 |
| **设备节点** | ✅ 完整 | `/dev/video*`, `/dev/snd/*`, `/sys/class/...` |
| **C++ 应用层封装** | ⚠️ 部分 | 仅实现基础状态读取和输入处理 |
| **硬件抽象层** | ❌ 缺失 | 需要开发者根据 Skills 文档自行实现 |

**开发模式**: Template 提供架构参考，开发者需要：
1. 参考 `.agents/skills/cardputerzero-peripherals/references/` 中的 API 设计模式
2. 在 `src/platform/` 下创建对应的 `.cpp` 文件
3. 封装 Linux 系统调用为 C++ 类
4. 通过 ViewModel 暴露给 UI 层

---

## 11. 总结

CardputerZero 是一个设计精良的嵌入式 Linux GUI 框架模板，具有以下特点：

1. **架构清晰**: MVVM 分层，响应式数据绑定
2. **跨平台**: 统一的 CMake 构建系统支持桌面和设备
3. **文档完善**: README、Skills、代码注释齐全
4. **易于扩展**: BaseScreen/BaseWidget 基类设计合理
5. **生产就绪**: 包含打包、部署、systemd 服务等完整流程

适合作为 CardputerZero 设备应用开发的基础模板。

---

*文档生成工具: Qoder Agent*  
*分析日期: 2026-11-06*
