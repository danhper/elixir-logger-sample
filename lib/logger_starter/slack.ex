defmodule LoggerStarter.Slack do
  use GenEvent

  defstruct [format: nil, metadata: nil, level: nil, hook_url: nil, channel: nil, username: nil]

  def init(__MODULE__) do
    {:ok, configure([], %__MODULE__{})}
  end

  def handle_event({_level, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, _, _}}, %{level: log_level} = state) do
    if meet_level?(level, log_level) do
      post_to_slack(level, msg, state)
    end

    {:ok, state}
  end

  defp meet_level?(_lvl, nil), do: true
  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  def handle_call({:configure, opts}, state) do
    {:ok, :ok, configure(opts, state)}
  end

  defp configure(opts, state) do
    opts =
      Application.get_env(:logger, __MODULE__, [])
      |> Keyword.merge(opts)
    Application.put_env(:logger, __MODULE__, opts)

    Map.merge(state, Enum.into(opts, %{}))
  end

  defp post_to_slack(level, message, %{hook_url: hook_url} = state) do
    headers = [{"Content-Type", "application/json"}]
    payload = make_slack_payload(level, message, state)
    :hackney.post(hook_url, headers, payload)
  end

  defp make_slack_payload(level, message, %{channel: channel, username: username}) do
    icon = slack_icon(level)
    ~s({"channel": "#{channel}", "username": "#{username}", "text": "#{message}", "icon_emoji": "#{icon}"})
  end

  defp slack_icon(:debug), do: ":speaker:"
  defp slack_icon(:info), do: ":information_source:"
  defp slack_icon(:warn), do: ":warning:"
  defp slack_icon(:error), do: ":exclamation:"
end
