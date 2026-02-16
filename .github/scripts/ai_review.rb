#!/usr/bin/env ruby
require "json"
require "net/http"
require "uri"

abort("Usage: ai_review.rb file.json") unless ARGV[0]

api_key = ENV["GEMINI_API_KEY"]
abort("Missing GEMINI_API_KEY") unless api_key

changes = JSON.parse(File.read(ARGV[0]))

prompt = <<~PROMPT
You are a senior Ruby dependency reviewer.

For each dependency:
- explain possible breaking areas
- suggest validation steps
- highlight production risk
- keep it short
- output markdown

Dependencies:
#{JSON.pretty_generate(changes)}
PROMPT

# ⚠️ use modern model
uri = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=#{api_key}")

req = Net::HTTP::Post.new(uri)
req["Content-Type"] = "application/json"
req.body = {
  contents: [
    { role: "user", parts: [ { text: prompt } ] }
  ]
}.to_json

res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

unless res.is_a?(Net::HTTPSuccess)
  warn "Gemini HTTP Error: #{res.code}"
  warn res.body
  exit 1
end

body = JSON.parse(res.body)

text = body.dig("candidates", 0, "content", "parts", 0, "text")

if text.nil? || text.strip.empty?
  warn "Gemini returned unexpected response:"
  warn JSON.pretty_generate(body)
  exit 1
end

puts "## 🤖 AI Risk Insights\n\n"
puts text
