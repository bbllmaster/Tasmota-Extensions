#- ============================================================ -#
#-  rules_panel.be - Tasmota Extension: 规则面板                 -#
#-  标准 Extension driver，实现完整的生命周期管理                -#
#-  /btns  → console_panel.html（按钮规则面板）                  -#
#-  /rules → rules_panel.html（通用规则面板，支持所有触发类型）  -#
#-  规则存在设备 flash 中，重启不丢失                            -#
#- ============================================================ -#

import webserver
import persist

#- ============================================================ -#
#  Extension driver: RulesPanel
#- ============================================================ -#
class RulesPanel

  #- 配置项（持久化到 _persist.json）-#
  var enabled
  var show_btns_panel
  var show_rules_panel
  var max_rules_per_slot

  #- HTML 文件目录（在 init 时根据 tasmota.wd 构建）-#
  var html_dir

  #################################################################################
  # init
  #
  # 构造函数。模块加载时自动调用，注册 driver 并初始化配置。
  #################################################################################
  def init()
    self.load_config()
    #- tasmota.wd 在模块加载时指向 tapp 形如 '/.extensions/RulesPanel.tapp#' -#
    #- 本仓库采用扁平结构（gen.py 仅打包顶层文件），HTML 与 .be 同目录 -#
    self.html_dir = tasmota.wd
    tasmota.add_driver(self)
    #- 如果网络已就绪，直接注册路由（web_add_handler 事件可能已触发）-#
    if tasmota.is_network_up()
      self.web_add_handler()
    end
  end

  #################################################################################
  # load_config
  #
  # 从 persist 读取配置项，未设置时使用默认值
  #################################################################################
  def load_config()
    self.enabled            = persist.find("rp_enabled", true)
    self.show_btns_panel    = persist.find("rp_show_btns", true)
    self.show_rules_panel   = persist.find("rp_show_rules", true)
    self.max_rules_per_slot = persist.find("rp_max_rules", 4)
  end

  #################################################################################
  # unload
  #
  # 卸载扩展时清理资源（由 tasmota.unload_extension 调用）
  #################################################################################
  def unload()
    webserver.remove_route("/btns")
    webserver.remove_route("/rules")
    webserver.remove_route("/rules-cfg")
    tasmota.remove_driver(self)
  end

  #################################################################################
  # web_add_main_button
  #
  # 在 Tasmota 主页添加插件入口按钮（Tasmota 自动调用）
  #################################################################################
  def web_add_main_button()
    if !self.enabled return end
    webserver.content_send(
      "<p></p><div style='display:flex;gap:10px'>"
      "<button onclick='window.location.href=\"/btns\";'>按钮规则面板</button>"
      "<button onclick='window.location.href=\"/rules\";'>通用规则面板</button>"
      "</div>"
    )
  end

  #################################################################################
  # web_add_config_button
  #
  # 在 Tasmota 配置页面（/cn）添加插件配置入口按钮（Tasmota 自动调用）
  #################################################################################
  def web_add_config_button()
    webserver.content_send(
      "<p></p>"
      "<form id=rp_cfg action='rules-cfg' style='display: block;' method='get'>"
      "<button>规则面板</button>"
      "</form>"
    )
  end

 #################################################################################
  # web_add_handler
  #
  # 注册 HTTP 路由（Tasmota 自动调用；网络已就绪时需手动调用）
  #################################################################################
  def web_add_handler()
    webserver.on('/btns', / -> self.page_btns())
    webserver.on('/rules', / -> self.page_rules())
    webserver.on('/rules-cfg', / -> self.page_config(), webserver.HTTP_GET)
    webserver.on('/rules-cfg', / -> self.save_config(), webserver.HTTP_POST)
  end

  #################################################################################
  # serve_page
  #
  # 读取 HTML 文件并输出到 Web 客户端
  #################################################################################
  def serve_page(file, title)
    webserver.content_open(200, "text/html")
    var c = ""
    try
      var f = open(file, "r")
      c = f.read()
      f.close()
    except .. as e, m
      log("RP: cannot read " + file + " " + str(e) + " " + str(m), 3)
      c = "<html><body><h2>" + title + " 未找到</h2>"
         "<p>请确认插件已正确安装且 HTML 文件存在于扩展目录中。</p>"
         "</body></html>"
    end
    webserver.content_send(c)
    webserver.content_close()
  end

  #################################################################################
  # page_btns
  #
  # 按钮规则面板页面
  #################################################################################
  def page_btns()
    self.serve_page(self.html_dir + "console_panel.html", "按钮规则面板")
  end

  #################################################################################
  # page_rules
  #
  # 通用规则面板页面
  #################################################################################
  def page_rules()
    self.serve_page(self.html_dir + "rules_panel.html", "通用规则面板")
  end

  #################################################################################
  # page_config
  #
  # 插件配置页面（GET）— 展示启用开关、面板显示选项、规则槽数量、重置按钮
  #################################################################################
  def page_config()
    if !webserver.check_privileged_access() return nil end
    self.load_config()
    var vals = self.get_config_values()

    webserver.content_start("规则面板配置")
    webserver.content_send_style()

    webserver.content_send(
      "<fieldset>"
      "<legend><b>&nbsp;规则面板配置&nbsp;</b></legend>"
      "<form method='get' action='rules-cfg'>"
      "<table>"
      "<tr>"
      "<td style='width:220px'><b>启用插件</b></td>"
      "<td><input type='checkbox' name='enabled' " + (vals['enabled'] ? "checked" : "") + "> 启用后主菜单显示入口按钮</td>"
      "</tr>"
      "<tr>"
      "<td><b>显示按钮规则面板</b></td>"
      "<td><input type='checkbox' name='show_btns_panel' " + (vals['show_btns_panel'] ? "checked" : "") + "> /btns 面板</td>"
      "</tr>"
      "<tr>"
      "<td><b>显示通用规则面板</b></td>"
      "<td><input type='checkbox' name='show_rules_panel' " + (vals['show_rules_panel'] ? "checked" : "") + "> /rules 面板</td>"
      "</tr>"
      "<tr>"
      "<td><b>每规则槽最大规则数</b></td>"
      "<td><input name='max_rules_per_slot' type='number' min='1' max='16' value='" + str(vals['max_rules_per_slot']) + "'> 影响规则分槽策略</td>"
      "</tr>"
      "</table>"
      "<p></p>"
      "<button name='save' type='submit' class='button bgrn'>保存设置</button>"
      "</form>"
      "</fieldset>"
      "<p></p>"
      "<fieldset>"
      "<legend><b>&nbsp;危险操作&nbsp;</b></legend>"
      "<form method='post' action='rules-cfg' onsubmit='return confirm(\"确定清空所有规则槽（Rule1/2/3）？此操作不可恢复。\");'>"
      "<button name='reset' type='submit' class='button bred'>重置插件（清空所有规则）</button>"
      "</form>"
      "</fieldset>"
    )

    webserver.content_button(webserver.BUTTON_CONFIGURATION)
    webserver.content_stop()
  end

  #################################################################################
  # save_config
  #
  # 保存插件配置（POST）— 读取表单参数并写入 persist
  #################################################################################
  def save_config()
    if !webserver.check_privileged_access() return nil end

    if webserver.has_arg('reset')
      #- 重置：清空所有规则槽 -#
      tasmota.cmd('Rule1 "', true)
      tasmota.cmd('Rule2 "', true)
      tasmota.cmd('Rule3 "', true)
      webserver.redirect("/cn?")                    #- 返回配置菜单 -#
      return nil
    end

    self.enabled            = webserver.has_arg('enabled')
    self.show_btns_panel    = webserver.has_arg('show_btns_panel')
    self.show_rules_panel   = webserver.has_arg('show_rules_panel')
    var mrps = int(webserver.arg('max_rules_per_slot'))
    if mrps < 1  mrps = 1  end
    if mrps > 16 mrps = 16 end
    self.max_rules_per_slot = mrps

    persist.rp_enabled      = self.enabled
    persist.rp_show_btns    = self.show_btns_panel
    persist.rp_show_rules   = self.show_rules_panel
    persist.rp_max_rules    = self.max_rules_per_slot
    persist.save()

    webserver.redirect("/cn?")                        #- 返回配置菜单 -#
  end

  #################################################################################
  # web_add_config
  #
  # 在 Tasmota 配置页面添加插件配置表单
  #（兼容 issue 中描述的 driver 接口；Tasmota 通过 web_add_config_button 调用）
  #################################################################################
  def web_add_config()
    self.page_config()
  end

  #################################################################################
  # web_save_config
  #
  # 保存插件配置
  #################################################################################
  def web_save_config()
    self.save_config()
  end

  #################################################################################
  # get_config_values
  #
  # 返回当前配置值（供配置页面渲染使用）
  #################################################################################
  def get_config_values()
    return {
      'enabled': self.enabled,
      'show_btns_panel': self.show_btns_panel,
      'show_rules_panel': self.show_rules_panel,
      'max_rules_per_slot': self.max_rules_per_slot
    }
  end

end

#- ============================================================ -#
#  模块导出：返回 RulesPanel 实例
#- ============================================================ -#
return RulesPanel()