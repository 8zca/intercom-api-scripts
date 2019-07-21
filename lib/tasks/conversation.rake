namespace :conversation do
  desc "Intercomの質問を抽出する"
  task get: :environment do
    api = Api.new
    headers = {
      Authorization: "Bearer #{ENV['access_token']}",
      Accept: 'application/json'
    }
    api.headers = headers

    url = 'https://api.intercom.io/conversations'

    # TODO 質問解析ちゃんとやる
    questions = ['？', 'でしょうか', 'お願い', 'ですか', 'ください', 'ませんか']

    loop do
      res = api.get(url)
      raise "http status error. code[#{res.status.to_s}] res[#{res.body}" if res.status != 200

      data = JSON.parse(res.body, symbolize_names: true)
      data[:conversations].each do |c|
        next if c[:conversation_message][:author][:type] != 'user'
        time = Time.zone.at(c[:created_at]).strftime('%Y-%m-%d %H:%i:%s')
        body = c[:conversation_message][:body]
        name = c[:conversation_message][:author][:name]

        if Regexp.union(questions) =~ body
          p "#{body},#{name},#{time}"
        end
      end

      break if data[:pages][:next].blank?
      url = data[:pages][:next]
    end
  end
end
