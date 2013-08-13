require 'rubygems'
require 'sinatra'
require 'net/https'
require 'json'
require "addressable/uri"

require './hash.rb'

# Storing costants - Codes can be retreived
# code.google.com/apis/console
# google.co.uk/cse
CUSTOM_SEARCH_API_KEY = "AIzaSyBr6OKMEtMPtSuEX9Y_aH6o9HnV9dqkYDo"
CUSTOM_ENGINE = "012047815045781284211:sez6z0rjws0"
PAGINATE = 10 # Max, lame.

get '/' do
  erb :home
end


# Posted data used as search term.
get '/search' do
  @page = (params['page'] || 1).to_i

  # BODMAS
  start = (@page > 1) ? @page * PAGINATE - (PAGINATE - 1) : @page

  pow = uri = Addressable::URI.new

  # Prepare our query to send to Google.
  pow.query_values = {
    :key => CUSTOM_SEARCH_API_KEY,
    :cx => CUSTOM_ENGINE,
    :alt => "json",
    :safe => "high",
    :q => URI.escape(params['q']),
    :num => PAGINATE,
    :start => start
  }

  # Can puts to logs from within running code.  Useful for development.
  puts pow
  puts pow.query

  # Create URI object
  uri = URI.parse "https://www.googleapis.com/customsearch/v1?#{pow.query}"

  # Prepare connection
  http = Net::HTTP.new uri.host, uri.port
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  # Send request
  req = Net::HTTP::Get.new uri.request_uri

  # Get results and parse
  @results = JSON.parse http.request(req).body

  # Most often 400 errors - if query is incorrect or (more commonly) over API limit
  if defined? @results.error
    # This raise gives more information to debug if necessary
    raise @results.error.to_json
  end

  erb :search
end


get '/google' do
  erb :google
end
