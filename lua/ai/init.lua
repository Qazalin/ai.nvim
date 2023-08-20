local curl = require("plenary.curl")
local popup = require("plenary.popup")
local M = {}

M.setup = function(opts)
	print("this thing isn't conifgurable yet lol")
end

local config = {}

local api_key = vim.fn.system("~/secrets/chatgpt_api_key.sh"):gsub("\n", "")
local openai_params = {
	model = "gpt-3.5-turbo",
	frequency_penalty = 0,
	presence_penalty = 0,
	temperature = 0,
	top_p = 1,
	n = 1,
}

M.send_api_request = function(question)
	local messages = {
		{
			role = "system",
			content = "You're a super smart programmer",
		},
		{
			role = "user",
			content = question,
		},
	}

	local json = vim.tbl_extend("force", openai_params, {
		messages = messages,
	})

	local body = vim.fn.json_encode(json)
	local res = curl.post("https://api.openai.com/v1/chat/completions", {
		body = body,
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = "Bearer " .. api_key,
		},
		timeout = 50000,
	})

	local data = vim.fn.json_decode(res.body)
	if data == nil then
		error("No response from API")
		return
	end
	local message = data.choices[1].message.content
	for s in message:gmatch("[^\r\n]+") do
		table.insert(lines, s)
	end
	vim.api.nvim_buf_set_lines(window.bufnr, -1, -1, false, lines)
end

M._create_window = function()
	local width = config.width or 80
	local height = config.height or 10
	local borderchars = config.borderchars or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	local bufnr = vim.api.nvim_create_buf(false, false)

	local AI_win_id, win = popup.create(bufnr, {
		title = "ai",
		highlight = "AIWindow",
		col = math.floor((vim.o.columns - width) / 2),
		line = math.floor(((vim.o.lines - height) / 2) - 1),
		minwidth = width,
		minheight = height,
		borderchars = borderchars,
	})

	vim.api.nvim_win_set_option(win.border.win_id, "winhl", "Normal:EthWindowBorder")
	vim.api.nvim_command("startinsert")

	return {
		win_id = AI_win_id,
		bufnr = bufnr,
	}
end

M.ask = function()
	local window = M._create_window()
	AI_bufh = window.bufnr

	vim.api.nvim_buf_set_option(AI_bufh, "filetype", "markdown")

	vim.api.nvim_buf_set_keymap(AI_bufh, "n", "q", "<Cmd>lua require('ai').toggle_quick_menu()<CR>", { silent = true })
	vim.api.nvim_buf_set_keymap(
		AI_bufh,
		"n",
		"<ESC>",
		"<Cmd>lua require('ai').toggle_quick_menu()<CR>",
		{ silent = true }
	)

	vim.api.nvim_buf_set_keymap(
		AI_bufh,
		"n",
		"<leader>r",
		"<cmd>lua require('ai').send_api_request(require('ai')._get_window_contents())<cr>",
		{ noremap = true, silent = true }
	)
end

M._get_window_contents = function()
	local lines = vim.api.nvim_buf_get_lines(AI_bufh, 0, -1, false)
	local contents = table.concat(lines, "\n")
	return contents
end

M._toggle_window = function()
	if AI_win_id ~= nil then
		vim.api.nvim_win_close(AI_win_id, true)
		vim.api.nvim_buf_delete(AI_bufh, { force = true })
		AI_win_id = nil
	else
		M._create_window()
	end
end

return M
