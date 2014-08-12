require 'rubygems'
require 'sinatra'
require  'pry'

set :sessions, true

helpers do
	def calculate_total(cards)
		arr = cards.map {|element| element[1]}

		total = 0 
		arr.each do |a|
			if a == "A"
				total += 11 
			else 
				total += a.to_i == 0 ? 10 : a.to_i
			end 
    end  

			arr.select{|element| element == "A"}.count.times do
				break if total <= 21 
				total -=10
			end 

	total
	end 

  def winner!(msg)
    @success = "<strong>#{session[:user_name]}, wins! </strong> #{msg}"
    @show_buttons = false
    @play_again = true 
  end 

  def loser!(msg)
    @error = "<strong>#{session[:user_name]}, loses! </strong> #{msg}"
    @show_buttons = false
    @play_again = true 
  end 

  def tie!(msg)
     @success = "<strong>#{session[:user_name]}, ties </strong> #{msg}"
     @show_buttons = false
     @play_again = true 
  end 

  def card_image(card)
    suit = case card[0] 
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end 
   value = card[1]
   
   if ['J', 'Q', 'K', 'A'].include?(value)
    value = case card[1]
      when 'J' then 'jack'
      when 'Q' then 'queen'
      when 'K' then 'king'
      when 'A' then 'ace'
    end  
  end 
    "<img src='/images/cards/#{suit}_#{value}.jpg' class = 'card_image'>"
  end 
end 

before do
  @show_buttons = true 
  @play_again = false 
end 

get '/' do 
	erb :name 
end 


post'/submit_name' do 

session[:user_name] = params[:user_name]

redirect '/game'
end 

get '/game' do 

  session[:turn] = session[:user_name]

	suits = ['H', 'C', 'D', 'S']
	values = ['2', '3', '4', '5', '6', '7', '8', '9', '10']

	session[:deck] = suits.product(values).shuffle! 

	session[:player_hand] = []
	session[:dealer_hand] = []

	session[:player_hand] << session[:deck].pop 
	session[:dealer_hand] << session[:deck].pop 

	session[:player_hand] << session[:deck].pop 
	session[:dealer_hand] << session[:deck].pop 

erb :game

end 

post '/game/player/hit' do 
  session[:player_hand] << session[:deck].pop
  player_total = calculate_total(session[:player_hand])

if player_total == 21 
  winner!("#{session[:user_name]} hit Balckjack")

elsif player_total > 21
  
  loser!("#{session[:user_name]} you busted at #{player_total}")
end 


  erb :game 
  end 

post '/game/player/stay' do
@success = "You have chosen to stay" 
@show_buttons = false 
erb :game
redirect '/game/dealer'
  
  end 

get '/game/dealer' do 
  session[:turn] = "dealer"
  @show_buttons = false 

  dealer_total = calculate_total(session[:dealer_hand])
  
  if dealer_total == 21 
    loser!("Dealer hit Blackjack")
  elsif dealer_total > 21 
    winner!("dealer busted at #{dealer_total}")
  elsif dealer_total>=17 
    redirect '/game/compare'
  else 
  
    @show_dealer_hit = true 
  end 

erb :game

end 

post '/game/dealer/hit' do 
session[:dealer_hand] << session[:deck].pop
redirect '/game/dealer' 
end 

get '/game/compare' do
@show_buttons = false 

dealer_total = calculate_total(session[:dealer_hand])
player_total = calculate_total(session[:player_hand])

if dealer_total > player_total
  loser!("#{session[:user_name]} stayed at #{player_total}, and the dealer had #{dealer_total}")

elsif player_total > dealer_total
  winner!("#{session[:user_name]}, stayed at #{player_total}, and the dealer had #{dealer_total}")

else  
  tie!("#{session[:user_name]}, stayed at #{player_total}, and the dealer had #{dealer_total}")
end 

erb :game

end

get '/game_over' do 

redirect '/'

end  
