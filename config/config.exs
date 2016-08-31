use Mix.Config

config :logger,
  backends: [:console, LoggerStarter.Slack]

config :logger, LoggerStarter.Slack,
  level: :warn,
  hook_url: System.get_env("SLACK_HOOK_URL"),
  channel: "@tuvistavie",
  username: "logger_starter"
