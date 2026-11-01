# 三、LangChain 核心组件与 RAG 全链路

## 1. LangChain 核心组件

| 组件 | 作用 | 关键注意点 |
|------|------|-----------|
| **Runnable / LCEL** | 统一执行接口，支持 invoke / stream / batch | 组链前先确认相邻组件的输入输出类型 |
| **Chat Model** | 理解并生成文本 | `temperature=0` 更适合 RAG 和分类 |
| **Embeddings** | 文本 → 向量 | 文档和查询必须使用同一模型 |
| **Output Parser** | 结构化输出 | 优先用模型原生结构化输出，其次 Prompt 写死 Schema 并校验 |
| **History** | 多轮会话记忆 | 历史越长 Token 成本越高，需要裁剪或摘要 |

---

## 2. RAG 全链路

### 离线索引线
```
数据源 → Loader → 清洗 → Splitter → Embeddings → 写入向量库
```

### 在线问答线
```
用户问题 → 查询改写 → 向量化 → Top-k 检索 → 重排 → 组装 Prompt → LLM → 答案 + 引用来源
```

---

## 关键工程要点

- **文本切分**：优先使用递归字符切分，保留 `parent_id` 支持父子块回溯。
- **检索与重排**：召回 Top-50~100 → Rerank 精排 → 取 Top-5~10 进入 Prompt。
- **向量库选型**：Chroma 适合快速原型；Milvus 适合生产级、大规模。
