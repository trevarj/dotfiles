import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Fast file search using fd. Finds files by glob pattern. Returns matching file paths sorted by modification time. Respects .gitignore by default.",
  args: {
    pattern: tool.schema.string().describe("Glob pattern to match files against (e.g. '*.ts', '**/*.test.ts')"),
    path: tool.schema.string().optional().describe("Directory to search in. Defaults to the current working directory."),
    type: tool.schema.enum(["file", "directory", "symlink"]).optional().describe("Filter by file type"),
    maxDepth: tool.schema.number().int().positive().optional().describe("Maximum directory depth to search"),
  },
  async execute(args, context) {
    const searchPath = args.path || context.directory

    const cmd = [
      "fd",
      "--glob",
      "--color", "never",
      args.pattern,
      searchPath,
    ]

    if (args.type) {
      cmd.splice(1, 0, "--type", args.type)
    }

    if (args.maxDepth !== undefined) {
      cmd.splice(1, 0, "--max-depth", String(args.maxDepth))
    }

    const proc = Bun.spawnSync({
      cmd,
      stdout: "pipe",
      stderr: "pipe",
    })

    const stdout = new TextDecoder().decode(proc.stdout)

    if (proc.exitCode !== 0) {
      const stderr = new TextDecoder().decode(proc.stderr)
      return `Error running fd: ${stderr}`
    }

    return stdout || "No files found."
  },
})
