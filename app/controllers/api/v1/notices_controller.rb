class Api::V1::NoticesController < ApplicationController
  before_action :authenticate, except: :login

  def create
    # TODO:バリデーション
    # TODO:例外処理と共通化
    begin
      if params[:title].present? &&
          params[:date].present? &&
          params[:url].present?

        Entities::Notice.new.transaction do
          Entities::Notice.new(
              title: params[:title],
              date: params[:date],
              url: params[:url],
          ).save!
        end
      end
    rescue ActiveRecord::RecordInvalid => db_err
      p db_err
      render(json: {}, status: 400) && return
    rescue => exception
      p exception
      render(json: {}, status: 400) && return
    end
    render json: {}, status: 200
  end

  def unread_total_count
    notices = Entities::Notice.all
    notices_read = Entities::NoticesRead.where(user_id: @current_user.id)

    save_list = []
    notices.each do |notice|
      if notices_read.present?
        next if Services::NoticeReadService.already_exists?(notice, notices_read, @current_user)
        save_list << Services::NoticeReadService.fetch_notice_read(notice, @current_user)
      else
        save_list << Services::NoticeReadService.fetch_notice_read(notice, @current_user)
      end
    end

    Entities::NoticesRead.import save_list, :on_duplicate_key_update => [:user_id, :read]
    @unread_total_count = Entities::NoticesRead.where(user_id: @current_user.id, read:  false).count
    render 'unread_total_count', formats: 'json', handlers: 'jbuilder'
  end

  def all_read
    unread_messaages = Entities::NoticesRead.where(user_id: @current_user.id, read:  false)
    save_list = unread_messaages.map do |urm|
      Entities::NoticesRead.new(
          id: urm[:id],
          notice_id: urm[:notice_id],
          user_id: urm[:user_id],
          read: true
      )
    end
    Entities::NoticesRead.import save_list, :on_duplicate_key_update => [:user_id, :read]
    render json: {}, status: 200
  end

  def index
    @notices = Entities::Notice.order(created_at: "DESC").page(params[:page])
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

end

