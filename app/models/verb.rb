require 'csv'
class Verb < ActiveRecord::Base
  belongs_to :infinitive
  validates_presence_of :infinitive
  validates_presence_of :word
  before_save :remove_accents
  before_save :split_comma

  enum pronoun: [:no_pronoun, :yo, :tu, :el, :nosotros, :vosotros, :ellos]
  enum tense: [:no_tense, :past, :present, :future, :imperfect, :conditional, :preterite, :imperfect2, :affirmative, :negative]
  enum mood: [:no_mood, :indicative, :subjunctive, :imperative]

  def self.matches_for word
    return [] if word == "para"
    matches = Verb.where(:word=>word)
    return matches if matches.any?
    return [] if word == "se" #i.e. not "sé"
    return [] if word == "de" #i.e. not "dé"
    matches = Verb.where(:word_no_accents=>Verb.remove_accents(word))
    return matches if matches.any?
    #e.g. "eschuchame"
    ["me","la","le","te","nos","os","les"].each do |indirect_object|
      if word.end_with?(indirect_object)
        word =  word[0,word.length-indirect_object.length] 
        return Verb.where(:word_no_accents=>Verb.remove_accents(word))
      end
    end
    matches
  end


  def self.remove_accents str
    str.downcase.gsub("á","a").gsub("é","e").gsub("í","i").gsub("ó","o").gsub("ú","u").gsub("ü","u").gsub("ñ","n")
  end

  def self.seed
    file = File.join(Rails.root, "db","verbs.csv")
    CSV.foreach(file) do |row|
      x = row
      Verb.add(row[0], row[1])
      sleep(0.5)
    end
  end

  def self.add nom, meaning = nil
    nom = nom.strip.downcase
    return true if Infinitive.where(:name=>nom).any?
    agent = Mechanize.new
    url = "https://www.spanishdict.com/conjugate/#{nom}"
    page = agent.get url
    doc = Nokogiri::HTML.parse(page.body)
    meaning = doc.css("#quickdef1-es").text()
    meaning = "should, must" if nom == "deber"
    return false if meaning.blank?
    inf = Infinitive.create!(:name=>nom, :meaning=>meaning)
    inf.verbs.destroy_all
    inf.verbs.create(:word=>nom, :is_infinitive=>true)

    participles_table = true
    doc.css("table").each do |table|
      if participles_table
        inf.verbs.create(:word=>table.css("tr")[0].text().gsub("Present:",""), :is_participle=>true, :tense=>Verb.tenses["present"])
        inf.verbs.create(:word=>table.css("tr")[1].text().gsub("Past:",""), :is_participle=>true, :tense=>Verb.tenses["past"])
        participles_table = false
        next
      end
      possible_tenses = nil
      ["Indicative","Subjunctive","Imperative"].each do |mood|
        table_text = table.parent().parent().text() #e.g. "IndicativeIrregularities are in redPresentPreteriteImperfectConditionalFutureyovengovineveníavendríavendré ...
        if table_text.start_with?(mood)
          for i in 0...table.css("tr").length
            row = table.css("tr")[i]
            if i == 0 #i.e. header row
              possible_tenses = row.css("td").map{|i|i.text()} #e.g. ["", "Present", "Preterite", "Imperfect", "Conditional", "Future"]
            else
              for j in 1...row.css("td").length
                td = row.css("td")[j]
                tense = possible_tenses[j] #e.g. "Future"
                #td.text().split(",").each do |part| #e.g. see "ha,hay"
                  #part = td.text()
                  #part.gsub!("no ","") #i.e. remove "no " from negative imperative
                  inf.verbs.create(:word=>td.text(), :pronoun=>i, :mood=>Verb.moods[mood.downcase], :tense=>Verb.tenses[tense.downcase.gsub(" 2","2")])
                #end
              end
            end
          end

        end #i.e. end table_text
      end #e.g. end Indicative block

    end #i.e. end table loop
    true
  end #i.e. end self.add

protected

  def split_comma
    if word.include?(",") #e.g. see "ha,hay"
      parts = word.split(",") 
      self.word = parts.pop
      parts.each do |part|
        Verb.create(:infinitive_id=>self.infinitive_id, :word=>part, :pronoun=>pronoun, :mood=>mood, :tense=>tense, :is_infinitive=>is_infinitive, :is_participle=>is_participle)
      end
    end
  end

  def remove_accents
    self.word = word.downcase.gsub("no ","")  #i.e. remove "no " from negative imperative
    self.word_no_accents = Verb.remove_accents(word)
  end

end
