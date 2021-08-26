defmodule Aggregator do
  use GenServer

  def start() do
    {:ok, pid} = Client.start

    GenServer.start_link(__MODULE__, %{tweets: %{}, tcp: pid}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def add(tweet) do
    GenServer.cast(__MODULE__, {:add, tweet})
  end

  @impl true
  def handle_cast({:add, tweet}, state) do
    tweets = add_tweet(tweet, state.tweets)

    Client.send_message(state.tcp, "PUBLISH tweeter " <> Poison.encode!(tweet) <> "\n")

    {:noreply, %{tweets: tweets, tcp: state.tcp}}
  end

  defp add_tweet(element, tweets) do
    id = Map.get(element, :id)

    existing_tweet = Map.get(tweets, id)

    if !existing_tweet do
      Map.put(tweets, id, element)
    else
      sentiments_score =
        Map.get(existing_tweet, "sentiments_score", Map.get(element, "sentiments_score", 0.0))

      engagement_score =
        Map.get(existing_tweet, "engagement_score", Map.get(element, "engagement_score", 0.0))

      existing_tweet = Map.put(existing_tweet, "sentiments_score", sentiments_score)
      existing_tweet = Map.put(existing_tweet, "engagement_score", engagement_score)

      {user, message} = Map.pop(existing_tweet, "user")

      DB.save_one(message, user)

      Map.put(tweets, existing_tweet["id"], existing_tweet)
    end
  end
end
