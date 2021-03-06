# frozen_string_literal: true

require 'faraday'
require 'json'

class RedmineClient
  URL_PATTERN = /\Ahttps?:\/\/.+\/issues\/\d+\z/.freeze
  COLOR = '#A00F1B'

  def enabled?
    ENV['REDMINE_API_ACCESS_KEY']
  end

  def target?(url)
    url =~ URL_PATTERN
  end

  def get(url)
    return nil unless url =~ URL_PATTERN

    response = Faraday.get("#{url}.json?key=#{ENV['REDMINE_API_ACCESS_KEY']}")
    issue = JSON.parse(response.body)['issue']

    return nil if issue['is_private']

    title = "#{issue['project']['name']} | #{issue['subject']}"

    fields = ['tracker', 'status', 'priority', 'author'].map do |key|
      if issue[key]
        {
          title: key,
          value: issue[key]['name'],
          short: true
        }
      else
        nil
      end
    end.filter { |f| !f.nil? }

    fields += issue.keys
      .filter { |key| !%w(subject description).include?(key) && ![Hash, Array].include?(issue[key].class) }
      .map do |key|
      {
        title: key,
        value: issue[key],
        short: true
      }
    end

    if issue['custom_fields'] && !ignore_custom_fields?
      fields += issue['custom_fields'].map do |custom_field|
      {
        title: custom_field['name'],
        value: custom_field['value'],
        short: true
      }
      end
    end

    {
      title: title,
      title_link: url,
      text: truncate(issue['description']),
      color: COLOR,
      fields: skip_fields? ? [] : fields
    }
  end

  private

  def truncate(description)
    description&.lines[0, 10].map { |line| line.chomp }.join("\n")
  end

  def skip_fields?
    %w(true t yes y).include?(ENV['SKIP_FIELDS'])
  end

  def ignore_custom_fields?
    %w(true t yes y).include?(ENV['IGNORE_CUSTOM_FIELDS'])
  end
end

