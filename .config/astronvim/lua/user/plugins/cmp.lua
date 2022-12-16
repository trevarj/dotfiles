local compare = require("cmp.config.compare")
return {
  sorting = {
    priority_weight = 2,
    comparators = {
      compare.order,
      -- compare.offset,
      compare.exact,
      -- compare.scopes,
      -- compare.score,
      compare.recently_used,
      compare.locality,
      -- compare.kind,
      compare.sort_text,
      -- compare.length,
    },
  },
}
