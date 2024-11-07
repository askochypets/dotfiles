return {
	{
		"mfussenegger/nvim-dap",
		optional = true,
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = function(_, opts)
					opts.ensure_installed = opts.ensure_installed or {}
					table.insert(opts.ensure_installed, "js-debug-adapter")
				end,
			},
		},
		opts = function()
			local dap = require("dap")
			if not dap.adapters["pwa-node"] then
				-- Setup for `pwa-node` adapter
				dap.adapters["pwa-node"] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = {
							-- Update this path to point to the correct `js-debug-adapter` location
							require("mason-registry").get_package("js-debug-adapter"):get_install_path()
								.. "/js-debug/src/dapDebugServer.js",
							"${port}",
						},
					},
				}
			end

			-- Ensure `node` adapter is mapped to `pwa-node`
			if not dap.adapters["node"] then
				dap.adapters["node"] = function(cb, config)
					if config.type == "node" then
						config.type = "pwa-node"
					end
					local nativeAdapter = dap.adapters["pwa-node"]
					if type(nativeAdapter) == "function" then
						nativeAdapter(cb, config)
					else
						cb(nativeAdapter)
					end
				end
			end

			-- Supported JavaScript and TypeScript filetypes
			local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

			-- Configure dap for each JavaScript-related filetype
			for _, language in ipairs(js_filetypes) do
				dap.configurations[language] = {
					{
						-- Launch configuration to start the npm script
						type = "pwa-node",
						request = "launch",
						name = "tsx API debugger",
						cwd = "${workspaceFolder}/api",
						program = "src/server.ts",
						runtimeExecutable = "tsx",
						-- runtimeArgs = { "start", "--workspace=api" }, -- Specify your npm script here
						console = "integratedTerminal", -- Run command in integrated terminal
					},
					{
						-- Launch configuration to start the npm script
						type = "pwa-node",
						request = "launch",
						name = "Start API debugger",
						cwd = "${workspaceFolder}",
						runtimeExecutable = "npm",
						runtimeArgs = { "start", "--workspace=api" }, -- Specify your npm script here
						console = "integratedTerminal", -- Run command in integrated terminal
					},
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
						console = "integratedTerminal", -- Use Neovim's integrated terminal for `node-terminal` requirement
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Auto Attach to Process",
						cwd = vim.fn.getcwd(),
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach to Process",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
					-- Divider for the launch.json derived configs
					{
						name = "----- ↓ launch.json configs ↓ -----",
						type = "",
						request = "launch",
					},
				}
			end
		end,
	},
}
