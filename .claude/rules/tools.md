# Development Tools

## Sosumi MCP (Apple Documentation & WWDC)
When looking up Apple API documentation, best practices, or implementation guidance, use the sosumi MCP tools:
- `searchAppleDocumentation` / `fetchAppleDocumentation` for API docs
- `fetchAppleVideoTranscript` for WWDC session transcripts
- `fetchExternalDocumentation` for other Apple developer resources

Always prefer newer WWDC sessions — newer sessions may supersede older APIs and best practices. When multiple sessions cover the same topic, prioritize the most recent one and verify that older recommendations haven't been replaced.

## Linearis CLI (Linear Integration)
Use Linearis to interact with Linear.app issue tracking.

```bash
linearis issues list                        # List issues
linearis issues search "keyword"            # Search for issues
linearis issues read $TicketName            # Get issue details
linearis issues create "Issue title"        # Create an issue
```
