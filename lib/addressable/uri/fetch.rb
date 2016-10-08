# frozen_string_literal: true
require 'addressable/uri'
require 'net/http'

module Addressable
  class URI
    def fetch(limit: 50, use_get: :never)
      Net::HTTP.start(hostname, port, use_ssl: scheme == 'https') do |http|
        case use_get
        when :always
          response, uri = follow(http, self, limit, :get)
        when :never
          response, uri = follow(http, self, limit, :head)
        when :on_error
          response, uri = follow(http, self, limit, :head)
          response, uri = follow(http, self, (limit / 10).to_i, :get) unless response.is_a?(Net::HTTPOK)
        when :on_text
          response, uri = follow(http, self, limit, :head)
          response, uri = follow(http, self, (limit / 10).to_i, :get) if !response.is_a?(Net::HTTPOK) || text?(response.content_type)
        end

        response.uri ||= uri
        response
      end
    end

    private

    def text?(type)
      type == 'application/json' || type.start_with?('text/')
    end

    def follow(http, uri, limit, method)
      limit.times do
        request = case method
                  when :get
                    Net::HTTP::Get.new(uri)
                  when :head
                    Net::HTTP::Head.new(uri)
                  end
        request['user-agent'] = 'Mozilla/5.0'

        response = http.request(request)

        return response, uri unless response.is_a?(Net::HTTPRedirection)

        previous_uri = uri
        uri = self.class.join(uri, response['location']).fixup!

        # Detect redirect loops
        return response, uri if uri == previous_uri
      end
    end
  end
end
