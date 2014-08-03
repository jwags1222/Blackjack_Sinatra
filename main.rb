require 'rubygems'
require 'sinatra'
require  'pry'

set :sessions, true

get '/' do 
	"Hello Big Daddy Papa"
end 


get '/test' do 
erb :test 

end 


