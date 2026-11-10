-- New versions: a daily GitHub check, a status badge, and managed update guidance.
local config = require("./config")
local M = {}

local P = "plugin.omp-usage."
local SOURCE = "https://github.com/joaodutra88/tern-omp-usage"
local LATEST = "https://api.github.com/repos/joaodutra88/tern-omp-usage/releases/latest"
local DAY_S = 86400

M.VERSION = "0.0.0"
local latest: { version: string, url: string, checked_at: number }? = nil
local checking = false

-- "v0.10.2" → {0, 10, 2}; versions compare part by part, missing parts are 0.
local function parts(v: string): { number }
	local out = {}
	for n in string.gmatch(v, "%d+") do
		table.insert(out, tonumber(n) :: number)
	end
	return out
end

function M.newer(a: string, b: string): boolean
	local x, y = parts(a), parts(b)
	for i = 1, math.max(#x, #y) do
		local p, q = x[i] or 0, y[i] or 0
		if p ~= q then
			return p > q
		end
	end
	return false
end

local function kv(key: string): any
	local ok, v = pcall(tern.kv.get, key)
	return if ok then v else nil
end

local function enabled(): boolean
	return config.shows("updates") and not tern.getenv("OMP_USAGE_NO_UPDATE_CHECK")
end

function M.available(): boolean
	return latest ~= nil and enabled() and M.newer(latest.version, M.VERSION)
end

-- One toast per new version, across windows and restarts.
local function announce(cx: any)
	if cx and latest and M.available() and kv("notified") ~= latest.version then
		tern.kv.set("notified", latest.version)
		cx:toast("info", string.format(config.labels.update_ready, latest.version), config.labels.update_how)
	end
end

-- Asks GitHub at most once a day per machine (the answer is shared through tern.kv). `force` (the palette command)
-- asks now, even with checks turned off, and always answers with a toast.
function M.check(force: boolean?, cx: any?)
	if checking then
		return
	end
	local saved = kv("update")
	if type(saved) == "table" and type(saved.version) == "string" then
		latest = saved
	end
	local fresh = latest ~= nil and os.time() - (tonumber(latest.checked_at) or 0) < DAY_S
	if not force and (fresh or not enabled()) then
		announce(cx)
		return
	end
	checking = true
	local headers = { Accept = "application/vnd.github+json", ["User-Agent"] = "tern-omp-usage/" .. M.VERSION }
	local started = pcall(tern.fetch, LATEST, { headers = headers, timeout_ms = 15000 }, function(res, later)
		checking = false
		local ok, data = pcall(tern.json.decode, res.body)
		local answered = res.status == 200 and ok and type(data) == "table" and type(data.tag_name) == "string"
		if answered then
			latest = { version = (string.gsub(data.tag_name, "^v", "")), url = tostring(data.html_url), checked_at = os.time() }
			tern.kv.set("update", latest)
		end
		local where = later or cx
		if force and where and not answered then
			where:toast("error", config.labels.update_failed, res.error or ("GitHub answered " .. res.status))
		elseif force and where and latest and M.newer(latest.version, M.VERSION) then
			where:toast("info", string.format(config.labels.update_ready, latest.version), config.labels.update_how)
		elseif force and where then
			where:toast("success", string.format(config.labels.up_to_date, M.VERSION))
		else
			announce(where)
		end
		tern.chrome.refresh()
	end)
	if not started then
		checking = false
	end
end

function M.install(cx: any)
	cx:toast("info", "Managed by tern-omp-settings", "Sync the fork, pull plugins/fork/tern-omp-usage, then run sync.ps1.")
end

-- After an update (not a first install), one toast per window says which version runs now.
function M.greet(cx: any)
	local seen = kv("seen_version")
	if seen == M.VERSION then
		return
	end
	tern.kv.set("seen_version", M.VERSION)
	if seen ~= nil then
		cx:toast("success", string.format(config.labels.updated, M.VERSION), config.labels.whats_new)
	end
end

function M.segments(out: { any })
	if latest and M.available() then
		table.insert(out, { text = "⬆ " .. latest.version, command = P .. "update" })
	end
end

function M.init()
	local ok, manifest = pcall(tern.fs.read, "plugin.toml")
	M.VERSION = ok and string.match(manifest, '\nversion%s*=%s*"([^"]+)"') or M.VERSION
	tern.command({
		id = "update",
		title = "OMP usage: update to the latest version",
		icon = "gauge",
		available = function()
			return M.available()
		end,
		run = M.install,
	})
	tern.command({
		id = "check-update",
		title = "OMP usage: check for updates",
		icon = "gauge",
		run = function(cx)
			M.check(true, cx)
		end,
	})
	tern.command({
		id = "whats-new",
		title = "OMP usage: what's new",
		icon = "gauge",
		run = function(cx)
			cx:open(SOURCE .. "/releases/tag/v" .. M.VERSION)
		end,
	})
end

return M
