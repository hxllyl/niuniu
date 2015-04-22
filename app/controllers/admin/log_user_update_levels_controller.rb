# encoding: utf-8

class Admin::LogUserUpdateLevelsController < Admin::BaseController

  def index
    @logs = Log::UserUpdateLevel.unapproved.order(status: :asc, updated_at: :desc).page(params[:page] || 1).per(20)
  end

  def show
    @log = Log::UserUpdateLevel.find params[:id]
    @types = case @log.end_level
           when 1 then
            %w(identity hand_id)
           when 2 then
            %w(license)
           when 3 then
            %w(visiting room_outer room_inner license)
           when 4 then
            %w(visiting room_outer room_inner)
            end
  end

  def update_status
    @log = Log::UserUpdateLevel.find params[:id]

    @log.transaction do
      if @log.update(status: params[:status].to_i)
        @log.reload
        level = if @log.status == Log::UserUpdateLevel::STATUS.keys[1]
                  @log.end_level.to_i
                else
                  @log.start_level.to_i
                end
        @log.user.update(level: level)
        # TODO: 加操作人
        flash[:notice] = '操作成功'
      else
        flash[:error]  = '操作不成功'
      end
    end

    redirect_to :back
  end

end
