local M = {}

M.setup = function(opts)
    print("this thing isn't conifgurable yet lol")
end

local model = "gpt-3.5-turbo"
local api_key = vim.fn.system("~/secrets/chatgpt_api_key.sh"):gsub("\n", "")
local openai_params = {
    model = "gpt-3.5-turbo",
    frequency_penalty = 0,
    presence_penalty = 0,
    max_tokens = 300,
    temperature = 0,
    top_p = 1,
    n = 1,
}

M.ask = function(question)
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
    })

    local data = vim.fn.json_decode(res.body)
    if data.error then
        print(vim.inspect(data.error))
        return
    end
    local message = data.choices[1].message.content
    print(message)
end
