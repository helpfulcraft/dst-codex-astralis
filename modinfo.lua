name = "万象全书 (Codex Astralis)"
description = "一本出生自带的超级指南，内置新手攻略、团队规划和AI助手！\nA super guide book you spawn with, featuring beginner's guides, team planner, and an AI assistant!\n原CanKao模组的扩展版本，保留了所有原有功能。\nExtended version of CanKao mod, keeping all original features." 
author = "Codex Team"
version = "2.0"
forumthread = ""

api_version = 10


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
      hover = "设置化石碎片配方数量 Configure the number of fossil pieces in the ingredients", 
      label = "化石数量 num_fossil pieces",
      options = {
        {description = "1", data = 1, hover = ""},
        {description = "2", data = 2, hover = ""},
      },

      default = 1,

    }
  }