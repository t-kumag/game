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
    @unread_total_count = Entities::Notice.where(marked:  false).count
    render 'unread_total_count', formats: 'json', handlers: 'jbuilder'
  end

  def mark
    unread_read_messaages = Entities::Notice.where(marked:  false)
    save_list = unread_read_messaages.map do |urm|
      Entities::Notice.new(
          id: urm[:id],
          title: urm[:title],
          date: urm[:date],
          url: urm[:url],
          marked: true,
          created_at: urm[:created_at]
      )
    end
    Entities::Notice.import save_list, :on_duplicate_key_update => [:id, :marked]
    render json: {}, status: 200
  end

  def index
    @notices = Entities::Notice.order(created_at: "DESC").page(params[:page])
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

end

