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
    notices_marks = Entities::NoticesMark.where(user_id: @current_user.id)

    save_list = []
    notices.each do |notice|
      if notices_marks.present?
        next if Services::NoticeMarkService.already_exists?(notice, notices_marks, @current_user)
        save_list << Services::NoticeMarkService.fetch_notice_marks(notice, @current_user)
      else
        save_list << Services::NoticeMarkService.fetch_notice_marks(notice, @current_user)
      end
    end

    Entities::NoticesMark.import save_list, :on_duplicate_key_update => [:user_id, :mark]
    @unread_total_count = Entities::NoticesMark.where(mark:  false).count
    render 'unread_total_count', formats: 'json', handlers: 'jbuilder'
  end

  def mark
    unread_read_messaages = Entities::NoticesMark.where(mark:  false)
    save_list = unread_read_messaages.map do |urm|
      Entities::NoticesMark.new(
          id: urm[:id],
          notice_id: urm[:notice_id],
          user_id: urm[:user_id],
          mark: true
      )
    end
    Entities::NoticesMark.import save_list, :on_duplicate_key_update => [:user_id, :mark]
    render json: {}, status: 200
  end

  def index
    @notices = Entities::Notice.order(created_at: "DESC").page(params[:page])
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

end

