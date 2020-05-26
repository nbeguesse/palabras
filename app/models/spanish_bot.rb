require "google/cloud/translate"
class SpanishBot


#export GOOGLE_APPLICATION_CREDENTIALS=/Users/nicolebeguesse/Desktop/labels/config/googleauth/translation-api--1590372040635-03e3b9e2dcf4.json


  def self.say str
    response = %x(curl 'https://ttsmp3.com/makemp3_new.php' \
  -H 'Connection: keep-alive' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36' \
  -H 'Content-type: application/x-www-form-urlencoded' \
  -H 'Accept: */*' \
  -H 'Origin: https://ttsmp3.com' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: https://ttsmp3.com/text-to-speech/US%20Spanish/' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  --data $'msg=#{URI.escape(str)}&lang=Conchita&source=ttsmp3' \
  --compressed)
    return JSON.parse(response)["URL"]

  end

  def self.translate str
    client = Google::Cloud::Translate.new version: :v2, project_id: "translation-api--1590372040635"
    translation = client.translate str, to: 'en', from: 'es'
    return translation.text
  end

  def self.test
    client = Google::Cloud::Translate.new version: :v2, project_id: "translation-api--1590372040635"
    translation = client.translate "Hola", to: 'en', from: 'es'
    return translation.text
  end

end