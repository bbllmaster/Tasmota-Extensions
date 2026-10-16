# 打包命令（在 raw/RulesPanel 目录下执行，扁平结构，使用 zip -j 去掉目录前缀）：
# rm RulesPanel.tapp; zip -j -0 RulesPanel.tapp autoexec.be rules_panel.be manifest.json console_panel.html rules_panel.html
do                          # embed in `do` so we don't add anything to global namespace
  import introspect
  var rules_panel = introspect.module('rules_panel', true)     # load module but don't cache
  tasmota.add_extension(rules_panel)
end

# to remove:
#       tasmota.unload_extension('Rules Panel')