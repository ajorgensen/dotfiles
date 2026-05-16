local ok, cinder = pcall(require, 'cinder')
if not ok then
  return
end

cinder.setup({
  provider = 'pi',
  model = 'openai/gpt-5.5',

  profiles = {
    quick = { model = 'openai/gpt-5.4-mini' },
  },
})
