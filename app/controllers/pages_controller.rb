class PagesController < ApplicationController
  allow_unauthenticated_access
  layout "geocities"

  def home
    SiteCounter.increment!(:home_visits)
    @visitor_count = SiteCounter.count_for(:home_visits)
  end

  def about
  end

  def links
  end

  def apps
  end

  def guestbook
    @entries = GuestbookEntry.recent
    @entry = GuestbookEntry.new
  end

  def sign_guestbook
    @entry = GuestbookEntry.new(guestbook_params)

    if @entry.save
      redirect_to guestbook_path, notice: "Thanks for signing my guestbook!!"
    else
      @entries = GuestbookEntry.recent
      render :guestbook, status: :unprocessable_entity
    end
  end

  private

  def guestbook_params
    params.expect(guestbook_entry: [ :name, :message ])
  end
end
