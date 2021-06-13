(** Handles efficiently updating and writing to JSON files *)

(** Writes a direct message to a file. [message] is the text to write,
    and [file] is the name of the local file to write to *)
val update_json : string -> string -> unit

(** Credit: https://github.com/ocaml-community/yojson/issues/54
    seanpoulter, from GitHub, provided this JSON helper function, which
    is utilized to efficiently update single-layer JSON values *)
val update :
  string ->
  (Yojson.Basic.t option -> Yojson.Basic.t option) ->
  Yojson.Basic.t ->
  Yojson.Basic.t

(** Used as a helper wrapper around the update function. Takes [file] as
    a file name, [field] as the JSON field to edit, and [new_val] as the
    updated value for the JSON field*)
val update_field : string -> string -> string -> unit

(** Used to quickly update TD Ameritrade Bearer key (in config.json)
    upon key expiration*)
val update_td_ameritrade_bearer : string -> string -> unit

(** Used to quickly update TD Ameritrade Refresh date (in config.json)
    upon key expiration*)
val update_td_ameritrade_refresh : string -> string -> unit

(** Used as a helper function to configure the sentiment API keys
    through config.json.*)
val new_sentiment : string -> Yojson.Basic.t -> Yojson.Basic.t

(** Used as a helper function to configure the TDAmeritrade API keys
    through config.json*)
val new_td : string -> string -> Yojson.Basic.t -> Yojson.Basic.t

(** Used as a helper function to configure the Twitter API keys through
    config.json*)
val new_twitter : string -> Yojson.Basic.t -> Yojson.Basic.t

(** Used as a helper function to configure the user's email field
    through config.json*)
val new_email : string -> Yojson.Basic.t -> Yojson.Basic.t

(** Used as a helper function to configure the algo values through
    config.json*)
val algo_update : string -> float -> Yojson.Basic.t -> Yojson.Basic.t

(** Used as a helper function to configure the algo volume through
    config.json*)
val algo_update_volume : int -> Yojson.Basic.t -> Yojson.Basic.t

(** Used as a helper function to configure the entire algo dictionary of
    values through config.json*)
val new_algo :
  float ->
  float ->
  int ->
  float ->
  float ->
  float ->
  Yojson.Basic.t ->
  Yojson.Basic.t

(** Takes all required parameters from user, to fully fill in and
    construct config.json. Required data is in the order of
    [sent_api_key], [td_api], [refresh_token], [twitter_bearer],
    [email_dest], [trailing_stop], [max_price], [max_volume],
    [profit_target], [error], [cap_limit] *)
val add_config :
  string ->
  string ->
  string ->
  string ->
  string ->
  float ->
  float ->
  int ->
  float ->
  float ->
  float ->
  unit

(** Used as a helper to build JSON body when stocks are being appended
    to portfolio or watchlist*)
val build_json : string -> string -> string

(** Used to add a stock to either portfolio, or watch (depending on
    [file]). Takes [ticker_to_add] and appends it as a new stock to the
    [file]*)
val add_stock : string -> string -> unit

(** Used to remove a stock to either portfolio, or watch (depending on
    [file]). Takes [ticker_to_add] and removes the stock from the [file]*)
val remove_stock : string -> string -> unit
