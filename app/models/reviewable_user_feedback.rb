# frozen_string_literal: true

class ReviewableUserFeedback < Reviewable
  def self.action_aliases
    {
      agree_and_hide: :agree_and_hide_feedback,
      agree_and_keep: :agree_and_keep_feedback,
      agree_and_edit: :agree_and_edit_feedback,
      delete_feedback: :agree_and_delete_feedback
    }
  end

  # Override target to load even soft-deleted feedbacks
  def target
    @target ||= begin
      return nil unless target_id
      feedback = DiscourseUserFeedbacks::UserFeedback.unscoped.find_by(id: target_id)
      Rails.logger.info("ReviewableUserFeedback#target - Found feedback #{feedback&.id} for reviewable #{id}")
      feedback
    end
  rescue => e
    Rails.logger.error("Error loading target for ReviewableUserFeedback #{id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    nil
  end

  # Required by the base Reviewable class for update_flag_stats
  # The base class uses post&.user_id to exclude self-flags from stats
  # For user feedback, we return the target (UserFeedback) which has a user_id
  def post
    target
  end

  def build_actions(actions, guardian, args)
    return unless pending?
    return unless target

    Rails.logger.info("ReviewableUserFeedback#build_actions - Building actions for reviewable #{id}, target: #{target.id}")

    # Yes (Agree) bundle
    agree_bundle = actions.add_bundle(
      "#{id}-agree",
      icon: 'thumbs-up',
      label: 'reviewables.actions.agree.title'
    )

    # Hide feedback - agree with flag and hide the feedback (similar to Hide post)
    build_action(
      actions,
      :agree_and_hide,
      icon: 'far-eye-slash',
      bundle: agree_bundle
    )

    # Agree and Keep - agree with flag but keep the feedback visible
    build_action(
      actions,
      :agree_and_keep,
      icon: 'thumbs-up',
      bundle: agree_bundle
    )

    # Agree and Edit - agree with flag and open editor to edit the feedback
    if guardian.can_edit_user_feedback?(target)
      build_action(
        actions,
        :agree_and_edit,
        icon: 'pencil-alt',
        bundle: agree_bundle,
        client_action: 'edit'
      )
    end

    # Delete feedback - agree with flag and delete the feedback permanently
    if guardian.can_delete_user_feedback?(target)
      build_action(
        actions,
        :delete_feedback,
        icon: 'trash-alt',
        bundle: agree_bundle,
        confirm: true
      )
    end

    # No (Reject) - single action
    build_action(actions, :disagree, icon: 'thumbs-down')

    # Ignore bundle
    if guardian.is_staff?
      ignore_bundle = actions.add_bundle(
        "#{id}-ignore",
        icon: 'external-link-alt',
        label: 'reviewables.actions.ignore.title'
      )

      # Do nothing - ignore the flag, keep everything as-is
      build_action(
        actions,
        :ignore,
        icon: 'external-link-alt',
        bundle: ignore_bundle
      )

      # Ignore and delete - ignore the flag but delete the feedback
      if guardian.can_delete_user_feedback?(target)
        build_action(
          actions,
          :ignore_and_delete_feedback,
          icon: 'far-trash-alt',
          bundle: ignore_bundle,
          confirm: true
        )
      end
    end
  rescue => e
    Rails.logger.error("Error building actions for ReviewableUserFeedback #{id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise
  end

  # Perform methods for "Yes" (Agree) actions

  def perform_agree_and_hide_feedback(performed_by, args)
    agree(performed_by) do
      # Hide the feedback with the appropriate reason
      # Use inappropriate as the default reason (similar to posts)
      reason_id = PostActionType.types[:inappropriate]
      target.hide!(reason_id)
    end
  end

  def perform_agree_and_keep_feedback(performed_by, args)
    agree(performed_by)
  end

  def perform_agree_and_edit_feedback(performed_by, args)
    # This action is handled by the client (client_action: 'edit')
    # The backend just agrees with the flag
    agree(performed_by)
  end

  def perform_agree_and_delete_feedback(performed_by, args)
    agree(performed_by) do
      target.soft_delete!
    end
  end

  # Perform method for "No" (Reject) action

  def perform_disagree(performed_by, args)
    create_result(:success, :rejected) do |result|
      result.update_flag_stats = { status: :disagreed, user_ids: [created_by_id] }
      result.recalculate_score = true
    end
  end

  # Perform methods for "Ignore" actions

  def perform_ignore(performed_by, args)
    create_result(:success, :ignored)
  end

  def perform_ignore_and_delete_feedback(performed_by, args)
    ignore_result = create_result(:success, :ignored)
    target.soft_delete!
    ignore_result
  end

  private

  def agree(performed_by, &block)
    create_result(:success, :approved) do |result|
      result.update_flag_stats = { status: :agreed, user_ids: [created_by_id] }
      result.recalculate_score = true

      # Execute any additional actions passed in the block
      yield if block_given?
    end
  end

  def build_action(actions, id, icon:, bundle: nil, button_class: nil, client_action: nil, confirm: false, label: nil)
    actions.add(id, bundle: bundle) do |action|
      action.icon = icon
      action.label = label || "reviewables.actions.#{id}.title"
      action.description = "reviewables.actions.#{id}.description"
      action.button_class = button_class
      action.client_action = client_action if client_action
      action.confirm_message = "reviewables.actions.#{id}.confirm" if confirm
    end
  end
end
