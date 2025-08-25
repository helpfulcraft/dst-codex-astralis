-- 多语言支持：检测当前语言
local language = "zh"  -- 默认中文，如果无法获取语言信息
if GLOBAL and GLOBAL.LanguageTranslator and GLOBAL.LanguageTranslator.defaultlang then
    language = GLOBAL.LanguageTranslator.defaultlang
end

-- 多语言名称和描述
local mod_names = {
    zh = "万象全书 (Codex Astralis)",
    en = "Codex Astralis (万象全书)"
}

local mod_descriptions = {
    zh = "一本出生自带的超级指南，内置新手攻略、团队规划！\nA super guide book you spawn with, featuring beginner's guides, team planner!",
    en = "A super guide book you spawn with, featuring beginner's guides, team planner!\n一本出生自带的超级指南，内置新手攻略、团队规划！"
}

local config_labels = {
    zh = "化石数量 num_fossil pieces",
    en = "Fossil Pieces 化石数量"
}

local config_hovers = {
    zh = "设置化石碎片配方数量 Configure the number of fossil pieces in the ingredients",
    en = "Configure the number of fossil pieces in the ingredients 设置化石碎片配方数量"
}

-- 根据语言设置模组信息
name = mod_names[language] or mod_names.zh
description = mod_descriptions[language] or mod_descriptions.zh
author = "Codex Team"
version = "3.1"
forumthread = ""

api_version_dst = 10


all_clients_require_mod = true
client_only_mod = false

reign_of_giants_compatible = false
dont_starve_compatible = false
dst_compatible = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"


configuration_options =
  {
    {
      name = "fos",
      hover = config_hovers[language] or config_hovers.zh,
      label = config_labels[language] or config_labels.zh,
      options = {
        {description = "1", data = 1, hover = ""},
        {description = "2", data = 2, hover = ""},
      },

      default = 1,

    }
  }