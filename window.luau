-- Claude and Codex usage from omp in Tern's status line (usage.luau). See README.md.
local config = require("./config")
local update = require("./update")
local usage = require("./usage")
local FETCH_MS = 5 * 60 * 1000 -- Anthropic usage endpoint answers 429 below ~5 min
local TICK_MS = 60 * 1000
local UPDATE_MS = 60 * 60 * 1000 -- update.check asks GitHub at most once a day; this only looks at the cache

local OMP = config.omp_bin()

local function every(ms: number, fn: () -> ())
	local function loop()
		fn()
		tern.timer(ms, loop)
	end
	loop()
end

local function hidden(id: string, run: (any) -> ())
	tern.command({
		id = id,
		title = "Status line: " .. id,
		available = function()
			return false
		end,
		run = run,
	})
end

tern.command({
	id = "refresh",
	title = "OMP usage: refresh Claude and Codex limits",
	run = function()
		usage.fetch(true)
	end,
})

-- One dashboard per window: focus the open one, else open it beside the focused pane.
local function open_dashboard(cx: WindowCx)
	for _, pane in cx.session:panes() do
		if pane.title == "OMP usage" then
			cx.layout:focus(pane.pane)
			return
		end
	end
	if cx:new_block("omp-usage.dashboard", nil, "beside") == nil then
		cx:toast("error", config.labels.dash_missing)
	end
end

tern.command({
	id = "dashboard",
	title = "OMP usage: dashboard",
	icon = "gauge",
	run = open_dashboard,
})
hidden("today", open_dashboard)
hidden("cost", open_dashboard)
usage.init(OMP, hidden)
config.load()
config.commands()
update.init()

-- window_start doesn't fire again after `tern plugin reload`; a load-time timer covers both. Each callback starts
-- one process or request at most: one over 50 ms makes Tern turn off every timer of the plugin until a reload.
tern.timer(0, function()
	every(FETCH_MS, usage.fetch)
end)
tern.timer(1000, function()
	every(FETCH_MS, usage.fetch_today)
end)
tern.timer(2000, function(cx)
	if cx then
		update.greet(cx)
	end
	local function look(later)
		update.check(false, later)
		tern.timer(UPDATE_MS, look)
	end
	look(cx)
end)
tern.timer(TICK_MS, function()
	-- The countdown moves without new data, and another window may have changed a setting.
	every(TICK_MS, function()
		config.load()
		tern.chrome.refresh()
	end)
end)

tern.css("statusline", [[
/* Tern spaces plugin segments with a flex gap; zero it and let each segment set its own margin.
   Colors are Tern's tokens (--ok, --warn, --bad, --accent, --t1..t4, --l2), so light, dark and user themes follow.
   White text sits only on the *-fill tokens, which are made for it. */
#statusline .sl-plugins { gap: 0 !important; }
#statusline .sl-plugins > .sl-plugin { margin-left: 6px; }
#statusline .sl-plugin[title^="plugin.omp-usage."] { margin: 0 0 0 6px; padding: 0; }
#statusline .sl-plugin[title="plugin.omp-usage.claude"] { margin-left: 16px; padding-left: 12px;
  border-left: 1px solid var(--l2); color: var(--t1); font-weight: 600; }
#statusline .sl-plugin[title="plugin.omp-usage.codex"] { margin-left: 16px; padding-left: 12px;
  border-left: 1px solid var(--l2); color: var(--t1); font-weight: 700; }
#statusline .sl-plugin[title="plugin.omp-usage.today"] { margin-left: 16px; padding-left: 12px;
  border-left: 1px solid var(--l2); color: var(--t2); font-weight: 600; }
#statusline .sl-plugin[title="plugin.omp-usage.cost"] { margin-left: 8px; padding: 0 6px; border-radius: 4px;
  color: var(--accent-ink); background: rgb(from var(--accent) r g b / 12%); font-weight: 700; }
#statusline .sl-plugin[title="plugin.omp-usage.credits"] { color: var(--accent-ink); }
#statusline .sl-plugin[title="plugin.omp-usage.slack-ok"] { margin-left: 10px; padding: 0 6px; border-radius: 4px;
  color: var(--ok); background: rgb(from var(--ok) r g b / 12%); font-weight: 700; }
#statusline .sl-plugin[title="plugin.omp-usage.slack-bad"] { margin-left: 10px; padding: 0 6px; border-radius: 4px;
  color: var(--bad); background: rgb(from var(--bad) r g b / 18%); font-weight: 700; animation: omppulse 1.2s ease-in-out infinite; }
#statusline .sl-plugin[title="plugin.omp-usage.reset"] { color: var(--t3); }
#statusline .sl-plugin[title="plugin.omp-usage.reset-soon"] { color: var(--ok); font-weight: 600; }
#statusline .sl-plugin[title="plugin.omp-usage.eta"] { margin-left: 4px; color: var(--warn); font-weight: 600; }
#statusline .sl-plugin[title="plugin.omp-usage.locked"] { margin-left: 16px; color: white; background: var(--bad-fill);
  padding: 0 6px; border-radius: 4px; font-weight: 700; animation: omppulse 0.9s ease-in-out infinite; }
#statusline .sl-plugin[title^="plugin.omp-usage.dot-"] { margin-left: 0; }
#statusline .sl-plugin[title="plugin.omp-usage.dot-1"] { margin-left: 6px; color: var(--ok); }
#statusline .sl-plugin[title="plugin.omp-usage.dot-2"] { color: color-mix(in srgb, var(--ok) 50%, var(--warn)); }
#statusline .sl-plugin[title="plugin.omp-usage.dot-3"] { color: var(--warn); }
#statusline .sl-plugin[title="plugin.omp-usage.dot-4"] { color: color-mix(in srgb, var(--warn) 50%, var(--bad)); }
#statusline .sl-plugin[title="plugin.omp-usage.dot-5"] { color: var(--bad); }
#statusline .sl-plugin[title="plugin.omp-usage.empty"] { color: var(--t4); }
#statusline .sl-plugin[title^="plugin.omp-usage.dot-"] + .sl-plugin[title="plugin.omp-usage.empty"] { margin-left: 0; }
#statusline .sl-plugin[title="plugin.omp-usage.pct-1"] { color: var(--ok); }
#statusline .sl-plugin[title="plugin.omp-usage.pct-2"] { color: color-mix(in srgb, var(--ok) 50%, var(--warn)); }
#statusline .sl-plugin[title="plugin.omp-usage.pct-3"] { color: var(--warn); }
#statusline .sl-plugin[title="plugin.omp-usage.pct-4"] { color: color-mix(in srgb, var(--warn) 50%, var(--bad)); font-weight: 600; }
#statusline .sl-plugin[title="plugin.omp-usage.pct-crit"] { color: white; font-weight: 700; background: var(--bad-fill);
  padding: 0 4px; border-radius: 3px; animation: omppulse 1.2s ease-in-out infinite; }
#statusline .sl-plugin[title="plugin.omp-usage.update"] { margin-left: 10px; padding: 0 6px; border-radius: 4px;
  color: white; background: var(--accent-fill); font-weight: 700; }
@keyframes omppulse { 50% { opacity: 0.35; } }
]])

-- Personal segments: extras.luau beside window.luau (git ignores it), else the copy an update moved to the
-- data folder, because `tern plugin install --force` replaces this folder.
local function load_extras(): any?
	local ok, mod = pcall(require, "./extras")
	if ok then
		return mod
	end
	local kept = tern.plugin.data .. "/extras.luau"
	if not tern.fs.exists(kept) then
		return nil
	end
	local chunk = loadstring(tern.fs.read(kept), "=extras.luau")
	local loaded, result = pcall(chunk or error)
	return if loaded then result else nil
end
local extras = load_extras()
if extras then
	extras.init(hidden, every)
end

tern.chrome.status(function(pane)
	local out = {}
	if extras then
		extras.segments(out, pane)
	end
	-- First, so a narrow window that clips the end of the status line still shows it.
	update.segments(out)
	usage.segments(out)
	return out
end)
