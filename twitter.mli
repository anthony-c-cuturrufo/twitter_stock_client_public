(**
Twitter Module to scrape given Twitter accounts (accounts.json), and return any relevant stocks found within recent Tweets.
*)

(** Endpoint for Twitter Tweet Retrieval API *)
val api_endpoint : string

(** Bearer Token for Twitter API *)
val bearer : string

(** Retrieves a json object containing a list of the most recent tweets
   by a given user Parameters: [user] the Twitter handle (username) of
   the user to retrieve tweets from Returns: A json object, containing a
   list of recent tweets (past 7 days) from the user Notes: List will be
   in chronological order (most recent tweet being first element) *)
val latest_tweet_json : string -> string

(** Retrieves a string list of the most recent tweets by a given user
   Parameters: [user] the Twitter handle (username) of the user to
   retrieve tweets from [num] number of desired tweets (if exceeds
   number of user tweets in past 7 days, all tweets will be returned)
   Returns: A string list, containing a list of recent tweets (past 7
   days) from the user Notes: List will be in chronological order (most
   recent tweet being first element) *)
val latest_tweets : string -> int -> string list

(** Retrieves a string of the lastest tweet from a given user Parameters:
   [user] the Twitter handle (username) of the user to retrieve tweets
   from Returns: A string, containing the single most recent tweet from
   a user Notes: Returns "" (empty string) if no tweets from user within
   7 days *)
val most_recent_tweet : string -> string

(** Attempts to extract ticker symbol from a given tweet Parameters:
   [tweet] string, given tweet to search Returns: A string, containing
   the ticker symbol (if any) found within the tweet Empty string if no
   tickers are found Note: Duplicates functionality of Twitter extended
   entities, in order to reduce API calls *)
val get_tickers : string -> string
