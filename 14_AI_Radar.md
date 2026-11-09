# 14 · AI 情报雷达（滚动更新）

> **用途**：只留"能落到你手上的"AI 动态。每条必须回答三个问题——**是什么 / 与你什么关系 / 今天能做什么**。
> **筛选口径**：① 影响你现有技术选型或成本；② 能直接试用的工具或模型；③ 影响教育 B 端合规与竞争格局；④ 推翻你已有结论的新证据。**不满足任何一条的，不收录。**
> **更新节奏**：每周一轮（周一），重大事件随时插播。每轮在"归档"区追加一节，最新在最上面。
> **核实标记**：✅ 已读一手页面 ｜ 🟡 仅有标题/二手转述 ｜ ⚠️ 存在争议或反证

---

## 目录

- [第 1 期 · 2026-11-09（W45）](#第-1-期--2026-11-09w45)
- [情报源与方法](#情报源与方法)
- [订阅与节流策略](#订阅与节流策略)
- [归档](#归档)

---

## 第 1 期 · 2026-11-09（W45）

### A. 安全：本周最高优先级（直接影响常驻 Agent 的机器与仓库）

| # | 事件 | 出处 | 核实 |
|:-:|------|------|:----:|
| A1 | **Claude Code "Don't Ask Again" 把密码写进 1,122 个公开 GitHub 文件**；另有 issue 指出 Claude Code 会向被访问网站发送你的邮箱地址 | [apiiro 分析](https://apiiro.com/blog/coding-agents-leaking-secrets-github-dont-ask-again)、[anthropics/claude-code#107757](https://github.com/anthropics/claude-code/issues/107757) | 🟡 |
| A2 | **Postman 静默安装 AI 插件并尝试上报全部 API 数据**（社区 issue 1.5k+ 热度） | [postmanlabs/postman-app-support#14370](https://github.com/postmanlabs/postman-app-support/issues/14370) | 🟡 |
| A3 | **OpenSSH 10.6p2 密码认证绕过**（Alpine 已发安全公告）；**Ubuntu 关键内核 0day RCE（CVE-2026-98432）近三周未修** | [Alpine 公告](https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/)、[freenode 报道](https://freenode.net/article/ubuntu-lts-kernels-still-unfixed-for-critical-cve-2026-98432) | 🟡 |

**与你什么关系**：你正在跑"常驻智能体 + 定时任务 + 本地/轻量服务器"。A1 是**harness 层的泄密路径**（不是模型问题），A2 是**工具链默认行为的信任问题**，A3 是**执行环境本身的洞**。三者叠加 = 一台被 Agent 长期占用、开着密码登录、装着自动上报插件的机器。

**今天能做什么（30 分钟）**
1. 覆盖全仓历史，查"被 Agent 顺手写进去的密钥"：
   ```powershell
   # 在仓库根目录执行（Windows PowerShell）
   git log -p --all | Select-String -Pattern "sk-[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{30,}|AKIA[0-9A-Z]{16}" |
     Select-Object -First 50
   ```
2. 让 SSH 只认密钥：`PasswordAuthentication no`、`PermitRootLogin no`，改完 `sshd -t` 再重启。
3. 常驻任务用的密钥**一律走环境变量/凭据中心**，禁止落在仓库、日志、`args` 回显里；工具输出落盘前先过一遍脱敏。
4. 检查本机 OpenSSH 版本（`ssh -V`），低于修复版本就升级或先关密码登录。

> 这四条正好对应 [10.1 文档](./10_Stanford_AI_Agents_Update_2026.md) 检查清单 Q5 的"副作用与权限边界"，建议一起写进上线前 checklist。

---

### B. DeepSeek API：模型改名 + 内置搜索/抓取 API（影响你的配置与成本）

| 变化 | 内容 | 核实 |
|------|------|:----:|
| 模型名 | 现在只有 `deepseek-flash`（由 **DeepSeek-V4.1-Flash-1017** 提供）与 `deepseek-v4-pro`；旧名 `deepseek-v4-flash` 已退役，仍会被受理但按 Flash 计费 | ✅ |
| 新能力 | 官方新增 **Search / Fetch API**（自有搜索引擎，支持网页搜索与抓取） | ✅ |
| 接入面 | 官方已列出 Claude Code / Codex / OpenCode / OpenClaw / Hermes / Qoder / WorkBuddy 等接入文档 | ✅ |

**与你什么关系**：① 你的 AGENTS 配置里写着 `deepseek-v4.1-flash`，直连官方 API 时应改用 `deepseek-flash`（走 opencode-go 则是另一套 ID，别混）；② 你现在**没有 `DEEPSEEK_API_KEY`**，所以本会话的联网检索是靠新闻源 API 拼出来的——官方 Search/Fetch API 一旦配好 Key，情报收集可以自动化和降噪；③ 官方文档把"7 个 Agent 客户端接入"列全了，意味着你换客户端时几乎不用改代码。

**今天能做什么**
- 若已申请 Key：在 [api-docs](https://api-docs.deepseek.com/guides/search) 拿 Search/Fetch 用法，把"每周情报"做成脚本（检索词固定 + 结果落盘），我来做摘要。
- 若没有 Key：保持现状（HN Algolia + GitHub API 直连即可覆盖 80% 信号，见"情报源与方法"）。

---

### C. Kimi K3.1 Pro 放出权重（🟡 待你侧验证）

- 现象：HN 11-04 出现 "Kimi K3.1 Pro model weights are out"，指向 HF 仓库 `moonshotai/Kimi-K3.1-Pro`（640+ 热度）。
- **与你什么关系**：你现在代码攻坚走的是 `kimi-k2.7-code`（云 API，$0.95/1M 输入）。若 K3.1 Pro 权重可本地/私有部署，**校本数据不出校**这条硬约束就多了一条落地路径（你现有产品定位正是"数据不出校园"）。
- **动作建议**：先别急着换。按"必要性四问"评估：若等的是"更强的代码能力"，权重发布不解决你的算力问题；若等的是"数据合规"，才值得测。测试顺序：量化版能否在你现有机器上跑出 ≥30 tok/s → 是否值得替换一次代码任务。

> ⚠️ 我这边 HF 域名不可达，未核实许可证与量化版本。你确认前，不要把它写进方案。

---

### D. 反炒作：Astra"读写权重改进 Qwen"被系统性拆解（校准"自我进化"预期）

- 原始说法：GPT-6 Astra 仅看原始权重就能识别模型用途，并把 Qwen3.5-0.8B 的 MATH-500 从 7.9% 提到 48.1%（改 0.016% 权重）。
- 反证（✅ 已读全文，[honnibal.dev，2026-11-03](https://honnibal.dev/blog/astra-read-write-misleading)）：该文把 8 组实验逐一列了表——**"纯看原始权重"只发生在 17K–172K 参数的小网络**（实验 1、2、4）；所有涉及真实语言模型的实验（含 Qwen 那个标题结论）都**写了 Python、跑了模型（最多 50 个 batch 练习）**。也就是说，成绩来自"会写分析/修改权重的程序 + 能跑模型验证"，而不是"看一眼权重就懂"。

**与你什么关系**：这条恰好验证了 [10.1 文档](./10_Stanford_AI_Agents_Update_2026.md) 的核心论点——**能力上限由 Harness（工具 + 执行 + 验证）决定，不由"模型神秘直觉"决定**。你写方案时若引用"权重空间编程"，一定带上这个限定，否则对甲方是过度承诺。

**今天能做什么**：把 10.1 文档 §2.3 的"验证器分级"当成对外话术模板——凡宣称"AI 自己优化了自己"，先问：它有没有跑起来验证？验证信号是不是可执行？

---

### E. 可直接试的工具（本周 4 个，按你的场景排序）

| 工具 | 一句话 | 为什么对你有用 | 试的成本 |
|------|--------|----------------|----------|
| [anything2explainer](https://github.com/Vincentwei1021/anything2explainer) | 给一个主题 → 输出带旁白/字幕/章节的讲解视频（Remotion 逐帧用代码画，中英双语） | 直接命中你的"物理教研分享包 / 教师培训视频"，比手工剪映快一个量级 | 中（要 Node + 渲染时间） |
| [google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model) | Google 开源的"用 Agent 做设计与评审"插件（agent-skills / spec-driven / multi-agent） | 官方出品的 spec-driven 范式，可对照你的 02_prompts 与教研 SOP 做升级 | 低（读 README 即可） |
| [agent-autoloop](https://github.com/KKKKhazix/agent-autoloop) | 事件驱动的 Agent 自动循环（claude-code / codex / MCP，Node/TS，自托管） | 你 [10.1 §4.3](./10_Stanford_AI_Agents_Update_2026.md) 想做的"关闭界面后继续干活"，这是现成参考实现 | 中 |
| [coucou](https://github.com/Louis-CFM/coucou) | 在 Mac 刘海/手机锁屏上盯 Agent，并**一键批准** | HITL（人机升级）的交互参考：把"需要人确认"做成低成本动作 | 低（仅 macOS/iOS） |

> 注意：这几个都是近两个月的高星新项目，**没有生产验证**。按 10.1 检查清单 Q4 的口径——先当"参考实现"读，不当"依赖"引入。

---

### F. 成本侧：小模型裁判 + 大模型兜底，拿到 4 折成本

- 事件：HN 11-06 "A Jev that can ask Opus for help gives Opus accuracy at 4x lower cost"（[hightouch 案例](https://hightouch.com/blog/llm-judges-identity-resolution)）。
- **与你什么关系**：这就是你 10.1 文档 §2.2 的"预算调度器"在真实业务里的形态——**便宜模型做判定（judge），只在不确定时升级到强模型**。你在批改场景可以直接套：普通题用 Flash 判定，低置信度/争议题才升级。
- **动作**：给你的批改流水线加一个 `confidence` 门限（如 <0.75 升级），先按 10% 升级率试跑一周，记录"升级带来的准确率增量 / 成本增量"。

---

### G. 教育侧信号（⚠️ 待核实）

- 标题：**"Google will turn off search for schools that reject AI"**（NYT，2026-11-03；相关官方博客 "AI learning era updates 2026"）。
- **与你什么关系**：如果属实，说明"学校是否接受 AI 工具"正在被平台方当成商业杠杆，这会改变你进校谈判的话术（从"我们帮您用上 AI"变成"不接入会失去什么"）。
- **但**：我这边 NYT 付费墙 + Google 博客抓取失败，**未读原文**。在你对外使用这个论点前，务必自己打开核实；否则宁可只讲"平台侧 AI 教育投入在加速"这种安全表述。

---

## 情报源与方法

**为什么用这些源**：`web_search` 在本机不可用（缺 `DEEPSEEK_API_KEY`）。以下源直连可达、免费、稳定，覆盖了工程圈 80% 的有效信号。

| 源 | 用途 | 调用方式 |
|----|------|----------|
| HN Algolia API | 工程圈热议（按热度/时间过滤） | `https://hn.algolia.com/api/v1/search?tags=story&numericFilters=points>70,created_at_i>...` |
| GitHub Search API | 新项目/高星工具侦察 | `https://api.github.com/search/repositories?q=topic:ai-agents+created:>YYYY-MM-DD&sort=stars` |
| 官方文档/Changelog | 模型名、价格、能力变更 | 如 `api-docs.deepseek.com`、各家 news/changelog 页 |
| 一手仓库 issue | 真实故障与泄密事件 | `github.com/<org>/<repo>/issues` |
| 反证文章 | 校准炒作 | 惯例：热点出现 48 小时内会有人写拆解，优先读拆解 |

**筛法（三步，10 分钟内完成）**
1. **去重**：同一事件只留热度最高的一条 + 一条反证。
2. **过四问**：影响选型/成本？能试用？影响合规？推翻结论？——全否，丢弃。
3. **定级**：✅ 已读一手 → 可写进方案；🟡 仅标题 → 只能当线索；⚠️ 有反证 → 写进"别信这个"。

---

## 订阅与节流策略

| 策略 | 做法 |
|------|------|
| **周更不日更** | 每天都有噪音，每周一轮足够；重大安全事件随时插播 |
| **只推"可执行"** | 每条必须带"今天能做什么"，否则不进简报 |
| **一页上限** | 每期正文不超过 7 个条目；多的进"归档一句话列表" |
| **核实分级** | 未经一手的，一律标 🟡，禁止拿去对客户讲 |
| **留反证位** | 每期至少保留 1 条"反炒作/反证"，防止自己被热点带偏 |

---

## 归档

### 2026-W45（第 1 期）
- 安全：Claude Code 密钥泄露（1,122 个公开文件）、Postman 静默上报、OpenSSH 10.6p2 绕过 + Ubuntu CVE-2026-98432 未修。
- 模型：DeepSeek 模型名收敛为 `deepseek-flash` / `deepseek-v4-pro`，新增 Search/Fetch API；Kimi K3.1 Pro 权重发布（🟡）。
- 认知：Astra 权重空间编程被拆解——真实能力来自"写程序 + 跑模型"，不是"看权重"。✅
- 工具：anything2explainer、elephant-goldfish-model、agent-autoloop、coucou。
- 成本：小模型 judge + 大模型兜底，4 倍成本下降的实践案例。
- 教育：Google 对拒绝 AI 的学校关闭搜索（⚠️ 待核实）。

---

*维护：本文件由 AI 情报流程生成，人工只做"取舍与核实"。下期建议时间：2026-11-16（W46）。*
