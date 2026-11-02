# macOS 安装说明（非官方适配）

本文件和配套改动不是原作者发布的内容，是在原包基础上为 macOS 做的最小适配。原作者只在 Windows 上做过真实验收；macOS 路线**尚未在真实 Mac 上验收**，装好后请按第 5 步实际验证再使用。原有的许可（PolyForm Noncommercial 1.0.0）和 NOTICE 署名照旧适用。

## 改了什么

| 文件 | 改动 | 原因 |
|---|---|---|
| `tools/opencli-launch.cjs` | 启动 OpenCLI 时，除 `USERPROFILE` 外也把 `HOME` 指向 `state/opencli-home`；白名单加入 `HOME`、`USER`、`LOGNAME`、`TMPDIR`、`LANG` | OpenCLI 用 `os.homedir()` 找 `~/.opencli/clis/taobao` 适配器。Windows 上它读 `USERPROFILE`，macOS 上读 `HOME`。不改的话 Mac 会去用户真实目录找，找不到淘宝工具 |
| `tools/taobao.js` | 同样的白名单与 `HOME` 设置；macOS 上自动查找 `/Applications/Google Chrome.app` 和 `~/Applications/Google Chrome.app` | 原代码只认 Windows 的 `chrome.exe` 路径 |
| `install-mac.sh` | 新增，等同 `Install.ps1` | Mac 没有 PowerShell |
| `MANIFEST.sha256` | 更新上述文件的校验值 | 让安装前的完整性核对仍然有效 |

Windows 上行为不变：Windows 的 Node 不用 `HOME` 判断用户目录，Chrome 路径仍按原逻辑查找。

## 安装步骤

1. 准备 **Node.js 22+**（`node -v` 检查）和 **Google Chrome**。
2. Chrome 里安装 OpenCLI 官方扩展（来源与版本见 `SOURCES-AND-VALIDATION.md`，基线 1.0.26）。
3. 在本目录运行：
   ```bash
   sh install-mac.sh
   ```
4. 打开 Chrome 确认扩展已连接，然后：
   ```bash
   node scripts/bind-browser.cjs
   ```
   在这个 Chrome 里**手动登录淘宝**。
5. 把生成的 `mcp-config.generated.json` 里的 `taobao` 一项合并进 Claude 的 MCP 配置，保留已有的其他 MCP：
   - Claude Desktop：`~/Library/Application Support/Claude/claude_desktop_config.json`
   - Claude Code：`claude mcp add taobao -- <node 路径> <本目录>/server.cjs`

   Chrome 不在 `/Applications` 时，在配置中加 `"env": {"TAOBAO_CHROME_PATH": "<Chrome 可执行文件完整路径>"}`。
6. 重启客户端，先调用 `taobao_status`，再做一次只读搜索和商品详情，确认真的拿到数据。加购和联系商家不要为了测试而执行。

## 已知风险

- 仅按代码阅读适配，未在真实 Mac 和淘宝页面上跑通；OpenCLI 扩展、桥接端口 19825 等部分预计跨平台，但没有实测。
- macOS 首次由程序启动 Chrome 时，系统可能弹出权限提示，按需允许。
- 其余限制与 README「验收与限制」相同。
