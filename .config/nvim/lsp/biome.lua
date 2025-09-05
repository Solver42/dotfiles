return {
  cmd = { 'biome', 'lsp-proxy' },
  filetypes = {
    'astro',
    'css',
    'graphql',
    'html',
    'javascript',
    'javascriptreact',
    'json',
    'jsonc',
    'svelte',
    'typescript',
    'typescript.tsx',
    'typescriptreact',
    'vue',
  },
  -- root_markers = { 'biome.json' },
  -- Use biome.json, biome.jsonc, or fallback to .git
  root_dir = function(bufnr)
    local fname = vim.api.nvim_buf_get_name(bufnr)

    -- Candidates to search for
    local candidates = { 'biome.json', 'biome.jsonc' }

    -- Check package.json for "biome" field and prioritize it
    local package_json = vim.fs.find('package.json', { path = fname, upward = true })[1]
    if package_json then
      local content = vim.fn.readfile(package_json)
      local joined = table.concat(content, "\n")
      if string.find(joined, '"biome"%s*:') then
        table.insert(candidates, 1, 'package.json')
      end
    end

    -- Try to find any of the candidate files, fallback to .git
    local found = vim.fs.find(candidates, { path = fname, upward = true })[1]
        or vim.fs.find('.git', { path = fname, upward = true })[1]

    return found and vim.fs.dirname(found) or nil
  end,
}
