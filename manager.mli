(** Manager runs the entire flow of the software on a timer, from
    scanning tweets, to extracting stock tickers, to determining whether
    to buy or sell stocks *)

(** Helper function to structure JSON properly when writing new tweets
    to file*)
val build_json : string -> string

(** Helper regex to replace line breaks with the empty string (keeps
    JSON formatted properly)*)
val trim : string -> string

(** Takes a [stock] as input, and writes it to watch.json*)
val watching_write : string -> unit

(** Takes a [stock] as input, and removes it from watch.json*)
val watching_remove : string -> unit

(** Takes a [stock] as input, and writes it to portfolio.json*)
val portfolio_write : string -> unit

(** Takes a [stock] as input, and removes it from portfolio.json*)
val portfolio_remove : string -> unit

(** Takes a [stock] as input, sells the stock (using Trader)*)
val sell_stock : Core_kernel__.Import.string -> bool -> unit

(** Takes a [stock] as input, and uses Algo to determine whether or not
    to sell the stock, add to watch list, or neither*)
val handle_selling : Core_kernel__.Import.string -> bool * bool -> unit

(** Takes a [stock] as input, and uses Algo to determine whether or not
    to buy the stock*)
val handle_buying : Core_kernel__.Import.string -> bool -> unit

(** Takes a [stock] as input, and uses Algo to determine whether or not
    to buy the stock back from watchlist*)
val handle_buyback : Core_kernel__.Import.string -> bool -> unit

(** Scans entire portfolio, checking whether or not to sell stocks based
    on market conditions (dictated by config.json, along with Algo)*)
val sell_check : unit -> unit

(** Scans entire watchlist, checking whether or not to buy back stocks
    based on market conditions (dictated by config.json, along with
    Algo)*)
val watch_check : unit -> unit

(** Takes a JSON [body] as input, and returns a JSON structure that is
    ready to be written to accounts.json*)
val json_build : string -> string -> string -> string

(** Simply prints a message notifying the user of a [tweet_prior] and a
    [current_tweet] from a user ([handle])*)
val tweet_result : string -> string -> string -> unit

(** Utilizes YoJSON to return portfolio.json as an easily parsable
    object*)
val get_portfolio : unit -> Yojson.Basic.t list

(** Takes a tweet as input, and returns the stock ticker if and only if
    the current tweet does not equal the prior tweet (in other words, it
    is a new tweet), the tweet contains a stock that our trading
    algorithm approves, and the tweet is bullish (otherwise, an empty
    string is returned). This indicates whether or not the tweet
    contains a stock that we will proceed to purchase. *)
val is_ready_ticker : string -> string -> string

(** Calls Trade to check whether or not the current API bearers and
    access keys are valid. If they are expired, new ones are generated.*)
val trade_refresh : unit -> unit

(** Manager.scanning runs this function: Scans through every account in
    accounts.json, and updates all with most recent tweet If the tweets
    are new, bullish, and match our market standards, we buy! *)
val start : unit -> unit

(** Called from Manager.run, executes 3 functions: start (to search for
    tweets and potentially buying stocks), sell_check (to check for
    selling stocks), and watch_check (for potentially re-buying stocks
    on watch list)*)
val scanning : unit -> unit

(** Runs on a timer (every 5 seconds, infinitely). Every iteration,
    ensures that there are sufficient funds, that the bearer tokens are
    valid and active, and then proceeds to call Manager.scanning, to
    parse tweet and stock information *)
val run : unit -> 'a

(** Called from main.ml to begin execution of the software*)
val create : unit -> 'a
