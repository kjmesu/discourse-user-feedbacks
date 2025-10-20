# frozen_string_literal: true

class ::LegacyTradesController < ::ApplicationController
  requires_plugin ::DiscourseUserFeedbacks::PLUGIN_NAME

  before_action :ensure_logged_in

  def update
    user = User.find(params[:id])
    guardian.ensure_can_edit_user!(user)

    count = params[:legacy_trade_count].to_i
    user.custom_fields["user_feedbacks_legacy_trade_count"] = count
    user.save_custom_fields

    render json: success_json.merge(legacy_trade_count: count)
  end
end
