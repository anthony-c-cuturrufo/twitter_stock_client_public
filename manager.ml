open Stock
open Trade
open Str
open Cohttp
open Cohttp_lwt_unix
open Yojson.Basic.Util
open Str
open Twitter
open Sentiment
open Json_writer
open Unix

(* Helper function to structure JSON properly when writing new tweets to
   file*)
let build_json body = "{\"accounts\": [" ^ body ^ "]  \n  }"

(* Helper regex to replace line breaks with the empty string (keeps JSON
   formatted properly)*)
let trim message =
  let r = Str.regexp "\n" in
  Str.global_replace r "" message

(* Manager.start runs this function: Scans through every account in
   accounts.json, and updates all with most recent tweet If the tweets
   are new, bullish, and match our market standards, we buy! TODO: Scan
   through current portfolio, checking to sell TODO: Run this function
   on a timer or cron job *)

let watching_write (stock : string) =
  let () = print_endline ("Added " ^ stock ^ " to WATCH list") in
  let () = Json_writer.add_stock "watch.json" stock in
  Json_writer.remove_stock "portfolio.json" stock

let watching_remove (stock : string) =
  let () = print_endline ("Rebought " ^ stock ^ " to WATCH list") in
  Json_writer.remove_stock "watch.json" stock

let portfolio_write (stock : string) =
  let () = print_endline ("Added " ^ stock ^ " to PORTFOLIO") in
  Json_writer.add_stock "portfolio.json" stock

let portfolio_remove (stock : string) =
  let () = print_endline ("Removed " ^ stock ^ " from PORTFOLIO") in
  Json_writer.remove_stock "portfolio.json" stock

let sell_stock stock watch =
  let () = Trader.sell stock in
  let () = portfolio_remove stock in
  let () = print_endline (stock ^ " sold!") in
  if watch = true then watching_write stock else ()

let handle_selling ticker to_sell =
  match to_sell with
  | sell, watch -> if sell = true then sell_stock ticker watch else ()

let handle_buying ticker buyback =
  let () = Trader.buy ticker in
  let () = portfolio_write ticker in
  let () = print_endline (ticker ^ " bought!") in
  if buyback = true then watching_remove ticker else ()

let handle_buyback ticker good_to_buy =
  if good_to_buy = true then
    let () = handle_buying ticker true in
    watching_remove ticker
  else ()

let sell_check () =
  let rec scan_portfolio port =
    match port with
    | h :: t ->
        let ticker = h |> member "ticker" |> to_string in
        let () = print_endline ("Scanning PORTFOLIO for " ^ ticker) in
        let sell = Algo.keep_stock ticker in
        let () = handle_selling ticker sell in
        scan_portfolio t
    | [] -> print_endline "All portfolio items scanned"
  in
  let portfolio =
    "portfolio.json" |> Yojson.Basic.from_file |> member "tickers"
    |> to_list
  in
  scan_portfolio portfolio

let watch_check () =
  let rec scan_portfolio port =
    match port with
    | h :: t ->
        let ticker = h |> member "ticker" |> to_string in
        let () = print_endline ("Scanning WATCHES for " ^ ticker) in
        let rebuy = Algo.rebuy ticker in
        let () = handle_buyback ticker rebuy in
        scan_portfolio t
    | [] -> print_endline "All watchlist items scanned"
  in
  let portfolio =
    "watch.json" |> Yojson.Basic.from_file |> member "tickers"
    |> to_list
  in
  scan_portfolio portfolio

let json_build handle current_tweet new_json =
  let next_json =
    "{\"handle\": \"" ^ handle ^ "\", \"last_tweet\": \""
    ^ current_tweet ^ "\"}"
  in
  if new_json <> "" then new_json ^ "," ^ next_json else next_json

let tweet_result handle tweet_prior current_tweet =
  print_endline
    (handle ^ ": " ^ tweet_prior ^ " (prior). Current: " ^ current_tweet)

let get_portfolio () =
  "accounts.json" |> Yojson.Basic.from_file |> member "accounts"
  |> to_list

let is_ready_ticker current_tweet tweet_prior =
  if current_tweet = tweet_prior then ""
  else
    let ticker = get_tickers current_tweet in
    if ticker = "" || is_bullish current_tweet = false then ""
    else if check_stock ticker (ticker_info_json ticker) then ticker
    else ""

let trade_refresh () =
  let _ =
    Trade.check_bearer Config.td_api_key
      (Config.td_refresh_token "config.json")
  in
  Trade.check_refresh Config.td_api_key
    (Config.td_refresh_token "config.json")

let start () =
  let rec main_driver portf new_json =
    match portf with
    | h :: t ->
        let tweet_prior = h |> member "last_tweet" |> to_string in
        let handle = h |> member "handle" |> to_string in
        let current_tweet = trim (most_recent_tweet handle) in
        let final_json = json_build handle current_tweet new_json in
        let () = tweet_result handle tweet_prior current_tweet in
        let ticker = is_ready_ticker current_tweet tweet_prior in
        if ticker = "" then main_driver t final_json
        else
          let () = handle_buying ticker false in
          main_driver t final_json
    | [] -> new_json
  in
  let portfolio = get_portfolio () in
  let new_json_to_write = main_driver portfolio "" in
  Json_writer.update_json (build_json new_json_to_write) "accounts.json"

let scanning () =
  let () = start () in
  let () = sell_check () in
  watch_check ()

let rec run () =
  let _ = trade_refresh () in
  let () =
    if
      Config.algo_capital_limit
      < Trade.available_funds
          (Trade.account_info_json (Config.td_bearer "config.json"))
    then scanning ()
    else
      let () =
        print_endline "Not enough funds to buy. Checking to sell"
      in
      sell_check ()
  in
  let () = Unix.sleepf 5. in
  run ()

let create () = run ()
