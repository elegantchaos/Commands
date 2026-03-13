## Project Specific Rules

- This repository is a Swift package for defining reusable command models and SwiftUI command UI. 

## Standard Rules

- Follow the shared engineering baseline in ~/.local/share/agents/instructions/COMMON.md, ~/.local/share/agents/instructions/Principles.md, ~/.local/share/agents/instructions/Good Code.md, ~/.local/share/agents/instructions/Validation.md, ~/.local/share/agents/instructions/Trusted Sources.md, and ~/.local/share/agents/instructions/languages/Swift.md.
- Keep changes minimal, focused, and aligned with a single source of truth; fix root causes instead of layering workarounds.
- For non-UI code, use red/green TDD and update or add tests with behavior changes. For UI code, create previews and keep UI-facing logic on the main actor where appropriate.
- Run the relevant validation workflow before finishing, prefer the shared validation workflow skill at ~/.local/share/skills/validation-flow-skill/SKILL.md when applicable, and report every skipped check with a reason.
- Prefer trusted primary sources for technical decisions and research; use ~/.local/share/agents/instructions/Trusted Sources.md as the source-selection policy.
- Do not add compatibility shims, wrappers, or aliases unless the user explicitly asks for compatibility support.
- Keep interfaces explicit and small, avoid hidden coupling and surprising side effects, localize user-facing strings, and use modern Swift features that fit the package's current toolchain and platform targets.
- Add compact documentation comments for each type, method, and member when changing Swift sources, with comments that explain intent rather than restating names.
- Use the shared Swift specialist skills when needed: ~/.local/share/skills/Swift-Concurrency-Agent-Skill/swift-concurrency-pro/SKILL.md, ~/.local/share/skills/Swift-Testing-Agent-Skill/swift-testing-pro/SKILL.md, ~/.local/share/skills/SwiftUI-Agent-Skill/swiftui-pro/SKILL.md, ~/.local/share/skills/SwiftData-Agent-Skill/swiftdata-pro/SKILL.md.
- Use the shared git workflow skill at ~/.local/share/skills/codex-git-skill/SKILL.md and the shared GitHub workflow skill at ~/.local/share/skills/codex-github-skill/SKILL.md for repository and GitHub operations.
- Do not perform irreversible destructive actions without explicit approval. If unexpected workspace changes appear, pause and confirm direction before proceeding.

To refresh this file, use the ~/.local/share/skills/refresh-agents-skill/SKILL.md skill.
