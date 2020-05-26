class TranslationsController < ApplicationController

  def new
    if params[:text].present?
      @original = params[:text]
      #if Rails.env.development?
        @translation  = Rails.cache.fetch(@original) do
          SpanishBot.translate params[:text]
        end
      #end
    end
  end

end
