(** Command Line Interface to fill certain feilds in config.json *)

(** Unit function which asks for user name and prints project intro *)
val twitter_stock_client_instructions : unit -> unit

(** Unit function which prints sentiment analysis instructions, set
    equal to sentiment analysis api key *)
val sentiment_api_key : unit -> string

(** Unit function which prints TD Ameritrade info *)
val td_instructions : unit -> unit

(** Unit function which prints TD Ameritrade api key instructions, set
    equal to TD Ameritrade api key *)
val td_api_key : unit -> string

(** Unit function which prints TD Ameritrade refresh token instructions,
    set equal to TD Ameritrade refresh token *)
val td_refresh_token : unit -> string

(** Unit function which prints Twitter bearer instructions, set equal to
    Twitter bearer *)
val twitter_bearer : unit -> string

(** Unit function which prints email info *)
val alert_instructions : unit -> unit

(** Unit function which prints email destination instructions, set equal
    to email address destination *)
val email_address_destination : unit -> string

(** Unit function which prints high frequency trading algorithm info *)
val algo_instructions : unit -> unit

(** Unit function which prints algorithm trailing stop loss
    instructions, set equal to trailing stop loss number as string *)
val algo_trailing_stop : unit -> string

(** Unit function which prints algorithm max price instructions, set
    equal to max price as string *)
val algo_max_price : unit -> string

(** Unit function which prints algorithm max volume instructions, set
    equal to max volume as string *)
val algo_max_volume : unit -> string

(** Unit function which prints algorithm profit target instructions, set
    equal to profit target as string *)
val algo_profit_target : unit -> string

(** Unit function which prints algorithm error margin instructions, set
    equal to error margin number as string *)
val algo_error_margin : unit -> string

(** Unit function which prints algorithm capital limit instructions, set
    equal to capital limit as string *)
val algo_capital_limit : unit -> string

(** Calls all helper functions and rewrites config.json *)
val build_config : unit
