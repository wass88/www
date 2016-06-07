#!/usr/bin/env ruby

require "sinatra"
set :bind, '0.0.0.0'
set :environment, :production

post '/payload' do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)

  content_type :text
  p `git pull origin master 2>&1`
end

def verify_signature(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'),
    IO.read("#{ENV['HOME']}/token").chomp, payload_body)
  return halt 500, "Signatures didn't match!" unless
    Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end

not_found do
  "Not Found"
end
