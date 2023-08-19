local curl = require("plenary.curl")

local M = {}

local api_key = vim.fn.system("~/secrets/chatgpt_api_key.sh")

local json = {
	model = "gpt-3.5-turbo",
	messages = {
		{
			role = "system",
			content = "You are a helpful assistant.",
		},
		{
			role = "user",
			content = "Hello!",
		},
	},
}

local body = vim.fn.json_encode(json)
local res = curl.post("https://api.openai.com/v1/chat/completions", {
	body = body,
	headers = {
		["Content-Type"] = "application/json",
		["Authorization"] = "Bearer " .. api_key,
	},
})

print(res.status)
print(vim.inspect(res))
data = vim.fn.json_decode(res.body).json
print(vim.inspect(data))
