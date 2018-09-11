class SyncAccounttrackerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    params = {"TOKEN_KEY" => "Y+3NCJ8PcCaRljYEi4EXMrlJLwei2JdTjgqyRt1JvFU=",
              "FNC_ID" => "caLgM3L73wFB/8VWisAwr8NnkaTqGj6kV/d5+S5+YRoSKxVcY/dpSHfo92LUsFa/mSdeHNowy0NPcjspAVIvX6Q==",
              "START_DATE" => "20180701",
              "END_DATE" => "20180820"}
    requester = AtAPIRequest::AtUser::GetTransaction.new(params)
    p AtAPIClient.new(requester).request
  end
end
