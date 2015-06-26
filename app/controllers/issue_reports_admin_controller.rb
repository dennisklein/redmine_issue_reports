class IssueReportsAdminController < ApplicationController
  layout 'admin'
  menu_item :issue_reports_admin

  before_filter :require_admin

  helper :sort
  include SortHelper
  helper :users

  def index
    sort_init 'login', 'asc'
    sort_update %w(login firstname lastname mail receives_issue_reports)
    @limit = per_page_option

    @status = params[:status] || 1

    scope = User.logged.status(@status)
    scope = scope.like(params[:name]) if params[:name].present?
    scope = scope.in_group(params[:group_id]) if params[:group_id].present?

    @user_count = scope.count
    @user_pages = Paginator.new @user_count, @limit, params['page']
    @offset ||= @user_pages.offset
    @users =  scope.order(sort_clause).limit(@limit).offset(@offset).all

    respond_to do |format|
      format.html {
        @groups = Group.all.sort
        render :layout => !request.xhr?
      }
    end
  end
end
