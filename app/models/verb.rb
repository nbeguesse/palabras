require 'csv'
class Verb < ActiveRecord::Base
  belongs_to :infinitive
  validates_presence_of :infinitive
  validates_presence_of :word
  before_save :split_comma
  before_save :set_previous_word
  attr_accessor :perfect

  enum pronoun: [:no_pronoun, :yo, :tu, :el, :nosotros, :vosotros, :ellos]
  enum tense: [:no_tense, :past, :present, :future, :imperfect, :conditional, :preterite, :pluperfect, :affirmative, :negative, :anterior]
  enum mood: [:no_mood, :indicative, :subjunctive, :imperative, :continuous]

  scope :auxable, ->{where("mood <> ?",Verb.moods[:imperative])}

  def make_perfect participle
    return nil unless participle.is_participle
    self.word = word+" "+participle.word
    errors.add(:base,"Do Not Save Temporary modification")
    if infinitive.name == "estar"
      self.mood = Verb.moods[:continuous]
      return self
    elsif infinitive.name == "haber" 
      if self.imperfect? #i.e. perfect + imperfect = pluperfect!
        self.tense = Verb.tenses[:pluperfect] 
      elsif self.preterite?
        self.tense = Verb.tenses[:anterior] #rare!
      end 
      self.perfect = true
      return self
    end
    nil
  end

  def same_as? other
    [:infinitive_id, :tense, :mood, :is_participle, :is_infinitive, :word].each do |attr|
      return false if self.send(attr) != other.send(attr)
    end
    true
  end

  def self.matches_for word
    return [] if word == "para"
    return [] if word == "una"
    #i.e. first search for an exact match
    matches = Verb.where(:word=>word)
    return matches if matches.any?
    if ["se","de","este","cómo"].include?(word)
      #i.e. the accent must match exactly with these words
      return []
    end
    #i.e. do a broader search without accents
    matches = Verb.where(:word_no_accents=>Verb.remove_accents(word))
    return matches if matches.any?
    #i.e. search for word combos e.g. "eschuchame"
    ["me","la","le","te","nos","os","les","lo","se"].each do |indirect_object|
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
      #i.e. look at only these three moods. Other moods (like Continuous etc) are created dynamically
      #  by looking at the auxiliary verbs
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
                inf.verbs.create(:word=>td.text(), :pronoun=>i, :mood=>Verb.moods[mood.downcase], :tense=>Verb.tenses[tense.downcase.gsub(" 2","")])
              end
            end
          end

        end #i.e. end table_text
      end #e.g. end Indicative block

    end #i.e. end table loop
    true
  end #i.e. end self.add

protected

  def set_previous_word
    if word == "-"
      errors.add(:word, "is not valid")
    end
    if imperative? && affirmative?
      self.previous_word_is_not = "no"
    end
    #i.e. two use cases:
    #  (1) Verb is an imperative negative and previous word is "no"
    #  (2) Verb is reflexive and previous word is indirect object
    if word.include?(" ")
      parts = word.split(" ")
      self.word = parts.pop
      self.previous_word_is = parts.pop
      #i.e. there might be three parts; see "arrebatamos"
    end
    if word == "debe"
      self.previous_word_is_not = "el"
    end
    if word == "cena"
      self.previous_word_is_not = "la"
    end
    self.word_no_accents = Verb.remove_accents(word)
  end

  def split_comma
    if word.include?(",") #e.g. see "ha,hay"
      parts = word.split(",") 
      self.word = parts.pop
      parts.each do |part|
        Verb.create(:infinitive_id=>self.infinitive_id, :word=>part, :pronoun=>pronoun, :mood=>mood, :tense=>tense, :is_infinitive=>is_infinitive, :is_participle=>is_participle)
      end
    end
  end


end
