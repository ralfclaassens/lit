# frozen_string_literal: true

require_relative 'base'
require 'net/http'

module Lit::Cloud::Providers
  # Yandex Translate API provider for Lit translation suggestions.
  #
  # Configuration:
  #
  #   require 'lit/cloud/providers/yandex'
  #
  #   Lit::Cloud.provider = Lit::Cloud::Providers::Yandeex
  #
  #   # API key can be given via ENV['YANDEX_TRANSLATE_API_KEY'].
  #   #
  #   # Alternatively, it can be set programmatically after setting provider:
  #
  #   Lit::Cloud.configure do |config|
  #     config.api_key = 'the_api_key'
  #   end
  class Yandex < Base
    def translate(text:, from: nil, to:, opts: {}) # rubocop:disable Metrics/MethodLength, Metrics/LineLength
      # puts "api key is: #{config.api_key}"
      # puts "translating #{text} from #{from} to #{to}"
      uri = URI('https://translate.yandex.net/api/v1.5/tr.json/translate')
      params = {
        key: config.api_key,
        text: text,
        lang: [from, to].compact.join('-'),
        format: opts[:format],
        options: opts[:options]
      }.compact
      uri.query = URI.encode_www_form(params)
      res = Net::HTTP.get_response(uri)

      case res
      when Net::HTTPOK
        translations = JSON.parse(res.body)['text']
        translations.size == 1 ? translations.first : translations
      else
        raise TranslationError,
              (JSON.parse(res.body) rescue "Unknown error: #{res.body}") # rubocop:disable Style/RescueModifier, Metrics/LineLength
      end
    end

    private

    def default_config
      { api_key: ENV['YANDEX_TRANSLATE_API_KEY'] }
    end

    def require_config!
      return if config.api_key.present?
      raise 'YANDEX_TRANSLATE_API_KEY env or `config.api_key` not given'
    end
  end
end
