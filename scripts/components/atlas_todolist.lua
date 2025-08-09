local AtlasTodoList = Class(function(self, inst)
    self.inst = inst
    self.tasks = {} -- 任务列表
    self.next_id = 1 -- 下一个任务ID
    
    print("[万象全书] 创建 atlas_todolist 组件")
    
    -- 确保这是服务器端组件
    if self.inst.ismastersim then
        -- 初始化后延迟同步，确保所有客户端都已连接
        self.inst:DoTaskInTime(1, function()
            print("[万象全书] 初始同步任务列表")
            self:SyncToClients()
        end)
    else
        -- 客户端组件
        print("[万象全书] 这是客户端组件")
        
        -- 在客户端，我们需要监听来自服务器的更新
        self.inst:DoTaskInTime(0.5, function()
            print("[万象全书] 客户端组件准备就绪，触发事件")
            self.inst:PushEvent("atlas_todolist_ready")
        end)
    end
end)

-- 添加任务
function AtlasTodoList:AddTask(text)
    -- 在客户端，转发到服务器
    if not self.inst.ismastersim then
        if text and text:gsub("%s+", "") ~= "" then
            print("[万象全书] 客户端发送添加任务RPC: " .. tostring(text))
            SendModRPCToServer(MOD_RPC[ATLAS_RPC.NAMESPACE][ATLAS_RPC.ADD_TASK], text)
        end
        return nil
    end
    
    -- 服务器端逻辑
    if text and text:gsub("%s+", "") ~= "" then
        local task = {
            id = self.next_id,
            text = text,
            completed = false,
            timestamp = os.time() -- 添加时间戳，用于排序
        }
        
        table.insert(self.tasks, task)
        self.next_id = self.next_id + 1
        
        print("[万象全书] 添加任务: " .. tostring(text) .. " ID: " .. tostring(task.id))
        self:SyncToClients()
        
        return task
    end
    return nil
end

-- 切换任务状态
function AtlasTodoList:ToggleTask(task_id, is_completed)
    -- 在客户端，转发到服务器
    if not self.inst.ismastersim then
        print("[万象全书] 客户端发送切换任务状态RPC:", task_id, is_completed)
        SendModRPCToServer(MOD_RPC[ATLAS_RPC.NAMESPACE][ATLAS_RPC.TOGGLE_TASK], task_id, is_completed)
        return true
    end
    
    -- 服务器端逻辑
    for i, task in ipairs(self.tasks) do
        if task.id == task_id then
            task.completed = is_completed
            print("[万象全书] 切换任务状态:", task.text, is_completed)
            self:SyncToClients()
            return true
        end
    end
    print("[万象全书] 切换任务状态失败，未找到任务:", task_id)
    return false
end

-- 删除任务
function AtlasTodoList:DeleteTask(task_id)
    -- 在客户端，转发到服务器
    if not self.inst.ismastersim then
        print("[万象全书] 客户端发送删除任务RPC:", task_id)
        SendModRPCToServer(MOD_RPC[ATLAS_RPC.NAMESPACE][ATLAS_RPC.DELETE_TASK], task_id)
        return true
    end
    
    -- 服务器端逻辑
    for i, task in ipairs(self.tasks) do
        if task.id == task_id then
            local task_text = task.text
            table.remove(self.tasks, i)
            print("[万象全书] 删除任务:", task_text, "ID:", task_id)
            self:SyncToClients()
            return true
        end
    end
    print("[万象全书] 删除任务失败，未找到任务:", task_id)
    return false
end

-- 获取任务列表
function AtlasTodoList:GetTasks()
    return self.tasks
end

-- 从服务器同步任务列表（客户端方法）
function AtlasTodoList:SyncTasks(tasks_json)
    if not self.inst.ismastersim then
        if tasks_json then
            local json_length = string.len(tasks_json)
            print("[万象全书] 开始解析任务列表JSON，长度: " .. tostring(json_length))
            
            local success, tasks = pcall(function() 
                return json.decode(tasks_json) 
            end)
            
            if success and tasks then
                if type(tasks) == "table" then
                    self.tasks = tasks
                    print("[万象全书] 客户端收到任务列表更新，共 " .. tostring(#self.tasks) .. " 个任务")
                    
                    -- 打印任务内容用于调试
                    for i, task in ipairs(self.tasks) do
                        print("[万象全书] 任务 " .. tostring(i) .. ": ID=" .. tostring(task.id) .. ", 文本=" .. tostring(task.text) .. ", 完成=" .. tostring(task.completed))
                    end
                    
                    -- 触发事件，通知UI更新
                    self.inst:PushEvent("atlas_todolist_updated")
                else
                    print("[万象全书] 错误: 解析的任务列表不是表格，而是 " .. tostring(type(tasks)))
                end
            else
                print("[万象全书] 错误: 解析任务列表JSON失败: " .. tostring(tasks or "未知错误"))
                if tasks_json then
                    print("[万象全书] JSON内容预览: " .. tostring(string.sub(tasks_json, 1, 100)))
                end
            end
        else
            print("[万象全书] 错误: 收到空的任务列表JSON")
        end
    end
end

-- 同步到所有客户端（服务器方法）
function AtlasTodoList:SyncToClients()
    -- 确保这是服务器端组件
    if not self.inst.ismastersim then
        print("[万象全书] 错误: 非服务器组件尝试同步数据")
        return
    end

    -- 将任务列表转换为JSON字符串
    local success, tasks_json = pcall(function() return json.encode(self.tasks) end)
    
    if not success or not tasks_json then
        print("[万象全书] 错误: 将任务列表转换为JSON失败")
        return
    end
    
    local task_count = #self.tasks
    local json_length = string.len(tasks_json or "")
    print("[万象全书] 同步任务列表到客户端，任务数量: " .. tostring(task_count) .. " JSON长度: " .. tostring(json_length))
    
    -- 向所有客户端广播任务列表
    for i, v in ipairs(AllPlayers) do
        if v:IsValid() then
            print("[万象全书] 向玩家同步: " .. tostring(v.name))
            local success = pcall(function()
                SendModRPCToClient(GetClientModRPC(ATLAS_RPC.NAMESPACE, ATLAS_RPC.SYNC_TASKS), v.userid, tasks_json)
            end)
            
            if not success then
                print("[万象全书] 错误: 向玩家 " .. tostring(v.name) .. " 发送RPC失败")
            end
        end
    end
end

-- 保存数据
function AtlasTodoList:OnSave()
    if not self.inst.ismastersim then
        return nil
    end
    
    print("[万象全书] 保存任务列表，任务数量:", #self.tasks)
    return {
        tasks = self.tasks,
        next_id = self.next_id
    }
end

-- 加载数据
function AtlasTodoList:OnLoad(data)
    if not self.inst.ismastersim then
        return
    end
    
    if data then
        if data.tasks then
            self.tasks = data.tasks
            print("[万象全书] 加载任务列表，任务数量:", #self.tasks)
        end
        if data.next_id then
            self.next_id = data.next_id
        end
    end
    
    -- 加载后同步到所有客户端
    self.inst:DoTaskInTime(1, function()
        print("[万象全书] 加载后同步任务列表")
        self:SyncToClients()
    end)
end

return AtlasTodoList 