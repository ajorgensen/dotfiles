local M = {}

local method = vim.lsp.protocol.Methods.textDocument_documentHighlight

local function clear_fallback_matches()
    local match_ids = vim.w.reference_highlight_match_ids
    if not match_ids then
        return
    end

    for _, match_id in ipairs(match_ids) do
        pcall(vim.fn.matchdelete, match_id)
    end

    vim.w.reference_highlight_match_ids = nil
end

local function has_document_highlight(bufnr)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client:supports_method(method) then
            return true
        end
    end

    return false
end

local function highlight_current_word()
    local cword = vim.fn.expand("<cword>")
    if cword == nil or cword == "" then
        return
    end

    local pattern = ([[\V\<%s\>]]):format(vim.fn.escape(cword, [[\]]))
    vim.w.reference_highlight_match_ids = {
        vim.fn.matchadd("LspReferenceText", pattern, 10),
    }
end

function M.clear()
    clear_fallback_matches()
    pcall(vim.lsp.buf.clear_references)
end

function M.highlight()
    local bufnr = vim.api.nvim_get_current_buf()

    M.clear()

    if has_document_highlight(bufnr) then
        vim.lsp.buf.document_highlight()
        return
    end

    highlight_current_word()
end

return M
