# 打包命令（在 RulesPanel 目录下执行，保留 html/ 子目录结构）：
# rm RulesPanel.tapp; zip -0 RulesPanel.tapp autoexec.be rules_panel.be manifest.json html/console_panel.html html/rules_panel.html
do                          # embed in `do` so we don't add anything to global namespace
  import introspect
  var rules_panel = introspect.module('rules_panel', true)     # load module but don't cache
  tasmota.add_extension(rules_panel)
end

# to remove:
#       tasmota.unload_extension('Rules Panel')