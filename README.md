# 万象全书 (Codex Astralis)

一个多功能的《饥荒：联机版》指南模组，包含静态攻略和团队协作规划功能。

![万象全书](https://steamuserimages-a.akamaihd.net/ugc/1617175662178880460/D0D9F3C8AEFB0B7C0F3AE9E4F6F8D9E7F5E4C3B2/?imw=268&imh=268&ima=fit&impolicy=Letterbox)

## 功能特点

### 静态攻略书
- 包含游戏基础知识和生存技巧
- 支持目录导航和翻页
- 记忆上次阅读位置

### 团队计划器
- 共享的待办事项列表
- 实时同步到所有玩家
- 支持添加、完成和删除任务

## 技术架构

本模组基于 Lua 语言开发，主要包含以下组件：

1. **模组核心**
   - `modinfo.lua`: 模组的基本信息
   - `modmain.lua`: 模组的主入口文件

2. **物品预制体**
   - `scripts/prefabs/atlas_book.lua`: 书本预制体定义

3. **UI组件**
   - `scripts/widgets/atlasbook_ui.lua`: 书本UI界面实现

4. **数据组件**
   - `scripts/components/atlas_todolist.lua`: 任务列表组件，处理数据同步

## 安装方法

### 通过 Steam 创意工坊
1. 访问模组的 Steam 创意工坊页面
2. 点击"订阅"按钮
3. 等待 Steam 客户端下载模组
4. 在游戏中启用模组

### 手动安装
1. 下载本仓库的代码
2. 将文件夹重命名为 `CanKaoMod`
3. 将文件夹放入游戏的 mods 目录：
   - Windows: `C:\Users\[用户名]\Documents\Klei\DoNotStarveTogether\mods\`
   - Mac: `~/Library/Application Support/Klei/DoNotStarveTogether/mods/`
   - Linux: `~/.klei/DoNotStarveTogether/mods/`
4. 在游戏中启用模组

## 使用方法

1. 游戏开始时自动获得万象全书
2. 右键点击书本打开界面
3. 使用标签页切换不同功能：
   - "静态攻略"：浏览游戏指南
   - "团队计划"：查看和管理共享任务列表

## 开发计划

详见 [imp.md](imp.md) 文件和 [content_improvement.md](content_improvement.md) 文件。

### 当前进度
- [x] 阶段1：静态攻略书（已完成）
- [x] 阶段2：团队计划器（已完成）
- [ ] 阶段3：AI助手（计划中）

## 贡献指南

欢迎提交 Pull Request 或 Issue 来帮助改进这个模组！

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开一个 Pull Request

## 许可证

[MIT License](LICENSE)

## 致谢

- 感谢 Klei Entertainment 创造了精彩的《饥荒：联机版》游戏
- 感谢所有为本模组提供反馈和建议的玩家 