# Rules Panel — Tasmota Extension

规则面板插件，将 Tasmota 原生规则（Rule1/2/3）以可视化方式暴露给用户。

## 功能

- **按钮规则面板**（`/btns`）：面向物理按钮/开关的规则配置，通过按钮 + 动作 + MQTT topic + payload 组装规则。
- **通用规则面板**（`/rules`）：面向所有触发器类型的规则配置，支持按钮/开关、电源、系统事件、时间、MQTT、传感器、自定义 Event 等。

两个面板共用同一套 Tasmota 规则槽（Rule1/2/3），规则存储在设备 flash 中，重启不丢失。

## 安装

### 方式一：通过 Extension Manager（推荐）

1. 在 Tasmota 主页进入 **Configuration（配置）→ Extension Manager**。
2. 在 Online Store 中找到 **Rules Panel**，点击 **Install**（仅安装）或 **Install+Run**（安装并运行）。
3. 安装完成后，插件会自动出现在已安装列表中。

### 方式二：手动安装

1. 将本目录下的文件打包为 `.tapp`（zip，保留目录结构）：

   ```bash
   zip -j -0 RulesPanel.tapp autoexec.be rules_panel.be manifest.json html/console_panel.html html/rules_panel.html
   ```

2. 将生成的 `RulesPanel.tapp` 上传到设备的 `/.extensions/` 目录。
3. 在 Extension Manager 中点击 **Run**（或重启设备自动加载）。

## 配置

### 通过配置页面

1. 进入 **Configuration（配置）**，在扩展列表中找到 **Rules Panel**，点击其配置按钮进入配置页面。
2. 配置项：

   | 配置项 | 默认值 | 说明 |
   |--------|--------|------|
   | enabled | true | 是否启用插件。禁用后主菜单入口按钮不再显示。 |
   | show_btns_panel | true | 是否显示按钮规则面板（`/btns`）。 |
   | show_rules_panel | true | 是否显示通用规则面板（`/rules`）。 |
   | max_rules_per_slot | 4 | 每个规则槽最大规则数，影响规则分槽策略。 |

3. 点击 **保存设置** 生效。

### 重置插件

在配置页面点击 **重置插件（清空所有规则）**，会清空 Rule1/2/3 三个规则槽。此操作不可恢复。

## 使用

### 主菜单入口

启用后，Tasmota 主页的 **Main Menu** 中会出现两个按钮：
- **按钮规则面板** — 打开 `/btns` 页面。
- **通用规则面板** — 打开 `/rules` 页面。

### 按钮规则面板（/btns）

- **添加规则**：点击「＋ 添加规则」，填写物理按钮/开关（Button1、Switch1…）、触发动作（SINGLE/DOUBLE/LONG）、MQTT topic 和 payload。
- **读取规则**：点击「读取规则」，从设备读取已有规则。
- **保存并生效**：点击「保存并生效」，将规则写入 Rule1/2/3 并启用。

### 通用规则面板（/rules）

- 支持所有触发器类型：按钮/开关、电源、系统事件、时间、MQTT、传感器、自定义 Event 等。
- 提供模板下拉框快捷填充触发器和命令。
- 命令支持所有 Tasmota 命令（publish / Power / Backlog / Var1 / RuleTimer 等），可用 `%value%` 引用触发值。

## 卸载

1. 在 Extension Manager 中找到 **Rules Panel**，点击 **Uninstall**。
2. 或者在配置页面将 `enabled` 设为 OFF，插件会被禁用但不删除。

## 注意事项

- 两个面板共用同一套规则槽（Rule1/2/3），请勿在两个页面分别保存，否则会互相覆盖。
- 规则面板需要 ESP32 固件（tasmota32），因为 Berry 脚本仅在 ESP32 上支持。

## 依赖

- WS-257（规则面板开发）— 已完成，两个 Bug 已修复。