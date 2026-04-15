"""ScholarBot inference module — agent configuration, variants, and execution.

Both the server and the evaluation notebook import from this module to ensure
they use identical agent behavior. See docs/ARCHITECTURE.md.
"""

from claude_agent_sdk import ClaudeAgentOptions, ClaudeSDKClient, ResultMessage


def get_agent_options(variant: str = "v1-baseline") -> ClaudeAgentOptions:
    """Return agent configuration for a named variant.

    Variants are named configurations representing each improvement attempt.
    See docs/EVAL_GUIDE.md for the variant naming convention and iteration loop.
    """
    if variant == "v1-baseline":
        return ClaudeAgentOptions(
            model="claude-haiku-4-5",
            permission_mode="bypassPermissions",
            allowed_tools=["WebSearch", "WebFetch"],
            system_prompt=(
                "You are ScholarBot, a research assistant. "
                "When asked a question, use web search to find current, accurate information. "
                "Provide a clear answer with cited sources (include URLs)."
            ),
            max_turns=20,
        )

    raise ValueError(f"Unknown variant: {variant}")


async def research(question: str, variant: str = "v1-baseline") -> str:
    """Run a research query against the named agent variant.

    Returns the agent's final answer as a string. Traces are captured
    automatically via mlflow.anthropic.autolog() if enabled by the caller.

    If the agent hits the turn limit or encounters an error, returns an
    empty string. Callers can check the trace for details.
    """
    options = get_agent_options(variant)
    async with ClaudeSDKClient(options=options) as client:
        await client.query(question)
        async for message in client.receive_response():
            if isinstance(message, ResultMessage):
                if message.subtype == "success":
                    return message.result or "[Agent completed but produced no text]"
                return f"[Agent did not complete: {message.subtype}]"
    return "[Agent produced no result]"
