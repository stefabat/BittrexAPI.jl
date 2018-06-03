__precompile__()
module BittrexAPI

# module dependencies
import HTTP: get
import JSON: Parser.parse
import Nettle: hexdigest

# exports
export Bittrex
# public functions
export getmarkets,getcurrencies,getticker
export getmarketsummary,getmarketsummaries
export getorderbook,getmarkethistory
# private functions
export buylimit,selllimit,cancel
export getopenorders,getorder
export getbalances,getbalance
export getdepositaddress,withdraw
export getorderhistory,getwithdrawalhistory,getdeposithistory
# additional functions
export gettickshistory


# endpoint formats
# v1.1: "https://bittrex.com/api/$version/$apitype/$method?$parameter=$value
# v2.0: "https://bittrex.com/api/$version/$type/$section/$method?$parameter=$value

URLROOT = "https://bittrex.com/api/"

# class defining the Bittrex API
struct Bittrex
    apikey   ::String
    apisecret::String
    version  ::String
end

# constructor for public API
function Bittrex(version = "v1.1")
    return Bittrex("","",version)
end

# constructor for private API
function Bittrex(apikey, apisecret)
    return Bittrex(apikey,apisecret, "v1.1")
end

# Public API

"""
    getmarkets(api::Bittrex)

Used to get the open and available trading markets at Bittrex along with other meta data.

# Example output

```jldoctest
julia> getmarkets()[1]
Dict{String,Any} with 11 entries:
  "MarketCurrencyLong" => "Litecoin"
  "IsSponsored"        => nothing
  "MarketCurrency"     => "LTC"
  "BaseCurrency"       => "BTC"
  "LogoUrl"            => "https://bittrex.com/..."
  "BaseCurrencyLong"   => "Bitcoin"
  "IsActive"           => true
  "MarketName"         => "BTC-LTC"
  "MinTradeSize"       => 0.0278418
  "Notice"             => nothing
  "Created"            => "2014-02-13T00:00:00"
```
"""
function getmarkets(api::Bittrex)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/public/getmarkets")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/markets/getmarkets")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    url = endpoint
    
    return apirequest(url)
end


"""
    getcurrencies(api::Bittrex)

Used to get all supported currencies at Bittrex along with other meta data.

# Example output

```jldoctest
julia> getcurrencies()[1]
Dict{String,Any} with 8 entries:
  "Currency"        => "BTC"
  "IsActive"        => true
  "BaseAddress"     => "1N52wHoVR79PMDishab2XmRHsbekCdGquK"
  "CurrencyLong"    => "Bitcoin"
  "Notice"          => nothing
  "TxFee"           => 0.001
  "CoinType"        => "BITCOIN"
  "MinConfirmation" => 2
```
"""
function getcurrencies(api::Bittrex)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/public/getcurrencies")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/currencies/getcurrencies")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    url = endpoint

    return apirequest(url)
end


"""
    getticker(api::Bittrex, market::String)

Used to get the current tick values for a market.

# Example output

```jldoctest
julia> getticker(api, "BTC-LTC")
Dict{String,Any} with 3 entries:
  "Bid"  => 0.00949003
  "Last" => 0.00950316
  "Ask"  => 0.00950315
```
"""
function getticker(api::Bittrex, market::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/public/getticker")
        query = ["market"=>market]
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/market/getlatesttick")
        query = ["marketname"=>market]
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    url = urlquery(endpoint, query)

    return apirequest(url)
end


"""
    getmarketsummaries(api::Bittrex)

Used to get the last 24 hour summary of all active exchanges.

# Example output

```jldoctest
julia> getmarketsummaries(api)[1]
Dict{String,Any} with 13 entries:
  "Bid"            => 4.621e-5
  "TimeStamp"      => "2017-11-26T15:33:37.473"
  "Last"           => 4.645e-5
  "Low"            => 4.3e-5
  "OpenBuyOrders"  => 239
  "OpenSellOrders" => 2870
  "High"           => 4.796e-5
  "MarketName"     => "BTC-1ST"
  "Ask"            => 4.643e-5
  "BaseVolume"     => 41.8878
  "Volume"         => 9.27222e5
  "PrevDay"        => 4.72e-5
  "Created"        => "2017-06-06T01:22:35.727"  
```
"""
function getmarketsummaries(api::Bittrex)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/public/getmarketsummaries")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/market/getmarketsummaries")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    url = endpoint

    return apirequest(url)
end


"""
    getmarketsummary(api::Bittrex, market::String)

Used to get the last 24 hour summary for a market.

# Example output

```jldoctest
julia> getmarketsummary(api, "BTC-LTC")
Dict{String,Any} with 13 entries:
  "Bid"            => 0.00945801
  "TimeStamp"      => "2017-11-26T15:27:31.04"
  "Last"           => 0.00945801
  "Low"            => 0.00921
  "OpenBuyOrders"  => 4310
  "OpenSellOrders" => 7074
  "High"           => 0.010238
  "MarketName"     => "BTC-LTC"
  "Ask"            => 0.00948002
  "BaseVolume"     => 2285.16
  "Volume"         => 2.33973e5
  "PrevDay"        => 0.00978736
  "Created"        => "2014-02-13T00:00:00"
```
"""
function getmarketsummary(api::Bittrex, market::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/public/getmarketsummary")
        query = ["market"=>market]
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/market/getmarketsummary")
        query = ["marketname"=>market]
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    url = urlquery(endpoint, query)

    return apirequest(url)
end


"""
    getorderbook(api::Bittrex, market::String, [booktype::String = "both"])

Used to retrieve the orderbook for a given market.
`booktype` can be any either "buy", "sell" or "both" 

# Example output

```jldoctest
julia> getorderbook(api, "BTC-LTC")
Dict{String,Any} with 2 entries:
  "sell" => Any[Dict{String,Any}(Pair{String,Any}("Quantity", 129.906),Pair{String,Anly}("Rate", 0.00945511)), ...]
  "buy"  => Any[Dict{String,Any}(Pair{String,Any}("Quantity", 1.30807),Pair{String,Anly}("Rate", 0.00945508)), ...]
```
"""
function getorderbook(api::Bittrex, market::String, booktype::String = "both")
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/public/getorderbook")
        query = ["market"=>market,"type"=>booktype]
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/market/getmarketorderbook")
        query = ["marketname"=>market,"type"=>booktype]
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    url = urlquery(endpoint, query)

    return apirequest(url)
end


"""
    getmarkethistory(api::Bittrex, market::String)

Used to retrieve the latest trades that have occured for a specific market.

# Example output

```jldoctest
julia> getmarkethistory(api, "BTC-LTC")[1]
Dict{String,Any} with 7 entries:
  "Id"        => 105218942
  "Quantity"  => 0.250755
  "FillType"  => "FILL"
  "TimeStamp" => "2017-11-26T15:39:43.637"
  "Total"     => 0.0023681
  "Price"     => 0.00944392
  "OrderType" => "SELL"
```
"""
function getmarkethistory(api::Bittrex, market::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/public/getmarkethistory")
        query = ["market"=>market]
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/market/getmarkethistory")
        query = ["marketname"=>market]
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    url = urlquery(endpoint, query)

    return apirequest(url)
end

# End of Public API

# Market API

"""
    buylimit(api::Bittrex, market::String, quantity, rate)

Used to place a buy order in a specific market.
"""
function buylimit(api::Bittrex, market::String, quantity, rate)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/market/buylimit")
        query = ["market"=>market,"quantity"=>quantity,"rate"=>rate]
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/market/buylimit")
        query = ["marketname"=>market,"quantity"=>quantity,"rate"=>rate]
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    unshift!(query,"apikey"=>api.apikey,"nonce"=>nonce)
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end


"""
    selllimit(api::Bittrex, market::String, quantity, rate)

Used to place a sell order in a specific market.
"""
function selllimit(api::Bittrex, market::String, quantity, rate)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/market/selllimit")
        query = ["market"=>market,"quantity"=>quantity,"rate"=>rate]
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/market/selllimit")
        query = ["marketname"=>market,"quantity"=>quantity,"rate"=>rate]
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    unshift!(query,"apikey"=>api.apikey,"nonce"=>nonce)
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end


"""
    cancel(api::Bittrex, uuid::String)

Used to cancel a buy or sell order by specifying the uuid.
"""
function cancel(api::Bittrex, uuid::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/market/cancel")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/market/cancel")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["apikey"=>api.apikey,"nonce"=>nonce,"uuid"=>uuid]
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end


"""
    getopenorders(api::Bittrex, [market::String])

Get all orders that you currently have opened. A specific market can be requested.
"""
function getopenorders(api::Bittrex)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/market/getopenorders")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/market/getopenorders")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["apikey"=>api.apikey,"nonce"=>nonce]
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end

function getopenorders(api::Bittrex, market::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/market/getopenorders")
        query = ["market"=>market]
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/market/getopenorders")
        query = ["marketname"=>market]
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    unshift!(query,"apikey"=>api.apikey,"nonce"=>nonce)
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end

# End of Market API

# Account API

"""
    getbalances(api::Bittrex)

Used to retrieve all balances from your account.
"""
function getbalances(api::Bittrex)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/account/getbalances")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/account/getbalances")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["apikey"=>api.apikey,"nonce"=>nonce]
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end


"""
    getbalance(api::Bittrex, currency::String)

Used to retrieve the balance from your account for a specific currency.
"""
function getbalance(api::Bittrex, currency::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/account/getbalance")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/account/getbalance")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["apikey"=>api.apikey,"nonce"=>nonce,"currency"=>currency]
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end


"""
    getdepositaddress(api::Bittrex, currency::String)

Used to retrieve or generate an address for a specific currency.
If one does not exist, the call will fail and return ADDRESS_GENERATING until one is available.
"""
function getdepositaddress(api::Bittrex, currency::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/account/getdepositaddress")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/account/getdepositaddress")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["apikey"=>api.apikey,"nonce"=>nonce,"currency"=>currency]
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end


"""
    withdraw(api::Bittrex, currency::String, quantity, address::String)

Used to withdraw funds from your account.
"""
function withdraw(api::Bittrex, currency::String, quantity, address::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/account/withdraw")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/account/withdraw")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["currency"=>currency,"quantity"=>quantity,"address"=>address]
    unshift!(query,"apikey"=>api.apikey,"nonce"=>nonce)
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end


"""
    getorder(api::Bittrex, uuid::String)

Used to retrieve a single order by uuid.
"""
function getorder(api::Bittrex, uuid::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/account/getorder")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/account/getorder")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["apikey"=>api.apikey,"nonce"=>nonce,"uuid"=>uuid]
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end


"""
    getorderhistory(api::Bittrex, [market::String])

Used to retrieve your order history. A specific market can be requested.
"""
function getorderhistory(api::Bittrex)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/account/getorderhistory")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/account/getorderhistory")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["apikey"=>api.apikey,"nonce"=>nonce]
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end

function getorderhistory(api::Bittrex, market::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/account/getorderhistory")
        query = ["market"=>market]
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/account/getorderhistory")
        query = ["marketname"=>market]
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    unshift!(query,"apikey"=>api.apikey,"nonce"=>nonce)
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end


"""
    getwithdrawalhistory(api::Bittrex, [currency::String])

Used to retrieve your withdrawal history. A specific currency can be requested.
"""
function getwithdrawalhistory(api::Bittrex)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/account/getwithdrawalhistory")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/account/getwithdrawalhistory")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["apikey"=>api.apikey,"nonce"=>nonce]
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end

function getwithdrawalhistory(api::Bittrex, currency::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/account/getwithdrawalhistory")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/account/getwithdrawalhistory")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["apikey"=>api.apikey,"nonce"=>nonce,"currency"=>currency]
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end


"""
    getdeposithistory(api::Bittrex, [currency::String])

Used to retrieve your deposit history. A specific currency can be requested.
"""
function getdeposithistory(api::Bittrex)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/account/getdeposithistory")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/account/getdeposithistory")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["apikey"=>api.apikey,"nonce"=>nonce]
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end

function getdeposithistory(api::Bittrex, currency::String)
    if api.version == "v1.1"
        endpoint = string(URLROOT,api.version,"/account/getdeposithistory")
    elseif api.version == "v2.0"
        endpoint = string(URLROOT,api.version,"/pub/account/getdeposithistory")
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    nonce   = string(Int(round(time()*1000,0)))
    query   = ["apikey"=>api.apikey,"nonce"=>nonce,"currency"=>currency]
    url     = urlquery(endpoint, query)
    apisign = hexdigest("sha512",api.apisecret,url)

    return apirequest(url,["apisign"=>apisign])
end

# End of Account API

# nice function available in API v2.0 only

"""
    gettickshistory(api::Bittrex, market::String [, interval = "oneMin"])

Used to retrieve the latest ticks that have occured for a specific market and tick interval.
Valid tickintervals = ["oneMin","fiveMin","thirtyMin","hour","day"]

# Example output

```jldoctest
julia> gettickshistory()[1]
Dict{String,Any} with 7 entries:
  "T"  => "2017-10-17T16:00:00"
  "C"  => 0.01076
  "V"  => 2127.41
  "L"  => 0.01074
  "BV" => 22.971
  "H"  => 0.010831
  "O"  => 0.0108139
```
"""
function gettickshistory(api::Bittrex, market::String, interval = "oneMin")
    # API v2.0 only
    if api.version == "v1.1" || api.version == "v2.0"
        endpoint = string(URLROOT,"/v2.0/pub/market/getticks")
        query = ["marketname"=>market,"tickinterval"=>interval]
    else
        error("supported versions are 'v1.1' and 'v2.0'")
    end

    url = urlquery(endpoint, query)

    return apirequest(url)
end


### Helper functions ###

"""Perform a request and parse the JSON resonse into a `Dict` or `Array{Dict}`"""
function apirequest(url::String, headers = [])
    try
        resp = get(url, headers)
        body = parse(String(resp.body))
        if body["success"] 
            if length(body["result"]) == 1
                return body["result"][1]
            else
                return body["result"]
            end
        else
            error(body["message"])
        end
    catch exception
        info("caught ",typeof(exception)," exception\n",exception)
    end
end

"""Form a URL `string` by merging an endpoint and query paramenters"""
function urlquery(endpoint::String, query)
    endpoint *= "?"
    for i=1:length(query)
        endpoint *= query[i][1] * "=" * string(query[i][2])
        if i < length(query)
            endpoint *= "&"
        end
    end
    return endpoint
end

end # end of module
