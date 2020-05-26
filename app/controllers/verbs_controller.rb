class VerbsController < ApplicationController

  def create
    if params[:word].present?
      if Verb.add(params[:word])
        flash[:notice] = "Successfully added."
      else
        flash[:error] = "Couldn't add that verb."
      end
    end
    text = params[:text] ? "?text="+URI.parse(URI.escape(params[:text])).to_s : ""
    redirect_to root_url+text
  end
end
