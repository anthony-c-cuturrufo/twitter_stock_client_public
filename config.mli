(** Turns the info in config.json into variables *)

(** Represents info in config.json *)
type t = {
  sentiment_api_key : string;
  td_api_key : string;
  td_refresh_token : string;
  td_refresh_date : string;
  td_bearer : string;
  td_bearer_date : string;
  twitter_bearer : string;
  email_address : string;
  email_password : string;
  email_address_destination : string;
  algo_trailing_stop : float;
  algo_max_price : float;
  algo_max_volume : int;
  algo_strategy : string;
  algo_profit_target : float;
  algo_error_margin : float;
  algo_capital_limit : float;
}

(** Converts json file [filename] into a [t] type *)
val make_config : string -> t

(** File config.json as [t] type *)
val config : t

(** Sentiment -> api_key from file config.json *)
val sentiment_api_key : string

(** TD_Ameritrade -> api_key from file config.json *)
val td_api_key : string

(** TD_Ameritrade -> refresh_token from file config.json. Takes string
    arguement [file] so that config.json can be refactored *)
val td_refresh_token : string -> string

(** TD_Ameritrade -> refresh_date from file config.json. Takes string
    arguement [file] so that config.json can be refactored *)
val td_refresh_date : string -> string

(** TD_Ameritrade -> bearer from file config.json. Takes string
    arguement [file] so that config.json can be refactored *)
val td_bearer : string -> string

(** TD_Ameritrade -> bearer_date from file config.json. Takes string
    arguement [file] so that config.json can be refactored *)
val td_bearer_date : string -> string

(** Twitter -> bearer from file config.json *)
val twitter_bearer : string

(** Email -> address from file config.json *)
val email_address : string

(** Email -> password from file config.json *)
val email_password : string

(** Email -> address_destination from file config.json *)
val email_address_destination : string

(** Algo -> trailing_stop from file config.json *)
val algo_trailing_stop : float

(** Algo -> max_price from file config.json *)
val algo_max_price : float

(** Algo -> max_volume from file config.json *)
val algo_max_volume : int

(** Algo -> strategy from file config.json *)
val algo_strategy : string

(** Algo -> profit_target from file config.json *)
val algo_profit_target : float

(** Algo -> error_margin from file config.json *)
val algo_error_margin : float

(** Algo -> capital_limit from file config.json *)
val algo_capital_limit : float

(** Rep-ok function. Makes sure variables which are strings are strings,
    and makes sure Algo variables are in proper bounds *)
val check_configs : unit -> unit
