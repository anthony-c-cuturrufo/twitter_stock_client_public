(** Module for analyzing sentiment of a tweet *)

(** helper function which makes the payload for a HTTP Post request. It
    takes the payload generates as a tuple list [(arg, value)] and
    returns a string representation of a json to feed into Cohttp.
    Precondition: [lst] is non-empty *)
val of_json_string : (string * string) list -> string

(** default args for text2data *)
val args : (string * string) list

(** endpoint of text2data *)
val text2data_endpoint : string

(** headers for text2data request *)
val headers : Cohttp.Header.t

(** makes a post request with endpoint, args and [phrase] *)
val get_post : string -> string

(** Checks through response from http post request and returns true if
    DocSentimentPolarity is not equal to "-". This is the sentiment of
    [phrase]*)
val is_bullish : string -> bool
