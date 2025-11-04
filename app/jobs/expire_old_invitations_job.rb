class ExpireOldInvitationsJob < ApplicationJob
  queue_as :default

  def perform
    GroupInvitation.expire_old_invitations!
  end
end
