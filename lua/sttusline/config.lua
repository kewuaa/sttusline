local vim = vim
local uv = vim.uv or vim.loop
local api = vim.api
local g = vim.g
local type = type
local require = require
local pcall = pcall

local colors = require("sttusline.utils.color")
local M = {}

local configs = {
	-- statusline_color = "#1e2030",
	-- statusline_color = "StatusLine",
	-- on_attach = function(create_update_group) end
	disabled = {
		filetypes = {},
		buftypes = {
			"terminal",
		},
	},
	components = {
		{
			name = "mode",
			event = { "ModeChanged", "VimResized" },
			user_event = "VeryLazy",
			configs = {
				modes = {
					["n"] = { "NORMAL", "STTUSLINE_NORMAL_MODE" },
					["no"] = { "NORMAL (no)", "STTUSLINE_NORMAL_MODE" },
					["nov"] = { "NORMAL (nov)", "STTUSLINE_NORMAL_MODE" },
					["noV"] = { "NORMAL (noV)", "STTUSLINE_NORMAL_MODE" },
					["noCTRL-V"] = { "NORMAL", "STTUSLINE_NORMAL_MODE" },
					["niI"] = { "NORMAL i", "STTUSLINE_NORMAL_MODE" },
					["niR"] = { "NORMAL r", "STTUSLINE_NORMAL_MODE" },
					["niV"] = { "NORMAL v", "STTUSLINE_NORMAL_MODE" },

					["nt"] = { "TERMINAL", "STTUSLINE_NTERMINAL_MODE" },
					["ntT"] = { "TERMINAL (ntT)", "STTUSLINE_NTERMINAL_MODE" },

					["v"] = { "VISUAL", "STTUSLINE_VISUAL_MODE" },
					["vs"] = { "V-CHAR (Ctrl O)", "STTUSLINE_VISUAL_MODE" },
					["V"] = { "V-LINE", "STTUSLINE_VISUAL_MODE" },
					["Vs"] = { "V-LINE", "STTUSLINE_VISUAL_MODE" },
					[""] = { "V-BLOCK", "STTUSLINE_VISUAL_MODE" },

					["i"] = { "INSERT", "STTUSLINE_INSERT_MODE" },
					["ic"] = { "INSERT (completion)", "STTUSLINE_INSERT_MODE" },
					["ix"] = { "INSERT completion", "STTUSLINE_INSERT_MODE" },

					["t"] = { "TERMINAL", "STTUSLINE_TERMINAL_MODE" },
					["!"] = { "SHELL", "STTUSLINE_TERMINAL_MODE" },

					["R"] = { "REPLACE", "STTUSLINE_REPLACE_MODE" },
					["Rc"] = { "REPLACE (Rc)", "STTUSLINE_REPLACE_MODE" },
					["Rx"] = { "REPLACEa (Rx)", "STTUSLINE_REPLACE_MODE" },
					["Rv"] = { "V-REPLACE", "STTUSLINE_REPLACE_MODE" },
					["Rvc"] = { "V-REPLACE (Rvc)", "STTUSLINE_REPLACE_MODE" },
					["Rvx"] = { "V-REPLACE (Rvx)", "STTUSLINE_REPLACE_MODE" },

					["s"] = { "SELECT", "STTUSLINE_SELECT_MODE" },
					["S"] = { "S-LINE", "STTUSLINE_SELECT_MODE" },
					[""] = { "S-BLOCK", "STTUSLINE_SELECT_MODE" },

					["c"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },
					["cv"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },
					["ce"] = { "COMMAND", "STTUSLINE_COMMAND_MODE" },

					["r"] = { "PROMPT", "STTUSLINE_CONFIRM_MODE" },
					["rm"] = { "MORE", "STTUSLINE_CONFIRM_MODE" },
					["r?"] = { "CONFIRM", "STTUSLINE_CONFIRM_MODE" },
					["x"] = { "CONFIRM", "STTUSLINE_CONFIRM_MODE" },
				},
				mode_colors = {
					["STTUSLINE_NORMAL_MODE"] = { fg = colors.blue },
					["STTUSLINE_INSERT_MODE"] = { fg = colors.green },
					["STTUSLINE_VISUAL_MODE"] = { fg = colors.purple },
					["STTUSLINE_NTERMINAL_MODE"] = { fg = colors.gray },
					["STTUSLINE_TERMINAL_MODE"] = { fg = colors.cyan },
					["STTUSLINE_REPLACE_MODE"] = { fg = colors.red },
					["STTUSLINE_SELECT_MODE"] = { fg = colors.magenta },
					["STTUSLINE_COMMAND_MODE"] = { fg = colors.yellow },
					["STTUSLINE_CONFIRM_MODE"] = { fg = colors.yellow },
				},
				auto_hide_on_vim_resized = true,
			},
			update = function(configs)
				local mode_code = api.nvim_get_mode().mode
				local mode = configs.modes[mode_code]
				if mode then return { { mode[1], configs.mode_colors[mode[2]] } } end
				return " " .. mode_code .. " "
			end,
			condition = function(configs)
				if configs.auto_hide_on_vim_resized then
					vim.opt.showmode = not (vim.o.columns > 70)
					return not vim.opt.showmode:get()
				end
			end,
		},
		{
			name = "filename",
			event = { "BufEnter", "WinEnter", "TextChangedI", "BufWritePost" },
			user_event = "VeryLazy",
			colors = {
				{},
				{ fg = colors.orange },
			},
			configs = {
				extensions = {
					-- filetypes = { icon, color, filename(optional) },
					filetypes = {
						["NvimTree"] = { "󰙅", colors.red, "NvimTree" },
						["TelescopePrompt"] = { "", colors.red, "Telescope" },
						["mason"] = { "󰏔", colors.red, "Mason" },
						["lazy"] = { "󰏔", colors.red, "Lazy" },
						["checkhealth"] = { "", colors.red, "CheckHealth" },
						["plantuml"] = { "", colors.green },
						["dashboard"] = { "", colors.red },
					},

					-- buftypes = { icon, color, filename(optional) },
					buftypes = {
						["terminal"] = { "", colors.red, "Terminal" },
					},
				},
			},
			update = function(configs)
				local filename = vim.fn.expand("%:t")

				local has_devicons, devicons = pcall(require, "nvim-web-devicons")
				local icon, color_icon = nil, nil
				if has_devicons then
					icon, color_icon = devicons.get_icon_color(filename, vim.fn.expand("%:e"))
				end

				if not icon then
					local extensions = configs.extensions
					local buftype = vim.bo.buftype

					local extension = extensions.buftypes[buftype]
					if extension then
						icon, color_icon, filename =
							extension[1], extension[2], extension[3] or filename ~= "" and filename or buftype
					else
						local filetype = vim.bo.filetype
						extension = extensions.filetypes[filetype]
						if extension then
							icon, color_icon, filename =
								extension[1], extension[2], extension[3] or filename ~= "" and filename or filetype
						end
					end
				end

				if filename == "" then filename = "No File" end

				-- check if file is read-only
				if not vim.bo.modifiable or vim.bo.readonly then
					return {
						icon and { icon .. " ", { fg = color_icon } } or "",
						filename,
						{ " ", { fg = colors.red } },
					}
				-- check if unsaved
				elseif vim.bo.modified then
					return {
						icon and { icon .. " ", { fg = color_icon } } or "",
						filename,
						{ " ", { fg = colors.fg } },
					}
				end
				return { icon and { icon .. " ", { fg = color_icon } } or "", filename }
			end,
		},
		{
			name = "git-branch",
			event = "BufEnter",
			user_event = { "VeryLazy", "GitSignsUpdate" },
			configs = {
				icon = "",
			},
			colors = { fg = colors.pink },
			space = {
				get_branch = function()
					local git_dir = vim.fn.finddir(".git", ".;")
					if git_dir ~= "" then
						local head_file = io.open(git_dir .. "/HEAD", "r")
						if head_file then
							local content = head_file:read("*all")
							head_file:close()
							-- branch name  or commit hash
							return content:match("ref: refs/heads/(.-)%s*$") or content:sub(1, 7) or ""
						end
						return ""
					end
					return ""
				end,
			},
			update = function(configs, space)
				local branch = space.get_branch()
				return branch ~= "" and configs.icon .. " " .. branch or ""
			end,
			condition = function() return vim.bo.buflisted end,
		},
		{
			name = "git-diff",
			event = { "BufWritePost", "VimResized", "BufEnter" },
			user_event = "GitSignsUpdate",
			colors = {
				{ fg = colors.tokyo_diagnostics_hint },
				{ fg = colors.tokyo_diagnostics_info },
				{ fg = colors.tokyo_diagnostics_error },
			},
			configs = {
				icons = {
					added = "",
					changed = "",
					removed = "",
				},
				order = { "added", "changed", "removed" },
			},
			update = function(configs)
				local git_status = vim.b.gitsigns_status_dict

				local order = configs.order
				local icons = configs.icons

				local should_add_spacing = false
				local result = {}
				for index, v in ipairs(order) do
					if git_status[v] and git_status[v] > 0 then
						if should_add_spacing then
							result[index] = " " .. icons[v] .. " " .. git_status[v]
						else
							should_add_spacing = true
							result[index] = icons[v] .. " " .. git_status[v]
						end
					else
						result[index] = ""
					end
				end
				return result
			end,
			condition = function() return vim.b.gitsigns_status_dict ~= nil and vim.o.columns > 70 end,
		},
		"%=",
		{
			name = "diagnostics",
			event = "DiagnosticChanged",
			colors = {
				{ fg = colors.tokyo_diagnostics_error },
				{ fg = colors.tokyo_diagnostics_warn },
				{ fg = colors.tokyo_diagnostics_hint },
				{ fg = colors.tokyo_diagnostics_info },
			},
			configs = {
				icons = {
					ERROR = "",
					INFO = "",
					HINT = "󰌵",
					WARN = "",
				},
				order = { "ERROR", "WARN", "INFO", "HINT" },
			},
			update = function(configs)
				local result = {}

				local icons = configs.icons
				local order = configs.order

				local should_add_spacing = false
				for index, key in ipairs(order) do
					local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[key] })

					if count > 0 then
						if should_add_spacing then
							result[index] = " " .. icons[key] .. " " .. count
						else
							should_add_spacing = true
							result[index] = icons[key] .. " " .. count
						end
					else
						result[index] = ""
					end
				end
				return result
			end,
			condition = function()
				return vim.bo.filetype ~= "lazy"
					and not api.nvim_buf_get_name(0):match("%.env$")
			end,
		},
		{
			name = "lsps-formatters",
			event = { "LspAttach", "LspDetach", "BufWritePost", "BufEnter", "VimResized" },
			colors = { fg = colors.magenta },
			update = function()
				local buf_clients = vim.lsp.get_clients({bufnr=0})
				local server_names = {}
				local has_null_ls = false
				local ignore_lsp_servers = {
					["null-ls"] = true,
					["copilot"] = true,
				}

				for _, client in pairs(buf_clients) do
					local client_name = client.name
					if not ignore_lsp_servers[client_name] then server_names[#server_names + 1] = client_name end
				end

				if package.loaded["null-ls"] then
					local null_ls = nil
					has_null_ls, null_ls = pcall(require, "null-ls")

					if has_null_ls then
						local buf_ft = vim.bo.filetype
						local null_ls_methods = {
							null_ls.methods.DIAGNOSTICS,
							null_ls.methods.DIAGNOSTICS_ON_OPEN,
							null_ls.methods.DIAGNOSTICS_ON_SAVE,
							null_ls.methods.FORMATTING,
						}

						local get_null_ls_sources = function(methods, name_only)
							local sources = require("null-ls.sources")
							local available_sources = sources.get_available(buf_ft)

							methods = type(methods) == "table" and methods or { methods }

							-- methods = nil or {}
							if #methods == 0 then
								if name_only then
									return vim.tbl_map(function(source) return source.name end, available_sources)
								end
								return available_sources
							end

							local source_results = {}

							for _, source in ipairs(available_sources) do
								for _, method in ipairs(methods) do
									if source.methods[method] then
										if name_only then
											source_results[#source_results + 1] = source.name
										else
											source_results[#source_results + 1] = source
										end
										break
									end
								end
							end

							return source_results
						end

						local null_ls_builtins = get_null_ls_sources(null_ls_methods, true)
						vim.list_extend(server_names, null_ls_builtins)
					end
				end

				if package.loaded["conform"] then
					local has_conform, conform = pcall(require, "conform")
					if has_conform then
						vim.list_extend(
							server_names,
							vim.tbl_map(function(formatter) return formatter.name end, conform.list_formatters(0))
						)
						if has_null_ls then server_names = vim.fn.uniq(server_names) end
					end
				end

				return #server_names > 0 and table.concat(server_names, ", ") or "NO LSP, FORMATTER  "
			end,
			condition = function() return vim.o.columns > 70 end,
		},
		{
			name = "copilot-loading",
			user_event = {
				"SttuslineCopilotStatusUpdate",
			},
			init = function(configs)
				local nvim_exec_autocmds = api.nvim_exec_autocmds
				local schedule = vim.schedule
				local sttusline_copilot_timer = uv.new_timer()
				api.nvim_create_autocmd("InsertEnter", {
					once = true,
					desc = "Init copilot status",
					callback = function()
						local cp_api_ok, cp_api = pcall(require, "copilot.api")
						if cp_api_ok then
							cp_api.register_status_notification_handler(function(data)
								schedule(function()
									-- don't need to get status when in TelescopePrompt
									if vim.bo.buftype == "prompt" then return end
									g.sttusline_copilot_status = string.lower(data.status or "")

									if g.sttusline_copilot_status == "inprogress" then
										sttusline_copilot_timer:start(
											0,
											math.floor(1000 / configs.fps),
											vim.schedule_wrap(
												function()
													nvim_exec_autocmds(
														"User",
														{ pattern = "SttuslineCopilotStatusUpdate", modeline = false }
													)
												end
											)
										)
										return
									end
									sttusline_copilot_timer:stop()
									nvim_exec_autocmds(
										"User",
										{ pattern = "SttuslineCopilotStatusUpdate", modeline = false }
									)
								end)
							end)
						end
					end,
				})
			end,
			configs = {
				icons = {
					normal = "",
					error = "",
					warning = "",
					inprogress = { "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥" },
				},
				fps = 3, -- should be 3 - 5
			},
			space = function(configs)
				local current_inprogress_index = 0
				local icons = configs.icons
				return {
					get_icon = function()
						if g.sttusline_copilot_status == "inprogress" then
							current_inprogress_index = current_inprogress_index < #icons.inprogress
									and current_inprogress_index + 1
								or 1
							return icons.inprogress[current_inprogress_index]
						else
							current_inprogress_index = 0
							return icons[g.sttusline_copilot_status] or g.sttusline_copilot_status or ""
						end
					end,
					check_status = function()
						local cp_client_ok, cp_client = pcall(require, "copilot.client")
						if not cp_client_ok then
							g.sttusline_copilot_status = "error"
							require("sttusline.utils.notify").error("Cannot load copilot.client")
							return
						end

						local copilot_client = cp_client.get()
						if not copilot_client then
							g.sttusline_copilot_status = "error"
							return
						end

						local cp_api_ok, cp_api = pcall(require, "copilot.api")
						if not cp_api_ok then
							g.sttusline_copilot_status = "error"
							require("sttusline.utils.notify").error("Cannot load copilot.api")
							return
						end

						cp_api.check_status(copilot_client, {}, function(cserr, status)
							if cserr or not status.user or status.status ~= "OK" then
								g.sttusline_copilot_status = "error"
								return
							end
						end)
					end,
				}
			end,
			update = function(_, space)
				if package.loaded["copilot"] then space.check_status() end
				return space.get_icon()
			end,
		},
		{
			name = "indent",
			update_group = "BUF_WIN_ENTER",
			colors = { fg = colors.cyan },
			update = function() return "Tab: " .. vim.bo.shiftwidth .. "" end,
		},
		{
			name = "encoding",
			update_group = "BUF_WIN_ENTER",
			configs = {
				["utf-8"] = "󰉿",
				["utf-16"] = "󰊀",
				["utf-32"] = "󰊁",
				["utf-8mb4"] = "󰊂",
				["utf-16le"] = "󰊃",
				["utf-16be"] = "󰊄",
			},
			colors = { fg = colors.yellow },
			update = function(configs)
				local enc = vim.bo.fenc ~= "" and vim.bo.fenc or vim.o.enc
				return configs[enc] or enc
			end,
		},
		{
			name = "pos-cursor",
			update_group = "CURSOR_MOVING",
			colors = { fg = colors.fg },
			update = function()
				local pos = api.nvim_win_get_cursor(0)
				return pos[1] .. ":" .. pos[2]
			end,
		},
		{
			name = "pos-cursor-progress",
			update_group = "CURSOR_MOVING",
			configs = {
				chars = { "_", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
			},
			padding = 0,
			colors = { fg = colors.orange },
			update = function(configs)
				local line = vim.fn.line
				return configs.chars[math.ceil(line(".") / line("$") * #configs.chars)] or ""
			end,
		},
	},
}

M.setup = function(user_opts)
	M.apply_user_config(user_opts)

	if type(configs.on_attach) == "function" then
		local create_update_group = require("sttusline.api").create_update_group
		configs.on_attach(create_update_group)
	end

	if configs.statusline_color then
		require("sttusline.highlight").set_hl("StatusLine", { bg = user_opts.statusline_color })
	end

	return configs
end

M.apply_user_config = function(opts, target)
	target = target or configs
	if type(opts) == "table" then
		for k, v in pairs(opts) do
			if type(v) == type(target[k]) then
				-- if is table and not array
				if type(v) == "table" and v[1] == nil and next(v) then
					M.apply_user_config(v, target[k])
				else
					target[k] = v
				end
			elseif not target[k] then
				target[k] = v
			end
		end
	end
	return target
end

M.get_config = function() return configs end

return M
