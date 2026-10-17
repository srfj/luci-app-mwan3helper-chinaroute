
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.mwan3helper", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/mwan3helper") then
		return
	end


  local page = entry({"admin", "services", "mwan3helper"},alias("admin", "services", "mwan3helper", "client"),_("MWAN3 Helper"), 300)
	page.dependent = true
	page.acl_depends = { "luci-app-mwan3helper" }
  entry({"admin", "services", "mwan3helper", "client"},cbi("mwan3helper/client"),_("Settings"), 10).leaf = true
 	
	entry({"admin", "services", "mwan3helper", "lists"},cbi("mwan3helper/list"),_("IPSet Lists"), 20).leaf = true
	
	entry({"admin","services","mwan3helper","status"},call("act_status")).leaf=true
	
end

function act_status()
  local e={}
  local enabled = luci.sys.exec("uci -q get mwan3helper.config.enabled"):gsub("%s+", "")
  local routed  = luci.sys.call("ip rule show 2>/dev/null | grep -q 'lookup 200'") == 0
  e.running = (enabled == "1") and routed
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end
