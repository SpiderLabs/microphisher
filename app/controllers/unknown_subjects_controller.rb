class UnknownSubjectsController < ApplicationController
  def index
    @unknown_subjects = current_user.unknown_subjects.asc(:name)
  end
  
  def show
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
  end
  
  def new
    @unknown_subject = current_user.unknown_subjects.new
  end
  
  def create
    @unknown_subject = current_user.unknown_subjects.new(params[:unknown_subject])
    @unknown_subject.save!
    redirect_to @unknown_subject
  end

  def edit
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
  end

  def update
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
    @unknown_subject.update_attributes(params[:unknown_subject])
    @unknown_subject.save!
    redirect_to @unknown_subject
  end  

  def destroy
    @unknown_subject = current_user.unknown_subjects.find(params[:id])
    @unknown_subject.destroy
    redirect_to unknown_subjects_path
  end
end
