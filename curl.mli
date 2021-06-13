(** Curl helper functions used in all API requests *)

(** Takes in arguement [p] which is a string tuple list. The function
    turns p into a Cohttp_lwt.Boby string which can be passed into the
    post request *)
val data_map : (string * string) list -> Cohttp_lwt.Body.t

(** Takes in arguement [url] which is a string and [headers] which is a
    Cohttp.Header.t. The function returns the call request as a json in
    a string *)
val get_curl : string -> Cohttp.Header.t -> string

(** Takes in arguement [url] which is a string, [headers] which is a
    Cohttp.Header.t, and [body] which is a Cohttp_lwt__.Body.t which
    stands for the data passed with e post request. The function returns
    the post request as a json in a string *)
val get_curl_data :
  string -> Cohttp.Header.t -> Cohttp_lwt__.Body.t -> string
