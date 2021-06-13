(** Contains utility functions used predominantly in Algo *)

(** returns current price of [ticker] *)
val get_current_price : string -> float

(** takes in json list [price_history] directly from http response and
    looks for all occuences of [tag] and returns list of values
    corresponding to tag. Examples of tag can be "high" or "volume"*)
val parse : string -> string -> float list

(** adds [item] to file [csv_name]. Item must formated as a list of
    strings *)
val csv_add : string -> string list -> unit

(** removes first element in the csv [csv_name]. This function is used
    predominantly for testing with the csv files *)
val csv_remove_first : string -> unit

(** find most recent purchase of [ticker] and returns field
    corresponding to [col_number] in file [csv_name] *)
val member_of_last_purchase : string -> int -> string -> string

(** takes a [dict] that maps [ticker] to highest price reached since
    bought. If [current_price] is higher than the max then it replaces
    the highest value with [current_price]. If [ticker] has no mapping,
    then the mapping [ticker] -> [current_price] is added to [dict]*)
val log_high : 'a -> 'b -> ('a, 'b) Hashtbl.t -> unit

(** calculates target by setting to rolling max unless if with a given
    error it is at the high then the target is set to [current_price] +
    [current_price] * [profit_target] *)
val calc_target : float -> float -> float -> float -> float
