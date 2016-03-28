require 'sinatra/base'

module PESlackBot
  class Web < Sinatra::Base
    get '/' do
      'Math is good for you.'
    end
  end
end
