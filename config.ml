open Yojson.Basic.Util

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

let make_config filename =
  let conf = filename |> Yojson.Basic.from_file in
  {
    sentiment_api_key =
      conf |> member "Sentiment" |> member "api_key" |> to_string;
    td_api_key =
      conf |> member "TD_Ameritrade" |> member "api_key" |> to_string;
    td_refresh_token =
      conf |> member "TD_Ameritrade" |> member "refresh_token"
      |> to_string;
    td_refresh_date =
      conf |> member "TD_Ameritrade" |> member "refresh_date"
      |> to_string;
    td_bearer =
      conf |> member "TD_Ameritrade" |> member "bearer" |> to_string;
    td_bearer_date =
      conf |> member "TD_Ameritrade" |> member "bearer_date"
      |> to_string;
    twitter_bearer =
      conf |> member "Twitter" |> member "bearer" |> to_string;
    email_address =
      conf |> member "Email" |> member "address" |> to_string;
    email_address_destination =
      conf |> member "Email"
      |> member "address_destination"
      |> to_string;
    email_password =
      conf |> member "Email" |> member "password" |> to_string;
    algo_trailing_stop =
      conf |> member "Algo" |> member "trailing_stop" |> to_float;
    algo_max_price =
      conf |> member "Algo" |> member "max_price" |> to_float;
    algo_max_volume =
      conf |> member "Algo" |> member "max_volume" |> to_int;
    algo_strategy =
      conf |> member "Algo" |> member "strategy" |> to_string;
    algo_profit_target =
      conf |> member "Algo" |> member "profit_target" |> to_float;
    algo_error_margin =
      conf |> member "Algo" |> member "error_margin" |> to_float;
    algo_capital_limit =
      conf |> member "Algo" |> member "capital_limit" |> to_float;
  }

let config = make_config "config.json"

let sentiment_api_key = config.sentiment_api_key

let td_api_key = config.td_api_key

let td_refresh_token file = (make_config file).td_refresh_token

let td_refresh_date file = (make_config file).td_refresh_date

let td_bearer file = (make_config file).td_bearer

let td_bearer_date file = (make_config file).td_bearer_date

let twitter_bearer = config.twitter_bearer

let email_address = config.email_address

let email_password = config.email_password

let email_address_destination = config.email_address_destination

let algo_trailing_stop = config.algo_trailing_stop

let algo_max_price = config.algo_max_price

let algo_max_volume = config.algo_max_volume

let algo_strategy = config.algo_strategy

let algo_profit_target = config.algo_profit_target

let algo_error_margin = config.algo_error_margin

let algo_capital_limit = config.algo_capital_limit

(* checks if configs are good *)
let check_configs () =
  let string_fields =
    [
      sentiment_api_key;
      td_api_key;
      td_refresh_token "config.json";
      td_refresh_date "config.json";
      td_bearer "config.json";
      td_bearer_date "config.json";
      twitter_bearer;
      email_address;
      email_password;
      email_address_destination;
    ]
  in
  if List.exists (fun x -> x = "") string_fields then
    print_string
      "missing field in config.json (Twitter, Email, TD_Ameritrade or \
       Sentiment)"
  else if
    algo_max_price < 0.0
    || algo_trailing_stop < 0.0
    || algo_max_volume < 0
  then
    print_string
      "missing fields in Algo in config.json or invalid max_price, \
       trailing_stop, or max_volume"
  else if
    not
      (algo_strategy = "rolling_max" || algo_strategy = "moving_average")
  then
    print_string
      "invalid Algo strategy in config.json. Needs to be rolling_max \
       or moving_average"
  else print_string "configs are good"
