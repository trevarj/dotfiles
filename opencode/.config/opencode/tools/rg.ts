import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Fast content search using ripgrep (rg). Searches file contents with full regex syntax. Returns file paths and line numbers with matches sorted by modification time. Respects .gitignore by default.",
  args: {
    pattern: tool.schema.string().describe("Regular expression pattern to search for in file contents"),
    path: tool.schema.string().optional().describe("Directory to search in. Defaults to the current working directory."),
    include: tool.schema.string().optional().describe("File pattern to include (e.g. '*.js', '*.{ts,tsx}'). Passed to rg --glob."),
  },
  async execute(args, context) {
    const searchPath = args.path || context.directory
    const includeFlag = args.include ? ["--glob", args.include] : []

    const cmd = [
      "rg",
      "--line-number",
      "--no-heading",
      "--color", "never",
      "--sort", "modified",
      ...includeFlag,
      "--",
      args.pattern,
      searchPath,
    ]

    const proc = Bun.spawnSync({
      cmd,
      stdout: "pipe",
      stderr: "pipe",
    })

    const stdout = new TextDecoder().decode(proc.stdout)

    if (proc.exitCode === 1) {
      return "No matches found."
    }

    if (proc.exitCode !== 0) {
      const stderr = new TextDecoder().decode(proc.stderr)
      return `Error running rg: ${stderr}`
    }

    return stdout || "No matches found."
  },
})
