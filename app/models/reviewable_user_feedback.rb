# frozen_string_literal: true

class ReviewableUserFeedback < Reviewable
  def self.action_aliases
    { agree_and_keep: :agree_and_restore }
  end

  def build_actions(actions, guardian, args)
    return unless pending?

    agree = actions.add_bundle("#{id}-agree", icon: 'thumbs-up', label: 'reviewables.actions.agree.title')

    if guardian.can_delete_user_feedback?(target)
      build_action(actions, :agree_and_delete, icon: 'thumbs-up', bundle: agree)
    end

    if target.deleted_at.present?
      build_action(actions, :agree_and_restore, icon: 'thumbs-up', bundle: agree)
    else
      build_action(actions, :agree_and_keep, icon: 'thumbs-up', bundle: agree)
    end

    reject = actions.add_bundle("#{id}-reject", icon: 'thumbs-down', label: 'reviewables.actions.reject.title')
    build_action(actions, :reject_and_keep, icon: 'thumbs-down', bundle: reject)

    if guardian.can_delete_user_feedback?(target)
      build_action(actions, :delete, icon: 'trash-alt')
    end

    if guardian.is_staff?
      build_action(actions, :ignore, icon: 'external-link-alt')
    end
  end

  def perform_agree_and_delete(performed_by, args)
    agree(performed_by)
    target.soft_delete!
  end

  def perform_agree_and_restore(performed_by, args)
    agree(performed_by)
    target.update!(deleted_at: nil)
  end

  def perform_agree_and_keep(performed_by, args)
    agree(performed_by)
  end

  def perform_reject_and_keep(performed_by, args)
    reject(performed_by)
  end

  def perform_delete(performed_by, args)
    target.soft_delete!
    reject(performed_by)
  end

  def perform_ignore(performed_by, args)
    ignore(performed_by)
  end

  private

  def agree(performed_by)
    create_result(:success, :approved) do |result|
      result.update_flag_stats = { status: :agreed, user_ids: [created_by_id] }
      result.recalculate_score = true
    end
  end

  def reject(performed_by)
    create_result(:success, :rejected) do |result|
      result.update_flag_stats = { status: :disagreed, user_ids: [created_by_id] }
      result.recalculate_score = true
    end
  end

  def ignore(performed_by)
    create_result(:success, :ignored)
  end

  def build_action(actions, id, icon:, bundle: nil, button_class: nil, confirm: false)
    actions.add(id, bundle: bundle) do |action|
      action.icon = icon
      action.button_class = button_class
      action.confirm_message = 'reviewables.actions.delete.confirm' if confirm
    end
  end
end
