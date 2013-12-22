require 'awesome_print'
require 'base64'
require 'cgi'
require 'erb'
require 'json'
require 'ostruct'
require 'rack/cors'
require 'rest_client'
require 'securerandom'
require 'sinatra/base'
require 'uri'

class OnbluedotWebsiteService < Sinatra::Base

  #-----------------------------------------------------------------------------
  # App Constants
  #-----------------------------------------------------------------------------

  PERMITTED_PARAMS = %w(name email message)
  MAILGUN_API_URL  = "https://api:#{ ENV['MAILGUN_API_KEY'] }@api.mailgun.net/v2/#{ ENV['MAILGUN_DOMAIN'] }"


  #-----------------------------------------------------------------------------
  # Middleware
  #-----------------------------------------------------------------------------

  use Rack::Cors do
    allow do
      origins 'localhost:4567', 'onbluedot.com', 'www.onbluedot.com'

      resource '/contact',    headers: :any, methods: [:post, :options]
    end
  end


  #-----------------------------------------------------------------------------
  # Actions
  #-----------------------------------------------------------------------------

  post '/contact' do
    p = request.POST.reject { |k,v| !PERMITTED_PARAMS.include? k }
    PERMITTED_PARAMS.each { |k| p[k] = nil unless p.has_key? k }
    email = p['email']

    halt(403, {'Content-Type' => 'text/plain'}, 'invalid email') if email.nil? || email !~ /@/


    subject = 'Contact Form: ' % p['name']
    body = erb :contact, locals: p, layout: false

    RestClient.post MAILGUN_API_URL + '/messages',
      from:    email,
      to:      ENV['CONTACT_TO_EMAIL'],
      subject: subject,
      text:    body

    'success'
  end

end
