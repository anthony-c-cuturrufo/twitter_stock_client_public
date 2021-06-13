open Cohttp
open Cohttp_lwt_unix
open Yojson.Basic.Util
open Lwt
open Str

let api_endpoint =
  "https://api.twitter.com/2/tweets/search/recent?query=from:"

let bearer = Config.twitter_bearer

(* Twitter API Documentation:
   https://developer.twitter.com/en/docs/api-reference-index *)

let latest_tweet_json user =
  let body =
    let uri = Uri.of_string (api_endpoint ^ user) in
    let headers =
      Header.init () |> fun h ->
      Header.add h "Authorization" ("Bearer " ^ bearer)
    in
    Client.call ~headers `GET uri >>= fun (resp, body) ->
    body |> Cohttp_lwt.Body.to_string >|= fun body ->
    let code = resp |> Response.status |> Code.code_of_status in
    (code, body)
  in
  match Lwt_main.run body with
  | code, body ->
      if code = 200 then body else failwith "POST request failed"

let latest_tweets user num =
  let json_list =
    latest_tweet_json user |> Yojson.Basic.from_string |> member "data"
    |> to_list
  in
  let rec every_tweet tweet_list tweets_str_list count =
    if count < num then
      match tweet_list with
      | h :: t ->
          every_tweet t
            (tweets_str_list @ [ h |> member "text" |> to_string ])
            (count + 1)
      | [] -> tweets_str_list
    else tweets_str_list
  in
  every_tweet json_list [] 0

let most_recent_tweet user =
  try
    let json_list =
      latest_tweet_json user |> Yojson.Basic.from_string
      |> member "data" |> to_list
    in
    let one_tweet tweet_list =
      match tweet_list with
      | h :: t -> h |> member "text" |> to_string
      | [] -> ""
    in
    one_tweet json_list
  with _ -> ""

let get_tickers tweet =
  let regex_stock = Str.regexp "[$][a-zA-Z]+" in
  let ind =
    try Str.search_forward regex_stock tweet 0 with Not_found -> -1
  in

  if ind > -1 then
    String.sub
      (Str.matched_string tweet)
      1
      (String.length (Str.matched_string tweet) - 1)
  else ""
