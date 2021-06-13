(** Handles stock information requests and checking if a stock is valid
    defined in config.json *)

(** headers for making request to TD Ameritrade *)
val headers : Cohttp.Header.t

(** Retrieves a json object as a string of the [ticker] info *)
val ticker_info_json : string -> string

(** Gets the price history of a stock from time called. [ticker] must be
    in all caps. Assumes all parameters are valid to make request. See
    API Documentation for help *)
val get_price_history :
  ?period_type:string ->
  ?period:string ->
  ?freq_type:string ->
  ?freq:string ->
  string ->
  string

(** represents info about a stock *)
type info = {
  symbol : string;
  start : float;
  high : float;
  low : float;
  price : float;
  volume : int;
  close : float;
  change : float;
}

(** converts json [j] into an [info] type *)
val info_of_json : Yojson.Basic.t -> info

(** converts json string [json] and the given stock [ticker] into an
    [info] type *)
val from_json : string -> string -> info

(** gets stock price from [ticker] and its corresponding [json] *)
val stock_price : string -> string -> float

(** get stock volume from [ticker] and its corresponding [json]*)
val stock_volume : string -> string -> int

(** checks price of [ticker] in its corresponding [json] to see if it is
    a valid price from config*)
val check_price : string -> string -> bool

(** checks volume of [ticker] in its corresponding [json] to see if it
    is a valid price from config*)
val check_volume : string -> string -> bool

(** checks volume and price of [ticker] in its corresponding [json] to
    see if it is a valid price from config*)
val check_stock : string -> string -> bool
