require 'rubygems'
require 'sinatra'
require 'net/https'
require 'json'
require "addressable/uri"

require './hash.rb'

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

  pow.query_values = {
    :key => CUSTOM_SEARCH_API_KEY,
    :cx => CUSTOM_ENGINE,
    :alt => "json",
    :safe => "high",
    :q => URI.escape(params['q']),
    :num => PAGINATE,
    :start => start
  }

  puts pow
  puts pow.query

  uri = URI.parse "https://www.googleapis.com/customsearch/v1?#{pow.query}"

  http = Net::HTTP.new uri.host, uri.port
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Get.new uri.request_uri
  @results = JSON.parse http.request(req).body

  if defined? @results.error
    raise @results.error.to_json
  end

  erb :search
end


get '/google' do
  erb :google
end
