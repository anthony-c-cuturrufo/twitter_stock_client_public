open OUnit2
open Twitter
open Sentiment
open Parser
open Yojson.Basic.Util

(* Our testing plan generally involved planning the flow of our
   software, designing and developing our respective modules, then lots
   of manual testing (using main as a spot for testing modules, along
   with print statements and debugging within the modules themselves).
   This project involves a lot of variable, dynamically changing data,
   and as such, designing OUnit test cases was moderately difficult for
   proving "correctness" in our software. With this in mind, as
   mentioned above, we relied on lots of manual testing: For example,
   twitter.ml, trade.ml, and json_writer.ml were all files that required
   a significant amount of manual testing for each function to ensure
   they were all correct (but could not be thoroughly tested with OUnit,
   since especially with Twitter, a user's tweets constantly change, as
   do stock prices). In order to make use of OUnit, however, we do
   primarily use it as a means of ensuring that all of our APIs are
   connected, functioning, and parsing and returning data (in other
   words, as a resource to ensure that our software is ready to run
   full-scale, and does not require direct maintenance with any of our
   accounts). To do this, we developed our test cases using primarily
   black-box testing, since we do not focus on the internal workings of
   each function; but rather, the output (and making sure none of our
   calls crash or return empty values). Using this same strategy of
   black-box testing, we were able to test many of our high-frequency
   trading algorithm results against precomputed values. This way, we do
   not have to worry about a user's tweets updating, for example, but
   instead, making sure that our Twitter scraping returns a valid
   result. Regarding correctness of the system, as mentioned, as put
   extensive focus on testing each individual component of our system.
   Through this modular approach to testing, we know that each "piece"
   works independently; and since our final result involves connecting
   all of our modules together through a large pipeline, we can ensure
   that the results will be as desired. *)
(********************************************************************
  Helper Functions. 
 ********************************************************************)
let str_equality_test (name : string) input out : test =
  name >:: fun _ ->
  (* the [printer] tells OUnit how to convert the output to a string *)
  assert_equal out input ~printer:(fun a -> a)

let bool_equality_test (name : string) input out : test =
  name >:: fun _ ->
  (* the [printer] tells OUnit how to convert the output to a string *)
  assert_equal out input ~printer:(fun a ->
      if a then "true" else "false")

(********************************************************************
   End helper functions.
 ********************************************************************)

let twitter_tests =
  [
    bool_equality_test "Twitter making sure that Bearer is configured"
      (Twitter.bearer = "") false;
    bool_equality_test
      "Twitter recent tweet test to make sure API calls are functioning"
      (Twitter.most_recent_tweet "elonmusk" = "")
      false;
    bool_equality_test
      "Twitter recent tweet test to make sure real, inactive accounts \
       do not return any tweets"
      (Twitter.most_recent_tweet "Randomaccount80" = "")
      true;
    bool_equality_test
      "Twitter recent tweet test to make sure non-existent accounts do \
       not return any tweets"
      ( Twitter.most_recent_tweet "this_is-not_a-real-account2291828193"
      = "" )
      true;
    bool_equality_test
      "Twitter recent tweet test to make sure API calls are \
       functioning for multi-tweets"
      (List.length (Twitter.latest_tweets "elonmusk" 3) = 3)
      true;
  ]

(* We only get 50 of these per day so be careful *)
let sentiment_tests =
  [
    bool_equality_test "test if tweet <AMC to the moooon> is bullish"
      (Sentiment.is_bullish "AMC to the mooon")
      true;
    bool_equality_test
      "test if tweet <AMC is going way down> is bullish"
      (Sentiment.is_bullish "AMC is going way down")
      false;
    bool_equality_test "test if tweet <AMC is the best> is bullish"
      (Sentiment.is_bullish "AMC is the best")
      true;
    bool_equality_test "test if tweet <I hate AMC> is not bullish"
      (Sentiment.is_bullish "I hate AMC")
      false;
    bool_equality_test
      "test if tweet <AMC started off really badly> is not bullish"
      (Sentiment.is_bullish "AMC started off really badly")
      false;
    bool_equality_test "test if tweet <AMC is amazing> is bullish"
      (Sentiment.is_bullish "AMC is amazing")
      true;
  ]

let stock_test =
  [
    bool_equality_test "check price function price is good"
      (Stock.check_price "NAKD" (Stock.ticker_info_json "NAKD"))
      true;
    bool_equality_test "check price function price is too high"
      (Stock.check_price "BRK.A" (Stock.ticker_info_json "BRK.A"))
      false;
    bool_equality_test "check stock function price is good"
      (Stock.check_price "NAKD" (Stock.ticker_info_json "NAKD"))
      true;
    bool_equality_test "check stock function price is too high"
      (Stock.check_price "BRK.A" (Stock.ticker_info_json "BRK.A"))
      false;
  ]

let manager_test =
  [
    bool_equality_test
      "Make sure that\n   Manager.trim\n functions to remove whitespace"
      (Manager.trim "Hello!\n Test\n" = "Hello! Test")
      true;
    bool_equality_test
      "Make\n\
      \   sure\n\
      \  Manager.get_portfolio returns portfolio from proper file"
      ( Manager.get_portfolio ()
      = ( "accounts.json" |> Yojson.Basic.from_file |> member "accounts"
        |> to_list ) )
      true;
    bool_equality_test
      "Make sure Manager.is_ready returns empty\n\
      \   string\n\
      \  when the last tweets match"
      (Manager.is_ready_ticker "Last Tweet" "Last Tweet" = "")
      true;
    bool_equality_test
      "Make\n\
      \   sure\n\
      \  Manager.is_ready returns empty string when the current\n\
      \   tweet  is new,\n\
      \  contains a stock, but is of negative sentiment"
      ( Manager.is_ready_ticker "$NAKD is so bad. Do not buy it"
          "Last\n\n   Tweet"
      = "" )
      true;
    bool_equality_test
      "Make sure Manager.is_ready\n\
      \ returns empty string when the current tweet is new, but  \
       contains\n\
      \   no\n\
      \  stock"
      ( Manager.is_ready_ticker "This contains no stock" "Last Tweet"
      = "" )
      true;
    bool_equality_test
      "Make sure\n\
      \   Manager.is_ready returns\n\
      \  empty string when the current tweet is\n\
      \   new, but contains a  stock that\n\
      \  our trading algorithm does not\n\
      \   approve"
      ( Manager.is_ready_ticker "This contains $AMZN, a good\n   stock."
          "Last Tweet"
      = "" )
      true;
    bool_equality_test
      "Make sure\n\
      \   Manager.is_ready returns the ticker\n\
      \  when the current tweet is\n\
      \   new, and contains a stock that our  trading\n\
      \  algorithm approves"
      ( Manager.is_ready_ticker
          "This contains $NAKD, a\n wonderful stock!" "Last Tweet"
      = "NAKD" )
      true;
  ]

let () = Json_writer.add_stock "portfolio.json" "TEST"

let json_test =
  [
    bool_equality_test "Make sure that JSON writing\n   to\n file works"
      (let file_json =
         "portfolio.json" |> Yojson.Basic.from_file
         |> Yojson.Basic.to_string
       in
       String.contains file_json 'T' = true)
      true;
    bool_equality_test
      "Make sure that removing non-existent ticker from file has no \
       impact on JSON"
      (let () = Json_writer.remove_stock "portfolio.json" "NO_FIELD" in
       let file_json =
         "portfolio.json" |> Yojson.Basic.from_file
         |> Yojson.Basic.to_string
       in
       String.contains file_json 'N' = false)
      true;
  ]

let () = Json_writer.remove_stock "portfolio.json" "TEST"

let json_test2 =
  [
    bool_equality_test
      "Make sure that JSON removing\n   from file works"
      (let file_json =
         "portfolio.json" |> Yojson.Basic.from_file
         |> Yojson.Basic.to_string
       in
       String.contains file_json 'T' = true)
      false;
  ]

let parser_test =
  [
    str_equality_test "testing if detects a gamestonk as GME"
      (Parser.custom_parse "I believe gamestonk is going to the moon")
      "GME";
    str_equality_test "testing if detects a capital gamestonk as GME"
      (Parser.custom_parse "Gamestonk is going to the moon")
      "GME";
    str_equality_test "testing if detects gamestonk as GME if last word"
      (Parser.custom_parse "I love gamestonk")
      "";
    str_equality_test "testing if detects a gamestop as GME"
      (Parser.custom_parse "We should all buy gamestop")
      "";
    str_equality_test "testing if detects a tesla as TSLA"
      (Parser.custom_parse "Anyone buy a new tesla?")
      "TSLA";
    str_equality_test "testing for empty string if detects nothing"
      (Parser.custom_parse "I believe gameston is going to the moon")
      "";
    str_equality_test "testing for $<TICKER>"
      (Parser.custom_parse "$AMC to the moon")
      "AMC";
    str_equality_test "testing for keyword precedent of $<TICKER>"
      (Parser.custom_parse "Gamestonk and $AMC going to the moon")
      "GME";
    str_equality_test
      "testing for keyword precedent of $<TICKER> reversed"
      (Parser.custom_parse "$AMC and Gamestonk are going to the moon")
      "AMC";
    str_equality_test "testing regex $ with no ticker"
      (Parser.custom_parse "testing regex $")
      "";
    str_equality_test "empty tweet" (Parser.custom_parse "") "";
    str_equality_test "one word test" (Parser.custom_parse "a") "";
  ]

(********************************************************************
   Algo_Utils test suite 
 ********************************************************************)

let price_history =
  "{\"candles\":[{\"open\":125.35,\"high\":125.35,\"low\":125.35,\"close\":125.35,\"volume\":200,\"datetime\":1621629600000},{\"open\":125.34,\"high\":125.43,\"low\":125.34,\"close\":125.34,\"volume\":641302,\"datetime\":1621629660000},{\"open\":125.33,\"high\":125.34,\"low\":125.33,\"close\":125.34,\"volume\":2338,\"datetime\":1621629720000},{\"open\":125.33,\"high\":125.33,\"low\":125.33,\"close\":125.33,\"volume\":441,\"datetime\":1621629780000},{\"open\":125.33,\"high\":125.34,\"low\":125.33,\"close\":125.34,\"volume\":1976,\"datetime\":1621629840000}],\"symbol\":\"AAPL\",\"empty\":false}"

let highs = [ 125.35; 125.43; 125.34; 125.33; 125.34 ]

let csv_entry = [ "BUY"; "TEST"; "45.32"; "time"; "10000000.0" ]

let rolling_max_index = 4

let high_dictionary_test = Hashtbl.create 1000

let () = Hashtbl.add high_dictionary_test "TEST" 30.0

let () = AlgoUtils.csv_add "stocks.csv" csv_entry

let algo_utils_tests =
  [
    bool_equality_test
      "testing get current price function to make sure it returns a \
       positive value"
      true
      (AlgoUtils.get_current_price "AAPL" > 0.0);
    bool_equality_test
      "testing get current price function to make sure it returns a \
       float with no error"
      true
      (AlgoUtils.get_current_price "AAPL" < Float.max_float);
    bool_equality_test
      "tests the parse function with set <price_history> and <highs> \
       defined above to make sure that the highs are correctly parsed \
       from the price history"
      true
      (highs = AlgoUtils.parse price_history "high");
    bool_equality_test
      "test adding an element into a csv and making sure it was the \
       most recently added element. This test case will end up testing \
       <csv_add> and <member_of_last_purchase>"
      true
      (let item =
         AlgoUtils.member_of_last_purchase "TEST" rolling_max_index
           "stocks.csv"
       in
       item = "10000000.0");
    bool_equality_test
      "second test for testing function member_of_last_purchase to \
       make sure that an element not listed in the csv will not fail"
      true
      (let res =
         try
           AlgoUtils.member_of_last_purchase "TESTT" rolling_max_index
             "stocks.csv"
         with _ -> "0.0"
       in
       res = "0.0");
    bool_equality_test "negative test for lowcase of stock" true
      (let res =
         try
           AlgoUtils.member_of_last_purchase "test" rolling_max_index
             "stocks.csv"
         with _ -> "0.0"
       in
       res = "0.0");
    bool_equality_test
      "this log high test makes sure the if the current price is \
       larger than the highest price, the highest price is replaced"
      true
      ( AlgoUtils.log_high "TEST" 1000.0 high_dictionary_test;
        Hashtbl.find high_dictionary_test "TEST" = 1000.0 );
    bool_equality_test
      "this log high test makes sure the if the current price is less \
       than the highest price, the highest price is in the dictionary \
       remains the same"
      true
      ( AlgoUtils.log_high "TEST" 2.0 high_dictionary_test;
        Hashtbl.find high_dictionary_test "TEST" = 30.0 );
    bool_equality_test
      "this calc_target test makes sure that when the rolling_max is \
       significantly larger than the current price then it chooses the \
       rolling max as a target  "
      true
      (let target = AlgoUtils.calc_target 35.0 100.0 0.1 0.015 in
       target = 100.0);
    bool_equality_test "negative test equivalent for the above test  "
      true
      (let target = AlgoUtils.calc_target (-35.0) 100.0 0.1 0.015 in
       target = 100.0);
    bool_equality_test
      "this calc_target test makes sure that when the rolling_max is \
       significantly less than the current price then it chooses the \
       current_price * target_const  "
      true
      (let target = AlgoUtils.calc_target 35.0 1.0 0.1 0.015 in
       target = 38.5);
    bool_equality_test
      "same test as above but testing with different error" true
      (let target = AlgoUtils.calc_target 35.0 1.0 0.1 0.0025 in
       target = 38.5);
    bool_equality_test
      "this calc_target test makes sure that when the rolling_max is \
       notsignificantly less than the current price then it chooses \
       the current_price * target_const  "
      true
      (let target = AlgoUtils.calc_target 35.0 35.5 0.1 0.015 in
       target = 38.5);
  ]

let algo_tests =
  [
    bool_equality_test "tests number lower than rolling max" false
      (Algo.hit_rolling_max "TEST" 1.0);
    bool_equality_test "tests number larger than hit_rolling_max" true
      (Algo.hit_rolling_max "TEST" 1000000000.0);
    bool_equality_test "tests number equal to hit_rolling_max" true
      (Algo.hit_rolling_max "TEST" 10000000.0);
    bool_equality_test "tests a negative number to false" false
      (Algo.hit_rolling_max "TEST" (-1.0));
  ]

let () = AlgoUtils.csv_remove_first "stocks.csv"

let suite =
  "test suite for twitter_stock_client"
  >::: List.flatten
         [
           twitter_tests;
           sentiment_tests;
           stock_test;
           manager_test;
           json_test;
           json_test2;
           parser_test;
           algo_utils_tests;
           algo_tests;
         ]

let _ = run_test_tt_main suite
