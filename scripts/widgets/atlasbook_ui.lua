local Screen = require "widgets/screen"
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local TEMPLATES = require "widgets/redux/templates"
local ScrollableList = require "widgets/scrollablelist"

-- 定义攻略内容数据，使用层级结构
local GUIDE_DATA = {
    -- 第一大节：新手指南
    beginner = {
        title = "新手指南",
        is_section = true,
        children = {
            beginner_day1to3 = {
                title = "开局前三天",
                text = "第一天：收集树枝、草、燧石，制作基本工具。\n第二天：建立营地，制作科学机器。\n第三天：准备食物和火把，迎接第一个夜晚。",
            },
            beginner_base = {
                title = "基地建设",
                text = "选择基地位置时要考虑资源、生物群落和季节因素。\n基础设施：营火、科学机器、烹饪锅、冰箱、晾肉架。\n围墙与陷阱可以提供安全保障。",
            },
        },
    },
    
    -- 第二大节：生存技巧
    survival = {
        title = "生存技巧",
        is_section = true,
        children = {
            survival_seasons = {
                title = "四季生存指南",
                text = "春季：雨水较多，注意防潮。\n夏季：高温引发自燃，准备降温装备。\n秋季：收获的季节，多收集资源。\n冬季：低温致命，准备保暖装备和充足食物。",
            },
            survival_food = {
                title = "食物与烹饪",
                text = "烹饪锅可以制作更有营养的食物。\n肉类食物：怪物肉、兔肉、鸟肉等。\n蔬菜：胡萝卜、浆果、蘑菇等。\n最佳食谱：肉丸、火鸡大餐、培根煎蛋。",
            },
        },
    },
    
    -- 第三大节：战斗指南
    combat = {
        title = "战斗指南",
        is_section = true,
        children = {
            combat_basics = {
                title = "战斗技巧",
                text = "学会走位和攻击节奏。\n制作武器：长矛、暗夜剑、触手棒等。\n制作护甲：草甲、木甲、大理石甲等。\n学会风筝怪物，避免被围攻。",
            },
            combat_bosses = {
                title = "常见BOSS攻略",
                text = "树精守卫：用火攻击最有效。\n克劳斯：冬季出现，掉落红宝石。\n蜂后：引出巢穴后集中攻击。\n远古守护者：地下世界的最终BOSS。",
            },
        },
    },
}

-- 扁平化章节列表，用于翻页
local FLAT_CHAPTERS = {}
local function FlattenChapters()
    FLAT_CHAPTERS = {}
    for section_id, section_data in pairs(GUIDE_DATA) do
        if section_data.is_section and section_data.children then
            for chapter_id, chapter_data in pairs(section_data.children) do
                if not chapter_data.is_section then
                    table.insert(FLAT_CHAPTERS, {id = chapter_id, section_id = section_id})
                end
            end
        end
    end
end
FlattenChapters()

local AtlasBookUI = Class(Screen, function(self, owner)
    Screen._ctor(self, "AtlasBookUI")
    self.owner = owner
    self.expanded_sections = {} -- 记录哪些大节是展开的
    self.current_view = "guide" -- 当前显示的视图
    self.tasks = {} -- 团队计划的任务列表

    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0, 0, 0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
    self.panel = self.root:AddChild(TEMPLATES.RectangleWindow(900, 600, "万象全书"))
    self.panel:SetBackgroundTint(unpack(UICOLOURS.BROWN_DARK))
    
    -- 手动添加关闭按钮
    self.close_button = self.panel:AddChild(TEMPLATES.StandardButton(function() self:Close() end, "Close", {100, 50}))
    self.close_button:SetPosition(900/2 - 50, 600/2 - 25, 0)

    -- 标签页
    self.tabs_root = self.panel:AddChild(Widget("TABS_ROOT"))
    self.tabs_root:SetPosition(0, 260, 0)

    self.guide_tab_button = self.tabs_root:AddChild(TEMPLATES.StandardButton(function() self:SetView("guide") end, "静态攻略", {150, 50}))
    self.guide_tab_button:SetPosition(-80, 0, 0)

    self.planner_tab_button = self.tabs_root:AddChild(TEMPLATES.StandardButton(function() self:SetView("planner") end, "团队计划", {150, 50}))
    self.planner_tab_button:SetPosition(80, 0, 0)

    -- 视图容器
    self.guide_view = self.panel:AddChild(Widget("GUIDE_VIEW"))
    self.planner_view = self.panel:AddChild(Widget("PLANNER_VIEW"))

    -- 创建目录区域和滚动条
    self.menu_root = self.guide_view:AddChild(Widget("MENU_ROOT"))
    self.menu_root:SetPosition(-350, 0, 0)
    
    -- 创建目录滚动区域
    self.menu_scroll_root = self.menu_root:AddChild(Widget("MENU_SCROLL_ROOT"))
    self.menu_scroll_root:SetPosition(0, 0, 0)
    
    -- 内容区域
    self.content_root = self.guide_view:AddChild(Widget("CONTENT_ROOT"))
    self.content_root:SetPosition(150, 0, 0)
    
    -- 增大标题字体
    self.content_title = self.content_root:AddChild(Text(DEFAULTFONT, 40))
    self.content_title:SetPosition(0, 150, 0)
    self.content_title:SetColour(1, 0.9, 0.5, 1) -- 使用金黄色，更加醒目
    
    -- 增大正文字体
    self.content_text = self.content_root:AddChild(Text(DEFAULTFONT, 30))
    self.content_text:SetPosition(0, -20, 0)
    self.content_text:SetColour(1, 0.95, 0.8, 1) -- 使用浅黄色，更易阅读
    self.content_text:SetVAlign(ANCHOR_TOP)
    self.content_text:SetHAlign(ANCHOR_LEFT)
    self.content_text:SetRegionSize(400, 300)

    -- 创建目录按钮
    self:CreateMenuButtons()

    -- 翻页按钮
    self.prev_button = self.guide_view:AddChild(TEMPLATES.StandardButton(function() self:OnPrevPage() end, "<", {50, 50}))
    self.prev_button:SetPosition(-100, -260, 0)

    self.next_button = self.guide_view:AddChild(TEMPLATES.StandardButton(function() self:OnNextPage() end, ">", {50, 50}))
    self.next_button:SetPosition(100, -260, 0)
    
    -- 团队计划视图
    self.planner_view:KillAllChildren()

    -- 添加任务输入区域
    self.task_input_area = self.planner_view:AddChild(Widget("TASK_INPUT_AREA"))
    self.task_input_area:SetPosition(0, -250, 0)
    
    -- 添加文本提示
    local input_label = self.task_input_area:AddChild(Text(DEFAULTFONT, 24))
    input_label:SetPosition(-200, 0, 0)
    input_label:SetString("输入任务:")
    input_label:SetColour(0, 0, 0, 1)
    
    -- 添加任务输入框（使用简单的文本显示模拟输入框）
    self.task_input_text = ""
    self.task_input_display = self.task_input_area:AddChild(Text(DEFAULTFONT, 24))
    self.task_input_display:SetPosition(0, 0, 0)
    self.task_input_display:SetRegionSize(300, 40)
    self.task_input_display:SetHAlign(ANCHOR_LEFT)
    self.task_input_display:SetVAlign(ANCHOR_MIDDLE)
    self.task_input_display:SetString(self.task_input_text)
    self.task_input_display:SetColour(1, 0.95, 0.8, 1) -- 使用浅黄色
    
    -- 输入框背景
    local input_bg = self.task_input_area:AddChild(Image("images/ui.xml", "blank.tex"))
    input_bg:SetSize(300, 40)
    input_bg:SetPosition(0, 0, 0)
    input_bg:SetTint(0.2, 0.2, 0.2, 0.8) -- 深色背景
    input_bg:MoveToBack()
    
    -- 添加"添加任务"按钮
    self.add_task_button = self.task_input_area:AddChild(TEMPLATES.StandardButton(
        function() 
            if self.task_input_text ~= "" then
                print("[万象全书] 尝试添加任务: " .. tostring(self.task_input_text))
                if TheWorld and TheWorld.components and TheWorld.components.atlas_todolist then
                    TheWorld.components.atlas_todolist:AddTask(self.task_input_text)
                    self.task_input_text = ""
                    self.task_input_display:SetString("")
                    self:UpdateTaskList() -- 添加任务后刷新列表
                else
                    print("[万象全书] 错误: TheWorld.components.atlas_todolist 不存在")
                end
            end
        end,
        "添加任务", {120, 40}
    ))
    self.add_task_button:SetPosition(200, 0, 0)
    
    -- 添加键盘输入处理
    self.OnRawKey = function(_, key, down)
        if self.current_view == "planner" and down then
            if key >= KEY_A and key <= KEY_Z then
                -- 字母键
                local char = string.char(key - KEY_A + string.byte('a'))
                self.task_input_text = self.task_input_text .. char
                self.task_input_display:SetString(self.task_input_text)
                return true
            elseif key >= KEY_0 and key <= KEY_9 then
                -- 数字键
                local char = string.char(key - KEY_0 + string.byte('0'))
                self.task_input_text = self.task_input_text .. char
                self.task_input_display:SetString(self.task_input_text)
                return true
            elseif key == KEY_SPACE then
                -- 空格键
                self.task_input_text = self.task_input_text .. " "
                self.task_input_display:SetString(self.task_input_text)
                return true
            elseif key == KEY_BACKSPACE and #self.task_input_text > 0 then
                -- 退格键
                self.task_input_text = string.sub(self.task_input_text, 1, #self.task_input_text - 1)
                self.task_input_display:SetString(self.task_input_text)
                return true
            elseif key == KEY_ENTER or key == KEY_KP_ENTER then
                -- 回车键，提交任务
                if self.task_input_text ~= "" then
                    print("[万象全书] 尝试添加任务: " .. tostring(self.task_input_text))
                    if TheWorld and TheWorld.components and TheWorld.components.atlas_todolist then
                        TheWorld.components.atlas_todolist:AddTask(self.task_input_text)
                        self.task_input_text = ""
                        self.task_input_display:SetString("")
                        self:UpdateTaskList() -- 添加任务后刷新列表
                    else
                        print("[万象全书] 错误: TheWorld.components.atlas_todolist 不存在")
                    end
                end
                return true
            end
        end
        return false
    end

    -- 使用简单的垂直列表替代 ScrollingGrid
    self.tasks_panel = self.planner_view:AddChild(Widget("TASKS_PANEL"))
    self.tasks_panel:SetPosition(0, 50, 0)
    
    -- 任务列表容器
    self.task_list = self.tasks_panel:AddChild(Widget("TASK_LIST"))
    self.task_list:SetPosition(0, 0, 0)
    
    -- 更新任务列表的显示
    self:UpdateTaskList()

    -- 加载上次的页面
    local last_page_id = nil
    
    -- 从玩家数据中获取上次阅读的页面
    if self.owner and self.owner.atlas_book_data then
        last_page_id = self.owner.atlas_book_data.last_page
        print("[万象全书] UI初始化，尝试加载上次阅读的页面: " .. tostring(last_page_id))
    end
    
    local last_section_id = nil
    
    -- 查找章节所属的大节
    if last_page_id then
        for _, chapter in ipairs(FLAT_CHAPTERS) do
            if chapter.id == last_page_id then
                last_section_id = chapter.section_id
                print("[万象全书] 找到章节所属的大节: " .. tostring(last_section_id))
                break
            end
        end
    end
    
    -- 如果找到了大节，展开它
    if last_section_id then
        print("[万象全书] 展开大节: " .. tostring(last_section_id))
        self.expanded_sections[last_section_id] = true
        self:CreateMenuButtons() -- 重建目录以反映展开状态
    end
    
    -- 设置初始章节
    if last_page_id then
        print("[万象全书] 设置上次阅读的章节: " .. tostring(last_page_id))
        self:SetChapter(last_page_id)
    else
        -- 默认显示第一个章节
        local first_chapter
        for _, chapter in ipairs(FLAT_CHAPTERS) do
            first_chapter = chapter.id
            break
        end
        if first_chapter then
            print("[万象全书] 设置默认章节: " .. tostring(first_chapter))
            self:SetChapter(first_chapter)
        end
    end

    -- 设置初始视图
    self:SetView("guide")
    self:UpdateTaskList()
end)

function AtlasBookUI:SetView(view_name)
    self.current_view = view_name
    
    if view_name == "guide" then
        self.guide_view:Show()
        self.planner_view:Hide()
        self.guide_tab_button:SetTextColour(0.8, 0, 0, 1) -- Red
        self.planner_tab_button:SetTextColour(0, 0, 0, 1) -- Black
    elseif view_name == "planner" then
        self.guide_view:Hide()
        self.planner_view:Show()
        self.guide_tab_button:SetTextColour(0, 0, 0, 1) -- Black
        self.planner_tab_button:SetTextColour(0.8, 0, 0, 1) -- Red
        self:UpdateTaskList() -- 切换到规划器时刷新列表
    end
end

function AtlasBookUI:UpdateTaskList()
    -- 清除现有任务项
    if self.task_items then
        for _, item in pairs(self.task_items) do
            if item and item.Kill then
                item:Kill()
            end
        end
    end
    
    self.task_items = {}
    
    -- 如果没有任务列表容器，直接返回
    if not self.task_list then
        print("[万象全书] 错误: 任务列表容器不存在")
        return
    end
    
    -- 获取世界组件中的任务列表
    local tasks = {}
    local success = pcall(function()
        -- 尝试从TheWorld获取组件
        if TheWorld and TheWorld.components and TheWorld.components.atlas_todolist then
            tasks = TheWorld.components.atlas_todolist:GetTasks() or {}
            print("[万象全书] 从TheWorld获取到任务列表，数量: " .. tostring(#tasks))
        else
            print("[万象全书] 警告: TheWorld.components.atlas_todolist 不存在")
        end
    end)
    
    if not success then
        print("[万象全书] 错误: 获取任务列表时发生异常")
        return
    end
    
    -- 创建新的任务项
    local y_offset = 200 -- 从上往下排列
    
    for i, task_data in ipairs(tasks) do
        print("[万象全书] 处理任务 " .. tostring(i) .. ": ID=" .. tostring(task_data.id) .. ", 文本=" .. tostring(task_data.text))
        
        local task_item = nil
        success = pcall(function()
            task_item = self:CreateTaskItem(task_data)
        end)
        
        if success and task_item then
            task_item:SetPosition(0, y_offset, 0)
            self.task_list:AddChild(task_item)
            table.insert(self.task_items, task_item)
            y_offset = y_offset - 60 -- 每个任务项的间距
            print("[万象全书] 成功添加任务项到UI: " .. tostring(task_data.id))
        else
            print("[万象全书] 错误: 创建任务项失败 " .. tostring(task_data and task_data.id or "未知ID"))
        end
    end
end

function AtlasBookUI:CreateTaskItem(task)
    print("[万象全书] 开始创建任务项: " .. tostring(task.id) .. ", " .. tostring(task.text))
    
    if not task or not task.id or not task.text then
        print("[万象全书] 错误: 任务数据不完整 " .. tostring(task and task.id or "无ID"))
        return nil
    end
    
    local item = Widget("task_item_" .. task.id)
    
    -- 状态按钮
    local status_button = nil
    local success = pcall(function()
        status_button = item:AddChild(TEMPLATES.StandardButton(
            function() 
                print("[万象全书] 尝试切换任务状态: " .. tostring(task.id) .. ", " .. tostring(not task.completed))
                if TheWorld and TheWorld.components and TheWorld.components.atlas_todolist then
                    TheWorld.components.atlas_todolist:ToggleTask(task.id, not task.completed)
                    self:UpdateTaskList()
                else
                    print("[万象全书] 错误: TheWorld.components.atlas_todolist 不存在")
                end
            end,
            task.completed and "✓" or "□", 
            {40, 40}
        ))
    end)
    
    if not success or not status_button then
        print("[万象全书] 错误: 创建状态按钮失败")
        return nil
    end
    
    status_button:SetPosition(-400, 0, 0)
    
    -- 任务文本
    local task_text = nil
    success = pcall(function()
        task_text = item:AddChild(Text(DEFAULTFONT, 32))
    end)
    
    if not success or not task_text then
        print("[万象全书] 错误: 创建任务文本失败")
        return nil
    end
    
    task_text:SetPosition(-180, 0, 0)
    task_text:SetRegionSize(400, 50)
    task_text:SetHAlign(ANCHOR_LEFT)
    task_text:SetString(task.text)
    
    -- 根据完成状态设置颜色
    success = pcall(function()
        if task.completed then
            task_text:SetColour(0.5, 0.5, 0.5, 1) -- 灰色
        else
            task_text:SetColour(1, 0.95, 0.8, 1) -- 使用浅黄色
        end
    end)
    
    if not success then
        print("[万象全书] 错误: 设置文本颜色失败")
    end
    
    -- 删除按钮
    local delete_button = nil
    success = pcall(function()
        delete_button = item:AddChild(TEMPLATES.StandardButton(
            function() 
                print("[万象全书] 尝试删除任务: " .. tostring(task.id))
                if TheWorld and TheWorld.components and TheWorld.components.atlas_todolist then
                    TheWorld.components.atlas_todolist:DeleteTask(task.id)
                    self:UpdateTaskList()
                else
                    print("[万象全书] 错误: TheWorld.components.atlas_todolist 不存在")
                end
            end,
            "删除", 
            {80, 40}
        ))
    end)
    
    if not success or not delete_button then
        print("[万象全书] 错误: 创建删除按钮失败")
        return nil
    end
    
    delete_button:SetPosition(250, 0, 0)
    
    print("[万象全书] 成功创建任务项: " .. tostring(task.id))
    return item
end

function AtlasBookUI:AddTask(text)
    if text and text:gsub("%s+", "") ~= "" then
        print("[万象全书] 尝试添加任务: " .. tostring(text))
        if TheWorld and TheWorld.components and TheWorld.components.atlas_todolist then
            TheWorld.components.atlas_todolist:AddTask(text)
        else
            print("[万象全书] 错误: TheWorld.components.atlas_todolist 不存在")
        end
    end
end

-- 不再需要这些本地函数，因为现在通过RPC处理
-- function AtlasBookUI:ToggleTask(index, checked)
-- function AtlasBookUI:DeleteTask(index)

-- 创建目录按钮
function AtlasBookUI:CreateMenuButtons()
    -- 清除现有按钮
    if self.menu_buttons then
        for _, button in pairs(self.menu_buttons) do
            button:Kill()
        end
    end
    
    self.menu_buttons = {}
    local y_offset = 250 -- 从顶部开始
    
    -- 为每个大节创建按钮
    for section_id, section_data in pairs(GUIDE_DATA) do
        if section_data.is_section then
            -- 创建大节按钮
            local section_button = self.menu_scroll_root:AddChild(TEMPLATES.StandardButton(
                function() self:ToggleSection(section_id) end, 
                (self.expanded_sections[section_id] and "v " or "> ") .. section_data.title, 
                {220, 50} -- 增大按钮尺寸
            ))
            section_button:SetPosition(0, y_offset, 0)
            -- 使用黑色
            section_button:SetTextColour(0, 0, 0, 1)
            -- 设置字体大小
            section_button:SetTextSize(30)
            self.menu_buttons[section_id] = section_button
            y_offset = y_offset - 55 -- 增加间距
            
            -- 如果大节是展开的，显示其子章节
            if self.expanded_sections[section_id] and section_data.children then
                for chapter_id, chapter_data in pairs(section_data.children) do
                    if not chapter_data.is_section then
                        -- 创建小节按钮，缩进显示
                        local chapter_button = self.menu_scroll_root:AddChild(TEMPLATES.StandardButton(
                            function() self:SetChapter(chapter_id) end, 
                            "   " .. chapter_data.title, 
                            {200, 45} -- 增大按钮尺寸
                        ))
                        chapter_button:SetPosition(10, y_offset, 0)
                        -- 使用黑色
                        chapter_button:SetTextColour(0, 0, 0, 1)
                        -- 设置字体大小
                        chapter_button:SetTextSize(26)
                        self.menu_buttons[chapter_id] = chapter_button
                        y_offset = y_offset - 50 -- 增加间距
                    end
                end
            end
        end
    end
end

-- 切换大节的展开/折叠状态
function AtlasBookUI:ToggleSection(section_id)
    self.expanded_sections[section_id] = not self.expanded_sections[section_id]
    self:CreateMenuButtons()
end

function AtlasBookUI:OnPrevPage()
    local current_index
    for i, chapter in ipairs(FLAT_CHAPTERS) do
        if chapter.id == self.current_chapter_id then
            current_index = i
            break
        end
    end
    if current_index and current_index > 1 then
        local prev_chapter = FLAT_CHAPTERS[current_index - 1]
        if prev_chapter then
            -- 确保所属大节是展开的
            self.expanded_sections[prev_chapter.section_id] = true
            self:CreateMenuButtons()
            self:SetChapter(prev_chapter.id)
        end
    end
end

function AtlasBookUI:OnNextPage()
    local current_index
    for i, chapter in ipairs(FLAT_CHAPTERS) do
        if chapter.id == self.current_chapter_id then
            current_index = i
            break
        end
    end
    if current_index and current_index < #FLAT_CHAPTERS then
        local next_chapter = FLAT_CHAPTERS[current_index + 1]
        if next_chapter then
            -- 确保所属大节是展开的
            self.expanded_sections[next_chapter.section_id] = true
            self:CreateMenuButtons()
            self:SetChapter(next_chapter.id)
        end
    end
end

function AtlasBookUI:UpdatePageButtons()
    local current_index
    for i, chapter in ipairs(FLAT_CHAPTERS) do
        if chapter.id == self.current_chapter_id then
            current_index = i
            break
        end
    end

    if current_index == 1 then
        self.prev_button:Disable()
    else
        self.prev_button:Enable()
    end

    if current_index == #FLAT_CHAPTERS then
        self.next_button:Disable()
    else
        self.next_button:Enable()
    end
end

-- 设置当前显示的章节
function AtlasBookUI:SetChapter(chapter_id)
    -- 查找章节数据
    local chapter_data
    local section_id
    
    for sid, section in pairs(GUIDE_DATA) do
        if section.is_section and section.children and section.children[chapter_id] then
            chapter_data = section.children[chapter_id]
            section_id = sid
            break
        end
    end
    
    if chapter_data then
        self.current_chapter_id = chapter_id
        self.content_title:SetString(chapter_data.title)
        self.content_text:SetString(chapter_data.text)
        
        -- 高亮当前选中的章节按钮
        for id, button in pairs(self.menu_buttons) do
            if id == chapter_id then
                -- 选中项使用红色
                button:SetTextColour(0.8, 0, 0, 1)
            elseif GUIDE_DATA[id] and GUIDE_DATA[id].is_section then
                -- 大节使用黑色
                button:SetTextColour(0, 0, 0, 1)
            else
                -- 小节使用黑色
                button:SetTextColour(0, 0, 0, 1)
            end
        end
        
        -- 保存当前章节ID到玩家数据
        if self.owner and self.owner.atlas_book_data then
            if self.owner.atlas_book_data.last_page ~= chapter_id then
                print("[万象全书] 保存当前章节ID: " .. tostring(chapter_id))
                self.owner.atlas_book_data.last_page = chapter_id
            end
        end

        self:UpdatePageButtons()
    end
end

-- 关闭UI
function AtlasBookUI:Close()
    -- 确保在关闭UI时保存当前章节
    if self.owner and self.owner.atlas_book_data and self.current_chapter_id then
        print("[万象全书] 关闭UI时保存当前章节: " .. tostring(self.current_chapter_id))
        self.owner.atlas_book_data.last_page = self.current_chapter_id
    end
    
    TheFrontEnd:PopScreen(self)
end

-- 处理输入
function AtlasBookUI:OnControl(control, down)
    if AtlasBookUI._base.OnControl(self, control, down) then return true end
    
    if not down and control == CONTROL_CANCEL then
        self:Close()
        return true
    end
    
    return false
end

-- 当UI获得焦点时
function AtlasBookUI:OnBecomeActive()
    AtlasBookUI._base.OnBecomeActive(self)
    -- 暂停游戏
    SetPause(true, "atlas_book")
    
    -- 监听任务列表更新事件
    if not self.task_update_listener then
        self.task_update_listener = TheWorld:ListenForEvent("atlas_todolist_updated", function() 
            print("[万象全书] 收到任务列表更新事件")
            self:UpdateTaskList() 
        end)
    end
    
    -- 监听任务列表组件准备就绪事件
    if not self.task_ready_listener then
        self.task_ready_listener = TheWorld:ListenForEvent("atlas_todolist_ready", function() 
            print("[万象全书] 收到任务列表组件准备就绪事件")
            self:UpdateTaskList() 
        end)
    end
    
    -- 检查组件是否存在
    if not TheWorld or not TheWorld.components or not TheWorld.components.atlas_todolist then
        print("[万象全书] 警告: TheWorld.components.atlas_todolist 不存在")
    end
end

-- 当UI失去焦点时
function AtlasBookUI:OnBecomeInactive()
    AtlasBookUI._base.OnBecomeInactive(self)
    -- 恢复游戏
    SetPause(false, "atlas_book")
    
    -- 移除事件监听
    if self.task_update_listener then
        TheWorld:RemoveEventCallback("atlas_todolist_updated", self.task_update_listener)
        self.task_update_listener = nil
    end
    
    if self.task_ready_listener then
        TheWorld:RemoveEventCallback("atlas_todolist_ready", self.task_ready_listener)
        self.task_ready_listener = nil
    end
end

return AtlasBookUI
