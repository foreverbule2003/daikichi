# frozen_string_literal: true
class LeaveApplicationsController < BaseController
  include Selectable

  def index
    @current_collection = collection_scope.with_year(specific_year)
    @current_collection = @current_collection.with_status(params[:status]) if status_selected?
    @current_collection = @current_collection.page(params[:page])
  end

  def create
    @current_object = collection_scope.new(resource_params)    
    if @current_object.save
      action_success
    else
      @error_message = @current_object.errors[:hours]
      render action: :new
    end
  end

  def update
    unless current_object.canceled? # and current_object.update(resource_params)
      current_object.revise(resource_params)
      unless current_object.errors[:hours].any?
        action_success
      else
        @error_message = @current_object.errors[:hours]
        render action: :edit
      end
    else
      action_fail t('warnings.not_cancellable'), :edit
    end
  end

  def cancel
    if current_object.may_cancel?
      current_object.cancel!
      @actions << :cancel
      action_success
    elsif current_object.approved?
      action_fail t('warnings.already_happened'), :index
    else
      action_fail t('warnings.not_cancellable'), :index
    end
  end

  private

  def collection_scope
    if params[:id]
      LeaveApplication.where(user_id: current_user.id)
    else
      LeaveApplication.where(user_id: current_user.id).order(id: :desc)
    end
  end

  def resource_params
    params.require(:leave_application).permit(
      :leave_type, :start_time, :end_time, :description
    )
  end

  def url_after(action)
    if @actions.include?(action)
      url_for(action: :index, controller: controller_path, params: { status: :pending })
    else
      request.env['HTTP_REFERER']
    end
  end
end
