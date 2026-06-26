return {
  {
    "mfussenegger/nvim-lint",
    name = "lint",
    ft = "php",
    config = function()
      local lint = require("lint")

      local container_cache = {}

      local function find_root(bufnr)
        local name = vim.api.nvim_buf_get_name(bufnr)
        local dir = (name ~= "" and vim.fs.dirname(name)) or vim.fn.getcwd()
        while dir do
          if vim.uv.fs_stat(dir .. "/tools/phpstan-ide") then
            return dir
          end
          local parent = vim.fs.dirname(dir)
          if parent == dir then
            return nil
          end
          dir = parent
        end
      end

      local function php_cli_container(root)
        if container_cache[root] then
          return container_cache[root]
        end

        local names = vim.fn.systemlist({ "docker", "ps", "--filter", "name=php_cli", "--format", "{{.Names}}" })
        local chosen
        if vim.v.shell_error == 0 then
          if #names == 1 then
            chosen = names[1]
          else
            for _, name in ipairs(names) do
              local mounts = vim.fn.system({
                "docker", "inspect", "--format",
                "{{range .Mounts}}{{println .Source}}{{end}}", name,
              })
              if mounts:find(root, 1, true) then
                chosen = name
                break
              end
            end
          end
        end

        container_cache[root] = chosen
        return chosen
      end

      local phpstan = lint.linters.phpstan
      phpstan.cmd = "docker"
      phpstan.stdin = false
      phpstan.append_fname = true
      phpstan.args = function()
        local container = php_cli_container(find_root(0))
        return {
          "exec", "-i", container,
          "./tools/phpstan-ide", "analyze", "--no-progress", "--error-format=json",
        }
      end

      local builtin_parser = phpstan.parser
      phpstan.parser = function(output, bufnr)
        local ok, result = pcall(builtin_parser, output, bufnr)
        return ok and result or {}
      end

      local function run()
        local bufnr = vim.api.nvim_get_current_buf()
        local root = find_root(bufnr)
        if root and php_cli_container(root) then
          lint.try_lint("phpstan")
        end
      end

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        pattern = "*.php",
        callback = run,
      })

      run()
    end,
  },
}
