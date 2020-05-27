require "google/cloud/translate"
require "google/cloud/text_to_speech"
class SpanishBot


#export GOOGLE_APPLICATION_CREDENTIALS=/Users/nicolebeguesse/Desktop/palabras/translation-api--1590372040635-03e3b9e2dcf4.json

  # Note: Free scraping works on localhost, but not Heroku
  # def self.say str
  #   response = %x(curl 'https://ttsmp3.com/makemp3_new.php' \
  # -H 'Connection: keep-alive' \
  # -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36' \
  # -H 'Content-type: application/x-www-form-urlencoded' \
  # -H 'Accept: */*' \
  # -H 'Origin: https://ttsmp3.com' \
  # -H 'Sec-Fetch-Site: same-origin' \
  # -H 'Sec-Fetch-Mode: cors' \
  # -H 'Sec-Fetch-Dest: empty' \
  # -H 'Referer: https://ttsmp3.com/text-to-speech/US%20Spanish/' \
  # -H 'Accept-Language: en-US,en;q=0.9' \
  # --data $'msg=#{URI.escape(str)}&lang=Conchita&source=ttsmp3' \
  # --compressed)
  #   return JSON.parse(response)["URL"]

  # end

  def self.say str
    # Instantiates a client
    client = Google::Cloud::TextToSpeech.text_to_speech

    # Set the text input to be synthesized
    synthesis_input = { text: str }

    # Build the voice request, select the language code ("en-US") and the ssml
    # voice gender ("neutral")
    voice = {
      language_code: "es-ES",
      ssml_gender:   "FEMALE"
    }

    # Select the type of audio file you want returned
    audio_config = { audio_encoding: "MP3" }

    # Perform the text-to-speech request on the text input with the selected
    # voice parameters and audio file type
    response = client.synthesize_speech(
      input:        synthesis_input,
      voice:        voice,
      audio_config: audio_config
    )
    return response.audio_content
  end

  def self.translate str, retries = 0
    begin
      client = Google::Cloud::Translate.new version: :v2, project_id: "translation-api--1590372040635"
      translation = client.translate str, to: 'en', from: 'es'
    return translation.text
    rescue RuntimeError => e
      #i.e. automatically copy the JSON file to the JSON path in case Heroku erases it
      if ENV['GOOGLE_APPLICATION_JSON'].present? && ENV['GOOGLE_APPLICATION_CREDENTIALS'].present?
        File.open(ENV['GOOGLE_APPLICATION_CREDENTIALS'], 'w') {|f| f.write(ENV['GOOGLE_APPLICATION_JSON']) }
        client = Google::Cloud::Translate.new version: :v2, project_id: "translation-api--1590372040635"
        translation = client.translate str, to: 'en', from: 'es'   
        return translation.text     
      else
        raise StandardError, "Could not get Google auth credentials"
      end
    end
  end


end