class Api::V1::NoticesController < ApplicationController
  before_action :authenticate, except: :login

  def create
    # TODO:バリデーション
    # TODO:例外処理と共通化
    begin
      if params[:title].present? &&
          params[:date].present? &&
          params[:description].present?

        Entities::Notice.new.transaction do
          Entities::Notice.new(
              title: params[:title],
              date: params[:date],
              description: params[:description],
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

  def show
    @notice = Entities::Notice.find_by(params[:id])
    render 'show', formats: 'html', handlers: 'jbuilder'
  end

  def index
    @notices = Entities::Notice.all
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

end

