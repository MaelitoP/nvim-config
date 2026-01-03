local M = {}

local cmds = { "nu!", "rnu!", "nonu!" }
local current_index = 1

function M.toggle_numbering()
  current_index = current_index % #cmds + 1
  vim.cmd("set " .. cmds[current_index])
  local signcolumn_setting = "auto"
  if cmds[current_index] == "nonu!" then
    signcolumn_setting = "yes:4"
  end
  vim.opt.signcolumn = signcolumn_setting
end

--- Toggle inlay hints
function M.toggle_inlay_hint()
  local is_enabled = vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(not is_enabled)
end

-- Toggle flow state mode, Disable most of the unnecessary plugins
local state = 0
function M.toggle_flow()
  if state == 0 then
    vim.o.relativenumber = false
    vim.o.number = false
    vim.opt.signcolumn = "yes:4"
    vim.o.winbar = ""
    state = 1
  else
    vim.o.relativenumber = true
    vim.o.number = true
    vim.opt.signcolumn = "auto"
    vim.o.winbar = "%{%v:lua.dropbar.get_dropbar_str()%}"
    state = 0
  end
end

-- Autocommands
local autocmd = vim.api.nvim_create_autocmd
vim.b.miniindentscope_disable = true
autocmd("FileType", {
  pattern = "help",
  desc = "Disable 'mini.indentscope' help page",
  callback = function(data)
    vim.b[data.buf].miniindentscope_disable = true
  end,
})

-- Rate-limited LSP progress notifications
local lsp_progress_last_update = 0
local LSP_PROGRESS_THROTTLE_MS = 100

autocmd("LspProgress", {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local now = vim.uv.hrtime()
    local elapsed_ms = (now - lsp_progress_last_update) / 1e6

    -- Always show completion, throttle progress updates
    local is_complete = ev.data.params.value.kind == "end"

    if is_complete or elapsed_ms >= LSP_PROGRESS_THROTTLE_MS then
      lsp_progress_last_update = now
      local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
      vim.notify(vim.lsp.status(), "info", {
        id = "lsp_progress",
        title = "LSP Progress",
        opts = function(notif)
          notif.icon = is_complete and " "
              or spinner[math.floor(now / (1e6 * 80)) % #spinner + 1]
        end,
      })
    end
  end,
})

return M
