let twitter_stock_client_instructions () =
  let _ = print_endline "Hi! What is your name" in
  let _ = print_string ">" in
  let name = read_line () in
  let _ =
    print_endline ("Welcome " ^ name ^ ", to the Twitter Stock Client\n")
  in
  let _ =
    print_endline
      "By Anthony Cuturrufo, Ashok Arun, and Erik Ossner. \n"
  in
  let _ =
    print_endline
      "We are going to start off by buidling your config.json"
  in
  print_endline
    "This config.json will serve as a file so that you can best use \
     our twitter stock trading bot. It will store parameters that will \
     fine tune our project to your own trading strategies and will \
     also serve as a container for your API keys and passwords. Note, \
     if you accidentally enter in a password or token incorrectly, \
     feel free to manually change it in config.json\n"

let sentiment_api_key () =
  let _ =
    print_endline
      "For our first question: Please enter your Text2Data API Key. \
       This API Key will serve to add Sentiment Analysis functionality \
       to your project. The sentiment analysis will be used after \
       mining tweets, it will double check to make sure that the tweet \
       is actually bullish. Otherwise, the bot could potentially buy a \
       stock with a tweet that would cause the stock price to crash \
       leaving you with a large loss. If you do not have a set API \
       yet, feel free to go to \
       https://text2data.com/Account/Manage?message=ChangeSecretSuccess \
       to set up your free account. If you wish to use a different \
       sentiment analysis API then feel free to do so in sentiment.py"
  in
  read_line ()

let td_instructions () =
  let _ =
    print_endline
      "\n\
       Now that you have finished your sentiment analysis \
       functionality, we are free to continue building the config. The \
       next steps will involve a TD Ameritrade account. In order to \
       query for price data, and acutally buy and sell the stock, a TD \
       Ameritrade account will be required."
  in
  print_endline
    "Now that you have a TD Ameritrade account, please go to \
     https://developer.tdameritrade.com/home to get the necessary \
     information for building the config. Note you will need to create \
     a developer account in order the necessary tokens and keys to \
     buy, sell, and get stock price quotes"

let td_api_key () =
  let _ =
    print_endline
      "For the first piece of personal information needed to build the \
       json, please enter your TD_Ameritrade api key. This will be \
       necessary for requests to TD Ameritrade. If you are having \
       trouble generating your API key, please follow the \
       documentation on the TD Ameritrade website above"
  in
  read_line ()

let td_refresh_token () =
  let _ =
    print_endline
      "\n\
       The next piece of personal information necessary will be your \
       TD Ameritrade refresh token. This token will be used to refresh \
       your Bearer authentifiation token (we will explain what this is \
       later). Your Bearer token needs to refresh every 90 days so the \
       twitter stock client will use your refresh token to \
       reauthenticate automatically every 90 days "
  in
  read_line ()

let twitter_bearer () =
  let _ =
    print_endline
      "\n\
       Congratualations! You have set up all the authentication \
       necessesary for your TD Ameritrade account. Now that we have \
       set up your buying, selling, and price quoting ability, you can \
       now move on to setting up your credentials for Twitter scraping"
  in
  let _ =
    print_endline
      "To scrape Twitter for stock related tweets, you will need to \
       setup a Twitter account and get access to the Twitter API. \
       After you gain access to an API key, please enter your Twitter \
       API key below"
  in
  read_line ()

let alert_instructions () =
  let _ =
    print_endline
      "Congratualations, you have set Twitter scraping functionality"
  in
  let _ =
    print_endline
      "Now that you have Twitter scraping functionality allowed for \
       your project, it is time to set up the stock buying and selling \
       alerts"
  in
  print_endline
    "The alert system is important since it will allow you to be aware \
     of how much the algorithm is buying and selling. It is important \
     to be attentive as there is a real risk of losing significant \
     amounts of money."

let email_address_destination () =
  let _ =
    print_endline
      "Our alert system will be done through email through an SMTP \
       server. TThis email will recieve the alerts so it is \
       recommended that you choose an email that you check frequently. \
       Note we do not recommend entering in a school email as those \
       have extra authentification that will take much longer than \
       needed"
  in
  read_line ()

let algo_instructions () =
  let _ =
    print_endline
      "\n\
       Congratualations, you have setup all of the required \
       functionality to send alerts."
  in
  let _ =
    print_endline
      "Now it is time for the final stride in building the \
       config.json. This step will involve information about trading \
       strategy and constants that we decided to let the user decide \
       what they should be. Do not worry if you are new to trading, we \
       will give you suggested parameters."
  in
  print_endline
    "The first parameter that you will enter in will be your choice of \
     trailing stop. The trailing stop is defined by a percentage that \
     if after buying the stock, if your the values drops to a certain \
     percentage value below the highest it had been since you bought \
     it will sell or stop out. "

let algo_trailing_stop () =
  let _ =
    print_endline
      "The trailing stop that we recommend is .08. This will limit \
       your losses to eight percent per trade and will also sell your \
       stock if the value drop eight percent below the rolling max"
  in
  let _ =
    print_endline
      "Given that please enter in your desired trailing stop: "
  in
  read_line ()

let algo_max_price () =
  let _ =
    print_endline
      "\n\
       Congratualations, you have added the trailing stop to your algo \
       configurations. "
  in
  let _ =
    print_endline
      "The next step in making the algo configurations is to add the \
       maximum buying price"
  in
  let _ =
    print_endline
      "The maximum arguments configuration will cap the twitter stock \
       client from buying expensive stocks. That is, it will not buy a \
       stock that is greater than the maximum price "
  in
  let _ = print_endline "Please enter in your maximum buying price" in
  read_line ()

let algo_max_volume () =
  let _ =
    print_endline
      "\n\
       Congratualations, you have set up the maximum price. The next \
       step is to set your maximum volume"
  in
  let _ =
    print_endline
      "Our twitter stock client was intended for use on low cap, high \
       volatility stocks. We created a maxiumum volume to similarly \
       cap larger cap stocks from being bought."
  in
  let _ = print_endline "Our recommended maximum volume is 500000000" in
  read_line ()

let algo_profit_target () =
  let _ =
    print_endline
      "\n\
       Congratualations, you have set up maximum volume. The next step \
       will be to setup the profit target"
  in
  let _ =
    print_endline
      "The profit target represents the level where the bot takes \
       profit. We recommend .1. This will take profit at ten percent. \
       Note this does not mean it will stop looking at the stop and it \
       will still actively watch to rebuy"
  in
  read_line ()

let algo_error_margin () =
  let _ =
    print_endline
      "\n\
       Congratualations, you have set up the profit target. The final \
       thing will be to add the error margin. Our bot makes lots of \
       quick calculation to maximuize profit. These calculations are \
       not exact as stock price fluctuate very quickly. This is why we \
       recommend adding an error marging so it can make decisions if \
       values are close to necessary values. We recommend an error \
       margin of 0.015"
  in
  read_line ()

let algo_capital_limit () =
  let _ =
    print_endline
      "\n\
       Congratualations, you have set up the profit target. The final \
       thing will be to add the capital limit. Here you can decide how \
       much capital you would like to spend on each stock. We will \
       stop buying stocks when the set capital per stock exceeds the \
       available funds in your account."
  in
  read_line ()

let build_config =
  let _ = twitter_stock_client_instructions () in
  let sent_api_key = sentiment_api_key () in
  let _ = td_instructions () in
  let td_api = td_api_key () in
  let refresh_token = td_refresh_token () in
  let twitter_bearer = twitter_bearer () in
  let _ = alert_instructions () in
  let email_dest = email_address_destination () in
  let _ = algo_instructions () in
  let trailing_stop = float_of_string (algo_trailing_stop ()) in
  let max_price = float_of_string (algo_max_price ()) in
  let max_volume = int_of_string (algo_max_volume ()) in
  let profit_target = float_of_string (algo_profit_target ()) in
  let error = float_of_string (algo_error_margin ()) in
  let cap_limit = float_of_string (algo_capital_limit ()) in
  Json_writer.add_config sent_api_key td_api refresh_token
    twitter_bearer email_dest trailing_stop max_price max_volume
    profit_target error cap_limit
