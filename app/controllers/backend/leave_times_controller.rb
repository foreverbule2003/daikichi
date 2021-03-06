# frozen_string_literal: true
class Backend::LeaveTimesController < Backend::BaseController
  helper_method :leave_type
  DEFAULT_LEAVE_POOL_TYPE = Settings.backend.default_leave_pool_type

  def index; end

  def leave_type
    @leave_type ||= params[:leave_type] || (params[:leave_time] ? params[:leave_time][:leave_type] : nil) || DEFAULT_LEAVE_POOL_TYPE
  end

  private

  def collection_scope
    if params[:id]
      LeaveTime
    else
      LeaveTime.joins(:user).where(leave_type: leave_type).order(expiration_date: :desc)
    end
  end

  def resource_params
    params.require(:leave_time).permit(
      :user_id, :leave_type, :quota, :effective_date, :expiration_date, :usable_hours, :used_hours, :remark
    )
  end

  def new_resource_params
    p = params.permit(
      :user_id, :leave_type
    ).to_h
    p['leave_type'] ||= leave_type
    p
  end

  def url_after(action)
    if @actions.include?(action)
      url_for(action: :index, leave_type: leave_type)
    else
      request.env['HTTP_REFERER']
    end
  end
end
