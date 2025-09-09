return {
	{
		"zbirenbaum/copilot.lua",
		event = "VeryLazy",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					accept = false,
				},
				panel = {
					enabled = false,
				},
				filetypes = {
					markdown = true,
					help = true,
					html = true,
					javascript = true,
					typescript = true,
					go = true,
					["*"] = true,
				},
			})

			local keymap = vim.keymap -- for conciseness
			local api = vim.api -- for conciseness

			keymap.set("i", "<S-Tab>", function()
				if require("copilot.suggestion").is_visible() then
					require("copilot.suggestion").accept()
				else
					api.nvim_feedkeys(api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
				end
			end, {
				silent = true,
			})

			-- Change the foreground color of the inline suggestions to a specific hex code
			api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#ada6a6" })
		end,
	},
}
