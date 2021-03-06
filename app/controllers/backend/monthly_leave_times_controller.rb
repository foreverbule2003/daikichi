# frozen_string_literal: true
class Backend::MonthlyLeaveTimesController < Backend::BaseController
  skip_load_and_authorize_resource

  def index
    @current_collection = collection_scope.total_leave_times_hours(specific_year, specific_month)
    authorize! action_name, @current_collection
  end

  def collection_scope
    EmployeeMonthlyStat
  end
end
