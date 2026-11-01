# 四、Agent 智能体核心机制

## 1. Agent 的本质

```
LLM（大脑）+ Tools（手脚）= Agent（完整的人）
```

---

## 2. ReAct 工作模型

ReAct = Reasoning + Action，核心是一个循环闭环：

```
Input
  ↓
Reasoning（分析需要调用什么工具）
  ↓
Action（调用工具）
  ↓
Observation（观察结果）
  ↓
判断是否足够？
  ├─ 是 → Output
  └─ 否 → 继续循环
```

**Tool Calling 关键认知**：
> 模型在云端，碰不到本地代码。模型只负责返回"该调用哪个工具、传什么参数"，真正执行的是宿主程序。

---

## 3. Middleware 控制面

LangChain 的 Middleware 通过节点式钩子（如 `before_agent`、`after_model`）在 Agent 执行流程中注入自定义逻辑，实现：

- 工具调用审计
- 参数改写
- PII 脱敏
- 人工介入审批

> Middleware 是生产级 Agent 的分界线：没有拦截与审计，Agent 的工具调用就是黑盒。
