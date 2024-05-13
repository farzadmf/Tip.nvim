local M = {}

---@class Tip.config
---@field seconds number
---@field title? string
---@field url? string
---@field display_on_startup? boolean

---@type Tip.config
M.config = {
  seconds = 2,
  title = 'Tip!',
  url = 'https://vtip.43z.one',
  display_on_startup = false,
}

-- https://www.reddit.com/r/neovim/comments/17qdqkt/get_a_handy_tip_when_you_launch_neovim/
-- setup is the initialization function for the carbon plugin
---@param params Tip.config
M.setup = function(params)
  M.config = vim.tbl_deep_extend('force', {}, M.config, params or {})

  local callback = function()
    vim.schedule(function()
      local job = require('plenary.job')

      job
        :new({
          command = 'curl',
          args = { M.config.url },
          on_exit = function(j, exit_code)
            local res = table.concat(j:result())
            if exit_code ~= 0 then
              res = 'Error fetching tip: ' .. res
            end

            -- Ignore '502 Bad Gateway'
            if string.match(res, 'Bad Gateway') then
              return
            end

            pcall(vim.notify, res, M.config.seconds, { title = M.config.title })
          end,
        })
        :start()
    end)
  end

  vim.api.nvim_create_user_command('Tip', callback, {})

  if params.display_on_startup then
    vim.api.nvim_create_autocmd('VimEnter', { callback = callback })
  end
end

return M
