class UnknownSubjectsController < ApplicationController
  def index
    @unknown_subjects = current_user.unknown_subjects
  end
  
  def show
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
  end
end
