open Yojson.Basic.Util

(* Writes a given message to a named file message: message to write to
   file (string) file: name of file to write to (string) *)
let update_json message file =
  let () =
    (* Write message to file *)
    let oc = open_out file in
    (* create or truncate file, return channel *)
    Printf.fprintf oc "%s\n" message;
    (* write something *)
    close_out oc
    (* flush and close the channel *)
  in
  print_endline ""

(* Credit: https://github.com/ocaml-community/yojson/issues/54
   seanpoulter, from GitHub, provided this JSON helper function, that we
   utilize to better update our JSON files *)
let update key f (json : Yojson.Basic.t) =
  let rec update_json_obj = function
    | [] -> ( match f None with None -> [] | Some v -> [ (key, v) ])
    | ((k, v) as m) :: tl ->
        if k = key then
          match f (Some v) with
          | None -> update_json_obj tl
          | Some v' -> if v' == v then m :: tl else (k, v') :: tl
        else m :: update_json_obj tl
  in
  match json with
  | `Assoc obj -> `Assoc (update_json_obj obj)
  | _ -> json

let update_field file field new_val =
  let file_json = file |> Yojson.Basic.from_file in
  let new_json =
    update field (fun _ -> Some (`String new_val)) file_json
  in
  let str_json = Yojson.Basic.to_string new_json in
  update_json str_json file

let update_td_ameritrade_bearer new_bearer bearer_date =
  let file_json = "config.json" |> Yojson.Basic.from_file in
  let td_info = file_json |> member "TD_Ameritrade" in
  let updated_bearer =
    update "bearer" (fun _ -> Some (`String new_bearer)) td_info
  in
  let updated_date =
    update "bearer_date"
      (fun _ -> Some (`String bearer_date))
      updated_bearer
  in
  let new_json =
    update "TD_Ameritrade" (fun _ -> Some updated_date) file_json
  in
  let str_json = Yojson.Basic.to_string new_json in
  update_json str_json "config.json"

let update_td_ameritrade_refresh new_refresh refresh_date =
  let file_json = "config.json" |> Yojson.Basic.from_file in
  let td_info = file_json |> member "TD_Ameritrade" in
  let updated_refresh =
    update "refresh_token" (fun _ -> Some (`String new_refresh)) td_info
  in
  let updated_date =
    update "refresh_date"
      (fun _ -> Some (`String refresh_date))
      updated_refresh
  in
  let new_json =
    update "TD_Ameritrade" (fun _ -> Some updated_date) file_json
  in
  let str_json = Yojson.Basic.to_string new_json in
  update_json str_json "config.json"

let new_sentiment sent_api_key input_json =
  let sentiment_info = input_json |> member "Sentiment" in
  let updated_sentiment =
    update "api_key"
      (fun _ -> Some (`String sent_api_key))
      sentiment_info
  in
  update "Sentiment" (fun _ -> Some updated_sentiment) input_json

let new_td td_api refresh_token input_json =
  let td_info = input_json |> member "TD_Ameritrade" in
  let updated_td_api =
    update "api_key" (fun _ -> Some (`String td_api)) td_info
  in
  let updated_td_refresh =
    update "refresh_token"
      (fun _ -> Some (`String refresh_token))
      updated_td_api
  in
  update "TD_Ameritrade" (fun _ -> Some updated_td_refresh) input_json

let new_twitter twitter_bearer input_json =
  let twitter_info = input_json |> member "Twitter" in
  let updated_twitter =
    update "bearer"
      (fun _ -> Some (`String twitter_bearer))
      twitter_info
  in
  update "Twitter" (fun _ -> Some updated_twitter) input_json

let new_email email_dest input_json =
  let email_info = input_json |> member "Email" in
  let updated_email =
    update "address_destination"
      (fun _ -> Some (`String email_dest))
      email_info
  in
  update "Email" (fun _ -> Some updated_email) input_json

let algo_update name value json =
  update name (fun _ -> Some (`Float value)) json

let algo_update_volume value json =
  update "max_volume" (fun _ -> Some (`Int value)) json

let new_algo
    trailing_stop
    max_price
    max_volume
    profit_target
    error
    cap_limit
    input_json =
  let algo_info = input_json |> member "Algo" in
  let alg_tstop = algo_update "trailing_stop" trailing_stop algo_info in
  let alg_mprice = algo_update "max_price" max_price alg_tstop in
  let alg_mvol = algo_update_volume max_volume alg_mprice in
  let alg_proft = algo_update "profit_target" profit_target alg_mvol in
  let alg_error = algo_update "error_margin" error alg_proft in
  let alg_final = algo_update "capital_limit" cap_limit alg_error in
  update "Algo" (fun _ -> Some alg_final) input_json

(*
We are aware this function is 21 lines due to the single-line paramaters, but our project manager verified this was okay
*)
  let add_config
    sent_api_key
    td_api
    refresh_token
    twitter_bearer
    email_dest
    trailing_stop
    max_price
    max_volume
    profit_target
    error
    cap_limit =
  let file_json = "config.json" |> Yojson.Basic.from_file in
  let sent = new_sentiment sent_api_key file_json in
  let td = new_td td_api refresh_token sent in
  let twitter = new_twitter twitter_bearer td in
  let email = new_email email_dest twitter in
  let algo =
    new_algo trailing_stop max_price max_volume profit_target error
      cap_limit email
  in
  update_json (Yojson.Basic.to_string algo) "config.json"

let build_json new_json_to_write ticker_to_add =
  if new_json_to_write = "" then
    "{\"ticker\": \"" ^ ticker_to_add ^ "\"}"
  else new_json_to_write ^ ", {\"ticker\": \"" ^ ticker_to_add ^ "\"}"

let add_stock file (ticker_to_add : string) =
  let json_text = "{\"tickers\": [" in
  let file_json = file |> Yojson.Basic.from_file in
  let rec stock_scan stocks new_json =
    match stocks with
    | h :: t ->
        let ticker = h |> member "ticker" |> to_string in
        let next_json = "{\"ticker\": \"" ^ ticker ^ "\"}" in
        let final_json =
          if new_json <> "" then new_json ^ "," ^ next_json
          else next_json
        in
        stock_scan t final_json
    | [] -> new_json
  in
  let stocks_list = file_json |> member "tickers" |> to_list in
  let new_json_to_write = stock_scan stocks_list "" in
  let to_send = build_json new_json_to_write ticker_to_add in
  update_json (json_text ^ to_send ^ "]}") file

let remove_stock file (ticker_to_rem : string) =
  let json_text = "{\"tickers\": [" in
  let file_json = file |> Yojson.Basic.from_file in
  let rec stock_scan stocks new_json =
    match stocks with
    | h :: t ->
        let ticker = h |> member "ticker" |> to_string in
        if ticker = ticker_to_rem then stock_scan t new_json
        else
          let next_json = "{\"ticker\": \"" ^ ticker ^ "\"}" in
          let final_json =
            if new_json <> "" then new_json ^ "," ^ next_json
            else next_json
          in
          stock_scan t final_json
    | [] -> new_json
  in
  let stocks_list = file_json |> member "tickers" |> to_list in
  let new_json_to_write = stock_scan stocks_list "" in
  update_json (json_text ^ new_json_to_write ^ "]}") file
