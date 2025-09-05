return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust', 'rs' },
  name = "rust-analyzer",
  root_dir = vim.fs.root(0, { "Cargo.toml" }),
}
