(** Handles All TD Ameritrade Functions *)

(** Takens in TD Ameritrade api-key as string [apikey] and TD Ameritrade
    refresh token as string [token]. Returns the new bearer token from
    the post request as a string *)
val get_bearer : string -> string -> string

(** Takens in TD Ameritrade api-key as string [apikey] and TD Ameritrade
    refresh token as string [token]. Returns the new access token from
    the post request as a string *)
val get_refresh : string -> string -> string

(** Takens in TD Ameritrade api-key as string [apikey] and TD Ameritrade
    refresh token as string [token]. Checks td_bearer_date in
    config.json and if 25 mintues have passed calls get_bearer function
    and updates the td_bearer and td_bearer_date in config.json *)
val check_bearer : string -> string -> unit

(** Takens in TD Ameritrade api-key as string [apikey] and TD Ameritrade
    refresh token as string [token]. Checks td_refresh_date in
    config.json and if 85 days have passed calls get_refresh function
    and updates the td_refresh_token and td_refresh_date in config.json *)
val check_refresh : string -> string -> unit

(** Takens in TD Ameritrade bearer token as string [bearer]. Returns the
    TD Ameritrade account information assosiated with the bearer token
    as a json in a string *)
val account_info_json : string -> string

(** Represents the accountId and availableFunds parameters in the
    account info json*)
type account_info = {
  account_id : string;
  available_funds : float;
}

(** Converts json [json] into a [account_info] type *)
val account_info_of_json : Yojson.Basic.t -> account_info

(** Converts the json in a string [json] into a [account_info] type *)
val account_from_json : string -> account_info

(** Gs account_id from its corresponding [json] *)
val account_id : string -> string

(** Gets available_funds from its corresponding [json] *)
val available_funds : string -> float

(** Takens in the arguements [order_type], [ticker], and [quantity] as
    strings and builds a json as a string to pass into the post request *)
val order : string -> string -> string -> string

(** Takens in the arguements [order_type], [bearer], [ticker], and
    [quantity] as strings and performs a post request to buy or sell a
    stock. *)
val place_order : string -> string -> string -> string -> string
